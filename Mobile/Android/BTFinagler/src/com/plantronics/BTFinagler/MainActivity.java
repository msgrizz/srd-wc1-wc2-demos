/* ********************************************************************************************************
	MainActivity.java
	com.plantronics.BTFinagler

	Created by mdavis on 06/22/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.BTFinagler;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.telephony.PhoneStateListener;
import android.util.Log;

public class MainActivity extends Activity {

	public static MainActivity mainActivity;

	private static final String TAG = "BTFinagler.MainActivity";

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
			return "STACK TRACE TO SHALLOW";
		}
	}

	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		mainActivity = this;

		com.plantronics.BTFinagler.FinaglePhoneStateListener listener = new com.plantronics.BTFinagler.FinaglePhoneStateListener();
		final TelephonyManager tm = (TelephonyManager)getSystemService(Context.TELEPHONY_SERVICE);
		tm.listen(listener, PhoneStateListener.LISTEN_CALL_STATE);
		Log.i(FN(), "Listening for phone state changes...");
	}
}
