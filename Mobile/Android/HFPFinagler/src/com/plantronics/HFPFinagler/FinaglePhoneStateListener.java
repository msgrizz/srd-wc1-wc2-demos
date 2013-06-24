/* ********************************************************************************************************
	FinaglePhoneStateListener.java
	com.plantronics.HFPFinagler

	Created by mdavis on 06/22/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.HFPFinagler;

import android.content.Context;
import android.media.AudioManager;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.util.Log;
import com.plantronics.HFPFinagler.MainActivity;

public class FinaglePhoneStateListener extends PhoneStateListener {

	private static final String TAG = "HFPFinagler.FinaglePhoneStateListener";

//	public PhoneStateListener () {
//
//	}

	/* ****************************************************************************************************
			PhoneStateListener
	*******************************************************************************************************/

	public void onCallStateChanged (int state, String incomingNumber) {
		Log.i(MainActivity.FN(), "onCallStateChanged: " + state);

		if (state == TelephonyManager.CALL_STATE_OFFHOOK) {
			Log.i(MainActivity.FN(), "CALL_STATE_OFFHOOK -- attempting to finagle BT audio ON...");

			AudioManager audioManager;
			audioManager = (AudioManager)MainActivity.mainActivity.getSystemService(Context.AUDIO_SERVICE);
			audioManager.setMode(AudioManager.MODE_IN_CALL);
			audioManager.setSpeakerphoneOn(false);
		}
	}
}
