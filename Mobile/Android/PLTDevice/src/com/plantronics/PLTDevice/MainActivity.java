/* ********************************************************************************************************
	MainActivity.java
	com.plantronics.PLTDevice

	Created by mdavis on 03/11/2014.
	Copyright (c) 2014 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.PLTDevice;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import com.plantronics.bladerunner.model.device.BladeRunnerDevice;

import java.util.Set;

public class MainActivity extends Activity implements ConnectionListener {

	private static final String TAG = "com.plantronics.PLTDevice";

	private Device 		_device;

	private TextView	_connectedTextView;
	private Button		_openConnectionButton;
	private Button		_subscribeButton;


	/* ****************************************************************************************************
			 Private (Activity)
	*******************************************************************************************************/

	public void onCreate(Bundle savedInstanceState) {
		Log.i(FN(), "onCreate()");
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		_connectedTextView = ((TextView)findViewById(R.id.connectedTextView));
		_connectedTextView.setVisibility(1);

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
		_subscribeButton.setEnabled(false);

//		_device = new Device(this);
//		_device.setConnectionListener(this);
	}

	@Override
	public void onResume() {
		Log.i(FN(), "onResume()");
		super.onResume();

		if (_device != null) {
			_device.onResume();
			_device.openConnection();
		}
	}

	@Override
	protected void onPause() {
		Log.i(FN(), "onPause()");
		super.onPause();

		if (_device != null) {
			_device.onPause();
		}
	}

	/* ****************************************************************************************************
			 Private
	*******************************************************************************************************/

	private void openConnectionButton() {
		Log.i(FN(), "openConnectionButton()");

		Device.getAvailableDevices(this, new Device.AvailableDevicesCallback() {
			@Override
			public void onAvailableDevices(Set<BladeRunnerDevice> devices) {
				Log.i(FN(), "onAvailableDevices(): " + devices);
			}

			@Override
			public void failure() {
				Log.i(FN(), "failure()");
			}
		});
	}

	private void subscribeButton() {

	}

	/* ****************************************************************************************************
			 ConnectionListener
	*******************************************************************************************************/

	public void onConnectionOpen(Device device) {
		Log.i(FN(), "onConnectionOpen()");

		_connectedTextView.setVisibility(0);
	}

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
}
