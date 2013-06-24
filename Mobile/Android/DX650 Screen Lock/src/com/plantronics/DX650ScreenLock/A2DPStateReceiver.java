/* ********************************************************************************************************
	A2DPStateReceiver.java
	com.plantronics.DX650ScreenLock

	Created by mdavis on 06/03/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650ScreenLock;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.bluetooth.BluetoothProfile;

public class A2DPStateReceiver extends BroadcastReceiver {

	private static final String TAG = "DX650ScreenLock.A2DPStateReceiver";

	public void onReceive(Context context, Intent intent) {
		Log.i(TAG, "onReceive: " + intent);
		Bundle extras = intent.getExtras();
		Log.i(TAG, "extras: " + extras);

		int state = extras.getInt(BluetoothProfile.EXTRA_STATE);

		if (state == BluetoothProfile.STATE_CONNECTED) {
			Log.i(TAG, "A2DP connected.");
		}
		else if (state == BluetoothProfile.STATE_DISCONNECTED) {
			Log.i(TAG, "A2DP disconnected.");
		}
	}
}
