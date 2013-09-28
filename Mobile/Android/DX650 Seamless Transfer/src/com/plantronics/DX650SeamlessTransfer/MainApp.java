/* ********************************************************************************************************
	MainApp.java
	com.plantronics.DX650SeamlessTransfer

	Created by mdavis on 05/31/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650SeamlessTransfer;

import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;
import android.os.*;
import android.os.RemoteException;
import android.util.Log;
import android.widget.Toast;
import com.cisco.telephony.*;
import com.plantronics.example.controller.HeadsetDataController;
import com.plantronics.example.controller.HeadsetDeviceCommand;
import com.plantronics.example.controller.HeadsetDeviceSetting;
import com.plantronics.example.controller.SettingsResult;
import com.plantronics.example.listener.*;
import com.plantronics.bladerunner.Definitions;
import com.plantronics.headsetdataservice.io.*;
import com.cisco.telephony.CiscoTelephonyManager.CiscoTelephonyManagerCall;
import com.cisco.telephony.CiscoTelephonyManager.CiscoTelephonyManagerCallInfo;
import com.cisco.telephony.CiscoTelephonyManager.CiscoTelephonyManagerCallInfo.CiscoTelephonyManagerCallInfoInvalidObject;
import com.cisco.telephony.CiscoTelephonyManager.CiscoTelephonyManagerDevice.CiscoTelephonyManagerDeviceInvalidObject;
import com.cisco.telephony.CiscoTelephonyManager.CiscoTelephonyManagerDeviceInfo;
import com.cisco.telephony.CiscoTelephonyManager.CiscoTelephonyManagerDeviceInfo.CiscoTelephonyManagerDeviceInfoInvalidObject;
import java.util.*;

public class MainApp extends Application
		implements BindListener, DiscoveryListener, HeadsetServiceConnectionListener, HeadsetServiceBluetoothListener {

	public static MainApp mainApp = null;
	private static final String TAG = "DX650SeamlessTransfer.MainApp";
	private static final double SignalStrength_FILTER_CONSTANT = .7;
	private static final int SIGNALSTRENGTH_NEAR_FAR_DELTA = 20;

	public static String PREFERENCES_THRESHOLD = "PREFERENCES_THRESHOLD";

	private enum CALL_STATE {
		CALl_STATE_IDLE,
		CALL_STATE_ACTIVE,
		CALL_STATE_RINGING,
		CALL_STATE_DIALING
	}

	private boolean hsConnected;
	private boolean hsNear;
	private boolean hsDonned;
	private int hsSignalStrength = 0;
	private int hsNearSignalStrengthThreshold = 60;
	private int hsFarSignalStrengthThreshold = hsNearSignalStrengthThreshold + SIGNALSTRENGTH_NEAR_FAR_DELTA;
	boolean askTransferActivityVisible;
	boolean askTransferActivityDismissed;

	private SharedPreferences preferences;
	private BluetoothAdapter mBluetoothAdapter;
	private static HeadsetDataController mController;
	private HeadsetDataDevice mLocalDevice;
	private String mDeviceAddress = "";
	private boolean isBoundToService = false;
	private boolean isConnectedToService = false;
	private boolean deviceDiscovered = false;
	private boolean discovering = false;
	private byte mRemoteDevicePort = -1;
	private String mRemoteDeviceAddress;
	private HeadsetDataDevice mRemoteDevice;
	private boolean remoteDeviceConnected = false;
	private CALL_STATE remoteDeviceCallState = CALL_STATE.CALl_STATE_IDLE;

	private CiscoTelephonyManager manager = null;
	private CiscoTelephonyManager.CiscoTelephonyManagerDeviceListener deviceListener = null;
	private CiscoTelephonyManager.CiscoTelephonyManagerCallListener callListener = null;

	private String ciscoCallState;

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
		Log.i(FN(), "************* onCreate() *************");
		super.onCreate();
		mainApp = this;

		mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
		mController = HeadsetDataController.getHeadsetControllerSingleton(this);
		if (mController.bindHeadsetDataService(this) == 2) {
			Log.i(FN(), "Service already bound: register callbacks with the service.");
			isBoundToService = true;
			mController.registerServiceCallbacks();
		}

		manager = getCiscoTelephonyManager();

		callListener = manager.new CiscoTelephonyManagerCallListener() {
			@Override
			public void onCallEvent(CallEventID eventId, CiscoTelephonyManagerCall call, CiscoTelephonyManagerCallInfo callInfo) {
				try {
					Log.i(FN(),
							"CUCMMode:"
									+ manager.getCiscoTelephonyManagerDevice()
									.getDeviceInfo().getCUCMMode()
									+ " # of calls:"
									+ manager.getCiscoTelephonyManagerDevice()
									.getDeviceInfo().getCalls().size()
									+ " isPhoneIdle:"
									+ manager.getCiscoTelephonyManagerDevice()
									.getDeviceInfo().isPhoneIdle());

					Log.e(FN(), "============================== call state: " + callInfo.getCallState() + " ==============================");

					ciscoCallState = callInfo.getCallState().toString();

					if (callInfo.getCallState().toString().contentEquals(CallStateEnum.REMCONNECTED.toString())) {
//						Log.i(FN(), "************* REMCONNECTED, killing BT audio! *************");

						// this apparently turns off the connection on both ends
//						runDelayed(new Runnable() {
//							@Override
//							public void run() {
//								Log.i(FN(), "Attempting to kill headset audio...");
//								AudioManager audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
//								audioManager.setBluetoothScoOn(false);
//								audioManager.stopBluetoothSco();
//								//audioManager.setMode(AudioManager.MODE_NORMAL);
//								//audioManager.setSpeakerphoneOn(false);
//							}
//						}, 500);
					}
					else if (callInfo.getCallState().toString().contentEquals(CallStateEnum.REMHOLD.toString())) {
						Log.i(FN(), "************* REMHOLD, resuming call! *************");
						try {
							call.resume(MediaDirection.MEDIA_DIRECTION_SENDRCV);//MEDIA_DIRECTION_RECV
						}
						catch (CiscoTelephonyManagerCall.CiscoTelephonyManagerCallInvalidObject e) {
							Log.i(FN(), "resume() e: " + e);
						}
					}
				}
				catch (CiscoTelephonyManagerDeviceInfoInvalidObject e) {
					e.printStackTrace();
				}
				catch (CiscoTelephonyManagerDeviceInvalidObject e) {
					e.printStackTrace();
				}
				catch (CiscoTelephonyManagerCallInfoInvalidObject e) {
					e.printStackTrace();
				}
			}
		};

		try {
			manager.getCiscoTelephonyManagerDevice().addListener(deviceListener);
			manager.getCiscoTelephonyManagerDevice().addCallListener(callListener);
			Log.i(FN(),"Successfully added Call and Device Listeners");

			startLineListeners();
		}
		catch (CiscoTelephonyManagerDeviceInvalidObject e) {
			e.printStackTrace();
		}
	}

	@Override
	public void onTerminate() {
		Log.i(FN(), "************* onTerminate() *************");

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
		try {
			manager.getCiscoTelephonyManagerDevice().removeListener(deviceListener);
			manager.getCiscoTelephonyManagerDevice().removeCallListener(callListener);
			Log.i(FN(),"Successfully removed Call and Device Listeners");

			removeLineListeners();
		}
		catch (CiscoTelephonyManagerDeviceInvalidObject e) {
			e.printStackTrace();
		}
		catch (NullPointerException npe) {
			npe.printStackTrace();
		}

		super.onTerminate();
	}

//	@Override
//	public void onActivityResult(int requestCode, int resultCode, Intent data) {
//		super.onActivityResult(requestCode, resultCode, data);
//
//		Log.i(FN(), "************* onActivityResult() *************");
//
//		switch (requestCode) {
//			case AskTransferActivity.ASK_TRANSFER_ACTIVITY:
//				Log.i(FN(), "************* AskTransferActivity closed. *************");
//
//				Log.i(FN(), "resultCode: " + resultCode);
//				if (resultCode==RESULT_OK) {
//					Log.i(FN(), "************* Yes *************");
//				}
//				else {
//					Log.i(FN(), "************* No *************");
//				}
//
//				break;
//			default:
//				Log.e(FN(), "onActivityResult(): unknown request code: '"+requestCode+"'");
//		}
//	}

	/* ****************************************************************************************************
			Public
	*******************************************************************************************************/

	public void setPreferences(SharedPreferences thePrefs) {
		preferences = thePrefs;
	}

	public void transferActivityResult(boolean transfer) {
		Log.i(FN(), "transferActivityResult(): " + transfer);

		if (transfer) {
			endMobileCall();
		}
		else {
			// ?
		}
	}

	public void kill() {
		Log.i(FN(), "************* Terminating... *************");
		android.os.Process.killProcess(android.os.Process.myPid());
	}

	public int getHSSignalStrength() {
		return hsSignalStrength;
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void doDiscovery() {
		Log.i(FN(), "************* doDiscovery() *************");

		deviceDiscovered = false;
		//progressBar.setVisibility(android.widget.ProgressBar.INVISIBLE);
		try {
			discovering = true;
			mController.registerDiscoveryCallback();
			int ret =  mController.getBladeRunnerDevices();
			Log.i(FN(), "getBladeRunnerDevices() returned " + ret);
		}
		catch (RemoteException e) {
			discovering = false;
			e.printStackTrace();
		}
	}

	private HeadsetDataDevice connectToDevice(String deviceAddress, int devicePort) {
		Log.i(FN(), "************* Connecting to device " + deviceAddress + " on port " + devicePort + "... *************");

		mController.newDevice(mDeviceAddress, (byte) devicePort, this);
		//mController.newDevice(deviceAddress, this);
		HeadsetDataDevice device = new HeadsetDataDevice(deviceAddress, (byte)devicePort);
		int ret = mController.open(device, this);
		if (ret==1) {
			Log.i(FN(), "Device already open.");
		}
		return device;
	}

	private void startListeningForEvents(HeadsetDataDevice device) {
		Log.i(FN(), "startListeningForEvents");
		if (device == null) {
			Log.i(FN(), "Device is null!");
		}
		ReceiveEventTask task = new ReceiveEventTask();
		task.execute(device);
	}

	private void startMonitoringProximity(boolean enable) {
		Log.i(FN(), "************* startMonitoringProximity: " + enable + " *************");

		short id = Definitions.Commands.CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND;
		Object objs[] = new Object[10];

		objs[0] = (Byte)(byte)0; /* The connection ID of the link being used to generate the signal strength event. */
		objs[1] = (Boolean)enable;  /* enable - If true, this will enable the signal strength monitoring. */
		objs[2] = (Boolean)false;   /* If true, report near far events only when headset is donned. */
		objs[3] = (Boolean)false;  /* trend - If true don't use trend detection */
		objs[4] = (Boolean)false;  /* report rssi audio - If true, Report rssi and trend events in headset audio */
		objs[5] = (Boolean)false;  /* report near far audio - If true, report Near/Far events in headset Audio */
		objs[6] = (Boolean)true;  /* report near far to base - If true, report SignalStrength and Near Far events to base  */
		objs[7] = (Byte)(byte)5;  /* sensitivity - This number multiplies the dead_band value (currently 5 dB) in the headset configuration.
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

	private void checkAskTransfer() {

		Log.i(FN(), "checkAskTransfer");

//		AudioManager audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
//		audioManager.setRingerMode(AudioManager.RINGER_MODE_SILENT);

		// the second the SignalStrength hits the "near" threshold, show the dialog

		Log.i(FN(), "hsConnected: " + hsConnected + ", hsDonned: " + hsDonned + ", hsNear: " + hsNear + ", remoteDeviceConnected: "
				+ remoteDeviceConnected + ", (remoteDeviceCallState == CALL_STATE.CALL_STATE_ACTIVE): " + (remoteDeviceCallState == CALL_STATE.CALL_STATE_ACTIVE)
				+ ", settingsActivity: " + SettingsActivity.settingsActivity);
		if (hsConnected && hsDonned && hsNear && remoteDeviceConnected && (remoteDeviceCallState == CALL_STATE.CALL_STATE_ACTIVE)) {

			if (!askTransferActivityVisible && (AskTransferActivity.askTransferActivity == null) && !askTransferActivityDismissed) {

//				//audioManager.startBluetoothSco();
//				audioManager.setBluetoothScoOn(false);
//				//audioManager.setSpeakerphoneOn(false);

				Log.i(FN(), "******** Asking to transfer ********");

				askTransferActivityVisible = true;

				Intent intent = new Intent("intent.ask_transfer_activity");
				intent.setComponent(new ComponentName(getApplicationContext().getPackageName(), AskTransferActivity.class.getName()));
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				//startActivityForResult(intent, AskTransferActivity.ASK_TRANSFER_ACTIVITY);
				getApplicationContext().startActivity(intent);
			}
		}
		else {
			if ( !hsDonned || !hsConnected || !hsDonned || !remoteDeviceConnected || (remoteDeviceCallState != CALL_STATE.CALL_STATE_ACTIVE)) {
				if (AskTransferActivity.askTransferActivity != null) {
					Log.i(FN(), "******** Closing transfer dialog ********");
					AskTransferActivity.askTransferActivity.finish();
				}
				askTransferActivityDismissed = false;
				askTransferActivityVisible = false;
			}
		}
	}

	private void runOnMainThread(Runnable runnable) {
		final Handler handler = new Handler(Looper.getMainLooper());
		handler.post(runnable);

		//runOnUiThread(runnable);
	}

	private void runDelayed(Runnable runnable, int delay) {
		final Handler handler = new Handler(Looper.getMainLooper());
		handler.postDelayed(runnable, delay);
	}

//	private void scheduleTimer(final Runnable runnable, long delay) {
//		timerTask = new TimerTask() {
//			@Override
//			public void run() {
//				runnable.run();
//			}
//		};
//
//		Timer timer = new Timer();
//		timer.schedule(timerTask, delay);
//	}
//
//	private void cancelTimer() {
//		if (timerTask != null) {
//			timerTask.cancel();
//		}
//	}

	private void queryWearingState() {
		Log.i(FN(), "queryWearingState()");

		if (mLocalDevice == null) {
			Log.i(FN(), "Local device is null!");
		}

		short id = Definitions.Settings.WEARING_STATE_SETTING;
		DeviceSetting ds = mController.getSetting(mLocalDevice, id, null) ;
		HeadsetDeviceSetting hds = new HeadsetDeviceSetting(ds, mLocalDevice);
		SettingTask task = new SettingTask();
		task.execute(hds);
	}

	private void queryRemoteCallState() {
		Log.i(FN(), "queryRemoteCallState() ciscoCallState: " + ciscoCallState);

		// this has been problematic after a remote device disconnected and re-connects. swapping out for cisco call state

		if ((ciscoCallState != null) && ciscoCallState.contentEquals(CallStateEnum.REMCONNECTED.toString())) {
			Log.i(FN(), "REMCONNECTED");
			remoteDeviceCallState = CALL_STATE.CALL_STATE_ACTIVE;
		}
		else {
			remoteDeviceCallState = CALL_STATE.CALl_STATE_IDLE;
		}

		checkAskTransfer();

//		if (mRemoteDevice == null) {
//			Log.i(FN(), "Remote device is null!");
//		}
//		Log.i(FN(), "mRemoteDevice: " + mRemoteDevice);
//
//		short id = Definitions.Settings.CALL_STATUS_SETTING;
//		DeviceSetting ds = mController.getSetting(mRemoteDevice, id, null);
//		if (ds == null) {
//			Log.i(FN(), "ds is null");
//		}
//		Log.i(FN(), "ds: " + ds);
//		HeadsetDeviceSetting hds = new HeadsetDeviceSetting(ds, mRemoteDevice);
//		SettingTask task = new SettingTask();
//		task.execute(hds);
	}

	private void updateWearingState(Boolean on) {
		Log.i(FN(), "updateWearingState: " + on);

		hsDonned = on;
		checkAskTransfer();
	}

	private void endMobileCall() {
		Log.i(FN(), "endMobileCall()");

		Log.i(FN(), "mRemoteDevice: " + mRemoteDevice);
		Log.i(FN(), "Device open? " + mController.isbDeviceOpen(mRemoteDevice));

		short id = Definitions.Commands.CALL_END_COMMAND;
		DeviceCommand dc = mController.getCommand(mRemoteDevice, id, null) ;
		if (dc != null) {
			HeadsetDeviceCommand hdc = new HeadsetDeviceCommand(dc, mRemoteDevice);
			CommandTask task = new CommandTask();
			task.execute(hdc);
		}
		else {
			Log.e(FN(), "Command does not exist " + id);
		}
	}

	private void updateSignalStrength(int rssi) {
		// low-pass the SignalStrength
		hsSignalStrength = (int)Math.round(rssi * SignalStrength_FILTER_CONSTANT + hsSignalStrength * (1.0 - SignalStrength_FILTER_CONSTANT));

		Log.d(TAG, "hsSignalStrength: " + hsSignalStrength + " (" + hsNearSignalStrengthThreshold + ", " + hsFarSignalStrengthThreshold + ")");

		hsNearSignalStrengthThreshold = preferences.getInt(PREFERENCES_THRESHOLD, 60);
		hsFarSignalStrengthThreshold = hsNearSignalStrengthThreshold + SIGNALSTRENGTH_NEAR_FAR_DELTA;

		if (hsSignalStrength <= hsNearSignalStrengthThreshold) {
			hsNear = true;
		}
		else if (hsSignalStrength >= hsFarSignalStrengthThreshold) {
			hsNear = false;
		}

		queryWearingState();
		//checkAskTransfer();
	}

	public CiscoTelephonyManager getCiscoTelephonyManager() {
		Object service = this.getSystemService(CiscoTelephonyManager.CISCO_TELEPHONY_MANAGER);
		if (service instanceof IBinder) {
			IBinder bounder = (IBinder) service;
			CiscoTelephonyManager manager = new CiscoTelephonyManager(bounder);
			return manager;
		} else if(service instanceof CiscoTelephonyManager) {
			return (CiscoTelephonyManager) service;
		}
		else {
			return null;
		}
	}

	public void removeLineListeners() {
		try {
			CiscoTelephonyManagerDeviceInfo deviceInfo = manager.getCiscoTelephonyManagerDevice().getDeviceInfo();
			CiscoTelephonyManager.CiscoTelephonyManagerLineList lineList = deviceInfo.getLines();
			for(int i =0; i<lineList.size(); i++) {
				CiscoTelephonyManager.CiscoTelephonyManagerLine line = lineList.get(i);
				line.removeCallListener(callListener);
			}
		} catch (CiscoTelephonyManager.CiscoTelephonyManagerException e) {
			e.printStackTrace();
		}
	}

	public void startLineListeners() {
		try {
			CiscoTelephonyManagerDeviceInfo deviceInfo = manager.getCiscoTelephonyManagerDevice().getDeviceInfo();
			CiscoTelephonyManager.CiscoTelephonyManagerLineList lineList = deviceInfo.getLines();
			for(int i =0; i<lineList.size(); i++) {
				CiscoTelephonyManager.CiscoTelephonyManagerLine line = lineList.get(i);
				line.addCallListener(callListener);
			}
		} catch (CiscoTelephonyManager.CiscoTelephonyManagerException e) {
			e.printStackTrace();
		}
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

		if (!isConnectedToService) {
			isConnectedToService = true;
			Log.i(FN(), "Registering service callbacks...");
			mController.registerServiceCallbacks();
			doDiscovery();
		}
	}

	@Override
	public void serviceDisconnected() {
		Log.i(FN(), "************* serviceDisconnected() *************");
	}

	/* ****************************************************************************************************
			DiscoveryListener
	*******************************************************************************************************/

	@Override
	public void foundDevice(final String name) {
		Log.i(FN(), "************* foundDevice: " + name + "*************");

		if (!deviceDiscovered) {
			deviceDiscovered = true;
			runOnMainThread(new Runnable() {
				@Override
				public void run() {
					BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(name);
					mDeviceAddress = device.getAddress();

					if (mController.isbServiceConnectionOpen()) {
						mLocalDevice = connectToDevice(mDeviceAddress, 0);
					}
					else {
						Log.e(FN(), "************* Connection to the service is not open!!! *************");
					}
				}
			});
		}
		else {
			Log.i(FN(), "Already found a device.");
		}
	}

	@Override
	public void discoveryStopped(int res) {
		Log.i(FN(), "discoveryStopped()");

		discovering = false;
		if (!deviceDiscovered) {
			Log.i(FN(), "************* No devices found. Restarting discovery... *************");
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
		Log.i(FN(), "************* deviceOpen: " + device + " *************");

		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (device.getPort() == 0) {
					Log.i(FN(), "(local device)");
					checkAskTransfer();
					if (!hsConnected) {
						hsConnected = true;
						startListeningForEvents(device);
						startMonitoringProximity(true);
						queryWearingState();
					}
				}
				else if (device.getPort() == mRemoteDevicePort) {
					Log.i(FN(), "(remote device)");
					checkAskTransfer();
					if (!remoteDeviceConnected) {
						Log.i(FN(), "************* Ready to transfer *************");
						Toast.makeText(getApplicationContext(), "Ready to transfer.", Toast.LENGTH_SHORT).show();
						remoteDeviceConnected = true;
						mRemoteDevice = device;
						startListeningForEvents(device);
						queryRemoteCallState();
					}
				}
			}
		});
	}

	@Override
	public void openFailed(final HeadsetDataDevice device) {
		Log.i(FN(), "************* openFailed: " + device + "*************");

		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (device.getPort() == 0) {
					Log.i(FN(), "(local device)");
					Toast.makeText(getApplicationContext(), "Local connection failed.", Toast.LENGTH_SHORT).show();
					hsConnected = false;
					if (!discovering) {
						runDelayed(new Runnable() {
							@Override
							public void run() {
								doDiscovery();
							}
						}, 1500);
					}
				}
				else if (device.getPort() == mRemoteDevicePort) {
					Log.i(FN(), "(remote device)");
					Toast.makeText(getApplicationContext(), "Remote connection failed.", Toast.LENGTH_SHORT).show();
					remoteDeviceConnected = false;

					runDelayed(new Runnable() {
						@Override
						public void run() {
							connectToDevice(mRemoteDeviceAddress, mRemoteDevicePort);
						}
					}, 2000);
				}
			}
		});
	}

	@Override
	public void deviceClosed(final HeadsetDataDevice device) {
		Log.i(FN(), "************* deviceClosed:" + device + "*************");

		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (device.getPort() == 0) {
					Log.i(FN(), "(local device)");
					Toast.makeText(getApplicationContext(), "Local connection closed.", Toast.LENGTH_SHORT).show();
					hsConnected = false;
					if (!discovering) {
						runDelayed(new Runnable() {
							@Override
							public void run() {
								doDiscovery();
							}
						}, 1500);
					}
				}
				else if (remoteDeviceConnected && (device.getPort() == mRemoteDevicePort)) {
					mRemoteDevicePort = -1;
					mRemoteDeviceAddress = null;
					mRemoteDevice = null;
					remoteDeviceConnected = false;

					Log.i(FN(), "(remote device)");
					Toast.makeText(getApplicationContext(), "Remote connection closed.", Toast.LENGTH_SHORT).show();
					// wait for CONNECTED_DEVICE_EVENT
				}
			}
		});
	}

	/* ****************************************************************************************************
			HeadsetServiceBluetoothListener
	*******************************************************************************************************/

	public void onBluetoothConnected(String bdaddr) {
		Log.i(FN(), "onBluetoothConnected()");
	}

	public void onBluetoothDisconnected(String bdaddr) {
		Log.i(FN(), "onBluetoothDisconnected()");
		remoteDeviceCallState = CALL_STATE.CALl_STATE_IDLE;
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
	public class CommandTask extends AsyncTask<HeadsetDeviceCommand, RemoteResult, Integer>
			implements HeadsetServiceResponseListener, HeadsetServiceConnectionListener {

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

					case Definitions.Settings.CURRENT_SIGNAL_STRENGTH_SETTING: {
						Log.i(FN(), "settingsResult.getSetting().toString(): " + settingsResult.getSetting().toString());
						List resultList = Arrays.asList(settingsResult.getSetting().getValues());
						Log.i(FN(), "resultList: " + resultList);
						String strength = resultList.get(0).toString();
						Log.i(FN(), "------------- Signal Strength Setting: " + strength + " -------------");
						break;
					}

					case Definitions.Settings.CALL_STATUS_SETTING: {
						Log.i(FN(), "settingsResult.getSetting().toString(): " + settingsResult.getSetting().toString());
						List resultList = Arrays.asList(settingsResult.getSetting().getValues());
						Log.i(FN(), "resultList: " + resultList);
						String status = resultList.get(0).toString();
						Log.i(FN(), "------------- Call Status Setting: " + status + " -------------");
						// idle, active, ringing, dialing
						switch (Integer.parseInt(status)) {
							case 0:
								remoteDeviceCallState = CALL_STATE.CALl_STATE_IDLE;
								break;
							case 1:
								remoteDeviceCallState = CALL_STATE.CALL_STATE_ACTIVE;
								break;
							case 2:
								remoteDeviceCallState = CALL_STATE.CALL_STATE_RINGING;
								break;
							case 3:
								remoteDeviceCallState = CALL_STATE.CALL_STATE_DIALING;
								break;
						}
						checkAskTransfer();
						break;
					}

					default:
						Log.i(FN(), "------------- Other Setting: " + values[0] + " -------------");
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
//			if (!mController.isbDeviceOpen(mLocalDevice)) {
//				Log.e(FN(), "device is not open, saving Setting Task");
//				// start the connection open process. It will result in asynchronous api callbacks handled from
//				// deviceOpen() and openFailed()
//				mController.open(mLocalDevice, this);
//
//			}
//			else {
				// connection is already open
				res = mController.fetch(deviceSettings[0].getDevice(), deviceSettings[0].getSetting(), remoteRes, this);
				// save the Setting result returned
				Log.e(FN(), "Copying setting - " + deviceSettings[0].getSetting().toString());

				//mResult = deviceSettings[0].getSetting().getValues();
				//Log.e(FN(), "Result=" + Arrays.asList(mResult).toString());
				//publishProgress(remoteRes);
//			}
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
					Log.i(FN(), "------------- Remote device connected on port " + remotePort + " -------------");
					// In case you are interested in DSP connection event, check if the value is 4
					// DSP is hard coded to port 4
					// Second phone connection event is received on either port 2 or 3
					// USB dongle connection port is hard coded to 1; if not interested ignore it.
					if ((remotePort > 1) && (remotePort < 4)) {
						// save the port you are interested in; or if multiple then keep an array
						Toast.makeText(getApplicationContext(), "Remote connection open.", Toast.LENGTH_SHORT).show();
						mRemoteDevicePort = remotePort;
						HeadsetDataDevice tempDevice = connectToDevice(mDeviceAddress, mRemoteDevicePort);
						if (tempDevice != null) {
							mRemoteDevice = tempDevice;
						}
						else {
							Log.i(FN(), "Attempt to open failed (tempDevice == null).");
						}
					}
					break;

				case Definitions.Events.DISCONNECTED_DEVICE_EVENT:
					Byte disconnectPort = (Byte)(((DeviceEvent)values[0]).getEventData()[0]);
					Log.i(FN(), "------------- Remote device on port " + disconnectPort + " disconnected. -------------");
					if (disconnectPort > 1) {
						// *************************************************************************************************************************
						// this shouldn't need to be here
						//mainApp.deviceClosed(mRemoteDevice);
						// *************************************************************************************************************************
					}

				case Definitions.Events.CALL_STATUS_CHANGE_EVENT:
					String status = ((DeviceEvent)values[0]).getEventData()[0].toString();
					Log.i(FN(), "------------- Call Status Event: " + status + " -------------");

					// idle, active, ringing, dialing
					switch (Integer.parseInt(status)) {
						case 0:
							remoteDeviceCallState = CALL_STATE.CALl_STATE_IDLE;
							break;
						case 1:
							remoteDeviceCallState = CALL_STATE.CALL_STATE_ACTIVE;
							break;
						case 2:
							remoteDeviceCallState = CALL_STATE.CALL_STATE_RINGING;
							break;
						case 3:
							remoteDeviceCallState = CALL_STATE.CALL_STATE_DIALING;
							break;
					}
					checkAskTransfer();
					break;

				default:
					Log.i(FN(), "------------- Other Event: " + values[0] + " -------------");
					break;
			}
		}

		// register to receive all Bladerunner Events
		@Override
		protected Integer doInBackground(HeadsetDataDevice... headsetDataDevices) {
			if (mController.registerEventListener(headsetDataDevices[0], this)) {
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
			Log.e(FN(), "ReceiveEventTask: device opened");
//			RemoteResult result = new RemoteResult(4, "Device Open");
//			publishProgress(result);

		}

		@Override
		public void openFailed(final HeadsetDataDevice device) {
			Log.e(FN(), "ReceiveEventTask: device open failed");
//			RemoteResult result = new RemoteResult(2, "Device Open Failed");
//			publishProgress(result);
		}

		@Override
		public void deviceClosed(final HeadsetDataDevice device) {
			Log.e(FN(), "ReceiveEventTask: device closed");
//			RemoteResult result = new RemoteResult(2, "Device Closed");
//			publishProgress(result);
		}
	}
}
