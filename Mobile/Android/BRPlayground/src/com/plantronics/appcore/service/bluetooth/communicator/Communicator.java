/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.communicator;

import java.util.HashSet;
import java.util.Set;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.AppTag;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothResponse;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 * This class instantiated by any subsystem that wants to use this utility communicator. Once you have the instance of the communicator, you can add certain CommunicatorHandlers, that provide
 * interface that should be implemented by your own behavior. Communicator handlers define interfaces for various subsystems that conform to event/request/response communication
 * <p/>
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs) Date: 5/4/12
 */
public class Communicator {
	private static final String TAG = LogTag.getBluetoothPackageTagPrefix() + Communicator.class.getSimpleName();
	
//	public static final String TO_COMMUNICATOR_ACTION = "com.plantronics.service.bluetooth.communicator." + AppTag.APPLICATION_TAG + ".TO_COMMUNICATOR";
	public static class Intents {
		
		public static String getToCommunicatiorAction(Context applicationContext) {
			return AppTag.getPackageName(applicationContext) + ".service.bluetooth.TO_COMMUNICATOR";
		}
		
	}

	public static final String TO_COMMUNICATOR_EXTRA = "toCommunicatorExtra";

	private Context mContext;

	private IntentFilter mIntentFilter;
	private BroadcastReceiver mBroadcastReceiver;

	private Set<CommunicatorHandler> mCommunicatorHandlers;

	private Set<Integer> mUnfulfilledRequestIds;

	public Communicator(Context mContext) {
		this.mContext = mContext;

		mCommunicatorHandlers = new HashSet<CommunicatorHandler>();
		mUnfulfilledRequestIds = new HashSet<Integer>();

		// mLocalBroadcastManager = mContext; // For testing purposes only, remove after done (Because tests can't instantiate LocalBroadcastManager)
		final String toCommunicatorAction = Intents.getToCommunicatiorAction(mContext.getApplicationContext());
		mIntentFilter = new IntentFilter(toCommunicatorAction);

		mBroadcastReceiver = new BroadcastReceiver() {
			@Override
			public void onReceive(Context context, Intent intent) {
				if (intent.getAction().equals(toCommunicatorAction)) {
					Object message = intent.getSerializableExtra(TO_COMMUNICATOR_EXTRA);

					boolean prehandlingResult = preHandle(message);
					if (prehandlingResult)
						handleMessage(message);
					postHandle(message);
				}
			}

		};

	}

	public void onPause() {
		Log.d(TAG, "Pausing in context: " + mContext);
		for (CommunicatorHandler communicatorHandler : mCommunicatorHandlers) {
			communicatorHandler.onPause();
		}
		mContext.unregisterReceiver(mBroadcastReceiver);
	}

	public void onResume() {
		Log.d(TAG, "Resuming in context: " + mContext);
		for (CommunicatorHandler communicatorHandler : mCommunicatorHandlers) {
			communicatorHandler.onResume();
		}
		mContext.registerReceiver(mBroadcastReceiver, mIntentFilter);
	}

	/**
	 * This is a helper method that does pre handling of all the messages communicator receives
	 * 
	 * @param message
	 *            message that is being received, and may need pre-handling
	 * @return true if handling should continued, false otherwise
	 */
	private boolean preHandle(Object message) {
		Log.d(TAG, "PreHandling: " + message);

		if (message instanceof Response) {
			Response responseMessage = (Response) message;
			if (!responseMessage.hasStableId()) {
				return true; // if some module is killing the communicator with him when it's being garbage collected - we do not retain IDs for that instance
			}

			int responseId = responseMessage.getResponseId();
			if (!mUnfulfilledRequestIds.contains(responseId) && responseId != BluetoothResponse.BROADCAST_ID) {
				// Log.d(TAG, "This message is not meant for this communicator!");
				return false;
			} else {
				mUnfulfilledRequestIds.remove(responseId);
			}
		}
		return true;
	}

	/**
	 * Override this method if you want to implement specific behavior when bluetooth event or response is received
	 */
	public void handleMessage(Object message) {
		int sizeOfHandlersSet = 0;
		if (mCommunicatorHandlers != null) {
			sizeOfHandlersSet = mCommunicatorHandlers.size();
		}
		Log.i(TAG, "Communicator is handling a message. Size of handlers set: " + sizeOfHandlersSet);
		for (CommunicatorHandler communicatorHandler : mCommunicatorHandlers) {
			communicatorHandler.startHandler(message);
		}
	}

	/**
	 * This is a helper method that does post-handling of all the messages communicator receives (Note, this may be removed in future, currently only serves as a placeholder)
	 * 
	 * @param message
	 *            message that was received, and may need post-handling
	 */
	private void postHandle(Object message) {
		// Log.d(TAG, "PostHandling: " + message.toString());
	}

	/**
	 * Broadcast event
	 * 
	 * @param event
	 *            that will be sent
	 */
	public void broadcastEvent(Event event) {
		final String toCommunicatorAction = Intents.getToCommunicatiorAction(mContext.getApplicationContext());
		Intent sendToActivityIntent = new Intent(toCommunicatorAction);
		sendToActivityIntent.putExtra(TO_COMMUNICATOR_EXTRA, event);
		mContext.sendBroadcast(sendToActivityIntent);
	}

	/**
	 * Send response to all listening communicators
	 * 
	 * @param response
	 *            response
	 */
	public void sendResponse(Response response) {
		final String toCommunicatorAction = Intents.getToCommunicatiorAction(mContext.getApplicationContext());
		Intent sendResponse = new Intent(toCommunicatorAction);
		sendResponse.putExtra(TO_COMMUNICATOR_EXTRA, response);
		Log.i(TAG, "Sending response via mLocalBroadcastManager: " + response);
		mContext.sendBroadcast(sendResponse);
	}

	/**
	 * Sends a request to Bluetooth Manager Service
	 * 
	 * @param request
	 */
	public void request(Request request) {
		mUnfulfilledRequestIds.add(request.getRequestId());
		Intent requestIntent = new Intent(request.getRequestTargetServiceAction(mContext));
		requestIntent.putExtra(Request.REQUEST_EXTRA, request);
		mContext.startService(requestIntent);
	}

	/**
	 * Adds a specific handler that exposes interface of certain subsytem
	 * 
	 * @param communicatorHandler
	 *            (i.e. XeventPluginCommunicationHandler)
	 */
	public void addHandler(CommunicatorHandler communicatorHandler) {
		if (!mCommunicatorHandlers.contains(communicatorHandler)) {
			mCommunicatorHandlers.add(communicatorHandler);
			communicatorHandler.addParentCommunicator(this);
		}
	}

	/**
	 * Removes a certain handler
	 * 
	 * @param communicatorHandler
	 *            handler
	 */
	public void removeHandler(CommunicatorHandler communicatorHandler) {
		mCommunicatorHandlers.remove(communicatorHandler);
	}

	/**
	 * Intent service helper method
	 * 
	 * @param intent
	 *            intent received by intent service
	 */
	public void handleIntent(Intent intent) {
		final String toCommunicatorAction = Intents.getToCommunicatiorAction(mContext.getApplicationContext());
		if (intent.getAction().equals(toCommunicatorAction)) {
			boolean prehandlingResult = preHandle(intent.getSerializableExtra(TO_COMMUNICATOR_EXTRA));
			if (prehandlingResult) {
				handleMessage(intent.getSerializableExtra(TO_COMMUNICATOR_EXTRA));
			}
			postHandle(intent.getSerializableExtra(TO_COMMUNICATOR_EXTRA));
		}
	}

	/**
	 * Helper method for intent service to start receiver
	 */
	public void startReceiver() {
		onResume();
	}

	/**
	 * Helper method for intent service to stop receiver
	 */
	public void stopReceiver() {
		onPause();
	}

}
