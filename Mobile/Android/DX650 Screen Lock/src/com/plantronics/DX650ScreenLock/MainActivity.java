package com.plantronics.DX650ScreenLock;

import android.app.Activity;
import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.Intent;
import android.os.*;
import android.os.RemoteException;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import android.speech.tts.TextToSpeech.OnInitListener;
import android.speech.tts.TextToSpeech.OnUtteranceCompletedListener;
import android.util.Log;
import android.view.Menu;
import android.widget.Toast;
import com.plantronics.bladerunner.Definitions;
import com.plantronics.example.controller.HeadsetDataController;
import com.plantronics.example.controller.HeadsetDeviceCommand;
import com.plantronics.example.controller.HeadsetDeviceSetting;
import com.plantronics.example.controller.SettingsResult;
import com.plantronics.example.listeners.*;
import com.plantronics.headsetdataservice.io.*;

import java.util.*;

public class MainActivity extends Activity implements BindListener, DiscoveryListener, HeadsetServiceConnectionListener, HeadsetServiceBluetoothListener,
		RecognitionListener, OnInitListener, OnUtteranceCompletedListener {

	public static MainActivity mainActivity = null;
	private static final String TAG = "com.plantronics.DX650ScreenLock.MainActivity";
	private static final double RSSI_FILTER_CONSTANT = .4;

	private static Context context = null;
	private SpeechRecognizer sr;
	private TextToSpeech tts;
	private static Toast lastToast;
	private boolean locked;
	private boolean hsConnected;
	private boolean hsNear;
	private boolean hsDonned;
	private int hsRSSI = 0;
	//List<Integer> recentHSRSSIs;
	private int hsNearRSSIThreshold = 60;
	private int hsFarRSSIThreshold = 75;
	private boolean speeking;
	private boolean waitingForUsername;
	private boolean waitingForPassphrase;
	private boolean readyToSpeak;

	// Bladerunner
	private BluetoothAdapter mBluetoothAdapter;
	private static HeadsetDataController mController;
	private HeadsetDataDevice mLocalDevice;
	private String mDeviceAddress = "";
	private boolean isBoundToService = false;
	private boolean deviceDiscovered = false;

	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		mainActivity = this;
		context = this.getApplicationContext();
		sr = SpeechRecognizer.createSpeechRecognizer(this);
		sr.setRecognitionListener(this);
		tts = new TextToSpeech(this, this);

		lockScreen(); // initializes LockScreen.lockScreen

		// Bladerunner

		mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
		mController = HeadsetDataController.getHeadsetControllerSingleton(this);
		if (mController.bindHeadsetDataService(this) == 2) {
			Log.i(TAG, "Service already bound: register callbacks with the service.");
			isBoundToService = true;
			mController.registerServiceCallbacks();
		}

		hsConnected = false;
		hsNear = false;
		hsDonned = false;
		waitingForUsername = false;
		waitingForPassphrase = false;
		readyToSpeak = false;
		//recentHSRSSIs = new ArrayList<Integer>();

		lockScreen();
	}

//	@Override
//	protected void onStart() {
//		super.onStart();
//
//		hsConnected = false;
//		hsNear = false;
//		hsDonned = false;
//		waitingForUsername = false;
//		waitingForPassphrase = false;
//		readyToSpeak = false;
//		//recentHSRSSIs = new ArrayList<Integer>();
//
//		lockScreen();
//	}

	@Override
	protected void onDestroy() {

		if (sr !=null) {
			sr.stopListening();
			sr.destroy();
		}
		if (tts != null) {
			tts.stop();
			tts.shutdown();
		}
		if (mBluetoothAdapter != null) {
			mBluetoothAdapter.cancelDiscovery();
		}
		if (mController != null) {
			mController.close(mLocalDevice);
			mController.unregisterDiscoveryCallback();
			mController.unbindHeadsetDataService(this);
		}
		if (isBoundToService) {
			mController.unbindHeadsetDataService(this);
		}

		super.onDestroy();
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void doDiscovery() {
		Log.i(TAG, "************* doDiscovery() *************");

		deviceDiscovered = false;
		if (LockScreen.lockScreen != null) LockScreen.lockScreen.setProgressBarHidden(false);
		try {
			mController.registerDiscoveryCallback();
			int ret =  mController.getBladeRunnerDevices();
			Log.i(TAG, "getBladeRunnerDevices() returned " + ret);
			toast("Looking for headset...");
		}
		catch (RemoteException e) {
			e.printStackTrace();
		}
	}

	private void connectToDevice(String deviceAddress) {
		Log.i(TAG, "************* Connecting to device " + deviceAddress + "... *************");
		toast("Connecting to headset...");

		mController.newDevice(deviceAddress, this);
		mLocalDevice = new HeadsetDataDevice(deviceAddress, (byte)0);
		int ret = mController.open(mLocalDevice, this);
		if (ret==1) {
			// device already open.
		}
	}

	private void startListeningForEvents() {
		Log.i(TAG, "startListeningForEvents");
		ReceiveEventTask task = new ReceiveEventTask();
		task.execute(mLocalDevice);
	}

	private void startMonitoringProximity(boolean enable) {
		Log.i(TAG, "************* startMonitoringProximity: " + enable + " *************");

		short id = Definitions.Commands.CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND;
		Object objs[] = new Object[10];

		objs[0] = (Byte)(byte)0; /* The connection ID of the link being used to generate the signal strength event. */
		objs[1] = (Boolean) enable;  /* enable - If true, this will enable the signal strength monitoring. */
		objs[2] = (Boolean) false;   /* If true, report near far events only when headset is donned. */
		objs[3] = (Boolean) false;  /* trend - If true don't use trend detection */
		objs[4] = (Boolean) false;  /* report rssi audio - If true, Report rssi and trend events in headset audio */
		objs[5] = (Boolean) false;  /* report near far audio - If true, report Near/Far events in headset Audio */
		objs[6] = (Boolean) true;  /* report near far to base - If true, report RSSI and Near Far events to base  */
		objs[7] = (Byte)(byte) 5;  /* sensitivity - This number multiplies the dead_band value (currently 5 dB) in the headset configuration.
                    This result is added to an minimum dead-band, currently 5 dB to compute the total deadband.
                    in the range 0 to 9*/
		objs[8] =  (Byte)(byte)40;  /* near threshold - The near / far threshold in dB  in the range -99 to +99; larger values mean a weaker signal */
		objs[9] =  (Short)(short)60; /*  max timeout - The number of seconds after any event before terminating sending rssi values */

		if (mLocalDevice != null) {
			// getCommand can return null, if the Comamnd does not exist
			DeviceCommand dc = mController.getCommand(mLocalDevice, id, objs);
			if (dc != null) {
				HeadsetDeviceCommand hdc = new HeadsetDeviceCommand(dc, mLocalDevice);
				Log.d(TAG, "createRSSI: execute command task:" + hdc);
				CommandTask task = new CommandTask();
				task.execute(hdc);
			}
			else {
				Log.e(TAG, "Command does not exist " + id);
			}
		}
	}

	void checkLockState() {
		Log.i(TAG, "************* checkLockState() *************");

		Log.i(TAG, "locked: " + locked + " hsConnected: " + hsConnected + " hsDonned: " + hsDonned + " hsNear: " + hsNear + " readyToSpeak: " + readyToSpeak + " speeking: " + speeking);
		if (locked && hsConnected && hsDonned && hsNear && readyToSpeak && !speeking) {
			Log.i(TAG, "Starting unlock sequence...");
			// regardless of whether we were previously waiting for a new verbal response from the user, start over the "hi say" sequence
			sr.stopListening();
			tts.stop();
			waitingForPassphrase = false;
			//recentHSRSSIs.clear();

			runDelayed(new Runnable() {
				@Override
				public void run() {
					startSpeaking("Welcome to the Cisco-Plantronics DX six-fifty screen lock demo. Please say your username.");
				}
			}, 1000);

			waitingForUsername = true;
			// will start listening after onUtteranceCompleted()
		}
		else if (!hsDonned || !hsConnected || !hsNear) {
			sr.stopListening();
			tts.stop();
			waitingForUsername = false;
			waitingForPassphrase = false;
			//lockScreen();
		}
	}

	private void userAuthenticated() {
		Log.i(TAG, "************* userAuthenticated() *************");

		waitingForPassphrase = false;
		startMonitoringProximity(false);
		startSpeaking("Thank you. Access granted.");
		runDelayed(new Runnable() {
			@Override
			public void run() {
				unlockScreen();
			}
		}, 2000);
	}

	private void lockScreen() {
		if ((context != null) && !locked) {
			Log.i(TAG, "************* Locking the screen! *************");
			Intent intent = new Intent(context, com.plantronics.DX650ScreenLock.LockScreen.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			context.startActivity(intent);
		}
		locked = true;
	}

	private void unlockScreen() {

		sr.stopListening();
		tts.stop();

		if (locked) {
			Log.i(TAG, "************* Unlocking the screen! *************");
			com.plantronics.DX650ScreenLock.LockScreen.unlockDevice();
		}
		locked = false;
	}

	private void startListening() {

		Log.i(TAG, "************* startListening *************");

		speeking = true;
		Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
		intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
		intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, "voice.recognition.test");
		intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3);
		sr.startListening(intent);
	}

	private void startSpeaking(String text) {

		Log.i(TAG, "************* startSpeaking: " + text + " *************");

		speeking = true;
		HashMap <String, String> params = new HashMap<String, String>();
		params.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, "stringId");
		tts.speak(text, TextToSpeech.QUEUE_FLUSH, params);
	}

	private void runOnMainThread(Runnable runnable) {
		final Handler handler = new Handler(Looper.getMainLooper());
		handler.post(runnable);
	}

	private void runDelayed(Runnable runnable, int delay) {
		final Handler handler = new Handler(Looper.getMainLooper());
		handler.postDelayed(runnable, delay);
	}

	private void queryWearingState() {
		Log.i(TAG, "queryWearingState");

		short id = Definitions.Settings.WEARING_STATE_SETTING;
		DeviceSetting ds = mController.getSetting(mLocalDevice, id, null) ;
		HeadsetDeviceSetting hds = new HeadsetDeviceSetting(ds, new HeadsetDataDevice(mLocalDevice.getAddress()));
		SettingTask task = new SettingTask();
		task.execute(hds);
	}

	private void updateWearingState(Boolean on) {
		hsDonned = on;
		checkLockState();
	}

	private void updateRSSI(int rssi) {

		// the second the RSSI hits the "near" threshold, show the dialog
//		if ((connectedDevice != null) && selDeviceIsWearing && ((selDeviceRSSI > -1) && (selDeviceRSSI <= NEAR_SIGNAL_THRESHOLD))) { // || not in call
//
//			if ((askTransferAlertDialog == null) && !askTransferAlertDismissed) {
//
//				Log.i(TAG, "******** Asking to transfer ********");
//
//				recentHSRSSIs.clear();
//
//
//			}
//		}
//		else {


		// low-pass filter the RSSI
		hsRSSI = (int)Math.round(rssi * RSSI_FILTER_CONSTANT + hsRSSI * (1.0 - RSSI_FILTER_CONSTANT));

		Log.i(TAG, "hsRSSI: " + hsRSSI);
		if (hsRSSI <= hsNearRSSIThreshold) {
			hsNear = true;
		}
		else if (hsRSSI >= hsFarRSSIThreshold) {
			hsNear = false;
		}
		Log.i(TAG, "hsNear: " + hsNear);


//			if ( ((count >= 5) && !close) || (connectedDevice == null) || !selDeviceIsWearing) { // || not in call
//				if (askTransferAlertDialog != null) {
//					Log.i(TAG, "******** Closing transfer dialog ********");
//					askTransferAlertDialog.cancel();
//					askTransferAlertDialog = null;
//				}
//				askTransferAlertDismissed = false;
//			}
//		}

//		recentHSRSSIs.add(0, hsRSSI);
//		if (recentHSRSSIs.size() > 5) {
//			recentHSRSSIs.remove(recentHSRSSIs.size()-1);
//		}

		checkLockState();
	}

	private void toast(String text) {
		if (lastToast != null) {
			lastToast.cancel();
		}
		lastToast = Toast.makeText(mainActivity, text, Toast.LENGTH_SHORT);
		lastToast.show();
	}

	/* ****************************************************************************************************
			BindListener
	*******************************************************************************************************/

	@Override
	public void bindSuccess() {
		Log.i(TAG, "************* bindSuccess() *************");

//		Log.i(TAG, "mController(2): " + mController);
//		if (!isBoundToService) {
//			if (mController == null) {
//				mController = HeadsetDataController.getHeadsetControllerSingleton(this);
//			}
//			mController.registerServiceCallbacks();
//		}

		isBoundToService = true;
	}

	@Override
	public void bindFailed() {
		Log.e(TAG, "bindFailed()");
	}

	@Override
	public void unbind() {
		Log.i(TAG, "unbind()");
	}

	@Override
	public void serviceConnected() {
		Log.i(TAG, "************* serviceConnected() *************");

		isBoundToService = true;
		mController.registerServiceCallbacks();
		doDiscovery();
	}

	@Override
	public void serviceDisconnected() {
		Log.e(TAG, "************* serviceDisconnected() *************");
	}

	/* ****************************************************************************************************
			DiscoveryListener
	*******************************************************************************************************/

	@Override
	public void foundDevice(final String name) {
		Log.i(TAG, "************* foundDevice: " + name +"*************");

		if (!deviceDiscovered) {
			deviceDiscovered = true;
			runOnMainThread(new Runnable() {
				@Override
				public void run() {
					toast("Found headset.");

					BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(name);
					mDeviceAddress = device.getAddress();

					if (mController.isbServiceConnectionOpen()) {
						connectToDevice(mDeviceAddress);
					} else {
						Log.e(TAG, "************* Connection to the service is not open!!! *************");
					}
				}
			});
		}
		else {
			Log.i(TAG, "Already found a device.");
		}
	}

	@Override
	public void discoveryStopped(int res) {
		Log.i(TAG, "discoveryStopped()");

		if (!deviceDiscovered) {
			runDelayed(new Runnable() {
				@Override
				public void run() {
					doDiscovery();
				}
			}, 2000);
		}
	}

	/* ****************************************************************************************************
			HeadsetServiceConnectionListener
	*******************************************************************************************************/

	@Override
	public void deviceOpen(final HeadsetDataDevice device) {
		Log.i(TAG, "************* deviceOpen:" + device + "*************");

		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				toast("Connected.");
				hsConnected = true;
				if (LockScreen.lockScreen != null) LockScreen.lockScreen.setProgressBarHidden(true);
				checkLockState();
				startListeningForEvents();
				startMonitoringProximity(true);
				queryWearingState();
			}
		});
	}

	@Override
	public void openFailed(final HeadsetDataDevice device) {
		Log.e(TAG, "************* openFailed: " + device + "*************");
		toast("Headset connection failed.");

		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				hsConnected = false;
				doDiscovery();
			}
		});
	}

	@Override
	public void deviceClosed(final HeadsetDataDevice device) {
		Log.e(TAG, "************* deviceClosed:" + device + "*************");
		toast("Headset connection closed.");

		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				hsConnected = false;
				doDiscovery();
			}
		});
	}

	/* ****************************************************************************************************
			HeadsetServiceBluetoothListener
	*******************************************************************************************************/

	public void onBluetoothConnected(String bdaddr) {
		Log.i(TAG, "onBluetoothConnected()");
	}

	public void onBluetoothDisconnected(String bdaddr) {
		Log.i(TAG, "onBluetoothDisconnected()");
	}

	/* ****************************************************************************************************
			RecognitionListener
	*******************************************************************************************************/

	public void onReadyForSpeech(Bundle params) {
		Log.i(TAG, "************* onReadyForSpeech *************");
	}

	public void onBeginningOfSpeech() {
		Log.i(TAG, "************* onBeginningOfSpeech *************");
	}

	public void onRmsChanged(float rmsdB) {
		Log.d(TAG, "onRmsChanged");
	}

	public void onBufferReceived(byte[] buffer) {
		Log.d(TAG, "onBufferReceived");
	}

	public void onEndOfSpeech() {
		Log.i(TAG, "************* onEndofSpeech *************");
	}

	public void onError(int error) {
		Log.i(TAG,  "************* onError: " +  error + "*************");

		if (error == SpeechRecognizer.ERROR_NO_MATCH) {
			if (waitingForUsername) {
				startSpeaking("I'm sorry, I didn't catch that. Please say your username again.");
			}
			else if (waitingForPassphrase) {
				startSpeaking("I'm sorry, I didn't catch that. Please say your passphrase again.");
			}
		}
		// OTHERS
	}

	public void onResults(Bundle results) {

		sr.stopListening();
		ArrayList data = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
		String str = new String();
		for (int i = 0; i < data.size(); i++) {
			str += data.get(i);
			Log.i(TAG, "************* Spoken: " + str + " *************");

			if (waitingForUsername) {
				if (str.toLowerCase().equals("morgan")) {
					waitingForUsername = false;
					startSpeaking("Hi, " + str + ". Please say your passphrase.");
					waitingForPassphrase = true;
				}
				else {
					startSpeaking("I'm sorry, I don't recognize that username. Please say your username again.");
				}
				break;
			}
			else if (waitingForPassphrase) {
				if (str.toLowerCase().equals("santa cruz")) {
					userAuthenticated();
				}
				else {
					startSpeaking("I'm sorry, that's not the correct passphrase. Please say your passphrase.");
				}
				break;
			}
		}
	}

	public void onPartialResults(Bundle partialResults) {
		Log.i(TAG, "onPartialResults");
	}

	public void onEvent(int eventType, Bundle params) {
		Log.i(TAG, "onEvent " + eventType);
	}

	/* ****************************************************************************************************
			OnInitListener
	*******************************************************************************************************/

	@Override
	public void onInit(int status) {

		if (status == TextToSpeech.SUCCESS) {
			int result = tts.setLanguage(Locale.US);
			if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
				Log.e(TAG, "This Language is not supported.");
			}
			else {
				tts.setOnUtteranceCompletedListener(this);
			}

			readyToSpeak = true;
			checkLockState();
		}
		else {
			Log.e(TAG, "Initilization Failed!");
		}
	}

	/* ****************************************************************************************************
			OnUtteranceCompletedListener
	*******************************************************************************************************/

	public void onUtteranceCompleted(String utteranceId) {

		Log.i(TAG, "************* onUtteranceCompleted *************");

		speeking = false;
		if (waitingForUsername || waitingForPassphrase) {
			runOnMainThread(new Runnable() {
				@Override
				public void run() {
					startListening();
				}
			});
		}
	}

	/* ****************************************************************************************************
			(Class) CommandTask
	*******************************************************************************************************/

/**
 * Command Task call Bladerunner perform() method on the
 * given {@link com.plantronics.headsetdataservice.io.DeviceCommand}
 * In background it also verifies if the bladerunner connection is open? If not, it initiates the Bladerunner
 * connection and also registers {@link HeadsetServiceConnectionListener}
 * When successful, this Task invokes the Command again
 * Updates the result of the perform() method to UI under onProgressUpdate
 */
public class CommandTask extends AsyncTask<HeadsetDeviceCommand, RemoteResult, Integer> implements HeadsetServiceResponseListener,
		HeadsetServiceConnectionListener {

	@Override
	protected void onPreExecute() {
		super.onPreExecute();
		Log.i(TAG, "Executing the CommandTask ");
	}

	@Override
	public void result(int res, RemoteResult result) {
		publishProgress(result);
	}

	@Override
	public void settingResult(int res, SettingsResult settingsResult) {
		publishProgress(settingsResult.getResult());
	}

	// onProgressUpdate implements a hack with the value returned from getResultCode()
	// the idea is to distinguish between deviceOpen()/deviceClose() callbacks
	// and the actual result returned form the execution of perform() command
	@Override
	protected void onProgressUpdate(RemoteResult... values) {
		super.onProgressUpdate(values);

		// ***************** see SettingTask onProgressUpdate() for info about error handling *************
		if (values[0].getResultCode() < 2) {
			Log.i(TAG, "Result returned=" + values[0].getResultCode());
			Log.i(TAG, "The result=" + values[0].getResultString());
		}
		else {
			Log.i(TAG, values[0].getResultString());
			if (values[0].getResultCode() == 4 ) {
				Log.e(TAG, "************************** CommandTask: execute the saved Task **************************" );
				//createRSSICommandObject(bToggleRSSI);
			}
		}
	}

	// Call the perform() method to execute the Command on the headset
	@Override
	protected Integer doInBackground(HeadsetDeviceCommand... deviceCommands) {
		int res = -1;
		RemoteResult remoteRes = new RemoteResult();
		Log.e(TAG, "doInBack: received args" + deviceCommands);
		if (!mController.isbDeviceOpen(mLocalDevice))  {
			Log.e(TAG, "device is not open, saving Command Task");
			mController.open(mLocalDevice, this);
		}
		else {
			res = mController.perform(deviceCommands[0].getDevice(), deviceCommands[0].getCommand(), remoteRes, this);
		}
		return res;
	}

	@Override
	protected void onPostExecute(Integer integer) {
		super.onPostExecute(integer);

		//bToggleRSSI = !bToggleRSSI;
		// set the screen with the result display
	}

	// in case the connection was not open, this callback will be called
	// Its a hack with value - 4  (I just want to distinguish between actual result returned from
	// the execution of the perform(..cmd ..)  and  the case where BR connection got established successfully
	// it can be handled better
	@Override
	public void deviceOpen(final HeadsetDataDevice device) {
		Log.e(TAG, "CommandTask: device opened");
		RemoteResult result = new RemoteResult(4, "Device Open");
		publishProgress(result);
	}

	// again the hack with value 2 returned as open failed so that
	// onProgressUpdate() can act on it
	@Override
	public void openFailed(final HeadsetDataDevice device) {
		Log.e(TAG, "CommandTask: device open failed");
		RemoteResult result = new RemoteResult(2, "Device Open Failed");
		publishProgress(result);
	}

	// again the hack with value 2 returned as open failed so that
	// onProgressUpdate() can act on it
	@Override
	public void deviceClosed(final HeadsetDataDevice device) {
		Log.e(TAG, "CommandTask: device closed");
		RemoteResult result = new RemoteResult(2, "Device Closed");
		publishProgress(result);
	}
}

	/* ****************************************************************************************************
			(Class) SettingTask
	*******************************************************************************************************/
/**
 * Setting Task call Bladerunner fetch() method on the
 * given {@link com.plantronics.headsetdataservice.io.DeviceSetting}
 * In background it also verifies if the bladerunner connection is open? If not, it initiates the Bladerunner
 * connection and also registers {@link HeadsetServiceConnectionListener}
 * When successful, this Task invokes the Setting again
 * Updates the result of the fetch() method to UI under onProgressUpdate
 */
public class SettingTask extends AsyncTask<HeadsetDeviceSetting, RemoteResult, Integer>
		implements HeadsetServiceResponseListener, HeadsetServiceConnectionListener {

	SettingsResult settingsResult;
//		RemoteResult queryResult;
//		Object[] mResult;

	@Override
	protected void onPreExecute() {
		super.onPreExecute();
		Log.i(TAG, "Executing SettingTask");
		// print the command going to be executed
	}

	@Override
	public void result(int res, RemoteResult result) {
		Log.i(TAG, "result");
		//publishProgress(result);


	}

	@Override
	public void settingResult(int res, SettingsResult theResult) {
		Log.i(TAG, "settingResult");
		settingsResult = theResult;
		//mResult = settingsResult.getSetting().getValues();
		publishProgress(settingsResult.getResult());
	}

	// onProgressUpdate implements a hack with the value returned from getResultCode()
	// the idea is to distinguish between deviceOpen()/deviceClose() callbacks
	// and the actual result returned form the execution of fetch() setting
	// this can be handled differently
	@Override
	protected void onProgressUpdate(RemoteResult... values) {
		super.onProgressUpdate(values);

		if (values[0].getResultCode() < 2) {
			// publish the result on the screen
			// This is the result from the execution of the Setting request fetch()
			Log.i(TAG, "Result returned = " + values[0].getResultCode());

			if (values[0].getResultCode() < 0) {
				// error case
				Log.i(TAG, "The result = " + values[0].getResultString());
			}
			else {
				// successful result, print the Settings value returned in the fetch()
				//Log.i(TAG, "Settings = " + Arrays.asList(mResult).toString());
			}

			int settingType = settingsResult.getSetting().getType().getID();
			switch (settingType) {

				case Definitions.Settings.WEARING_STATE_SETTING: {
					Log.i(TAG, "settingsResult.getSetting().toString(): " + settingsResult.getSetting().toString());
					List resultList = Arrays.asList(settingsResult.getSetting().getValues());
					Log.i(TAG, "resultList: " + resultList);
					Boolean on = (resultList.get(0).toString() == "true");
					Log.i(TAG, "------------- Don/Doff Setting: " + on + " -------------");
					updateWearingState(on);
					break;
				}

				case Definitions.Settings.CALL_STATUS_SETTING: {
					Log.i(TAG, "settingsResult.getSetting().toString(): " + settingsResult.getSetting().toString());
					List resultList = Arrays.asList(settingsResult.getSetting().getValues());
					Log.i(TAG, "resultList: " + resultList);
					String status = resultList.get(0).toString();
					Log.i(TAG, "------------- Call Status Setting: " + status + " -------------");
					break;
				}

				case Definitions.Settings.CURRENT_SIGNAL_STRENGTH_SETTING:
					Log.i(TAG, "settingsResult.getSetting().toString(): " + settingsResult.getSetting().toString());
					List resultList = Arrays.asList(settingsResult.getSetting().getValues());
					Log.i(TAG, "resultList: " + resultList);
					String strength = resultList.get(0).toString();
					Log.i(TAG, "------------- Signal Strength Setting: " + strength + " -------------");
					break;
			}
		}
		else {
			// This is the case where Bladerunner connection was not opened
			// hence the result is whether we were successful to open the connection or not
			Log.i(TAG, values[0].getResultString());
			if (values[0].getResultCode() == 4) {
				// result code == 4 ; means that we were successful in opening connection
				// now execute the Setting request again
				Log.e(TAG, "************* CommandTask: execute the saved Task *************");
				// execute settings api
				//createBatterySettingObject();
			}
		}
	}

	// call the fetch() for the Setting request
	@Override
	protected Integer doInBackground(HeadsetDeviceSetting... deviceSettings) {
		int res = -1;
		RemoteResult remoteRes = new RemoteResult();
		Log.e(TAG, "doInBackground: received args" + deviceSettings);
		if (!mController.isbDeviceOpen(mLocalDevice)) {
			Log.e(TAG, "device is not open, saving Setting Task");
			// start the connection open process. It will result in asynchronous api callbacks handled from
			// deviceOpen() and openFailed()
			mController.open(mLocalDevice, this);

		}
		else {
			// connection is already open
			res = mController.fetch(deviceSettings[0].getDevice(), deviceSettings[0].getSetting(), remoteRes, this);
			// save the Setting result returned
			Log.e(TAG, "Copying setting - " + deviceSettings[0].getSetting().toString());

			//mResult = deviceSettings[0].getSetting().getValues();
			//Log.e(TAG, "Result=" + Arrays.asList(mResult).toString());
			//publishProgress(remoteRes);
		}
		return res;
	}

	@Override
	protected void onPostExecute(Integer integer) {
		super.onPostExecute(integer);

		// set the screen with the result display
	}


	// in case the connection was not open, this callback will be called
	// Its a hack with value (4)  (I just want to distinguish between actual result returned from
	// the execution of the fetch(..setting ..)  and  the case where BR connection got established successfully
	// it can be handled better
	@Override
	public void deviceOpen(final HeadsetDataDevice device) {
		Log.e(TAG, "SettingTask: device opened");
		RemoteResult result = new RemoteResult(4, "Device Open");
		publishProgress(result);

	}

	@Override
	public void openFailed(final HeadsetDataDevice device) {
		Log.e(TAG, "SettingTask: device open failed");
		RemoteResult result = new RemoteResult(2, "Device Open Failed");
		publishProgress(result);
	}

	@Override
	public void deviceClosed(final HeadsetDataDevice device) {
		Log.e(TAG, "SettingTask: device closed");
		RemoteResult result = new RemoteResult(2, "Device Closed");
		publishProgress(result);
	}
}

/* ****************************************************************************************************
		(Class) ReceiveEventTask
*******************************************************************************************************/
public class ReceiveEventTask extends AsyncTask<HeadsetDataDevice, DeviceEvent, Integer>
		implements HeadsetServiceEventListener, HeadsetServiceConnectionListener {

	@Override
	protected void onProgressUpdate(DeviceEvent... values) {
		super.onProgressUpdate(values);

		// print the device event
		switch ( ((DeviceEvent)values[0]).getType().getID()) {

			case Definitions.Events.CUSTOM_BUTTON_EVENT:
				Log.i(TAG, "------------- Custom Button Event -------------");
				break;

			case Definitions.Events.WEARING_STATE_CHANGED_EVENT:
				boolean on = false;
				if (((DeviceEvent)values[0]).getEventData()[0].toString() == "true") on = true;
				Log.i(TAG, "------------- Don/Doff Event: " + on + " -------------");
				updateWearingState(on);

			case Definitions.Events.BATTERY_STATUS_CHANGED_EVENT:
				Log.i(TAG, "------------- Battery Status Event: " + Arrays.asList( ((DeviceEvent)values[0]).getEventData()).toString() + " -------------");
				break;

			case Definitions.Events.CALL_STATUS_CHANGE_EVENT:
				String status = ((DeviceEvent)values[0]).getEventData()[0].toString();
				Log.i(TAG, "------------- Call Status Event: " + status + " -------------");
				//updateCallStatus();
				break;

			case Definitions.Events.SIGNAL_STRENGTH_EVENT:
				String strengthString = ((DeviceEvent)values[0]).getEventData()[1].toString();
				int strength = Integer.parseInt(strengthString); // this is stupid.
				Log.i(TAG, "------------- Signal Strength Event: " + strengthString + " -------------");
//					strength = -strength;
//					strength += 80;
				updateRSSI(strength);
				break;

			case Definitions.Events.CONFIGURE_SIGNAL_STRENGTH_EVENT_EVENT:
				String enabled = ((DeviceEvent)values[0]).getEventData()[1].toString();
				Log.i(TAG, "------------- Configure Signal Strength Event: " + enabled + " -------------");
				break;

			default:
				Log.i(TAG, "------------- Other Event: " + values[0] + " -------------");
				break;
		}
	}

	// register to receive all Bladerunner Events
	@Override
	protected Integer doInBackground(HeadsetDataDevice... headsetDataDevices) {
		if (mController.registerEventListener(mLocalDevice, this)) {
			Log.i(TAG, "Registered for events.");
			return 0; // success
		}
		else {
			Log.e(TAG, "Device not open, failed to register for events.");
			return -1;  // failed
		}
	}

	@Override
	public void eventReceived(DeviceEvent de) {
		publishProgress(de);
	}

	@Override
	public void deviceOpen(final HeadsetDataDevice device) {
		//To change body of implemented methods use File | Settings | File Templates.
	}

	@Override
	public void openFailed(final HeadsetDataDevice device) {
		//To change body of implemented methods use File | Settings | File Templates.
	}

	@Override
	public void deviceClosed(final HeadsetDataDevice device) {
		//To change body of implemented methods use File | Settings | File Templates.
	}
}
}

