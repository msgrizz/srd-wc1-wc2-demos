/* ********************************************************************************************************
	TransferActivity.java
	com.plantronics.DX650SeamlessTransfer

	Created by mdavis on 05/31/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650SeamlessTransfer;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

public class AskTransferActivity extends Activity {

	public static AskTransferActivity askTransferActivity = null;
	public static final int ASK_TRANSFER_ACTIVITY = 101;

	private static final String TAG = "com.plantronics.DX650SeamlessTransfer.AskTransferActivity";

	private static boolean killYourself = true;

	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_ask_transfer);

		Log.i(TAG, "*********************************************** &^%#@&^%$@&*#^%$&*@^#%$&*@#%$&*^@%#$&^%@#$&^%@#$&^%@#*&$^%@&*^#$%&*^%#$&*^@%$ onCreate()");

		findViewById(R.id.yes_button).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				Log.i(TAG, "yes_button");
				Intent result = getIntent();
				setResult(RESULT_OK, result);
				finish();
			}
		});
		findViewById(R.id.no_button).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				Log.i(TAG, "no_button");
				Intent result = getIntent();
				setResult(RESULT_CANCELED, result);
				finish();
			}
		});
	}

	@Override
	public void onResume() {
		super.onResume();
		askTransferActivity = this;

		if (killYourself) {
			Log.i(TAG, "Killing myself now!");
			killYourself = false;
			finish();
		}
	}

	@Override
	public void onPause() {
		super.onPause();
		askTransferActivity = null;
	}
}
