/* ********************************************************************************************************
	MainActivity.java
	com.plantronics.DX650ScreenLock

	Created by mdavis on 05/something/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650ScreenLock;

import android.app.Activity;
import android.app.admin.DevicePolicyManager;
import android.content.*;
import android.os.*;
import android.text.Html;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import org.apache.commons.lang3.text.WordUtils;
import java.util.*;

public class LockActivity extends Activity {

	public static LockActivity lockActivity = null;

	private static final String TAG = "DX650ScreenLock.LockActivity";

	private DevicePolicyManager dpm;
	private ComponentName deviceAdmin;

	//private static boolean lockOnPause;
	private Timer clockTimer;
	private TimerTask clockTimerTask;

	private RelativeLayout mainLayout;
	private ProgressBar progressBar;
	private TextView bigTextView;
	private TextView smallTextView;
	private TextView timeTextView;
	private TextView dateTextView;

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

	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Log.i(FN(), "************* onCreate() *************");

		lockActivity = this;

		setContentView(R.layout.activity_main);

		mainLayout = (RelativeLayout)findViewById(R.id.mainLayout);
		progressBar = (ProgressBar)findViewById(R.id.progressBar);
		bigTextView = (TextView)findViewById(R.id.bigTextView);
		smallTextView = (TextView)findViewById(R.id.smallTextView);
		timeTextView = (TextView)findViewById(R.id.timeTextView);
		dateTextView = (TextView)findViewById(R.id.dateTextView);

		findViewById(R.id.killButton).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				killButtonClicked();
			}
		});
		findViewById(R.id.homeButton).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				homeButtonClicked();
			}
		});
		findViewById(R.id.settingsButton).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				settingsButtonClicked();
			}
		});

		dpm = (DevicePolicyManager)this.getSystemService(Context.DEVICE_POLICY_SERVICE);
		deviceAdmin = new ComponentName(this, com.plantronics.DX650ScreenLock.LockerReceiver.class);
		if (!dpm.isAdminActive(deviceAdmin)) {
			Intent adminIntent = new Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN);
			adminIntent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, deviceAdmin);
			adminIntent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, getString(R.string.add_admin_extra_app_text));
			this.startActivity(adminIntent);
		}
	}

	@Override
	protected void onPause() {
		Log.i(FN(), "************* onPause() *************");

		if (clockTimerTask != null) {
			clockTimerTask.cancel();
			clockTimer = null;
		}

		MainApp.mainApp.onPause();

		super.onPause();
		lockActivity = null;
	}

	@Override
	protected void onResume() {
		Log.i(FN(), "************* onResume() *************");
		super.onResume();
		lockActivity = this;

		getWindow().addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED);
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD);
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE);

		if (clockTimer == null) {
			clockTimerTask = new TimerTask() {
				@Override
				public void run() {
					updateClockUI();
				}
			};
			clockTimer = new Timer();
			clockTimer.scheduleAtFixedRate(clockTimerTask, 30000, 30000);
		}
		updateClockUI();

		MainApp.mainApp.onResume();
	}

	@Override
	protected void onDestroy() {
		Log.i(FN(), "************* onDestroy() *************");
		super.onDestroy();
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		MainApp.mainApp.onActivityResult(requestCode, resultCode, data);
	}

	/* ****************************************************************************************************
			View
	*******************************************************************************************************/

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event)  {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	/* ****************************************************************************************************
			Public
	*******************************************************************************************************/

	public void setUILocked() {
		Log.i(FN(), "setUILocked()");
		progressBar.setVisibility(android.widget.ProgressBar.INVISIBLE);
		mainLayout.setBackgroundResource(R.drawable.bg_locked);
//		Typeface robotoLight = Typeface.createFromAsset(context.getAssets(), "Roboto-Light.ttf");
//		bigTextView.setTypeface(robotoLight);
		bigTextView.setText(Html.fromHtml("Screen is <b>locked</b>"));
		smallTextView.setText("");
	}

	public void setUIUsername() {
		Log.i(FN(), "setUIUsername()");
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				mainLayout.setBackgroundResource(R.drawable.bg_userpass);
				bigTextView.setText(Html.fromHtml("Screen is <b>locked</b>"));
				smallTextView.setText("Please say your username");
			}
		});
	}

	public void setUIPassphrase(final String username, final boolean titleOnly) {
		Log.i(FN(), "setUIPassphrase: " + username + ", titleOnly: " + titleOnly);
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				String capitalizedName = WordUtils.capitalize(username);
				String nameString = String.format("Welcome <b>%s</b>", capitalizedName);
				bigTextView.setText(Html.fromHtml(nameString));

				if (titleOnly) {
					mainLayout.setBackgroundResource(R.drawable.bg_locked);
					smallTextView.setText("");
				}
				else {
					mainLayout.setBackgroundResource(R.drawable.bg_userpass);
					smallTextView.setText("Please say your passphrase");
				}
			}
		});
	}

	public void setUIDiscovery(final boolean flag) {
		Log.i(FN(), "setUIDiscovery: " + flag);
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (flag) {
					progressBar.animate();
					progressBar.setVisibility(ProgressBar.VISIBLE);
				}
				else {
					progressBar.setVisibility(ProgressBar.INVISIBLE);
				}
			}
		});
	}

	public void updateClockUI() {
		Log.i(FN(), "updateClockUI()");
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				final String[] weekdays = {"SUN", "MON", "TUES", "WED", "THURS", "FRI", "SAT"};
				final String[] months = {"JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"};
				Date date = new Date();
				String timeString = String.format("<b>%d</b>:%02d", date.getHours(), date.getMinutes());
				String dateString = String.format("<b>%s, %s %02d</b>", weekdays[date.getDay()], months[date.getMonth()], date.getDay());
				timeTextView.setText(Html.fromHtml(timeString));
				dateTextView.setText(Html.fromHtml(dateString));
			}
		});
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void killButtonClicked() {
		Log.i(FN(), "killButtonClicked()");

		MainApp.mainApp.kill();
	}

	private void homeButtonClicked() {
		Log.i(FN(), "homeButtonClicked()");
		MainApp.mainApp.goHome();
	}

	private void settingsButtonClicked() {
		Log.i(FN(), "settingsButtonClicked()");

		MainApp.mainApp.setLockOnPause(false);
		Intent intent = new Intent(getApplicationContext(), SettingsActivity.class);
//		Bundle bundle = new Bundle();
//		bundle.putInt(SettingsActivity.EXTRA_THRESHOLD, hsNearSignalStrengthThreshold);
		intent.putExtra(SettingsActivity.EXTRA_THRESHOLD, MainApp.mainApp.getHSNearSignalStrengthThreshold());
		intent.putExtra(SettingsActivity.EXTRA_USERS, MainApp.mainApp.getUsers());
		//intent.putExtras(bundle);
		startActivityForResult(intent, SettingsActivity.SETTINGS_ACTIVITY);
	}

	private void runOnMainThread(Runnable runnable) {
//		final Handler handler = new Handler(Looper.getMainLooper());
//		handler.post(runnable);

		runOnUiThread(runnable);
	}
}

