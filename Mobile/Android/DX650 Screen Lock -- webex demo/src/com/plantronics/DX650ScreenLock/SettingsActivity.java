/* ********************************************************************************************************
	SettingsActivity.java
	com.plantronics.DX650ScreenLock

	Created by mdavis on 05/30/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650ScreenLock;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.*;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

public class SettingsActivity extends Activity {

	public static final String EXTRA_THRESHOLD = "EXTRA_THRESHOLD";
	public static final String EXTRA_USERS = "EXTRA_USERS";
	public static final String EXTRA_QUIT_FLAG = "EXTRA_QUIT_FLAG";

	public static SettingsActivity settingsActivity = null;
	public static final int SETTINGS_ACTIVITY = 100;

	private static final String TAG = "com.plantronics.DX650ScreenLock.SettingsActivity";

	private SeekBar thresholdSeekBar;
	private TextView thresholdValueTextView;
	private Button useCurrentDistanceButton;
	private int threshold;
	private ArrayAdapter<User> usersArrayAdapter;
	private ListView usersListView;
	private ArrayList<User> users;
	private Button addUserButton;
	private Button removeUserButton;
	private Button terminateButton;

	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_settings);

		thresholdSeekBar = (SeekBar)findViewById(R.id.thresholdSeekBar);
		thresholdValueTextView = (TextView)findViewById(R.id.thresholdValueTextView);
		useCurrentDistanceButton = (Button)findViewById(R.id.useCurrentDistanceButton);

		useCurrentDistanceButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				// set from MainActivity's hsRSSI
			}
		});

		((SeekBar)findViewById(R.id.thresholdSeekBar)).setOnSeekBarChangeListener(onSeekBarChangeListener);

		threshold = getIntent().getExtras().getInt(EXTRA_THRESHOLD, 0);
		thresholdValueTextView.setText(new Integer(threshold).toString());
		thresholdSeekBar.setProgress(threshold);

		usersListView = (ListView)findViewById(R.id.usersListView);
		addUserButton = (Button)findViewById(R.id.addUserButton);
		removeUserButton = (Button)findViewById(R.id.removeUserButton);
		terminateButton = (Button)findViewById(R.id.terminateButton);

		addUserButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				addButtonClicked();
			}
		});
		removeUserButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				removeButtonClicked();
			}
		});
		terminateButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				terminateButton();
			}
		});

		users = (ArrayList<User>)getIntent().getExtras().get(EXTRA_USERS);
		usersArrayAdapter = new ArrayAdapter<User>(this, R.layout.listitem_users);
		ListView usersListView = (ListView) findViewById(R.id.usersListView);
		usersArrayAdapter.addAll(users);
		usersListView.setOnItemClickListener(userOnClickListener);
		usersListView.setAdapter(usersArrayAdapter);
	}

	@Override
	public void onResume() {
		super.onResume();
		settingsActivity = this;

		usersListView.setSelection(ListView.INVALID_POSITION);
		removeUserButton.setEnabled(false);
	}

	@Override
	public void onPause() {
		super.onPause();
		settingsActivity = null;
	}

	@Override
	public void onBackPressed() {
		Intent result = getIntent();
		result.putExtra(EXTRA_THRESHOLD, threshold);
		result.putExtra(EXTRA_USERS, users);
		setResult(RESULT_OK, result);
		finish();

		super.onBackPressed();
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		switch (requestCode) {
			case AddUserActivity.ADDUSER_ACTIVITY:
				Log.i(TAG, "************* AddUserActivity closed. *************");
				if (resultCode==RESULT_OK) {
					String newUsername = data.getStringExtra(AddUserActivity.EXTRA_USERNAME);
					String newPassphrase = data.getStringExtra(AddUserActivity.EXTRA_PASSPHRASE);
					Log.i(TAG, "newUsername: " + newUsername + " newPassphrase: " + newPassphrase);
					User newUser = new User(newUsername, newPassphrase);
					Log.i(TAG, "newUser: " + newUser);
					usersArrayAdapter.add(newUser);
					users.add(newUser);
				}
				break;
			default:
				Log.e(TAG, "onActivityResult(): unknown request code: '"+requestCode+"'");
		}
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

	private AdapterView.OnItemClickListener userOnClickListener = new AdapterView.OnItemClickListener() {
		public void onItemClick(AdapterView<?> av, View v, int position, long id) {

			User user = (User)av.getItemAtPosition(position);
			Log.i(TAG, "user: " + user);

			if (position != ListView.INVALID_POSITION ) {
				removeUserButton.setEnabled(true);
			}
		}
	};

	private void addButtonClicked() {
		Intent intent = new Intent(getApplicationContext(), AddUserActivity.class);
		startActivityForResult(intent, AddUserActivity.ADDUSER_ACTIVITY);
	}

	private void removeButtonClicked() {
		// check user selected, remove selected user
		int position = usersListView.getSelectedItemPosition();
		if (position != ListView.INVALID_POSITION ) {
			usersArrayAdapter.remove((User)usersListView.getSelectedItem());
		}
	}

	private void terminateButton() {
		Intent result = getIntent();
		result.putExtra(EXTRA_QUIT_FLAG, true);
		setResult(RESULT_OK, result);
		finish();
	}
}
