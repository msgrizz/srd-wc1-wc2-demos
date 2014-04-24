/* ********************************************************************************************************
	MainActivity.java
	com.plantronics.PLTDevice

	Created by mdavis on 03/11/2014.
	Copyright (c) 2014 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.device.test;

import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import com.plantronics.device.*;
import com.plantronics.device.info.Info;

import java.util.ArrayList;

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

		// OPTIONAL: If your activity's onPause() called Device.onPause() stop receiving subscribed info while inactive, call Device.onRusume() here to resume subscribed info.
		if (_device != null) {
			_device.onResume();
		}
	}

	@Override
	protected void onPause() {
		Log.i(FN(), "onPause()");
		super.onPause();

		_context = null;

		// OPTIONAL: If your activity doesnt want to receive subscribed info while inactive, call Device.onPause().
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

		if (_device == null) {
			ArrayList<Device> devices = Device.getPairedDevices();

			if (devices.size() > 0) {
				_device = devices.get(0);
				_device.registerConnectionListener(this);
				_device.openConnection();
			}
			else {
				Log.i(FN(), "No PLT devices found!");
			}
		}
	}

	private void subscribeButton() {
		Log.i(FN(), "subscribeButton()");

		_device.subscribe(this, Device.SERVICE_WEARING_STATE, Device.SUBSCRIPTION_MODE_PERIODIC, 1000);
//		_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_ON_CHANGE, 1000);
//		_device.subscribe(this, Device.SERVICE_ORIENTATION_TRACKING, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
//		_device.subscribe(this, Device.SERVICE_TAPS, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
//		_device.subscribe(this, Device.SERVICE_PEDOMETER, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
//		_device.subscribe(this, Device.SERVICE_FREE_FALL, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
//		_device.subscribe(this, Device.SERVICE_MAGNETOMETER_CAL_STATUS, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
//		_device.subscribe(this, Device.SERVICE_GYROSCOPE_CAL_STATUS, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
	}

	private void changeSubscriptionButton1() {
		Log.i(FN(), "changeSubscriptionButton1()");

		_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_PERIODIC, 2000);
	}

	private void changeSubscriptionButton2() {
		Log.i(FN(), "changeSubscriptionButton2()");

		_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_PERIODIC, 15);
	}

	private void changeSubscriptionButton3() {
		Log.i(FN(), "changeSubscriptionButton3()");

		_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_PERIODIC, 15);
	}

	private void changeSubscriptionButton4() {
		Log.i(FN(), "changeSubscriptionButton4()");

		_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
	}

	private void changeSubscriptionButton5() {
		Log.i(FN(), "changeSubscriptionButton5()");

		_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
	}

	private void unsubscribeButton() {
		Log.i(FN(), "unsubscribeButton()");

		_device.unsubscribe(this, Device.SERVICE_PROXIMITY);
	}

	private void unsubscribeAllButton() {
		Log.i(FN(), "unsubscribeAllButton()");

		_device.unsubscribe(this);
	}

	private void queryButton() {
		Log.i(FN(), "queryButton()");

		_device.queryInfo(this, Device.SERVICE_WEARING_STATE);
//		_device.queryInfo(this, Device.SERVICE_PROXIMITY);
//		_device.queryInfo(this, Device.SERVICE_ORIENTATION_TRACKING);
//		_device.queryInfo(this, Device.SERVICE_PEDOMETER);
//		_device.queryInfo(this, Device.SERVICE_FREE_FALL);
//		_device.queryInfo(this, Device.SERVICE_TAPS);
//		_device.queryInfo(this, Device.SERVICE_MAGNETOMETER_CAL_STATUS);
//		_device.queryInfo(this, Device.SERVICE_GYROSCOPE_CAL_STATUS);
	}

	private void getCachedButton() {
		Log.i(FN(), "getCachedButton()");

		Log.i(FN(), "SERVICE_PROXIMITY: " + _device.getCachedInfo(Device.SERVICE_PROXIMITY));
		Log.i(FN(), "SERVICE_WEARING_STATE: " + _device.getCachedInfo(Device.SERVICE_WEARING_STATE));
		Log.i(FN(), "SERVICE_ORIENTATION_TRACKING: " + _device.getCachedInfo(Device.SERVICE_ORIENTATION_TRACKING));
		Log.i(FN(), "SERVICE_PEDOMETER: " + _device.getCachedInfo(Device.SERVICE_PEDOMETER));
		Log.i(FN(), "SERVICE_FREE_FALL: " + _device.getCachedInfo(Device.SERVICE_FREE_FALL));
		Log.i(FN(), "SERVICE_TAPS: " + _device.getCachedInfo(Device.SERVICE_TAPS));
		Log.i(FN(), "SERVICE_MAGNETOMETER_CAL_STATUS: " + _device.getCachedInfo(Device.SERVICE_MAGNETOMETER_CAL_STATUS));
		Log.i(FN(), "SERVICE_GYROSCOPE_CAL_STATUS: " + _device.getCachedInfo(Device.SERVICE_GYROSCOPE_CAL_STATUS));
	}

	public void calibrateButton() {
		Log.i(FN(), "calibrateButton()");

		_device.setCalibration(null, Device.SERVICE_ORIENTATION_TRACKING);

		_device.setCalibration(null, Device.SERVICE_PEDOMETER);
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
		Log.i(FN(), "onConnectionOpen()");

		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				_connectedTextView.setText("Connected");
			}
		});
	}

	public void onConnectionFailedToOpen(Device device, int error) {
		Log.i(FN(), "onConnectionFailedToOpen()");

		if (error == Device.ERROR_CONNECTION_TIMEOUT) {
			Log.i(FN(), "Open connection timed out.");
		}
	}

	public void onConnectionClosed(Device device) {
		Log.i(FN(), "onConnectionClosed()");

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
