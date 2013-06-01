/* ********************************************************************************************************
	SettingsActivity.java
	com.plantronics.DX650ScreenLock

	Created by mdavis on 05/30/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650ScreenLock;

import android.R;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.SeekBar;
import android.widget.TextView;

public class SettingsActivity extends Activity {

	public static String EXTRA_THRESHOLD = "EXTRA_THRESHOLD";

	public static SettingsActivity settingsActivity = null;
	public static final int SETTINGS_ACTIVITY = 100;

	private static final String TAG = "com.plantronics.DX650SeamlessTransfer.SettingsActivity";

	private SeekBar thresholdSeekBar;
	private TextView thresholdValueTextView;
	private Button useCurrentDistanceButton;
	private int threshold;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
//		setContentView(R.layout.activity_settings);
//
//		thresholdSeekBar = (SeekBar)findViewById(R.id.thresholdSeekBar);
//		thresholdValueTextView = (TextView)findViewById(R.id.thresholdValueTextView);
//		useCurrentDistanceButton = (Button)findViewById(R.id.useCurrentDistanceButton);
//
//		findViewById(R.id.useCurrentDistanceButton).setOnClickListener(new View.OnClickListener() {
//			@Override
//			public void onClick(View v) {
//
//			}
//		});
//
//		((SeekBar)findViewById(R.id.thresholdSeekBar)).setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
//			@Override
//			public void onStartTrackingTouch (SeekBar seekBar) {
//				Log.i(TAG, "onStartTrackingTouch()");
//			}
//			@Override
//			public void onStopTrackingTouch (SeekBar seekBar) {
//				Log.i(TAG, "onStopTrackingTouch()");
//			}
//			@Override
//			public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
//				threshold = progress;
//				thresholdValueTextView.setText(new Integer(threshold).toString());
//				Log.i(TAG, "Seek bar changed: " + progress);
//			}
//		});

		threshold = getIntent().getExtras().getInt(EXTRA_THRESHOLD, 0);
		thresholdValueTextView.setText(new Integer(threshold).toString());
		thresholdSeekBar.setProgress(threshold);
	}

	@Override
	public void onResume() {
		super.onResume();
		settingsActivity = this;
	}

	@Override
	public void onPause() {
		super.onPause();
		settingsActivity = null;
	}

	@Override
	public void onBackPressed() {

		//Intent result = new Intent();
		Intent result = getIntent();
//		Bundle bundle = new Bundle();
//		bundle.putInt(SettingsActivity.EXTRA_THRESHOLD, threshold);
//		result.putExtras(bundle);
		result.putExtra(SettingsActivity.EXTRA_THRESHOLD, threshold);
		setResult(RESULT_OK, result);
		finish();

		super.onBackPressed();
	}
}
