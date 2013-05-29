package com.plantronics.DX650ScreenLock;

import android.os.Bundle;
import android.os.PowerManager;
import android.os.SystemClock;
import android.app.Activity;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;

public class LockScreen extends Activity {

	public static LockScreen lockScreen = null;
	private static final String TAG = "com.plantronics.DX650ScreenLock.LockScreen";

	private static DevicePolicyManager dpm = null;
	private static ComponentName deviceAdmin = null;
	private static boolean lockOnPause = true;
	public ProgressBar progressBar;

	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		setContentView(R.layout.lock_screen);

		dpm = (DevicePolicyManager)this.getSystemService(Context.DEVICE_POLICY_SERVICE);
		deviceAdmin = new ComponentName(this, com.plantronics.DX650ScreenLock.LockerReceiver.class);
		lockOnPause = true;
		lockScreen = this;

		this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED);
		this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD);
		this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
		this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		this.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE);

		progressBar = (ProgressBar)findViewById(R.id.progressBar);

		this.findViewById(R.id.unlock).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				unlockDevice();
			}
		});
//		this.findViewById(R.id.send_to_lock).setOnClickListener(new View.OnClickListener() {
//			@Override
//			public void onClick(View v) {
//				sendToLockScreen();
//			}
//		});

		if (!dpm.isAdminActive(deviceAdmin)) {
			Intent intent = new Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN);
	        intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, deviceAdmin);
	        intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, getString(R.string.add_admin_extra_app_text));
	        this.startActivity(intent);
		}
	}

//	@Override
//	protected void onStart() {
//		super.onStart();
//
//
//	}

	@Override
	protected void onResume() {
		super.onResume();
		lockScreen = this;
	}

	@Override
	protected void onPause() {
		super.onPause();

		if (lockOnPause) {
			lockDevice();
		}

		lockScreen = null;
	}

	public boolean onKeyDown(int keyCode, KeyEvent event)  {

	    if (keyCode == KeyEvent.KEYCODE_BACK) {

	        return true;
	    }
	    return super.onKeyDown(keyCode, event);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		return false;
	}

	/* ****************************************************************************************************
			Public
	*******************************************************************************************************/
//
//	public static void sendToLockScreen() {
//
//		lockOnPause = false;
//		lockDevice();
//		if (lockScreen!=null) {
//			lockScreen.finish();
//		}
//	}

	public static void unlockDevice() {

		Log.e(TAG,"unlock");
		lockOnPause = false;
		if (lockScreen!=null) {
			Log.e(TAG,"not null unlock");
			lockScreen.finish();
		}
	}

	public static void setProgressBarHidden(boolean hidden) {
		int visibility = (hidden ? android.widget.ProgressBar.INVISIBLE : android.widget.ProgressBar.VISIBLE);
		lockScreen.progressBar.setVisibility(visibility);
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private static void lockDevice() {

		if (dpm != null && deviceAdmin != null && lockScreen != null) {
			if (dpm.isAdminActive(deviceAdmin)) {
				dpm.lockNow();
			}

			PowerManager pm = (PowerManager) lockScreen.getSystemService(Context.POWER_SERVICE);
			PowerManager.WakeLock wl = pm.newWakeLock(PowerManager.FULL_WAKE_LOCK | PowerManager.ACQUIRE_CAUSES_WAKEUP, "BluetoothLocker");

			wl.acquire();
			wl.release();
		}
	}
}
