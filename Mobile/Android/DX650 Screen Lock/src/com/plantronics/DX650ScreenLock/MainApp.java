/* ********************************************************************************************************
	MainApp.java
	com.plantronics.DX650ScreenLock

	Created by mdavis on 06/23/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650ScreenLock;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.Application;
import android.app.admin.DevicePolicyManager;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;
import android.os.*;
import android.os.RemoteException;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.widget.Toast;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.plantronics.bladerunner.Definitions;
import com.plantronics.example.controller.HeadsetDataController;
import com.plantronics.example.controller.HeadsetDeviceCommand;
import com.plantronics.example.controller.HeadsetDeviceSetting;
import com.plantronics.example.controller.SettingsResult;
import com.plantronics.example.listeners.*;
import com.plantronics.headsetdataservice.io.*;
import android.app.ActivityManager.RunningAppProcessInfo;
import java.lang.reflect.Type;
import java.util.*;

public class MainApp extends Application implements BindListener, DiscoveryListener, HeadsetServiceConnectionListener, HeadsetServiceBluetoothListener,
		RecognitionListener, TextToSpeech.OnInitListener, TextToSpeech.OnUtteranceCompletedListener {

	public static MainApp mainApp = null;
	public static String PREFERENCES_THRESHOLD = "PREFERENCES_THRESHOLD";
	public static String PREFERENCES_USERS = "PREFERENCES_USERS";

	private static Context context = null;
	private static final String TAG = "DX650ScreenLock.MainApp";
	private static final double SIGNALSTRENGTH_FILTER_CONSTANT = .6;
	private static final int SIGNALSTRENGTH_NEAR_FAR_DELTA = 20;
	private static final String UTTERANCE_USERNAME = "DX650ScreenLock.utterance.username";
	private static final String UTTERANCE_PASSPHRASE = "DX650ScreenLock.utterance.passphrase";
	private static final String UTTERANCE_AUTHENTICATED = "DX650ScreenLock.utterance.authenticated";

	private static final String TIMED_TERMINATE = "TIMED_TERMINATE";
	private static final String TIMED_START_AUTH_SEQUENCE = "TIMED_START_AUTH_SEQUENCE";
	private static final String TIMED_UNLOCK_SCREEN = "TIMED_UNLOCK_SCREEN";
	private static final String TIMED_SPEECH_REC_TIMEOUT = "TIMED_SPEECH_REC_TIMEOUT";
	private static final String TIMED_START_SPEAKING = "TIMED_START_SPEAKING";
	private static final String TIMED_START_DISCOVERY = "TIMED_START_DISCOVERY";
	private static final String TIMED_SETUIPASSWORD = "TIMED_SETUIPASSWORD";
	private static final String TIMED_SHOW_SETTINGS = "TIMED_SHOW_SETTINGS";

	private SpeechRecognizer sr;
	private TextToSpeech tts;
	private ComponentName deviceAdmin;
	private DevicePolicyManager dpm;
	private boolean locked;
	private boolean hsConnected;
	private boolean hsNear;
	private boolean hsDonned;
	private int hsSignalStrength = 0;
	private int hsNearSignalStrengthThreshold = 60;
	private int hsFarSignalStrengthThreshold = hsNearSignalStrengthThreshold + SIGNALSTRENGTH_NEAR_FAR_DELTA;
	private boolean aboutToSpeak;
	private boolean speaking;
	private boolean listening;
	private String spokenUsername;
	private boolean waitingForUsername;
	private boolean waitingForPassphrase;
	private int unknownUsernameAttempts;
	private int notHeardUsernameAttempts;
	private int wrongPassphraseAttempts;
	private int notHeardPassphraseAttempts;
	private boolean readyToSpeak;
	//private boolean terminateOnResume;
	private boolean aboutToUnlock;
	private boolean lockOnPause;
	//private boolean authenticated;
	private boolean inAuthSequence;
	private ArrayList<NamedTimerTask> timerTasks;
	private int waitingToSaveHSNearSignalStrengthThreshold;
	private String waitingToSavePreferencesUsersJSON;

	private BluetoothAdapter mBluetoothAdapter;
	private static HeadsetDataController mController;
	private HeadsetDataDevice mLocalDevice;
	private String mDeviceAddress = "";
	private boolean isBoundToService = false;
	private boolean deviceDiscovered = false;
	private boolean discovering = false;

	private ArrayList<User> users;

	/* ****************************************************************************************************
			Static
	*******************************************************************************************************/

	public static String FN() {
		StackTraceElement[] trace = Thread.currentThread().getStackTrace();
		if (trace.length >= 3) {
			String methodName = trace[3].getMethodName();
			return String.format("%s.%s", TAG, methodName);
		}
		else {
			return "STACK TRACE TOO SHALLOW";
		}
	}

	/* ****************************************************************************************************
			Application
	*******************************************************************************************************/

	@Override
	public void onCreate() {
		super.onCreate();

		Log.i(FN(), "************* onCreate *************");

//		StackTraceElement[] trace = Thread.currentThread().getStackTrace();
//		Log.i(FN(), "trace len: " + trace.length);
//		for (int i=0; i<trace.length; i++) {
//			Log.i(TAG, i + ": " + trace[i].getMethodName());
//		}


//		if (numberOfMeAlive() > 1) {
//			Log.i(FN(), "Already alive. Killing myself.");
//			kill();
//		}


//		WindowManager windowManager =  (WindowManager)getSystemService(WINDOW_SERVICE);
//		Display display = windowManager.getDefaultDisplay();
//		Log.i(TAG, "getOrientation(): " + display.getOrientation());


		mainApp = this;

		cancelAllTimed();

		context = this.getApplicationContext();
		sr = SpeechRecognizer.createSpeechRecognizer(this);
		sr.setRecognitionListener(this);
		tts = new TextToSpeech(this, this);
		dpm = (DevicePolicyManager)this.getSystemService(Context.DEVICE_POLICY_SERVICE);
		deviceAdmin = new ComponentName(this, com.plantronics.DX650ScreenLock.LockerReceiver.class);
		timerTasks = new ArrayList<NamedTimerTask>();
		//lockOnPause = false;
		users = new ArrayList<User>();
		//terminateOnResume = false; // commented out for Service refactor

		mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
		mController = HeadsetDataController.getHeadsetControllerSingleton(this);
		if (mController.bindHeadsetDataService(this) == 2) {
			Log.i(FN(), "Service already bound: register callbacks with the service.");
			isBoundToService = true;
			mController.registerServiceCallbacks();
		}

		Log.i(FN(), "hsConnected: " + hsConnected);
	}

	@Override
	public void onTerminate() {

		Log.i(FN(), "************* onTerminate() *************");
		cleanup();
		super.onTerminate();
	}

	/* ****************************************************************************************************
			Public -- mimics Activity implementation
	*******************************************************************************************************/

	public void onPause() {
		Log.i(FN(), "************* onPause() *************");

		cancelAllTimed();

		aboutToUnlock = false;

		if (lockOnPause) {
			lockDevice();
		}
		else {
			locked = false;
		}

		//checkStartAuthSequence(); // shuts everything up
		//checkAbort();
		cancelAuthentication(true);
	}

	public void onResume() {
		Log.i(FN(), "************* onResume() *************");

		// ew

		if (waitingToSavePreferencesUsersJSON != null) {
			SharedPreferences preferences = LockActivity.lockActivity.getPreferences(MODE_PRIVATE);
			SharedPreferences.Editor editor = preferences.edit();
			Log.i(FN(), "Saving users: " + waitingToSavePreferencesUsersJSON + " threshold: " + waitingToSaveHSNearSignalStrengthThreshold);
			editor.putInt(PREFERENCES_THRESHOLD, waitingToSaveHSNearSignalStrengthThreshold);
			editor.putString(PREFERENCES_USERS, waitingToSavePreferencesUsersJSON);
			editor.commit();
		}
		waitingToSavePreferencesUsersJSON = null;

		SharedPreferences preferences = LockActivity.lockActivity.getPreferences(MODE_PRIVATE);
		hsNearSignalStrengthThreshold = preferences.getInt(PREFERENCES_THRESHOLD, 55);
		Log.i(FN(), "preferences threshold: " + hsNearSignalStrengthThreshold);
		hsFarSignalStrengthThreshold = hsNearSignalStrengthThreshold + 15;
		Gson gson = new Gson();
		String usersString = preferences.getString(PREFERENCES_USERS, "[]");
		Type collectionType = new TypeToken<ArrayList<User>>(){}.getType();
		users = gson.fromJson(usersString, collectionType);
		if ((users == null) || users.isEmpty()) {
			users = new ArrayList<User>();
		}
		Log.i(FN(), "Read users: " + users + "threshold: " + hsNearSignalStrengthThreshold);

		Log.i(FN(), "hsConnected: " + hsConnected);

		cancelAllTimed();

//		if (terminateOnResume) {
//			runTimed(new Runnable() {
//				@Override
//				public void run() {
//					cleanup();
//					kill();
//				}
//			}, 100, TIMED_TERMINATE);
//		}
//		else {
		setupAudio();

//			if (users.isEmpty()) {
//				runTimed(new Runnable() {
//					@Override
//					public void run() {
//						askAddUser();
//					}
//				}, 2000, TIMED_SHOW_SETTINGS);
//			}

		waitingForUsername = false;
		waitingForPassphrase = false;
		aboutToSpeak = false;
		speaking = false;
		listening = false;
		locked = true;
		lockOnPause = true;
		aboutToUnlock = false;
		//authenticated = false;

		LockActivity.lockActivity.updateClockUI();
		LockActivity.lockActivity.setUILocked();
		LockActivity.lockActivity.setUIDiscovery(discovering);
		lockScreen();

		if (mLocalDevice != null) {
			connectToDevice(mLocalDevice.getAddress());
		}

		checkStartAuthSequence();
//			}
//		}
	}

	// this isn't a "real" implementation -- LockActivity forwards its onActivityResult() here.
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.i(FN(), "onActivityResult()");

		switch (requestCode) {
			case SettingsActivity.SETTINGS_ACTIVITY:
				Log.i(FN(), "************* SettingsActivity closed. *************");

				if (resultCode== Activity.RESULT_OK) {
					int threshold = data.getExtras().getInt(SettingsActivity.EXTRA_THRESHOLD, 55);
					hsNearSignalStrengthThreshold = threshold;
					hsFarSignalStrengthThreshold = hsNearSignalStrengthThreshold + SIGNALSTRENGTH_NEAR_FAR_DELTA;
					users = (ArrayList<User>)data.getExtras().get(SettingsActivity.EXTRA_USERS);

					Log.i(FN(), "hsNearSignalStrengthThreshold: " + hsNearSignalStrengthThreshold);
					Log.i(FN(), "users: " + users);

					Gson gson = new Gson();
					String usersString = gson.toJson(users);

					waitingToSavePreferencesUsersJSON = usersString;
					waitingToSaveHSNearSignalStrengthThreshold = threshold;
				}



				break;

			default:
				Log.e(FN(), "onActivityResult(): unknown request code: '"+requestCode+"'");
		}
	}

	/* ****************************************************************************************************
			Public
	*******************************************************************************************************/

	public void setLockOnPause(boolean flag) {
		lockOnPause = flag;
	}

	public void goHome() {
		Log.i(FN(), "goHome()");
		lockOnPause = false;
		if (LockActivity.lockActivity != null) {
			LockActivity.lockActivity.finish();
		}
	}

	public void kill() {
		Log.i(FN(), "************* Terminating... *************");
		android.os.Process.killProcess(android.os.Process.myPid());
	}

	public int getHSNearSignalStrengthThreshold() {
		return hsNearSignalStrengthThreshold;
	}

	public ArrayList<User> getUsers() {
		return users;
	}

	public int getHSSignalStrength() {
		return hsSignalStrength;
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void cleanup() {
		Log.i(FN(), "************* cleanup() *************");

		if (sr != null) {
			sr.stopListening();
			sr.destroy();
		}
		if (tts != null) {
			stopSpeaking();
			tts.shutdown();
		}
		if (mBluetoothAdapter != null) {
			mBluetoothAdapter.cancelDiscovery();
		}
		if (mController != null) {
			mController.close(mLocalDevice);
			mController.unregisterDiscoveryCallback();
		}
		if (isBoundToService) {
			mController.unbindHeadsetDataService(this);
		}
	}

	private void doDiscovery() {
		Log.i(FN(), "************* doDiscovery() *************");

		if (LockActivity.lockActivity != null) {
			LockActivity.lockActivity.setUIDiscovery(true);
		}

		hsConnected = false;
		hsDonned = false;
		hsNear = false;
		deviceDiscovered = false;
		mLocalDevice = null;
		mDeviceAddress = null;

		try {
			discovering = true;
			mController.registerDiscoveryCallback();
			if (mController == null) {
				Log.i(FN(), "mController is null");
			}
			int ret =  mController.getBladeRunnerDevices();
			Log.i(FN(), "getBladeRunnerDevices() returned " + ret);
		}
		catch (RemoteException e) {
			discovering = false;
			e.printStackTrace();
		}
	}

	private void connectToDevice(String deviceAddress) {
		Log.i(FN(), "************* Connecting to device " + deviceAddress + "... *************");

		mController.newDevice(deviceAddress, this);
		mLocalDevice = new HeadsetDataDevice(deviceAddress, (byte)0);
		int ret = mController.open(mLocalDevice, this);
		if (ret==1) {
			Log.i(FN(), "************* Connection already open! *************");
			isBoundToService = true;
			mController.registerServiceCallbacks();
		}
	}

	private void startListeningForEvents() {
		Log.i(FN(), "startListeningForEvents");
		ReceiveEventTask task = new ReceiveEventTask();
		task.execute(mLocalDevice);
	}

	private void startMonitoringProximity(boolean enable) {
		Log.i(FN(), "************* startMonitoringProximity: " + enable + " *************");

		short id = Definitions.Commands.CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND;
		Object objs[] = new Object[10];

		objs[0] = (Byte)(byte)0; /* The connection ID of the link being used to generate the signal strength event. */
		objs[1] = (Boolean) enable;  /* enable - If true, this will enable the signal strength monitoring. */
		objs[2] = (Boolean) false;   /* If true, report near far events only when headset is donned. */
		objs[3] = (Boolean) false;  /* trend - If true don't use trend detection */
		objs[4] = (Boolean) false;  /* report rssi audio - If true, Report rssi and trend events in headset audio */
		objs[5] = (Boolean) false;  /* report near far audio - If true, report Near/Far events in headset Audio */
		objs[6] = (Boolean) true;  /* report near far to base - If true, report SignalStrength and Near Far events to base  */
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
				Log.d(TAG, "createSignalStrength: execute command task:" + hdc);
				CommandTask task = new CommandTask();
				task.execute(hdc);
			}
			else {
				Log.e(FN(), "Command does not exist " + id);
			}
		}
	}

	private boolean checkStartAuthSequence() {
		Log.i(FN(), "************* checkStartAuthSequence() *************");
		Log.i(FN(), "inAuthSequence: " + inAuthSequence);

		if (!inAuthSequence && goodToAuth(true)) {
			Log.i(FN(), "************* Starting authentication sequence... *************");
			// regardless of whether we were previously waiting for a new verbal response from the user, start over the "hi say" sequence
			sr.stopListening();
			stopSpeaking();
			inAuthSequence = true;
			waitingForUsername = true; // will start listening after onUtteranceCompleted()
			waitingForPassphrase = false;
			unknownUsernameAttempts = 0;
			notHeardUsernameAttempts = 0;
			wrongPassphraseAttempts = 0;
			notHeardPassphraseAttempts = 0;

			aboutToSpeak = true;
			runTimed(new Runnable() {
				@Override
				public void run() {
					startSpeaking("Welcome to the Cisco-Plantronics DX six-fifty screen lock demo. Please say your username.", UTTERANCE_USERNAME);
				}
			}, 1000, TIMED_START_AUTH_SEQUENCE);

			return true;
		}

		return false;
	}

	private boolean deviceIsLocked() {
		return (LockActivity.lockActivity != null);
	}

	private boolean goodToAuth(boolean checkLocked) {
		// returns true if state indicates that the unlock sequence can start/continue

		Log.i(FN(), "************* goodToAuth() checkLocked: " + checkLocked + " *************");

//		Log.i(FN(), "locked: " + locked + ", hsConnected: " + hsConnected + ", hsDonned: " + hsDonned + ", hsNear: " + hsNear + ", readyToSpeak: "
//				+ readyToSpeak + ", aboutToSpeak: " + aboutToSpeak + ", speaking: " + speaking + ", tts.isSpeaking(): " + tts.isSpeaking()
//				+ ", listening: " + listening + ", lockActivity: " + LockActivity.lockActivity + ", users.size(): " + users.size() + ", aboutToUnlock: " + aboutToUnlock);
//
//		if (locked && hsConnected && hsDonned && hsNear && readyToSpeak && !speaking && !tts.isSpeaking()
//				&& !aboutToSpeak && !listening && (LockActivity.lockActivity != null) && (users.size()>0) && !aboutToUnlock) {

		Log.i(FN(), "hsConnected: " + hsConnected + ", hsDonned: " + hsDonned + ", hsNear: " + hsNear + ", readyToSpeak: " + readyToSpeak
				+ ", aboutToSpeak: " + aboutToSpeak + ", speaking: " + speaking + ", tts.isSpeaking(): " + tts.isSpeaking() + ", listening: " + listening
				+ ", lockActivity: " + LockActivity.lockActivity + ", users.size(): " + users.size() + ", aboutToUnlock: " + aboutToUnlock
				+ ", deviceIsLocked: " + deviceIsLocked() + ", settingsActivity: " + (SettingsActivity.settingsActivity != null));

		if (hsConnected && hsDonned && hsNear && readyToSpeak && !speaking && !tts.isSpeaking() && !aboutToSpeak && !listening && (!checkLocked || deviceIsLocked())
				&& (users.size()>0) && !aboutToUnlock && (SettingsActivity.settingsActivity == null)) {
			Log.i(FN(), "(go)");
			return true;
		}
		Log.i(FN(), "(no go)");
		return false;
	}

	private boolean checkAbort() {
		Log.i(FN(), "************* checkAbort() *************");

//		Log.i(FN(), "hsDonned: " + hsDonned + ", hsConnected: " + hsConnected + ", hsNear: " + hsNear
//				+ ", aboutToSpeak: " + aboutToSpeak + ", lockActivity: " + LockActivity.lockActivity + ", aboutToUnlock: " + aboutToUnlock);
//
//		if (((((!hsDonned || !hsConnected || !hsNear) && !aboutToSpeak) || (LockActivity.lockActivity == null)) && !aboutToUnlock) && locked) { //ew

		Log.i(FN(), "hsDonned: " + hsDonned + ", hsConnected: " + hsConnected + ", hsNear: " + hsNear + ", aboutToSpeak: " + aboutToSpeak + ", lockActivity: "
				+ LockActivity.lockActivity + ", aboutToUnlock: " + aboutToUnlock + ", deviceIsLocked: " + deviceIsLocked()
				+ "settingsActivity: " + (SettingsActivity.settingsActivity != null));

			if ((((((!hsDonned || !hsConnected || !hsNear) && !aboutToSpeak) || !deviceIsLocked()) && !aboutToUnlock) && deviceIsLocked())
					|| (SettingsActivity.settingsActivity != null) && !aboutToUnlock) { //ew
			runOnMainThread(new Runnable() {
				@Override
				public void run() {
					Log.i(FN(), "************* Ending unlock sequence. *************");
					cancelAuthentication(false);
					lockScreen();
				}
			});

			return true;
		}
		return false;
	}

	private void checkLockScreen() {
		Log.i(FN(), "************* checkLockScreen() *************");

		if (!inAuthSequence && !hsNear) {
			lockScreen();
		}
	}

	private void cancelAuthentication(boolean delayLockedUI) {
		Log.i(FN(), "************* cancelAuthentication() *************");

		cancelAllTimed();
		tts.stop();
		sr.stopListening();
		stopSpeaking();
		listening = false;
		//aboutToSpeak = false;
		speaking = false;
		waitingForUsername = false;
		waitingForPassphrase = false;
		inAuthSequence = false;
		aboutToUnlock = false;
		aboutToSpeak = false;
		if ((LockActivity.lockActivity != null) && !delayLockedUI) {
			LockActivity.lockActivity.setUILocked();
		}
	}

	private void userAuthenticated() {
		Log.i(FN(), "************* userAuthenticated() *************");

		if (LockActivity.lockActivity != null) {
			LockActivity.lockActivity.setUIPassphrase(spokenUsername, true);
		}
		startSpeaking("Thank you. Access granted.", UTTERANCE_AUTHENTICATED);
		aboutToUnlock = true;
		runTimed(new Runnable() {
			@Override
			public void run() {
				unlockScreen();
			}
		}, 2200, TIMED_UNLOCK_SCREEN);
		waitingForUsername = false;
		waitingForPassphrase = false;
		spokenUsername = null;
		inAuthSequence = false;
	}

	private void lockScreen() {
		Log.i(FN(), "lockScreen() locked: " + locked);

		if (!deviceIsLocked()) {
			Log.i(FN(), "************* Locking the screen! (resuming) *************");
			if (LockActivity.lockActivity != null) {
				LockActivity.lockActivity.setUILocked();
			}
			cancelAllTimed();

			Intent intent = new Intent(context, LockActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			context.startActivity(intent);
		}

		locked = true;
	}

	public void unlockScreen() {
		Log.i(FN(), "unlockScreen()");

		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				sr.stopListening();
				stopSpeaking();
				//if (locked) {
				if (deviceIsLocked()) {
					Log.i(FN(), "************* Unlocking the screen! *************");
					lockOnPause = false;
					if (LockActivity.lockActivity != null) {
						LockActivity.lockActivity.finish();
					}
				}
				locked = false;
			}
		});
	}

	private void lockDevice() {
		Log.i(FN(), "************* Locking the device! *************");

		if ((dpm != null) && (deviceAdmin != null)) {
			Log.i(FN(), "(locking)");
			if (dpm.isAdminActive(deviceAdmin)) {
				dpm.lockNow();
			}

			PowerManager pm = (PowerManager)this.getSystemService(Context.POWER_SERVICE);
			PowerManager.WakeLock wl = pm.newWakeLock(PowerManager.FULL_WAKE_LOCK | PowerManager.ACQUIRE_CAUSES_WAKEUP, "DX650 Screen Lock");

			wl.acquire();
			wl.release();
		}
	}

	private void startListening() {

		Log.i(FN(), "************* startListening *************");

		listening = true;
		Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
		intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
		intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, "voice.recognition.DX650ScreenLock");
		intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 10);
		//intent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
		sr.startListening(intent);

//		AudioManager audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
//		audioManager.playSoundEffect(AudioManager.FX_FOCUS_NAVIGATION_UP);

		// schedule a timer that will check that the recognition gets something, otherwise ask again
		runTimed(new Runnable() {
			@Override
			public void run() {
				runOnMainThread(new Runnable() {
					@Override
					public void run() {
						Log.i(FN(), "************* Speech recognition timed out. *************");
						sr.cancel();
						listening = false;
						checkForSpeechRecognitionError();
					}
				});
			}
		}, 5000, TIMED_SPEECH_REC_TIMEOUT);
	}

	private void checkForSpeechRecognitionError() {

		cancelTimed(TIMED_SPEECH_REC_TIMEOUT);

		if (!checkAbort()) {

			if (waitingForUsername) {
				notHeardUsernameAttempts++;
				switch (notHeardUsernameAttempts) {
					case 1:
						startSpeaking("I'm sorry, I didn't catch that. Please say your username again.", UTTERANCE_USERNAME);
						break;
					default:
						startSpeaking("I'm sorry, I still didn't catch that. Please say your username again.", UTTERANCE_USERNAME);
						break;
				}
			}
			else if (waitingForPassphrase) {
				notHeardPassphraseAttempts++;
				switch (notHeardPassphraseAttempts) {
					case 1:
						startSpeaking("I'm sorry, I didn't catch that. Please say your passphrase again.", UTTERANCE_PASSPHRASE);
						break;
					case 2:
						startSpeaking("I'm sorry, I still didn't catch that. Please say your passphrase again.", UTTERANCE_PASSPHRASE);
						break;
					case 3:
						startSpeaking("I'm sorry, I still didn't catch that. Please say your passphrase one more time.", UTTERANCE_PASSPHRASE);
						break;
					default:
						waitingForPassphrase = false;
						waitingForUsername = true;
						unknownUsernameAttempts = 0;
						notHeardUsernameAttempts = 0;
						notHeardPassphraseAttempts = 0;
						wrongPassphraseAttempts = 0;
						if (LockActivity.lockActivity != null) {
							LockActivity.lockActivity.setUIUsername();
						}
						startSpeaking("Let's start over. Please say your username.", UTTERANCE_USERNAME);
						break;
				}
			}
		}
	}

	private void setupAudio() {
		//AudioManager audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
		//audioManager.setMode(AudioManager.MODE_IN_CALL);
		//audioManager.startBluetoothSco();
		//audioManager.setBluetoothScoOn(true);
		//audioManager.setSpeakerphoneOn(true);
		//audioManager.setMicrophoneMute(false);

//		try {
//			Class audioSystemClass = Class.forName("android.media.AudioSystem");
//			Method setForceUse = audioSystemClass.getMethod("setForceUse", int.class, int.class);
//// First 1 == FOR_MEDIA, second 1 == FORCE_SPEAKER. To go back to the default
//// behavior, use FORCE_NONE (0).
//			setForceUse.invoke(null, 1, 0);
//		}
//		catch (Exception e) {
//			Log.i(FN(), e.toString());
//		}

//		audioManager.setSpeakerphoneOn(true);
//		audioManager.setRouting(AudioManager.MODE_CURRENT, AudioManager.ROUTE_SPEAKER, AudioManager.ROUTE_ALL);
//		audioManager.setMode(AudioManager.MODE_CURRENT);
	}

	private void startSpeaking(String text, String utteranceID) {

		Log.i(FN(), "************* startSpeaking: " + text + " *************");

		tts.stop();

		if (!checkAbort()) {

			//stopSpeaking();
			aboutToSpeak = false;
			speaking = true;
			HashMap<String, String> params = new HashMap<String, String>();
			params.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, utteranceID);
			params.put(TextToSpeech.Engine.KEY_PARAM_STREAM, String.valueOf(AudioManager.STREAM_MUSIC)); //STREAM_MUSIC
			AudioManager audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
			audioManager.requestAudioFocus(null, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN);
			tts.speak(text, TextToSpeech.QUEUE_FLUSH, params);

			if (utteranceID.equals(UTTERANCE_USERNAME)) {
				runTimed(new Runnable() {
					@Override
					public void run() {
						if (LockActivity.lockActivity != null) {
							LockActivity.lockActivity.setUIUsername();
						}
					}
				}, 6200, TIMED_START_SPEAKING);
			}
			else if (utteranceID.equals(UTTERANCE_PASSPHRASE)) {

			}
		}
		else {
			Log.i(FN(), "Nevermind, aborted.");
		}
	}

	private void stopSpeaking() {
		Log.i(FN(), "stopSpeaking()");

		AudioManager audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
		audioManager.abandonAudioFocus(null);
	}

	private boolean checkUsername(String username) {
		// lookup all usernames and compare to 'username'
		for (int i = 0; i<users.size(); ++i) {
			User user = users.get(i);
			if (user.getUsername().toLowerCase().equals(username.toLowerCase())) {
				return true;
			}
		}
		return false;
	}

	private boolean checkPassword(String username, String password) {
		// lookup the correct password for 'spokenUsername' and compare to 'password'
		for (int i = 0; i<users.size(); ++i) {
			User user = users.get(i);
			if (user.getUsername().toLowerCase().equals(username.toLowerCase())) {
				if (user.getPassphrase().toLowerCase().equals(password.toLowerCase())) {
					return true;
				}
			}
		}
		return false;
	}

	private void runOnMainThread(Runnable runnable) {
		final Handler handler = new Handler(Looper.getMainLooper());
		handler.post(runnable);

		//runOnMainThread(runnable);
	}

	private void runTimed(final Runnable runnable, long delay, String id) {
		Log.i(FN(), "runTimed: " + id);

		NamedTimerTask task = new NamedTimerTask(id) {
			@Override
			public void run() {
				runnable.run();
				//timerTasks.remove(task);
			}
		};

		timerTasks.add(task);

		Timer timer = new Timer();
		timer.schedule(task, delay);
	}

	private void cancelTimed(String id) {
		Log.i(FN(), "cancelTimed: " + id);

		if (timerTasks != null) {
			for (int i=0; i<timerTasks.size(); i++) {
				NamedTimerTask task = timerTasks.get(i);
				if (task != null) {
					if (task.getIdentifier().equals(id)) {
						task.cancel();
						Log.i(FN(), "Canceled.");
					}
				}
			}
		}
		else {
			Log.i(FN(), "timedTasks is null!");
		}
	}

	private void cancelAllTimed() {
		Log.i(FN(), "cancelAllTimed()");

		if (timerTasks != null) {
			for (int i=0; i<timerTasks.size(); i++) {
				NamedTimerTask task = timerTasks.get(i);
				if (task != null) {
					task.cancel();
				}
			}
		}
		else {
			Log.i(FN(), "timedTasks is null!");
		}
	}

	private void queryWearingState() {
		Log.i(FN(), "queryWearingState");

		short id = Definitions.Settings.WEARING_STATE_SETTING;
		DeviceSetting ds = mController.getSetting(mLocalDevice, id, null) ;
		if (ds != null) {
			HeadsetDeviceSetting hds = new HeadsetDeviceSetting(ds, new HeadsetDataDevice(mLocalDevice.getAddress()));
			SettingTask task = new SettingTask();
			task.execute(hds);
		}
		else {
			Log.e(FN(), "Setting WEARING_STATE_SETTING for device " + mLocalDevice + "doesn't exist.");
		}
	}

	private void updateWearingState(Boolean on) {
		Log.e(FN(), "updateWearingState: " + on);

		hsDonned = on;
		if (on) {
			setupAudio();
		}
		checkStartAuthSequence();
	}

	private void updateSignalStrength(int strength) {

		// low-pass the SignalStrength
		hsSignalStrength = (int)Math.round(strength * SIGNALSTRENGTH_FILTER_CONSTANT + hsSignalStrength * (1.0 - SIGNALSTRENGTH_FILTER_CONSTANT));

		Log.d(TAG, "hsSignalStrength: " + hsSignalStrength + " (" + hsNearSignalStrengthThreshold + ", " + hsFarSignalStrengthThreshold + ")");

		if (hsSignalStrength <= hsNearSignalStrengthThreshold) {
			if (!hsNear) {
				Log.e(FN(), "************* Headset NEAR! *************");
			}
			hsNear = true;
			checkStartAuthSequence();
		}
		else if (hsSignalStrength >= hsFarSignalStrengthThreshold) {
			if (hsNear) {
				Log.e(FN(), "************* Headset FAR! *************");
			}
			hsNear = false;
			locked = false;
			checkAbort();
			checkLockScreen();
		}
	}

//	private void askAddUser() {
//		AlertDialog askDialog= new AlertDialog.Builder(this).create();
//		askDialog.setTitle("Add User");
//		askDialog.setMessage("Please add a new user before continuing.");
//		askDialog.setButton("Yes", new DialogInterface.OnClickListener() {
//			public void onClick(DialogInterface dialog, int which) {
//				Log.i(FN(), "Yes");
//				showSettings();
//			}
//		});
//		askDialog.setIcon(R.drawable.ic_launcher);
//		askDialog.show();
//	}

	private int numberOfMeAlive() {
		Log.i(FN(), "numberOfMeAlive()");

		ActivityManager am = (ActivityManager)this.getSystemService(ACTIVITY_SERVICE);
		List<RunningAppProcessInfo> apps = am.getRunningAppProcesses();
		Iterator<RunningAppProcessInfo> i = apps.iterator();
		int instances = 0;

		while(i.hasNext()) {
			RunningAppProcessInfo info = (i.next());
			if (info.processName.toString().contains("com.plantronics.DX650ScreenLock")) {
				instances++;
			}
		}
		return instances;
	}

	/* ****************************************************************************************************
			BindListener
	*******************************************************************************************************/

	@Override
	public void bindSuccess() {
		Log.i(FN(), "************* bindSuccess() *************");
		isBoundToService = true;
	}

	@Override
	public void bindFailed() {
		Log.e(FN(), "bindFailed()");
	}

	@Override
	public void unbind() {
		Log.i(FN(), "unbind()");
	}

	@Override
	public void serviceConnected() {
		Log.i(FN(), "************* serviceConnected() *************");

		isBoundToService = true;
		mController.registerServiceCallbacks();
		Log.i(FN(), "discovering: " + discovering + ", mLocalDevice null: " + (mLocalDevice!=null) + ", device open? " + mController.isbDeviceOpen(mLocalDevice));
		if (!discovering && ((mLocalDevice == null) || ((mLocalDevice != null) && !mController.isbDeviceOpen(mLocalDevice)))) {
			Log.i(FN(), "(actually doing discovery)");
			doDiscovery();
		}
		else {
			Log.i(FN(), "(nevermind...)");
		}
	}

	@Override
	public void serviceDisconnected() {
		Log.e(FN(), "************* serviceDisconnected() *************");
	}

	/* ****************************************************************************************************
			DiscoveryListener
	*******************************************************************************************************/

	@Override
	public void foundDevice(final String name) {
		Log.i(FN(), "************* foundDevice: " + name +" *************");

		if (!deviceDiscovered) {
			deviceDiscovered = true;

			BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(name);
			mDeviceAddress = device.getAddress();
		}
		else {
			Log.i(FN(), "Already found a device.");
		}
	}

	@Override
	public void discoveryStopped(int res) {
		Log.i(FN(), "discoveryStopped()");

		discovering = false;
		if (deviceDiscovered) {
			if (mController.isbServiceConnectionOpen()) {
				connectToDevice(mDeviceAddress);
			}
			else {
				Log.e(FN(), "************* Connection to the service is not open!!! *************");
			}
		}
		else {
			Log.i(FN(), "************* No devices found. Restarting discovery... *************");
			runTimed(new Runnable() {
				@Override
				public void run() {
					doDiscovery();
				}
			}, 2000, TIMED_START_DISCOVERY);
		}
	}

	/* ****************************************************************************************************
			HeadsetServiceConnectionListener
	*******************************************************************************************************/

	@Override
	public void deviceOpen(final HeadsetDataDevice device) {
		Log.i(FN(), "************* deviceOpen: " + device + " *************");

		hsConnected = true;

		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				Toast.makeText(getApplicationContext(), "Connection open.", Toast.LENGTH_SHORT).show();
				startListeningForEvents();
				startMonitoringProximity(true);
				queryWearingState();
			}
		});
		if (LockActivity.lockActivity != null) {
			LockActivity.lockActivity.setUIDiscovery(false);
		}
	}

	@Override
	public void openFailed(final HeadsetDataDevice device) {
		Log.i(FN(), "************* openFailed: " + device + " *************");

		runOnMainThread(new Runnable() {
			@Override
			public void run() {

				hsConnected = false;
				Toast.makeText(getApplicationContext(), "Connection failed.", Toast.LENGTH_SHORT).show();
				if (!discovering) {
					runTimed(new Runnable() {
						@Override
						public void run() {
							doDiscovery();
						}
					}, 1500, TIMED_START_DISCOVERY);
				}
			}
		});
	}

	@Override
	public void deviceClosed(final HeadsetDataDevice device) {
		Log.i(FN(), "************* deviceClosed:" + device + " *************");

		runOnMainThread(new Runnable() {
			@Override
			public void run() {

				hsConnected = false;
				Toast.makeText(getApplicationContext(), "Connection closed.", Toast.LENGTH_SHORT).show();
				if (!discovering) {
					runTimed(new Runnable() {
						@Override
						public void run() {
							doDiscovery();
						}
					}, 1500, TIMED_START_DISCOVERY);
				}
			}
		});
	}

	/* ****************************************************************************************************
			HeadsetServiceBluetoothListener
	*******************************************************************************************************/

	public void onBluetoothConnected(String bdaddr) {
		Log.i(FN(), "************* onBluetoothConnected() *************");
	}

	public void onBluetoothDisconnected(String bdaddr) {
		Log.i(FN(), "************* onBluetoothDisconnected() *************");
	}

	/* ****************************************************************************************************
			RecognitionListener
	*******************************************************************************************************/

	public void onReadyForSpeech(Bundle params) {
		Log.i(FN(), "************* onReadyForSpeech *************");
	}

	public void onBeginningOfSpeech() {
		Log.i(FN(), "************* onBeginningOfSpeech *************");
	}

	public void onRmsChanged(float rmsdB) {
		//Log.d(TAG, "onRmsChanged");
	}

	public void onBufferReceived(byte[] buffer) {
		//Log.d(TAG, "onBufferReceived");
	}

	public void onEndOfSpeech() {
		Log.i(FN(), "************* onEndofSpeech *************");
	}

	public void onError(int error) {
		Log.i(FN(), "************* onError: " + error + " *************");

		switch (error) {
			case SpeechRecognizer.ERROR_NO_MATCH:
			case SpeechRecognizer.ERROR_SPEECH_TIMEOUT:
				Log.i(FN(), "************* No speech match/timeout *************");
				runOnMainThread(new Runnable() {
					@Override
					public void run() {
						sr.cancel();
						listening = false;
						checkForSpeechRecognitionError();
					}
				});
				break;
			default:
				Log.i(FN(), "************* on(speech recognition)Error: " + error + "*************");
				break;
		}
	}

	public void onPartialResults(Bundle bundle) {
		//Log.d(TAG, "onPartialResults");
	}

	public void onResults(Bundle results) {
		Log.i(FN(), "************* onResults() *************");

		sr.stopListening();
		cancelTimed(TIMED_SPEECH_REC_TIMEOUT);
		listening = false;
		if (!checkAbort()) {
			ArrayList data = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
			for (int i = 0; i < data.size(); i++) {
				Log.i(FN(), "============== " + data.get(i) + " ==============");
			}

			boolean user = ((spokenUsername == null) || waitingForUsername);
			boolean pass = waitingForPassphrase;
			boolean gotIt = true;
			String str = new String();
			for (int i = 0; i < data.size(); i++) {
				str = (String)data.get(i);

				if ((spokenUsername == null) || waitingForUsername) {
					if (checkUsername(str)) {
						spokenUsername = str.toLowerCase();
						waitingForUsername = false;
						if (LockActivity.lockActivity != null) {
							LockActivity.lockActivity.setUIPassphrase(spokenUsername, true);
						}
						runTimed(new Runnable() {
							@Override
							public void run() {
								if (LockActivity.lockActivity != null) {
									LockActivity.lockActivity.setUIPassphrase(spokenUsername, false);
								}
							}
						}, 2900, TIMED_SETUIPASSWORD);
						startSpeaking("Hi " + str + ". Please say your passphrase.", UTTERANCE_PASSPHRASE);
						waitingForPassphrase = true;
						gotIt = true;
						i = 1000000; // this is the only thing that works?????
					}
					else {
						gotIt = false;
					}
				}
				else if (waitingForPassphrase) {
					if (checkPassword(spokenUsername, str)) {
						userAuthenticated();
						gotIt = true;
						i = 1000000; // this is the only thing that works?????
					}
					else {
						gotIt = false;
					}
				}
			}

			Log.i(FN(), "user: " + user);

			if (user) {
				if (!gotIt) {
					unknownUsernameAttempts++;
					switch (unknownUsernameAttempts) {
						case 1:
							startSpeaking("I'm sorry, I don't recognize that username. Please say your username again.", UTTERANCE_USERNAME);
							break;
						default:
							startSpeaking("I'm sorry, I still don't recognize that username. Please say your username again.", UTTERANCE_USERNAME);
							break;
					}
				}
			}
			else if (pass) {
				if (!gotIt) {
					wrongPassphraseAttempts++;
					switch (wrongPassphraseAttempts) {
						case 1:
							startSpeaking("I'm sorry, that's not the correct passphrase. Please say your passphrase.", UTTERANCE_PASSPHRASE);
							break;
						case 2:
							startSpeaking("I'm sorry, that's still not the correct passphrase. Please say your passphrase.", UTTERANCE_PASSPHRASE);
							break;
						case 3:
							startSpeaking("I'm sorry, that's still not the correct passphrase. Please say your passphrase one more time.", UTTERANCE_PASSPHRASE);
							break;
						default:
							waitingForPassphrase = false;
							waitingForUsername = true;
							unknownUsernameAttempts = 0;
							notHeardUsernameAttempts = 0;
							notHeardPassphraseAttempts = 0;
							wrongPassphraseAttempts = 0;
							startSpeaking("Let's start over. Please say your username.", UTTERANCE_USERNAME);
							break;
					}
				}
			}
		}
	}

	public void onEvent(int eventType, Bundle params) {
		Log.i(FN(), "************* onEvent *************");
	}

	/* ****************************************************************************************************
			OnInitListener
	*******************************************************************************************************/

	@Override
	public void onInit(int status) {

		if (status == TextToSpeech.SUCCESS) {
			int result = tts.setLanguage(Locale.US);
			if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
				Log.e(FN(), "This Language is not supported.");
			}
			else {
				tts.setSpeechRate((float)1.15);
				tts.setOnUtteranceCompletedListener(this);
			}

			Log.i(FN(), "************* Ready to speak *************");

//			HashMap <String, String> params = new HashMap<String, String>();
//			params.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, "voice.tts.DX650ScreenLock.silence");
//			tts.playSilence(10, TextToSpeech.QUEUE_FLUSH, params);

			readyToSpeak = true;
			checkStartAuthSequence();
		}
		else {
			Log.e(FN(), "Initilization Failed!");
		}
	}

	/* ****************************************************************************************************
			OnUtteranceCompletedListener
	*******************************************************************************************************/

	public void onUtteranceCompleted(final String utteranceId) {

		Log.i(FN(), "************* onUtteranceCompleted: " + utteranceId + " *************");
		speaking = false;

		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (!utteranceId.contentEquals(UTTERANCE_AUTHENTICATED)) {
					if (!checkAbort()) {
						//aboutToSpeak = false;
						Log.i(FN(), "waitingForUsername: " + waitingForUsername + ", waitingForPassphrase: " + waitingForPassphrase);
						if (utteranceId.contentEquals(UTTERANCE_USERNAME)) {
							startListening();
						}
						else if (utteranceId.contentEquals(UTTERANCE_PASSPHRASE))
							startListening();
					}
				}
			}
		});
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
			Log.i(FN(), "Executing the CommandTask ");
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
				Log.i(FN(), "Result returned=" + values[0].getResultCode());
				Log.i(FN(), "The result=" + values[0].getResultString());
			}
			else {
				Log.i(FN(), values[0].getResultString());
				if (values[0].getResultCode() == 4 ) {
					Log.e(FN(), "************************** CommandTask: execute the saved Task **************************" );
					//createSignalStrengthCommandObject(bToggleSignalStrength);
				}
			}
		}

		// Call the perform() method to execute the Command on the headset
		@Override
		protected Integer doInBackground(HeadsetDeviceCommand... deviceCommands) {
			int res = -1;
			RemoteResult remoteRes = new RemoteResult();
			Log.e(FN(), "doInBack: received args" + deviceCommands);
			if (!mController.isbDeviceOpen(mLocalDevice))  {
				Log.e(FN(), "device is not open, saving Command Task");
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

			//bToggleSignalStrength = !bToggleSignalStrength;
			// set the screen with the result display
		}

		// in case the connection was not open, this callback will be called
		// Its a hack with value - 4  (I just want to distinguish between actual result returned from
		// the execution of the perform(..cmd ..)  and  the case where BR connection got established successfully
		// it can be handled better
		@Override
		public void deviceOpen(final HeadsetDataDevice device) {
			Log.e(FN(), "CommandTask: device opened");
			RemoteResult result = new RemoteResult(4, "Device Open");
			publishProgress(result);
		}

		// again the hack with value 2 returned as open failed so that
		// onProgressUpdate() can act on it
		@Override
		public void openFailed(final HeadsetDataDevice device) {
			Log.e(FN(), "CommandTask: device open failed");
			RemoteResult result = new RemoteResult(2, "Device Open Failed");
			publishProgress(result);
		}

		// again the hack with value 2 returned as open failed so that
		// onProgressUpdate() can act on it
		@Override
		public void deviceClosed(final HeadsetDataDevice device) {
			Log.e(FN(), "CommandTask: device closed");
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
			Log.i(FN(), "Executing SettingTask");
			// print the command going to be executed
		}

		@Override
		public void result(int res, RemoteResult result) {
			Log.i(FN(), "result");
			//publishProgress(result);
		}

		@Override
		public void settingResult(int res, SettingsResult theResult) {
			Log.i(FN(), "settingResult");
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
				Log.i(FN(), "Result returned = " + values[0].getResultCode());

				if (values[0].getResultCode() < 0) {
					// error case
					Log.i(FN(), "The result = " + values[0].getResultString());
				}
				else {
					// successful result, print the Settings value returned in the fetch()
					//Log.i(FN(), "Settings = " + Arrays.asList(mResult).toString());
				}

				int settingType = settingsResult.getSetting().getType().getID();
				switch (settingType) {

					case Definitions.Settings.WEARING_STATE_SETTING: {
						Log.i(FN(), "settingsResult.getSetting().toString(): " + settingsResult.getSetting().toString());
						List resultList = Arrays.asList(settingsResult.getSetting().getValues());
						Log.i(FN(), "resultList: " + resultList);
						Boolean on = (resultList.get(0).toString() == "true");
						Log.i(FN(), "------------- Don/Doff Setting: " + on + " -------------");
						updateWearingState(on);
						break;
					}

					case Definitions.Settings.CALL_STATUS_SETTING: {
						Log.i(FN(), "settingsResult.getSetting().toString(): " + settingsResult.getSetting().toString());
						List resultList = Arrays.asList(settingsResult.getSetting().getValues());
						Log.i(FN(), "resultList: " + resultList);
						String status = resultList.get(0).toString();
						Log.i(FN(), "------------- Call Status Setting: " + status + " -------------");
						break;
					}

					case Definitions.Settings.CURRENT_SIGNAL_STRENGTH_SETTING:
						Log.i(FN(), "settingsResult.getSetting().toString(): " + settingsResult.getSetting().toString());
						List resultList = Arrays.asList(settingsResult.getSetting().getValues());
						Log.i(FN(), "resultList: " + resultList);
						String strength = resultList.get(0).toString();
						Log.i(FN(), "------------- Signal Strength Setting: " + strength + " -------------");
						break;
				}
			}
			else {
				// This is the case where Bladerunner connection was not opened
				// hence the result is whether we were successful to open the connection or not
				Log.i(FN(), values[0].getResultString());
				if (values[0].getResultCode() == 4) {
					// result code == 4 ; means that we were successful in opening connection
					// now execute the Setting request again
					Log.e(FN(), "************* CommandTask: execute the saved Task *************");
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
			Log.e(FN(), "doInBackground: received args" + deviceSettings);
			if (!mController.isbDeviceOpen(mLocalDevice)) {
				Log.e(FN(), "device is not open, saving Setting Task");
				// start the connection open process. It will result in asynchronous api callbacks handled from
				// deviceOpen() and openFailed()
				mController.open(mLocalDevice, this);

			}
			else {
				// connection is already open
				res = mController.fetch(deviceSettings[0].getDevice(), deviceSettings[0].getSetting(), remoteRes, this);
				// save the Setting result returned
				Log.e(FN(), "Copying setting - " + deviceSettings[0].getSetting().toString());

				//mResult = deviceSettings[0].getSetting().getValues();
				//Log.e(FN(), "Result=" + Arrays.asList(mResult).toString());
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
			Log.e(FN(), "SettingTask: device opened");
			RemoteResult result = new RemoteResult(4, "Device Open");
			publishProgress(result);

		}

		@Override
		public void openFailed(final HeadsetDataDevice device) {
			Log.e(FN(), "SettingTask: device open failed");
			RemoteResult result = new RemoteResult(2, "Device Open Failed");
			publishProgress(result);
		}

		@Override
		public void deviceClosed(final HeadsetDataDevice device) {
			Log.e(FN(), "SettingTask: device closed");
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
					String button = ((DeviceEvent)values[0]).getEventData()[0].toString();
					Log.i(FN(), "------------- Custom Button Event: " + button + " -------------");
					break;

				case Definitions.Events.WEARING_STATE_CHANGED_EVENT:
					boolean on = false;
					if (((DeviceEvent)values[0]).getEventData()[0].toString() == "true") on = true;
					Log.i(FN(), "------------- Don/Doff Event: " + on + " -------------");
					updateWearingState(on);

				case Definitions.Events.BATTERY_STATUS_CHANGED_EVENT:
					Log.i(FN(), "------------- Battery Status Event: " + Arrays.asList( ((DeviceEvent)values[0]).getEventData()).toString() + " -------------");
					break;

				case Definitions.Events.CALL_STATUS_CHANGE_EVENT:
					String status = ((DeviceEvent)values[0]).getEventData()[0].toString();
					Log.i(FN(), "------------- Call Status Event: " + status + " -------------");
					break;

				case Definitions.Events.SIGNAL_STRENGTH_EVENT:
					String strengthString = ((DeviceEvent)values[0]).getEventData()[1].toString();
					int strength = Integer.parseInt(strengthString); // this is stupid.
					Log.i(FN(), "------------- Signal Strength Event: " + strengthString + " -------------");
					updateSignalStrength(strength);
					break;

				case Definitions.Events.CONFIGURE_SIGNAL_STRENGTH_EVENT_EVENT:
					String enabled = ((DeviceEvent)values[0]).getEventData()[1].toString();
					Log.i(FN(), "------------- Configure Signal Strength Event: " + enabled + " -------------");
					break;

				case Definitions.Events.CONNECTED_DEVICE_EVENT:
					Byte remotePort = (Byte)(((DeviceEvent)values[0]).getEventData()[0]);
					Log.i(FN(), "------------- Remote device found on port " + remotePort + " -------------");
					break;

				case Definitions.Events.DISCONNECTED_DEVICE_EVENT:
					Byte disconnectPort = (Byte)(((DeviceEvent)values[0]).getEventData()[0]);
					Log.i(FN(), "------------- Remote device on port " + disconnectPort + " disconnected. -------------");
					// *************************************************************************************************************************
					// this shouldn't need to be here
					deviceClosed(mLocalDevice);
					// *************************************************************************************************************************

				default:
					Log.i(FN(), "------------- Other Event: " + values[0] + " -------------");
					break;
			}
		}

		// register to receive all Bladerunner Events
		@Override
		protected Integer doInBackground(HeadsetDataDevice... headsetDataDevices) {
			if (mController.registerEventListener(mLocalDevice, this)) {
				Log.i(FN(), "Registered for events.");
				return 0; // success
			}
			else {
				Log.e(FN(), "Device not open, failed to register for events.");
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

	public class NamedTimerTask extends TimerTask {

		private String identifier;

		NamedTimerTask(String id) {
			identifier = id;
		}

		public String getIdentifier() {
			return identifier;
		}

		public void setIdentifier(String id) {
			identifier = id;
		}

		@Override
		public void run() {

		}
	}
}
