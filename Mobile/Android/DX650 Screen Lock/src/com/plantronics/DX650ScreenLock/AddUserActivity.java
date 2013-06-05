/* ********************************************************************************************************
	AddUserActivity.java
	com.plantronics.DX650ScreenLock

	Created by mdavis on 06/04/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650ScreenLock;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

public class AddUserActivity extends Activity {

	public static final int ADDUSER_ACTIVITY = 102;
	public static final String EXTRA_USERNAME = "EXTRA_USERNAME";
	public static final String EXTRA_PASSPHRASE = "EXTRA_PASSPHRASE";

	private static final String TAG = "com.plantronics.DX650ScreenLock.AddUserActivity";

	private EditText usernameEditText;
	private EditText passphraseEditText;
	private Button saveButton;
	private Button cancelButton;

	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_adduser);

		usernameEditText = (EditText)findViewById(R.id.usernameEditText);
		passphraseEditText = (EditText)findViewById(R.id.passphraseEditText);
		saveButton = (Button)findViewById(R.id.saveButton);
		cancelButton = (Button)findViewById(R.id.cancelButton);

		saveButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				saveButtonClicked();
			}
		});
		cancelButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				cancelButtonClicked();
			}
		});
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void saveButtonClicked() {
		Log.i(TAG, "saveButtonClicked()");

		Intent result = getIntent();
		result.putExtra(EXTRA_USERNAME, usernameEditText.getText().toString());
		result.putExtra(EXTRA_PASSPHRASE, passphraseEditText.getText().toString());
		setResult(RESULT_OK, result);
		finish();
	}

	private void cancelButtonClicked() {
		Log.i(TAG, "cancelButtonClicked()");

		setResult(RESULT_CANCELED);
		this.finish();
	}

	@Override
	public void onBackPressed() {
		Log.i(TAG, "onBackPressed()");

		setResult(RESULT_CANCELED);
		this.finish();
	}
}
