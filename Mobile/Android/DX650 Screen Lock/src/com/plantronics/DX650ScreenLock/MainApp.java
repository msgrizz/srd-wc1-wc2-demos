package com.plantronics.DX650ScreenLock;

import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.RemoteException;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import android.speech.tts.TextToSpeech.OnInitListener;
import android.speech.tts.TextToSpeech.OnUtteranceCompletedListener;
import android.util.Log;
import android.widget.Toast;
import com.plantronics.example.controller.HeadsetDataController;
import com.plantronics.example.listeners.BindListener;
import com.plantronics.example.listeners.DiscoveryListener;
import com.plantronics.example.listeners.HeadsetServiceBluetoothListener;
import com.plantronics.example.listeners.HeadsetServiceConnectionListener;
import com.plantronics.headsetdataservice.io.HeadsetDataDevice;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;

public class MainApp extends Application implements BindListener, DiscoveryListener, HeadsetServiceConnectionListener, HeadsetServiceBluetoothListener,
		RecognitionListener, OnInitListener, OnUtteranceCompletedListener {

	public static MainApp mainApp = null;
	private static final String TAG = "com.plantronics.DX650ScreenLock.MainApp";

	private static Context context = null;
	private SpeechRecognizer sr;
	private TextToSpeech tts;
	private boolean locked;
	private boolean hsConnected;
	private boolean hsNear;
	private boolean hsDonned;
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
			Application
	*******************************************************************************************************/

	@Override
	public void onCreate() {
		super.onCreate();

		mainApp = this;
		context = this.getApplicationContext();
		sr = SpeechRecognizer.createSpeechRecognizer(this);
		sr.setRecognitionListener(this);
		tts = new TextToSpeech(this, this);

		// *************** just for now **************
		hsConnected = true;
		hsNear = true;
		// *******************************************

		hsDonned = false;
		waitingForUsername = false;
		waitingForPassphrase = false;
		readyToSpeak = false;

		this.lockScreen();

		// Bladerunner

		mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
		mController = HeadsetDataController.getHeadsetControllerSingleton(this);
		if (mController.bindHeadsetDataService(this) == 2) {
			Log.e(TAG, "Service already bound: register callbacks with the service.");
			//isBoundToService = true;
			mController.registerServiceCallbacks();
		}


//		// setup the HeadsetDataService and bind to it
//		mController = HeadsetDataController.getHeadsetControllerSingleton(this);
//		if (mController.bindHeadsetDataService(this) == 2) {
//			// service is already bound so serviceConnected() will not be called
//			// so register the service here itself
//			Log.e(TAG, "Service already bound: register callbacks with the service");
//			mController.registerServiceCallbacks();
//		}
//
//		if (mController.isbServiceConnectionOpen()) {
//
//			if (mLocalDevice == null)  {
//				Log.i(TAG, "Create new device " + mDeviceAddress);
//				mController.newDevice(mDeviceAddress, this);
//
//				mLocalDevice = new HeadsetDataDevice(mDeviceAddress, (byte)0);
//			}
//			if (!mController.isbDeviceOpen(mLocalDevice)) {
//				// open Bladerunner Connection asynchronous call
//				mController.open(mLocalDevice, this);
//			}
//
//		} else {
//			Log.e(TAG, "Connection to the service is not open");
//			Toast.makeText(this, "Service is disconnected.", Toast.LENGTH_SHORT).show();
//		}
	}

	@Override
	public void onTerminate() {

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

		super.onTerminate();
	}

	/* ****************************************************************************************************
			Static
	*******************************************************************************************************/

	public static void headsetACLConnected() {
		Log.i(TAG, "***************** headsetACLConnected *****************");

		if (MainApp.mainApp != null) {
			((MainApp)MainApp.mainApp).setHSConnected(true);
		}
	}

	public static void headsetACLDisconnected() {
		Log.i(TAG, "***************** headsetACLDisconnected *****************");

		if (MainApp.mainApp != null) {
			((MainApp)MainApp.mainApp).setHSConnected(false);
		}
	}

	public static void headsetDonned() {
		Log.i(TAG, "***************** headsetDonned *****************");

		if (MainApp.mainApp != null) {
			((MainApp)MainApp.mainApp).setHSDonned(true);
		}
	}

	public static void headsetDoffed() {
		Log.i(TAG, "***************** headsetDoffed *****************");

		if (MainApp.mainApp != null) {
			((MainApp)MainApp.mainApp).setHSDonned(false);
		}
	}

	/* ****************************************************************************************************
			Public
	*******************************************************************************************************/

	public void setHSConnected(boolean connected) {
		hsConnected = connected;
		checkLockState();
	}

	public void setHSDonned(boolean donned) {
		hsDonned = donned;
		checkLockState();
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void doDiscovery() {
		Log.i(TAG, "************* doDiscovery() *************");

		deviceDiscovered = false;
		try {
			mController.registerDiscoveryCallback();
			int ret =  mController.getBladeRunnerDevices();
			Log.i(TAG, "getBladeRunnerDevices() returned " + ret);
		}
		catch (RemoteException e) {
			e.printStackTrace();
		}
	}

	private void connectToDevice(String deviceAddress) {
		Log.i(TAG, "************* Connecting to device " + deviceAddress + "... *************");

		mController.newDevice(deviceAddress, this);
		mLocalDevice = new HeadsetDataDevice(deviceAddress, (byte)0);
		mController.open(mLocalDevice, this);
	}

	void checkLockState() {
		Log.i(TAG, "************* checkLockState() *************");
		if (locked && hsConnected && hsDonned && hsNear && !speeking) {
			if (readyToSpeak) {
				Log.i(TAG, "Starting unlock sequence...");
				// regardless of whether we were previously waiting for a new verbal response from the user, start over the "hi say" sequence
				sr.stopListening();
				tts.stop();
				waitingForPassphrase = false;

				startSpeaking(",,, Welcome to the Cisco-Plantronics DX six-fifty and Voyager Legend screen lock demo. Please say your username.");
				waitingForUsername = true;
				// will start listening after onUtteranceCompleted()
			}
			else {
				Log.i(TAG, "Not ready to speak.");
				// onReadyToSpeak will call us again
			}
		}
		else if (!hsDonned || !hsConnected || !hsNear) {
			sr.stopListening();
			tts.stop();
			waitingForUsername = false;
			waitingForPassphrase = false;
		}
	}

	private void lockScreen() {

		if ((context != null) && !locked) {
			Intent intent = new Intent(context, com.plantronics.DX650ScreenLock.LockScreen.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			context.startActivity(intent);
			this.locked = true;
		}
	}

	private void unlockScreen() {

		sr.stopListening();
		tts.stop();

		com.plantronics.DX650ScreenLock.LockScreen.unlockDevice();
		this.locked = false;
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

		HashMap<String, String> params = new HashMap<String, String>();
		params.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, "stringId");
		tts.speak(text, TextToSpeech.QUEUE_FLUSH, params);
	}

	private void runDelayed(Runnable runnable, int delay) {

		final Handler handler = new Handler(Looper.getMainLooper());
		handler.postDelayed(runnable, delay);
	}

	/* ****************************************************************************************************
			BindListener
	*******************************************************************************************************/

	@Override
	public void bindSuccess() {
		Log.i(TAG, "************* bindSuccess() *************");
		isBoundToService = true;
		if (mController == null) {
			Log.i(TAG, "NULL!!!!!!");
		}
		//mController.registerServiceCallbacks();
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
			final Handler handler = new Handler(Looper.getMainLooper());
			handler.post(new Runnable() {
				@Override
				public void run() {
					BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(name);
					mDeviceAddress = device.getAddress();

					if (mController.isbServiceConnectionOpen()) {
						connectToDevice(mDeviceAddress);
					}
					else {
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
			}, 1000);
		}
	}

	/* ****************************************************************************************************
			HeadsetServiceConnectionListener
	*******************************************************************************************************/

	@Override
	public void deviceOpen(final HeadsetDataDevice device) {
		Log.i(TAG, "************* deviceOpen:" + device + "*************");

		final Handler handler = new Handler(Looper.getMainLooper());
		handler.post(new Runnable() {
			@Override
			public void run() {
				// *********************** start monitoring RSSI *********************
			}
		});
	}

	/**
	 * Callback interface method called when the Bladerunner
	 * connection failed to open.
	 */
	@Override
	public void openFailed(final HeadsetDataDevice device) {
		Log.e(TAG, "************* openFailed: " + device + "*************");

		final Handler handler = new Handler(Looper.getMainLooper());
		handler.post(new Runnable() {
			@Override
			public void run() {
				doDiscovery();
			}
		});
	}

	/**
	 *  Callback interface method called when SDK closed the
	 *  bladerunner connection to the device
	 */
	@Override
	public void deviceClosed(final HeadsetDataDevice device) {
		Log.e(TAG, "************* deviceClosed:" + device + "*************");

		final Handler handler = new Handler(Looper.getMainLooper());
		handler.post(new Runnable() {
			@Override
			public void run() {
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
		Log.i(TAG, "************* onResults: " + results + "*************");

		sr.stopListening();
		ArrayList data = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
		String str = new String();
		for (int i = 0; i < data.size(); i++) {
			str += data.get(i);
			Log.i(TAG, "Spoken: " + str);

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
					waitingForPassphrase = false;
					startSpeaking("Thank you. Access granted.");
					runDelayed(new Runnable() {
						@Override
						public void run() {
							unlockScreen();
						}
					}, 1500);
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

		if (waitingForUsername || waitingForPassphrase) {
			final Handler handler = new Handler(Looper.getMainLooper());
			handler.post(new Runnable() {
				@Override
				public void run() {
					startListening();
				}
			});
		}
	}
}
