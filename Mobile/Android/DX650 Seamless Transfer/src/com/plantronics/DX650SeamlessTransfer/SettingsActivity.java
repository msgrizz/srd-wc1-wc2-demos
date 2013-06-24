/* ********************************************************************************************************
	SettingsActivity.java
	com.plantronics.DX650ScreenLock

	Created by mdavis on 05/30/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650SeamlessTransfer;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.TextView;

public class SettingsActivity extends Activity {

	public static String PREFERENCES_THRESHOLD = "PREFERENCES_THRESHOLD";
	public static SettingsActivity settingsActivity = null;

	private static final String TAG = "DX650SeamlessTransfer.SettingsActivity";
	//private static boolean killYourself = true;

	private SeekBar thresholdSeekBar;
	private TextView thresholdValueTextView;
	private int threshold;

	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_settings);

		thresholdSeekBar = (SeekBar)findViewById(R.id.thresholdSeekBar);
		thresholdValueTextView = (TextView)findViewById(R.id.thresholdValueTextView);

		((Button)findViewById(R.id.useCurrentDistanceButton)).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				useCurrentDistanceButtonClicked();
			}
		});
		((Button)findViewById(R.id.terminateButton)).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				MainApp.mainApp.kill();
			}
		});
		((Button)findViewById(R.id.saveButton)).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				finish();
			}
		});

		((SeekBar)findViewById(R.id.thresholdSeekBar)).setOnSeekBarChangeListener(onSeekBarChangeListener);

		SharedPreferences preferences = getPreferences(MODE_PRIVATE);
		MainApp.mainApp.setPreferences(preferences);
		threshold = preferences.getInt(PREFERENCES_THRESHOLD, 60);
		thresholdValueTextView.setText(new Integer(threshold).toString());
		thresholdSeekBar.setProgress(threshold);
	}

	@Override
	public void onResume() {
		super.onResume();
		settingsActivity = this;

//		if (killYourself) {
//			Log.i(TAG, "Killing myself now!");
//			killYourself = false;
//			finish();
//		}
	}

	@Override
	public void onPause() {
		super.onPause();

		SharedPreferences preferences = getPreferences(MODE_PRIVATE);
		SharedPreferences.Editor editor = preferences.edit();
		editor.putInt(PREFERENCES_THRESHOLD, threshold);
		editor.commit();

		settingsActivity = null;
	}

	@Override
	public void onBackPressed() {

	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private SeekBar.OnSeekBarChangeListener onSeekBarChangeListener = new SeekBar.OnSeekBarChangeListener() {
		@Override
		public void onStartTrackingTouch (SeekBar seekBar) {
			Log.i(TAG, "onStartTrackingTouch()");
		}
		@Override
		public void onStopTrackingTouch (SeekBar seekBar) {
			Log.i(TAG, "onStopTrackingTouch()");
		}
		@Override
		public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
			threshold = progress;
			thresholdValueTextView.setText(new Integer(threshold).toString());
			Log.i(TAG, "Seek bar changed: " + progress);
		}
	};

	private void useCurrentDistanceButtonClicked() {
		threshold = MainApp.mainApp.getHSSignalStrength();
		thresholdValueTextView.setText(new Integer(threshold).toString());
		thresholdSeekBar.setProgress(MainApp.mainApp.getHSSignalStrength());
	}
}
