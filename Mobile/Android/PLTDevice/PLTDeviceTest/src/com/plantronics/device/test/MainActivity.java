/* ********************************************************************************************************
	MainActivity.java
	com.plantronics.PLTDevice

	Created by mdavis on 03/11/2014.
	Copyright (c) 2014 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.device.test;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import com.plantronics.device.*;
import com.plantronics.device.calibration.OrientationTrackingCalibration;
import com.plantronics.device.info.*;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Set;

public class MainActivity extends Activity implements PairingListener, ConnectionListener, InfoListener {

	private static final String TAG = "com.plantronics.device.test.MainActivity";

	private Context		_context;
	private Device 		_device;
	private TextView	_connectedTextView;
	private Button		_openConnectionButton;
	private Button		_subscribeButton;
	private Button		_changeSubscriptionButton1;
	private Button		_changeSubscriptionButton2;
	private Button		_changeSubscriptionButton3;
	private Button		_changeSubscriptionButton4;
	private Button		_changeSubscriptionButton5;
	private Button		_unsubscribeButton;
	private Button		_unsubscribeAllButton;
	private Button		_queryButton;
	private Button		_getCachedButton;
	private Button		_calibrateButton;


	/* ****************************************************************************************************
			 Private (Activity)
	*******************************************************************************************************/

	public void onCreate(Bundle savedInstanceState) {
		Log.i(FN(), "onCreate()");
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		_connectedTextView = ((TextView)findViewById(R.id.connectedTextView));
		_connectedTextView.setText("Disconnected");

		_openConnectionButton = ((Button)findViewById(R.id.openConnectionButton));
		_openConnectionButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				openConnectionButton();
			}
		});

		_subscribeButton = ((Button)findViewById(R.id.subscribeButton));
		_subscribeButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				subscribeButton();
			}
		});

		_changeSubscriptionButton1 = ((Button)findViewById(R.id.changeSubscriptionButton1));
		_changeSubscriptionButton1.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				changeSubscriptionButton1();
			}
		});

		_changeSubscriptionButton2 = ((Button)findViewById(R.id.changeSubscriptionButton2));
		_changeSubscriptionButton2.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				changeSubscriptionButton2();
			}
		});

		_changeSubscriptionButton3 = ((Button)findViewById(R.id.changeSubscriptionButton3));
		_changeSubscriptionButton3.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				changeSubscriptionButton3();
			}
		});

		_changeSubscriptionButton4 = ((Button)findViewById(R.id.changeSubscriptionButton4));
		_changeSubscriptionButton4.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				changeSubscriptionButton4();
			}
		});

		_changeSubscriptionButton5 = ((Button)findViewById(R.id.changeSubscriptionButton5));
		_changeSubscriptionButton5.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				changeSubscriptionButton5();
			}
		});

		_unsubscribeButton = ((Button)findViewById(R.id.unsubscribeButton));
		_unsubscribeButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				unsubscribeButton();
			}
		});

		_unsubscribeAllButton = ((Button)findViewById(R.id.unsubscribeAllButton));
		_unsubscribeAllButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				unsubscribeAllButton();
			}
		});

		_queryButton = ((Button)findViewById(R.id.queryButton));
		_queryButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				queryButton();
			}
		});

		_getCachedButton = ((Button)findViewById(R.id.getCachedButton));
		_getCachedButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				getCachedButton();
			}
		});

		_calibrateButton = ((Button)findViewById(R.id.calibrateButton));
		_calibrateButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				calibrateButton();
			}
		});

		if (!Device.getIsInitialized()) {
			Log.v(FN(), "Initializing PLTDevice...");
			try {
				Device.initialize(this, new Device.InitializationCallback() {
					@Override
					public void onInitialized() {
						Log.i(FN(), "onInitialized(). Devices: " + Device.getPairedDevices());
						Device.registerPairingListener((PairingListener) _context);
					}

					@Override
					public void onFailure(int error) {
						Log.i(FN(), "onFailure()");

						if (error == Device.ERROR_PLTHUB_NOT_AVAILABLE) {
							Log.i(FN(), "PLTHub was not found.");
						} else if (error == Device.ERROR_FAILED_GET_DEVICE_LIST) {
							Log.i(FN(), "Failed to get device list.");
						}
					}
				});
			}
			catch (Exception e) {
				Log.e(FN(), "Exception initializing PLTDevice: " + e);
			}
		}
	}

//	@Override
//	public void onConfigurationChanged(Configuration newConfig) {
//		super.onConfigurationChanged(newConfig);
//	}

	@Override
	public void onResume() {
		Log.i(FN(), "onResume()");
		super.onResume();

		_context = this;

		if (_device != null) {
			_device.onResume();
		}
	}

	@Override
	protected void onPause() {
		Log.i(FN(), "onPause()");
		super.onPause();

		_context = null;

		if (_device != null) {
			_device.onPause();
		}
	}

	@Override
	protected void onDestroy() {
		Log.i(FN(), "onDestroy()");
		super.onDestroy();
	}

	/* ****************************************************************************************************
			 Private
	*******************************************************************************************************/

	private void openConnectionButton() {
		Log.i(FN(), "openConnectionButton()");

		try {
			if (_device == null) {
				ArrayList<Device> devices = Device.getPairedDevices();

				if (devices.size() > 0) {
					_device = devices.get(0);
					Log.d(FN(), "Got device: " + _device);
					Log.v(FN(), "Opening connection...");
					_device.registerConnectionListener(this);
					_device.openConnection();
				}
				else {
					Log.i(FN(), "No PLT devices found!");
				}
			}
		}
		catch(Exception e) {
			Log.e(FN(), "Exception opening connection: " + e);
		}
	}

	private void  subscribeButton() {
		Log.i(FN(), "subscribeButton()");

		try {
//		_device.subscribe(this, Device.SERVICE_WEARING_STATE, Device.SUBSCRIPTION_MODE_ON_CHANGE, (short)0);
//		_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_ON_CHANGE, (short)0);
//			_device.subscribe(this, Device.SERVICE_ORIENTATION_TRACKING, Device.SUBSCRIPTION_MODE_ON_CHANGE, (short)0);
			//_device.setCalibration(null, Device.SERVICE_ORIENTATION_TRACKING);
//		_device.subscribe(this, Device.SERVICE_TAPS, Device.SUBSCRIPTION_MODE_ON_CHANGE, (short)0);
		_device.subscribe(this, Device.SERVICE_PEDOMETER, Device.SUBSCRIPTION_MODE_ON_CHANGE, (short)0);
//		_device.subscribe(this, Device.SERVICE_FREE_FALL, Device.SUBSCRIPTION_MODE_ON_CHANGE, (short)0);
//		_device.subscribe(this, Device.SERVICE_MAGNETOMETER_CAL_STATUS, Device.SUBSCRIPTION_MODE_ON_CHANGE, (short)0);
//		_device.subscribe(this, Device.SERVICE_GYROSCOPE_CAL_STATUS, Device.SUBSCRIPTION_MODE_ON_CHANGE, (short)0);
		}catch(Exception e) {
			Log.e(FN(), "Exception: " + e);
		}
	}

	private void changeSubscriptionButton1() {
		Log.i(FN(), "changeSubscriptionButton1()");

		//_device.onPause();

		try {
			_device.subscribe(this, Device.SERVICE_ORIENTATION_TRACKING, Device.SUBSCRIPTION_MODE_PERIODIC, (short)1000);
		}
		catch(Exception e) {
			Log.e(FN(), "Exception: " + e);
		}
	}

	private void changeSubscriptionButton2() {
		Log.i(FN(), "changeSubscriptionButton2()");

		try {
			_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_PERIODIC, (short)15);
		}
		catch(Exception e) {
			Log.e(FN(), "Exception: " + e);
		}
	}

	private void changeSubscriptionButton3() {
		Log.i(FN(), "changeSubscriptionButton3()");

		try {
			_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_PERIODIC, (short)15);
		}
		catch(Exception e) {
			Log.e(FN(), "Exception: " + e);
		}
	}

	private void changeSubscriptionButton4() {
		Log.i(FN(), "changeSubscriptionButton4()");

		try {
			_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_ON_CHANGE, (short)0);
		}
		catch(Exception e) {
			Log.e(FN(), "Exception: " + e);
		}
	}

	private void changeSubscriptionButton5() {
		Log.i(FN(), "changeSubscriptionButton5()");

		try {
			_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_ON_CHANGE, (short)0);
		}
		catch(Exception e) {
			Log.e(FN(), "Exception: " + e);
		}
	}

	private void unsubscribeButton() {
		Log.i(FN(), "unsubscribeButton()");

		_device.unsubscribe(this, Device.SERVICE_ORIENTATION_TRACKING);
	}

	private void unsubscribeAllButton() {
		Log.i(FN(), "unsubscribeAllButton()");

		_device.unsubscribe(this);
	}

	private void queryButton() {
		Log.i(FN(), "queryButton()");

		try {
//		_device.queryInfo(this, Device.SERVICE_WEARING_STATE);
//		_device.queryInfo(this, Device.SERVICE_PROXIMITY);
			_device.queryInfo(this, Device.SERVICE_ORIENTATION_TRACKING);
//		_device.queryInfo(this, Device.SERVICE_PEDOMETER);
//		_device.queryInfo(this, Device.SERVICE_FREE_FALL);
//		_device.queryInfo(this, Device.SERVICE_TAPS);
//		_device.queryInfo(this, Device.SERVICE_MAGNETOMETER_CAL_STATUS);
//		_device.queryInfo(this, Device.SERVICE_GYROSCOPE_CAL_STATUS);
		}
		catch(Exception e) {
			Log.e(FN(), "Exception: " + e);
		}
	}

	private void getCachedButton() {
		Log.i(FN(), "getCachedButton()");

		try {
			Log.i(FN(), "SERVICE_PROXIMITY: " + _device.getCachedInfo(Device.SERVICE_PROXIMITY));
			Log.i(FN(), "SERVICE_WEARING_STATE: " + _device.getCachedInfo(Device.SERVICE_WEARING_STATE));
			Log.i(FN(), "SERVICE_ORIENTATION_TRACKING: " + _device.getCachedInfo(Device.SERVICE_ORIENTATION_TRACKING));
			Log.i(FN(), "SERVICE_PEDOMETER: " + _device.getCachedInfo(Device.SERVICE_PEDOMETER));
			Log.i(FN(), "SERVICE_FREE_FALL: " + _device.getCachedInfo(Device.SERVICE_FREE_FALL));
			Log.i(FN(), "SERVICE_TAPS: " + _device.getCachedInfo(Device.SERVICE_TAPS));
			Log.i(FN(), "SERVICE_MAGNETOMETER_CAL_STATUS: " + _device.getCachedInfo(Device.SERVICE_MAGNETOMETER_CAL_STATUS));
			Log.i(FN(), "SERVICE_GYROSCOPE_CAL_STATUS: " + _device.getCachedInfo(Device.SERVICE_GYROSCOPE_CAL_STATUS));
		}
		catch(Exception e) {
			Log.e(FN(), "Exception: " + e);
		}
	}

	public void calibrateButton() {
		Log.i(FN(), "calibrateButton()");

		try {
//		OrientationTrackingInfo oldOrientationInfo = (OrientationTrackingInfo)_device.getCachedInfo(Device.SERVICE_ORIENTATION_TRACKING);
//		OrientationTrackingCalibration orientationCal = new OrientationTrackingCalibration(oldOrientationInfo.getEulerAngles());
//		_device.setCalibration(orientationCal, Device.SERVICE_ORIENTATION_TRACKING);

			_device.setCalibration(null, Device.SERVICE_ORIENTATION_TRACKING);

			_device.setCalibration(null, Device.SERVICE_PEDOMETER);
		}
		catch(Exception e) {
			Log.e(FN(), "Exception: " + e);
		}
	}

	/* ****************************************************************************************************
			 PairingListener
	*******************************************************************************************************/

	public void onDevicePaired(Device device) {
		Log.i(FN(), "onDevicePaired(): " + device);
	}

	public void onDeviceUnpaired(Device device) {
		Log.i(FN(), "onDeviceUnpaired(): " + device);
	}

	/* ****************************************************************************************************
			 ConnectionListener
	*******************************************************************************************************/

	public void onConnectionOpen(Device device) {
		Log.i(FN(), "onConnectionOpen(): " + device);

		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				_connectedTextView.setText("Connected");
			}
		});
	}

	public void onConnectionFailedToOpen(Device device, int error) {
		Log.i(FN(), "onConnectionFailedToOpen(): " + device);

		if (error == Device.ERROR_CONNECTION_TIMEOUT) {
			Log.i(FN(), "Open connection timed out.");
		}
	}

	public void onConnectionClosed(Device device) {
		Log.i(FN(), "onConnectionClosed(): " + device);

		_device = null;

		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				_connectedTextView.setText("Disconnected");
			}
		});
	}

	/* ****************************************************************************************************
			 InfoListener
	*******************************************************************************************************/

	public void onSubscriptionChanged(Subscription oldSubscription, Subscription newSubscription) {
		Log.i(FN(), "onSubscriptionChanged(): oldSubscription=" + oldSubscription + ", newSubscription=" + newSubscription);
	}

	public void onInfoReceived(Info info) {
		Log.i(FN(), "onInfoReceived(): " + info);

		if (info.getClass() == OrientationTrackingInfo.class) {
			OrientationTrackingInfo theInfo = (OrientationTrackingInfo)info;
			EulerAngles eulerAngles = theInfo.getEulerAngles();
			int heading = (int)Math.round(-eulerAngles.getX());
			int pitch = (int)Math.round(eulerAngles.getY());
			int roll = (int)Math.round(eulerAngles.getZ());
			Log.i(FN(),"Orientation: {" + heading + ", " + pitch + ", " + roll + "}");

		}
		else if (info.getClass() == WearingStateInfo.class) {
			WearingStateInfo theInfo = (WearingStateInfo)info;
			Log.i(FN(), "Wearing: " + (theInfo.getIsBeingWorn() ? "yes" : "no"));
		}
		else if (info.getClass() == ProximityInfo.class) {
			ProximityInfo theInfo = (ProximityInfo)info;
			Log.i(FN(), "Local proximity: " + ProximityInfo.getStringForProximity(theInfo.getLocalProximity())
					+ ", Remote proximity: " + ProximityInfo.getStringForProximity(theInfo.getRemoteProximity()));
		}
		else if (info.getClass() == TapsInfo.class) {
			TapsInfo theInfo = (TapsInfo)info;
			int count = theInfo.getCount();
			Log.i(FN(), "Taps: " + count + " in " + TapsInfo.getStringForTapDirection(theInfo.getDirection()));
		}
		else if (info.getClass() == PedometerInfo.class) {
			PedometerInfo theInfo = (PedometerInfo)info;
			Log.i(FN(), "Steps: " + theInfo.getSteps());
		}
		else if (info.getClass() == FreeFallInfo.class) {
			FreeFallInfo theInfo = (FreeFallInfo)info;
			Log.i(FN(), "Free fall: " + (theInfo.getIsInFreeFall() ? "yes" : "no"));
		}
		else if (info.getClass() == MagnetometerCalInfo.class) {
			MagnetometerCalInfo theInfo = (MagnetometerCalInfo)info;
			Log.i(FN(), "Magno cal: " + (theInfo.getIsCalibrated() ? "yes" : "no"));
		}
		else if (info.getClass() == GyroscopeCalInfo.class) {
			GyroscopeCalInfo theInfo = (GyroscopeCalInfo)info;
			Log.i(FN(), "Gyro cal: " + (theInfo.getIsCalibrated() ? "yes" : "no"));
		}
	}

	/* ****************************************************************************************************
			Static
	*******************************************************************************************************/

	public static String FN() {
		StackTraceElement[] trace = Thread.currentThread().getStackTrace();
		if (trace.length >= 3) {
			//String methodName = trace[3].getMethodName();
			//return String.format("%s.%s", TAG, methodName);

			String fileName = trace[3].getFileName();
			int lineNumber = trace[3].getLineNumber();
			return String.format("%s:%d", fileName, lineNumber);
		}
		else {
			return "STACK TRACE TOO SHALLOW";
		}
	}
}
