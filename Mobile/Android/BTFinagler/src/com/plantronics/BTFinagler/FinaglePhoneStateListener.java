/* ********************************************************************************************************
	FinaglePhoneStateListener.java
	com.plantronics.BTFinagler

	Created by mdavis on 06/22/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.BTFinagler;

import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.media.AudioManager;
import android.os.Handler;
import android.os.Looper;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.widget.Toast;
import com.plantronics.BTFinagler.MainActivity;

import java.util.Timer;
import java.util.TimerTask;

public class FinaglePhoneStateListener extends PhoneStateListener {

	private static final String TAG = "BTFinagler.FinaglePhoneStateListener";

	private Timer timer;
	private TimerTask timerTask;
	private int scoAttempts;

	/* ****************************************************************************************************
			PhoneStateListener
	*******************************************************************************************************/

	public void onCallStateChanged (int state, String incomingNumber) {
		//Log.i(MainActivity.FN(), "onCallStateChanged: " + state);

		switch (state) {
			case TelephonyManager.CALL_STATE_OFFHOOK:
				Log.i(MainActivity.FN(), "CALL_STATE_OFFHOOK");
				break;
			case TelephonyManager.CALL_STATE_IDLE:
				Log.i(MainActivity.FN(), "CALL_STATE_IDLE");
				break;
			case TelephonyManager.CALL_STATE_RINGING:
				Log.i(MainActivity.FN(), "CALL_STATE_RINGING");
				break;
		}

//		if (state == TelephonyManager.CALL_STATE_OFFHOOK) {
//			Log.i(MainActivity.FN(), "CALL_STATE_OFFHOOK");
//
//			//Toast.makeText(MainActivity.mainActivity.getApplicationContext(), "Killing Bluetooth...", Toast.LENGTH_SHORT).show();
//			//bta.disable();
//
////			runDelayed(new Runnable() {
////				@Override
////				public void run() {
////					Log.i(MainActivity.FN(), "Attempting to finagle headset audio ON...");
////					AudioManager audioManager = (AudioManager)MainActivity.mainActivity.getSystemService(Context.AUDIO_SERVICE);
////					//audioManager.setMode(AudioManager.MODE_NORMAL);
////					audioManager.startBluetoothSco();
////					audioManager.setBluetoothScoOn(true);
////					//audioManager.setMode(AudioManager.MODE_IN_CALL);
////					//audioManager.setSpeakerphoneOn(false);
////
////					scoAttempts++;
////					scheduleTimer();
////
////					//Toast.makeText(MainActivity.mainActivity.getApplicationContext(), "Re-enabling Bluetooth...", Toast.LENGTH_SHORT).show();
//////					Log.i(MainActivity.FN(), "Turning Bluetooth ON...");
//////					BluetoothAdapter bta = BluetoothAdapter.getDefaultAdapter();
//////					bta.enable();
////				}
////			}, 1500);
//		}
//		else {
//			scoAttempts = 0;
//			if (timerTask != null) {
//				timerTask.cancel();
//			}
//		}
////		else if (state == TelephonyManager.CALL_STATE_IDLE) {
////			runDelayed(new Runnable() {
////				@Override
////				public void run() {
////					AudioManager audioManager;
////					audioManager = (AudioManager)MainActivity.mainActivity.getSystemService(Context.AUDIO_SERVICE);
////					audioManager.stopBluetoothSco();
////
////					Log.i(MainActivity.FN(), "Turning Bluetooth OFF...");
////					BluetoothAdapter bta = BluetoothAdapter.getDefaultAdapter();
////					bta.disable();
////				}
////			}, 100);
////		}
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void scheduleTimer() {
		Log.i(MainActivity.FN(), "scheduleTimer(" + scoAttempts + " attempts)");

		if (scoAttempts < 3) {
			Log.i(MainActivity.FN(), "(scheduling)");
			// start a timer to check if it worked
			timerTask = new TimerTask() {
				@Override
				public void run() {
					Log.i(MainActivity.FN(), "SCO timer fired");
					AudioManager audioManager = (AudioManager)MainActivity.mainActivity.getSystemService(Context.AUDIO_SERVICE);
					//if (!audioManager.isBluetoothScoOn()) {
						Log.i(MainActivity.FN(), "Still no SCO");
						scoAttempts++;
						audioManager.startBluetoothSco();
						audioManager.setBluetoothScoOn(true);
						//audioManager.setMode(AudioManager.MODE_IN_CALL);

						scheduleTimer();
//					}
//					else {
//						Log.i(MainActivity.FN(), "Got SCO!");
//					}
				}
			};

			timer = new Timer();
			timer.schedule(timerTask, 2000);
		}
	}

	private void runDelayed(Runnable runnable, int delay) {
		final Handler handler = new Handler(Looper.getMainLooper());
		handler.postDelayed(runnable, delay);
	}
}
