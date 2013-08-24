package com.plantronics.DX650ScreenLock;

import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

public class LockerReceiver extends DeviceAdminReceiver {

	@Override
	public CharSequence onDisableRequested(Context context, Intent intent) {
		//Toast.makeText(context, "onDisableRequested", Toast.LENGTH_LONG).show();
		return context.getString(R.string.disable_requested_text);
	}

	@Override
	public void onDisabled(Context context, Intent intent) {
		super.onDisabled(context, intent);
		//Toast.makeText(context, "onDisabled", Toast.LENGTH_LONG).show();
	}

	@Override
	public void onEnabled(Context context, Intent intent) {
		super.onEnabled(context, intent);
		//Toast.makeText(context, "onEnabled", Toast.LENGTH_LONG).show();
	}

	@Override
	public void onReceive(Context context, Intent intent) {
		super.onReceive(context, intent);
		//Toast.makeText(context, "onReceive", Toast.LENGTH_LONG).show();
	}

}
