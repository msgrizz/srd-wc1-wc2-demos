package com.plantronics.SpeechStuff;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.widget.TextView;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import android.speech.tts.TextToSpeech.OnInitListener;
import android.speech.tts.TextToSpeech.OnUtteranceCompletedListener;

public class MainActivity extends Activity implements RecognitionListener, OnInitListener, OnUtteranceCompletedListener {

	private TextView mText;
	private SpeechRecognizer sr;
	private TextToSpeech tts;
	private static final String TAG = "MainActivity";

	/* ****************************************************************************************************
			Activity
	*******************************************************************************************************/

	@Override
	public void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		setContentView(R.layout.speech_rec_activity);
		mText = (TextView) findViewById(R.id.textView);
		sr = SpeechRecognizer.createSpeechRecognizer(this);
		sr.setRecognitionListener(this);
		tts = new TextToSpeech(this, this);

		startListening();
	}

	@Override
	public void onResume() {
		super.onResume();
		startListening();
	}

	@Override
	public void onPause() {
		if (sr !=null ) {
			sr.stopListening();
		}
		if (tts != null) {
			tts.stop();
		}
		super.onPause();
	}

	@Override
	public void onDestroy() {
		if (sr !=null ) {
			sr.stopListening();
			sr.destroy();
		}
		if (tts != null) {
			tts.stop();
			tts.shutdown();
		}
		super.onDestroy();
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void startListening() {

		Log.i(TAG, "************* startListening *************");

		Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
		intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
		intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, "voice.recognition.test");
		intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3);
		sr.startListening(intent);
	}

	private void startSpeaking(String text) {

		Log.i(TAG, "************* onReadyForSpeech *************");

		HashMap<String, String> params = new HashMap<String, String>();
		params.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, "stringId");
		tts.speak(text, TextToSpeech.QUEUE_FLUSH, params);
	}

	/* ****************************************************************************************************
			RecognitionListener
	*******************************************************************************************************/

	public void onReadyForSpeech(Bundle params) {
		Log.i(TAG, "************* onReadyForSpeech *************");
	}

	public void onBeginningOfSpeech() {
		Log.i(TAG, "************* onBeginningOfSpeech *************");
	}

	public void onRmsChanged(float rmsdB) {
		Log.d(TAG, "onRmsChanged");
	}

	public void onBufferReceived(byte[] buffer) {
		Log.d(TAG, "onBufferReceived");
	}

	public void onEndOfSpeech() {
		Log.i(TAG, "************* onEndofSpeech *************");
	}

	public void onError(int error) {
		Log.i(TAG,  "************* onError: " +  error + "*************");
		//mText.setText("error " + error);
		mText.append("\n[error " + error + "]");
	}

	public void onResults(Bundle results) {

		Log.i(TAG, "************* onResults: " + results + "*************");
		ArrayList data = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
		String str = "\n";
		str += data.get(0);
		for (int i = 0; i < data.size(); i++) {
			Log.i(TAG, "result " + data.get(i));
			//str += "\n" + data.get(i);
		}

		mText.append(str);
		startSpeaking(str);
	}

	public void onPartialResults(Bundle partialResults) {
		Log.i(TAG, "onPartialResults");
	}

	public void onEvent(int eventType, Bundle params) {
		Log.i(TAG, "onEvent " + eventType);
	}

	/* ****************************************************************************************************
			OnInitListener
	*******************************************************************************************************/

	@Override
	public void onInit(int status) {

		if (status == TextToSpeech.SUCCESS) {
			int result = tts.setLanguage(Locale.US);
			if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
				Log.e(TAG, "This Language is not supported");
			}
			else {
				tts.setOnUtteranceCompletedListener(this);
			}
		}
		else {
			Log.e(TAG, "Initilization Failed!");
		}
	}

	/* ****************************************************************************************************
			OnUtteranceCompletedListener
	*******************************************************************************************************/

	public void onUtteranceCompleted(String utteranceId) {

		Log.i(TAG, "************* onUtteranceCompleted *************");

		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				final Handler handler = new Handler();
				handler.postDelayed(new Runnable() {
					@Override
					public void run() {
						startListening();
					}
				}, 500);
			}
		});
	}
}
