package com.plantronics.DX650ScreenLock;

import android.os.Bundle;
import android.app.Activity;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Intent;
import android.view.Menu;

public class MainActivity extends Activity {

	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		//setContentView(R.layout.activity_main);

		Intent i = new Intent(this, com.plantronics.DX650ScreenLock.LockScreen.class);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		this.startActivity(i);

		this.finish();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_main, menu);
		return true;
	}
}
