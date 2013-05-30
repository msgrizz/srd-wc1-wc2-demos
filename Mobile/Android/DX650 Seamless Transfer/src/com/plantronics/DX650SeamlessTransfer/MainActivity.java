/* ********************************************************************************************************
	MainActivity.java
	com.plantronics.DX650SeamlessTransfer.MainActivity

	Created by mdavis on 04/30/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650SeamlessTransfer;

import android.app.Activity;
import android.app.AlertDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.*;
import android.graphics.Color;
import android.graphics.Point;
import android.os.*;
import android.os.RemoteException;
import android.util.Log;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.*;
import android.view.View.OnClickListener;
import com.plantronics.BladeRunner.controller.HeadsetDataController;
import com.plantronics.BladeRunner.controller.HeadsetDeviceCommand;
import com.plantronics.BladeRunner.controller.HeadsetDeviceSetting;
import com.plantronics.BladeRunner.controller.SettingsResult;
import com.plantronics.BladeRunner.listener.*;
import com.plantronics.DX650SeamlessTransfer.R;
import com.plantronics.bladerunner.Definitions;
import com.plantronics.headsetdataservice.io.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MainActivity extends Activity implements BindListener, DiscoveryListener, HeadsetServiceConnectionListener, HeadsetServiceBluetoothListener {

	private static final String TAG = "com.plantronics.DX650SeamlessTransfer.MainActivity";
	private static final int NEAR_SIGNAL_THRESHOLD = 60;

	private enum CALL_STATUS {
		CALl_STATUS_IDLE,
		CALL_STATUS_ACTIVE,
		CALL_STATUS_RINGING,
		CALL_STATUS_DIALING
	}

	private ListView deviceListView;
	List<BRDevice> devices;
	ArrayAdapter<BRDevice> devicesArrayAdapter;
	//private ArrayAdapter<BRDevice> devicesArrayAdapter;
	//Boolean serviceIsBound;
	private BRDevice waitingToConnectDevice;
	private BRDevice connectedDevice;
	Boolean waitingForConnectionClose;
	private BluetoothAdapter bluetoothAdapter;
	private static HeadsetDataController dataController;
	private TextView selDeviceNameTextView;
	private TextView selDeviceAddrTextView;
	private TextView selConnectionStatusTextView;
	private TextView selWearingStateTextView;
	private TextView selCallStateTextView;
	private TextView deviceProximityLabelTextView;
	private ProgressBar selProximityProgressBar;
	private TextView debugTextView;
	private Button startRSSIButton;
	private Button stopRSSIButton;
	private Button queryCallStateButton;
	private Button queryWearingStateButton;
	private Button placeCallButton;
	private Button endCallButton;
	private Button closeButton;

	int selDeviceRSSI;
	List<Integer> recentRSSIs;
	Boolean selDeviceIsWearing;
	int selDeviceCallStatus;
	//Toast askTransferToast;
	//Boolean transferToastDismissed;
	AlertDialog askTransferAlertDialog;
	Boolean askTransferAlertDismissed;

	private AdapterView.OnItemClickListener deviceTappedListener = new AdapterView.OnItemClickListener() {
		public void onItemClick(AdapterView<?> av, View v, int position, long id) {
			BRDevice device  = (BRDevice)av.getItemAtPosition(position);
			Log.i(TAG, "Device selected: " + device.toString());
			deviceSelected(device);
		}
	};


	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
		devices = new ArrayList<BRDevice>();
		devicesArrayAdapter = new ArrayAdapter<BRDevice>(this, R.layout.device_list_item, devices);
		//devicesArrayAdapter = new ArrayAdapter<BRDevice>(this, R.layout.device_list_item);
		waitingForConnectionClose = false;

		// Find and set up the ListView for Bladerunner devices
		deviceListView = (ListView)findViewById(R.id.devicesListView);
		deviceListView.setAdapter(devicesArrayAdapter);
		deviceListView.setOnItemClickListener(deviceTappedListener);

		selDeviceNameTextView = (TextView)findViewById(R.id.deviceNameTextView);
		selDeviceAddrTextView = (TextView)findViewById(R.id.deviceAddressTextView);
		selConnectionStatusTextView = (TextView)findViewById(R.id.deviceConnectionStateTextView);
		selWearingStateTextView = (TextView)findViewById(R.id.deviceWearingStateTextView);
		selCallStateTextView = (TextView)findViewById(R.id.deviceCallStateTextView);
		deviceProximityLabelTextView = (TextView)findViewById(R.id.deviceProximityLabelTextView);
		selProximityProgressBar = (ProgressBar)findViewById(R.id.deviceProximityProgressBar);

		debugTextView = (TextView)findViewById(R.id.debugTextView);
		startRSSIButton = (Button)findViewById(R.id.startRSSIButton);
		stopRSSIButton = (Button)findViewById(R.id.stopRSSIButton);
		queryCallStateButton = (Button)findViewById(R.id.queryCallStateButton);
		queryWearingStateButton = (Button)findViewById(R.id.queryWearingStateButton);
		placeCallButton = (Button)findViewById(R.id.placeCallButton);
		endCallButton = (Button)findViewById(R.id.endCallButton);
		closeButton = (Button)findViewById(R.id.closeButton);
		startRSSIButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				startRSSIButtonClicked();
			}
		});
		stopRSSIButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				stopRSSIButtonClicked();
			}
		});
		queryCallStateButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				queryCallStateButtonClicked();
			}
	});
		queryWearingStateButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				queryWearingStateButtonClicked();
			}
		});
		placeCallButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				placeCallButtonClicked();
			}
		});
		endCallButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				endCallButtonClicked();
			}
		});
		closeButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				closeButtonClicked();
			}
		});

		dataController = HeadsetDataController.getHeadsetControllerSingleton(this);
		dataController.bindHeadsetDataService(this);

		selDeviceRSSI = Integer.MAX_VALUE;
		selDeviceIsWearing = false;
		//CALL_STATUS selDeviceCallStatus = CALl_STATUS_IDLE;
		askTransferAlertDialog = null;
		askTransferAlertDismissed = false;
		recentRSSIs = new ArrayList<Integer>();

		setNoSelectionState();

//		Display display = getWindowManager().getDefaultDisplay();
//		Point size = new Point();
//		display.getSize(size);
//		int width = size.x;
//		int height = size.y;
//		Log.i(TAG, "width: " + width + " height: " + height);
	}

	@Override
	protected void onStart() {
		Log.i(TAG, "onStart()");
		super.onStart();
	}

	@Override
	protected void onStop() {
		Log.i(TAG, "onStop()");

//		if (dataController != null) {
//				Log.i(TAG, "onStop(): calling close on " + connectedDevice.address);
//				dataController.close();
//				dataController.unregisterServiceCallbacks();
//
//			// Check if this Activity bound to the service,
//			// if yes then only unbind. otherwise the previous activity will unbound
//			//if (bIsBoundToService) {
//				Log.i(TAG, "onStop(): unbindHeadsetDataService()");
//				dataController.unbindHeadsetDataService(this);
//			//}
//		}

		super.onStop();
	}

	@Override
	protected void onDestroy() {
		Log.i(TAG, "onDestroy()");
		super.onDestroy();
		//doUnbindService();

		if (dataController != null) {
			Log.i(TAG, "onDestroy(): calling close on " + connectedDevice.address);
			dataController.close();
			dataController.unregisterServiceCallbacks();

			// Check if this Activity bound to the service,
			// if yes then only unbind. otherwise the previous activity will unbound
			//if (bIsBoundToService) {
			Log.i(TAG, "onDestroy(): unbindHeadsetDataService()");
			dataController.unbindHeadsetDataService(this);
			//}
		}
	}


	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void deviceSelected(BRDevice device) {

		if (!waitingForConnectionClose) {
			if ((connectedDevice != device) && (waitingToConnectDevice != device)) {
				if (connectedDevice == null) {
					connectedDevice = device;
					selDeviceNameTextView.setText(device.name);
					selDeviceAddrTextView.setText(device.address);

					setConnectingState();

					selDeviceRSSI = Integer.MAX_VALUE;
					selDeviceIsWearing = false;
					//selDeviceCallStatus = CALl_STATUS_IDLE;
					askTransferAlertDialog = null;
					askTransferAlertDismissed = false;
					recentRSSIs = new ArrayList<Integer>();

					openDeviceConnection(device);
				}
				else {
					waitingToConnectDevice = device;
					closeDeviceConnection();
				}
			}
		}
		else {
			waitingToConnectDevice = device;
		}
	}

	void openDeviceConnection(BRDevice device) {

		// setup the HeadsetDataService and bind to it
		dataController = HeadsetDataController.getHeadsetControllerSingleton(this);
		if (dataController.bindHeadsetDataService(this)) {
			Log.e(TAG, "Service already bound: register callbacks with the service");
			dataController.registerServiceCallbacks();
		}

		if (dataController.isbServiceConnectionOpen()) {
			Log.i(TAG, "Create new device " + device.address);
			dataController.newDevice(device.address, this);

			//if (!dataController.isbDeviceOpen()) { // always returns false
			// open Bladerunner Connection asynchronous call
			setConnectingState();
			connectedDevice = null;
			waitingToConnectDevice = device;
			dataController.open(this);

			// since there is no callback when the connection is already open, wait for a while and see if connectedToDevice is set. if not, assume the device was already open...
			final Handler handler = new Handler();
			handler.postDelayed(new Runnable() {
				@Override
				public void run() {
					if (connectedDevice == null) {
						Log.i(TAG, "New connection doesn't appear to have opened... Assuming existing connection.");
						deviceOpen();
					}
					else {
						Log.i(TAG, "New connection was opened.");
					}
				}
			}, 3500);
			//}
		}
		else {
			Log.e(TAG, "Connection to the service is not open");
			Toast.makeText(this, "Service is disconnected.", Toast.LENGTH_SHORT).show();
		}
	}

	private void closeDeviceConnection() {
		Log.i(TAG, "Closing device connection: " + connectedDevice.getAddress());

		if (dataController != null) {
			waitingForConnectionClose = true;
			dataController.close();
		}
	}

	private void startRSSIButtonClicked() {
		startMonitoringRSSI(true);
	}

	private void stopRSSIButtonClicked() {
		startMonitoringRSSI(false);
	}

	private void queryCallStateButtonClicked() {
		Toast.makeText(MainActivity.this, "Not implemented.", Toast.LENGTH_SHORT).show();
	}

	private void queryWearingStateButtonClicked() {
		queryWearingState();
	}

	private void placeCallButtonClicked() {
		placeCallOnSecondDevice();
	}

	private void endCallButtonClicked() {
		Toast.makeText(MainActivity.this, "Not implemented.", Toast.LENGTH_SHORT).show();
	}

	private void closeButtonClicked() {
		closeDeviceConnection();
	}

	private void startListeningForEvents() {
		Log.i(TAG, "startListeningForEvents");
		ReceiveEventTask task = new ReceiveEventTask();
		task.execute(new HeadsetDataDevice(connectedDevice.address));
	}

	private void startMonitoringRSSI(boolean enabled) {
		Log.i(TAG, "startMonitoringRSSI: " + enabled);

		// Get this Command ID from the Definitions.java file
		short id = Definitions.Commands.CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND;

        /* Definitions.java file has the payload definition for this command - look at
         *  CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND_PAYLOAD_IN { }
         */
		Object objs[] = new Object[10];

		objs[0] = (Byte)(byte)0; /* The connection ID of the link being used to generate the signal strength event. */
		objs[1] = (Boolean) enabled;  /* enable - If true, this will enable the signal strength monitoring. */
		objs[2] = (Boolean) false;   /* If true, report near far events only when headset is donned. */
		objs[3] = (Boolean) false;  /* trend - If true don't use trend detection */
		objs[4] = (Boolean) false;  /* report rssi audio - If true, Report rssi and trend events in headset audio */
		objs[5] = (Boolean) false;  /* report near far audio - If true, report Near/Far events in headset Audio */
		objs[6] = (Boolean) false;  /*report near far to base - If true, report RSSI and Near Far events to base  */
		objs[7] = (Byte)(byte) 5;  /* sensitivity - This number multiplies the dead_band value (currently 5 dB) in the headset configuration.
                    This result is added to an minimum dead-band, currently 5 dB to compute the total deadband.
                    in the range 0 to 9*/
		objs[8] =  (Byte)(byte)30;  /* near threshold - The near / far threshold in dB  in the range -99 to +99; larger values mean a weaker signal */
		objs[9] =  (Short)(short)60; /*  max timeout - The number of seconds after any event before terminating sending rssi values */

		DeviceCommand dc = dataController.getCommand(connectedDevice.address, id, objs) ;
		HeadsetDeviceCommand hdc = new HeadsetDeviceCommand(dc, new HeadsetDataDevice(connectedDevice.address));
		Log.i(TAG, "Starting RSSI monitoring:" + hdc);
		CommandTask task = new CommandTask();
		task.execute(hdc);
	}

	private void placeCallOnSecondDevice() {
		Log.i(TAG, "placeCallOnSecondDevice");

		// Get this Command ID from the Definitions.java file
		short id = Definitions.Commands.MAKE_CALL_COMMAND;

        /* Definitions.java file has the payload definition for this command - look at
         *  MAKE_CALL_COMMAND_PAYLOAD_IN { }
         */
		Object objs[] = new Object[1];
		objs[0] = (String)"5304170189";

		DeviceCommand dc = dataController.getCommand(connectedDevice.address, id, objs) ;
		HeadsetDeviceCommand hdc = new HeadsetDeviceCommand(dc, new HeadsetDataDevice(connectedDevice.address));
		Log.i(TAG, "Placing call... " + hdc);
		CommandTask task = new CommandTask();
		task.execute(hdc);
	}

	private void queryWearingState() {
		Log.i(TAG, "queryWearingState");

		short id = Definitions.Settings.WEARING_STATE_SETTING;
		DeviceSetting ds = dataController.getSetting(connectedDevice.address, id, null) ;
		HeadsetDeviceSetting hds = new HeadsetDeviceSetting(ds, new HeadsetDataDevice(connectedDevice.address));
		SettingTask task = new SettingTask();
		task.execute(hds);
	}

	private void setNoSelectionState() {
		//selDeviceNameTextView.setVisibility(4); // invisible
		selDeviceNameTextView.setText("Select a device");
		selDeviceAddrTextView.setVisibility(4); // invisible
		selConnectionStatusTextView.setVisibility(4); // invisible
		selWearingStateTextView.setVisibility(4); // invisible
		selCallStateTextView.setVisibility(4); // invisible
		deviceProximityLabelTextView.setVisibility(4); // invisible
		selProximityProgressBar.setVisibility(4); // invisible
		debugTextView.setVisibility(4); // invisible
		startRSSIButton.setVisibility(4); // invisible
		stopRSSIButton.setVisibility(4); // invisible
		queryCallStateButton.setVisibility(4); // invisible
		queryWearingStateButton.setVisibility(4); // invisible
		placeCallButton.setVisibility(4); // invisible
		endCallButton.setVisibility(4); // invisible
		closeButton.setVisibility(4); // invisible
	}

	private void setConnectingState() {
		selConnectionStatusTextView.setText("Connecting....");
		selConnectionStatusTextView.setTextColor(Color.rgb(255, 127, 0));
		selDeviceNameTextView.setVisibility(0); // visible
		selDeviceAddrTextView.setVisibility(0); // visible
		selConnectionStatusTextView.setVisibility(0); // visible
	}

	private void setConnectedState() {
		selConnectionStatusTextView.setText("Connected");
		selConnectionStatusTextView.setTextColor(Color.rgb(0, 150, 0));
		selWearingStateTextView.setVisibility(0); // visible
		selCallStateTextView.setVisibility(0); // visible
		deviceProximityLabelTextView.setVisibility(0); // visible
		selProximityProgressBar.setIndeterminate(true);
		selProximityProgressBar.setVisibility(0); // visible
		debugTextView.setVisibility(0); // visible
		startRSSIButton.setVisibility(0); // visible
		stopRSSIButton.setVisibility(0); // visible
		queryCallStateButton.setVisibility(0); // visible
		queryWearingStateButton.setVisibility(0); // visible
		placeCallButton.setVisibility(0); // visible
		endCallButton.setVisibility(0); // visible
		closeButton.setVisibility(0); // visible
	}

	private void setDisconnectedState() {
		selConnectionStatusTextView.setText("Disconnected");
		selConnectionStatusTextView.setTextColor(Color.rgb(200, 0, 0));
		selWearingStateTextView.setVisibility(4); // invisible
		selCallStateTextView.setVisibility(4); // invisible
		deviceProximityLabelTextView.setVisibility(4); // invisible
		selProximityProgressBar.setVisibility(4); // invisible
		debugTextView.setVisibility(4); // invisible
		startRSSIButton.setVisibility(4); // invisible
		stopRSSIButton.setVisibility(4); // invisible
		queryCallStateButton.setVisibility(4); // invisible
		queryWearingStateButton.setVisibility(4); // invisible
		placeCallButton.setVisibility(4); // invisible
		endCallButton.setVisibility(4); // invisible
		closeButton.setVisibility(4); // invisible
	}

	private void updateCallStatus(int status) {
		selDeviceCallStatus = status;
//		switch (status) {
//			case CALL_STATUS_ACTIVE:
//				selCallStateTextView.setText("In a call");
//				break;
//			default:
//				selCallStateTextView.setText("Not in a call");
//				break;
//		}
	}

	private void updateWearingState(Boolean on) {
		selDeviceIsWearing = on;
		if (on) {
			selWearingStateTextView.setText("Wearing");
		}
		else {
			selWearingStateTextView.setText("Not wearing");
		}
	}

	private void checkAskTransfer() {

		// the second the RSSI hits the "near" threshold, show the dialog
		if ((connectedDevice != null) && selDeviceIsWearing && ((selDeviceRSSI > -1) && (selDeviceRSSI <= NEAR_SIGNAL_THRESHOLD))) { // || not in call

			if ((askTransferAlertDialog == null) && !askTransferAlertDismissed) {

				Log.i(TAG, "******** Asking to transfer ********");

				recentRSSIs.clear();

				askTransferAlertDialog = new AlertDialog.Builder(this).create();
				askTransferAlertDialog.setTitle("Transfer Call");
				askTransferAlertDialog.setMessage("Would you like to transfer your mobile call?");

//				LayoutInflater inflater = getLayoutInflater();
//				View layout = inflater.inflate(R.layout.pony_view, null);
//				askTransferAlertDialog.setView(layout);

				askTransferAlertDialog.setButton("Yes", new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int which) {
						Log.i(TAG, "Yes");
						askTransferAlertDialog = null;
						askTransferAlertDismissed = true;
						recentRSSIs.clear();
					}
				});
				askTransferAlertDialog.setButton2("No", new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int which) {
						Log.i(TAG, "No");
						askTransferAlertDialog = null;
						askTransferAlertDismissed = true;
						recentRSSIs.clear();
					}
				});
				askTransferAlertDialog.setIcon(R.drawable.ic_launcher);
				askTransferAlertDialog.show();
			}
		}
		else {

			// when closing the dialog, check the 5 RSSI readings to minimize blinky behavior
			int count = 0;
			Boolean close = false;
			for (Integer i : recentRSSIs) {
				Log.i(TAG, "i: " + i.toString());
				count++;
				if (i < NEAR_SIGNAL_THRESHOLD) {
					close = true;
					break;
				}
			}
			if ( ((count >= 5) && !close) || (connectedDevice == null) || !selDeviceIsWearing) { // || not in call
				if (askTransferAlertDialog != null) {
					Log.i(TAG, "******** Closing transfer dialog ********");
					askTransferAlertDialog.cancel();
					askTransferAlertDialog = null;
				}
				askTransferAlertDismissed = false;
			}
		}

		recentRSSIs.add(0, selDeviceRSSI);
		if (recentRSSIs.size() > 5) {
			recentRSSIs.remove(recentRSSIs.size()-1);
		}
	}

//			if ( (askTransferToast == null) && !transferToastDismissed) {
//
//				Log.i(TAG, "******** Asking to transfer ********");
//
//				LayoutInflater inflater = getLayoutInflater();
//				View layout = inflater.inflate(R.layout.transfer_toast, (ViewGroup)findViewById(R.id.transfer_toast_root));
//
//				TextView text = (TextView)layout.findViewById(R.id.text);
//				text.setText("Would you like to transfer the call from <mobile device name>?");
//
//				Button yesButton =  (Button)layout.findViewById(R.id.yes_button);
//				yesButton.setOnClickListener(new OnClickListener() {
//					@Override
//					public void onClick(View view) {
//						Log.i(TAG, "Yes");
//						askTransferToast.cancel();
//						askTransferToast = null;
//						transferToastDismissed = true;
//					}
//				});
//
//				Button noButton =  (Button)layout.findViewById(R.id.no_button);
//				noButton.setOnClickListener(new OnClickListener() {
//					@Override
//					public void onClick(View view) {
//						Log.i(TAG, "No");
//						askTransferToast.cancel();
//						transferToastDismissed = true;
//						askTransferToast = null;
//					}
//				});
//
//				askTransferToast = new Toast(getApplicationContext());
//				askTransferToast.setGravity(Gravity.CENTER_VERTICAL, 0, 0);
//				askTransferToast.setDuration(Toast.LENGTH_LONG);
//				askTransferToast.setView(layout);
//				askTransferToast.show();
//				transferToastDismissed = false;

//			if (askTransferToast != null) {
//				askTransferToast.cancel();
//				askTransferToast = null;
//			}
//			transferToastDismissed = false;

	/* ****************************************************************************************************
			DiscoveryListener
	*******************************************************************************************************/

	/**
	 * A Bladerunner Bluetooth device is found by the SDK
	 * @param name Bluetooth address of the device
	 */
	@Override
	public void foundDevice(final String name) {
		Log.i(TAG, "Found device: " + name);
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				BluetoothDevice device = bluetoothAdapter.getRemoteDevice(name);
				Boolean exists = false;
				for (BRDevice d : devices) {
					if (d.getAddress() == device.getAddress()) {
						exists = true;
						break;
					}
				}
				//if (!Arrays.asList(devices).contains(device)) {
				if (!exists) {
					devicesArrayAdapter.add(new BRDevice(device));
				}
			}
		});
	}

	/**
	 * Discovery is stopped
	 * @param res boolean success if a result was found
	 */
	@Override
	public void discoveryStopped(int res) {
		Log.i(TAG, "Discovery stopped.");
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (devices.size() == 1) deviceSelected(devices.get(0));
			}
		});
	}


	/* ****************************************************************************************************
			BindListener
	*******************************************************************************************************/

	@Override
	public void serviceConnected() {
		Log.e(TAG, "Service connected.");
		// service is connected, now register to hear discovery callbacks
		dataController.registerDiscoveryCallback();

		try {
			int ret =  dataController.getBladeRunnerDevices();
		} catch (RemoteException e) {
			e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
		}
	}

	@Override
	public void serviceDisconnected() {
		Log.e(TAG, "Service disconnected.");
	}

	@Override
	public void bindSuccess() {
		Log.i(TAG, "Binding succeeded.");
	}

	@Override
	public void bindFailed() {
		Log.i(TAG, "Binding failed.");
	}

	@Override
	public void unbind() {
		Log.i(TAG, "Unbind.");
	}


	/* ****************************************************************************************************
			HeadsetServiceConnectionListener
	*******************************************************************************************************/

	/**
	 *  Callback interface method called when
	 *  Bladerunner connection is successfully established/opened
	 */
	@Override
	public void deviceOpen() {
		Log.i(TAG, "****************** Device opened. ******************");

		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				selConnectionStatusTextView.setText("Connected");
				connectedDevice = waitingToConnectDevice;
				waitingToConnectDevice = null;
				setConnectedState();
				startListeningForEvents();
				startMonitoringRSSI(true);
				queryWearingState();
			}
		});
	}

	/**
	 * Callback interface method called when the Bladerunner
	 * connection failed to open.
	 */
	@Override
	public void openFailed() {
		Log.e(TAG, "Device open failed.");
		selConnectionStatusTextView.setText("Error connecting");
	}

	/**
	 *  Callback interface method called when SDK closed the
	 *  bladerunner connection to the device
	 */
	@Override
	public void deviceClosed() {
		Log.i(TAG, "Device connection closed.");

		this.runOnUiThread( new Runnable() {
			@Override
			public void run() {
				waitingForConnectionClose = false;
				setDisconnectedState();

				if (waitingToConnectDevice != null) {
					openDeviceConnection(waitingToConnectDevice);
				}
				else {
					connectedDevice = null;
					waitingToConnectDevice = null;
				}
			}
		});
	}

	/* ****************************************************************************************************
			HeadsetServiceBluetoothListener
	*******************************************************************************************************/

	/**
	 * Callback method called when Headset's bluetooth connection is connected
	 * @param bdaddr  BD_ADDR of the device connected
	 */
	@Override
	public void onBluetoothConnected(final String bdaddr) {
		Log.e(TAG, "Bluetooth is connected for " + bdaddr);
		this.runOnUiThread( new Runnable() {
			@Override
			public void run() {
				Toast.makeText(MainActivity.this, "Bluetooth Connected for " + bdaddr , Toast.LENGTH_SHORT).show();

				// Bluetooth go connected; App can try re-initiating the BR Connection here
			}
		});

		// if Bladerunner connection is broken, this callback is the place to re-establish the bladerunner
		// connection.
	}

	/**
	 * Callback method called when Headset's bluetooth connection is disconnected
	 * @param bdaddr  BD_ADDR of the device disconnected
	 */
	@Override
	public void onBluetoothDisconnected(final String bdaddr) {
		Log.e(TAG, "Bluetooth is disconnected for " + bdaddr);
		this.runOnUiThread( new Runnable() {
			@Override
			public void run() {
				Toast.makeText(MainActivity.this, "Bluetooth Disconnected for " + bdaddr , Toast.LENGTH_SHORT).show();
				setDisconnectedState();
				connectedDevice = null;
				waitingToConnectDevice = null;
			}
		});

	}


	/* ****************************************************************************************************
			(Class) BRDevice
	*******************************************************************************************************/

	private class BRDevice {

		private String name = null;
		private String address = null;

		private BRDevice() {
		}

		private BRDevice(BluetoothDevice dev) {
			address = dev.getAddress();
			name = dev.getName();
		}

		public String getAddress() {
			return address;
		}

		public String getName() {
			return name;
		}

		@Override
		public String toString() {
			final StringBuilder sb = new StringBuilder();
			if (name == null) {
				return getResources().getText(R.string.none_paired).toString();
			} else {
				sb.append(name).append("\n").append(address);
				//sb.append(address).append(" (").append(name).append(")");
			}
			return sb.toString();
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
			if (!dataController.isbDeviceOpen())  {
				Log.e(TAG, "device is not open, saving Command Task");
				dataController.open(this);
			}
			else {
				res = dataController.perform(deviceCommands[0].getDevice(), deviceCommands[0].getCommand(), remoteRes, this);
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
		public void deviceOpen() {
			Log.e(TAG, "CommandTask: device opened");
			RemoteResult result = new RemoteResult(4, "Device Open");
			publishProgress(result);
		}

		// again the hack with value 2 returned as open failed so that
		// onProgressUpdate() can act on it
		@Override
		public void openFailed() {
			Log.e(TAG, "CommandTask: device open failed");
			RemoteResult result = new RemoteResult(2, "Device Open Failed");
			publishProgress(result);
		}

		// again the hack with value 2 returned as open failed so that
		// onProgressUpdate() can act on it
		@Override
		public void deviceClosed() {
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
						//updateCallStatus(status);
						break;
					}
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
			if (!dataController.isbDeviceOpen()) {
				Log.e(TAG, "device is not open, saving Setting Task");
				// start the connection open process. It will result in asynchronous api callbacks handled from
				// deviceOpen() and openFailed()
				dataController.open(this);

			}  else {
				// connection is already open
				res = dataController.fetch(deviceSettings[0].getDevice(), deviceSettings[0].getSetting(), remoteRes, this);
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
		public void deviceOpen() {
			Log.e(TAG, "SettingTask: device opened");
			RemoteResult result = new RemoteResult(4, "Device Open");
			publishProgress(result);

		}

		@Override
		public void openFailed() {
			Log.e(TAG, "SettingTask: device open failed");
			RemoteResult result = new RemoteResult(2, "Device Open Failed");
			publishProgress(result);
		}

		@Override
		public void deviceClosed() {
			Log.e(TAG, "SettingTask: device closed");
			RemoteResult result = new RemoteResult(2, "Device Closed");
			publishProgress(result);
		}
	}


	/* ****************************************************************************************************
			(Class) ReceiveEventTask
	*******************************************************************************************************/

	/**
	 * Event task.
	 */
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
					Log.i(TAG, "------------- Don/Doff Event: " + on + "-------------");
					updateWearingState(on);

				case Definitions.Events.BATTERY_STATUS_CHANGED_EVENT:
					Log.i(TAG, "------------- Battery Status Event: " + Arrays.asList( ((DeviceEvent)values[0]).getEventData()).toString() + "-------------");
					break;

				case Definitions.Events.CALL_STATUS_CHANGE_EVENT:
					String status = ((DeviceEvent)values[0]).getEventData()[0].toString();
					Log.i(TAG, "------------- Call Status Event: " + status + "-------------");
					//updateCallStatus();
					break;

				case Definitions.Events.SIGNAL_STRENGTH_EVENT:
					String strengthString = ((DeviceEvent)values[0]).getEventData()[1].toString();
					int strength = Integer.parseInt(strengthString); // this is stupid.
					selDeviceRSSI = strength;
					Log.i(TAG, "------------- Signal Strength Event: " + strengthString + "-------------");
					strength = -strength;
					strength += 80;
					//signalStrengthTextView.setText("-" + strengthString);
					selProximityProgressBar.setIndeterminate(false);
					selProximityProgressBar.setProgress(strength);
					break;

				default:
					Log.i(TAG, "------------- Other Event: " + values[0] + "-------------");
					break;
			}

			checkAskTransfer();
		}

		// register to receive all Bladerunner Events
		@Override
		protected Integer doInBackground(HeadsetDataDevice... headsetDataDevices) {
			if (dataController.registerEventListener(this)) {
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
		public void deviceOpen() {
			//To change body of implemented methods use File | Settings | File Templates.
		}

		@Override
		public void openFailed() {
			//To change body of implemented methods use File | Settings | File Templates.
		}

		@Override
		public void deviceClosed() {
			//To change body of implemented methods use File | Settings | File Templates.
		}
	}


	/**
	 *  If the connection is open, get the list of all Deckard messesges implmented by the headset.
	 * @return   boolean success/failure
	 */
	public boolean listMetadata() {
		if (!dataController.isbDeviceOpen()) {
			Log.e(TAG, "device is not open, can't get metadata information");
			return false;

		}  else {
			HeadsetDataDevice device =  new HeadsetDataDevice(connectedDevice.address);
			Log.i(TAG, "Commands=" +   dataController.getSupportedCommands(device));
			Log.i(TAG, "Settings=" +   dataController.getSupportedSettings(device));
			Log.i(TAG, "Events=" +   dataController.getSupportedEvents(device));
			return true;
		}
	}
}
