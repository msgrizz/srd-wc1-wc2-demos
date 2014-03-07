/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins;

import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;
import com.plantronics.appcore.service.bluetooth.BluetoothManagerService;
import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.appcore.service.bluetooth.communicator.Response;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 * Abstract Bluetooth-related work handling module.
 * Bluetooth plugins extend this class in order to define behaviour.
 *
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */

public abstract class BluetoothPluginHandler {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + BluetoothPluginHandler.class.getSimpleName();

    protected Context mContext;
    protected Communicator mCommunicator;


    /**
     * Public constructor that calls the plugin's implementation of {@link #initPlugin}
     * and instantiates this plugin's {@link Communicator}.
     *
     * @param mContext
     *      Context of the caller
     */
    public BluetoothPluginHandler(Context mContext) {
        this.mContext = mContext;
        initPlugin();
        mCommunicator = new Communicator(mContext);
    }


    /**
     * Initialization of plugin object.
     */
    public abstract void initPlugin();


    /**
     * Defines whether this plugin is dedicated for processing certain type of events
     *
     * @param eventOrigin
     *      The origin of the event
     * @return
     *      True if this plugin is handling the specified type of event
     */
    public abstract boolean isHandlingEvent(String eventOrigin);


    /**
     * Handles a {@link com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent}
     *
     * @param bluetoothEvent
     *      The event to be being handled
     */
    public abstract void handleEvent(BluetoothEvent bluetoothEvent);


    /**
     * Defines whether this plugin is dedicated for processing certain type of requests
     *
     * @param requestOrigin
     *      The origin of the request
     * @return
     *      True if this plugin is handling the specified type of request
     */
    public abstract boolean isHandlingRequest(String requestOrigin);


    /**
     * Handles a {@link BluetoothRequest}
     *
     * @param request
     *      The request to handle
     */
    public abstract void handleRequest(BluetoothRequest request);


    /**
     * Calls {#link #handleEvent} in a separate new {@link android.os.AsyncTask}.
     *
     * @param bluetoothEvent
     *      The Bluetooth event to process
     */
    public void startEventHandler(BluetoothEvent bluetoothEvent) {
        Log.d(TAG, "Starting event handler");

        AsyncTask handleEventTask = new AsyncTask<Object, Void, Void>() {

            @Override
            protected Void doInBackground(Object... bluetoothEvents) {
                Log.d(TAG, "Started async task");
                handleEvent((BluetoothEvent) bluetoothEvents[0]);
                return null;
            }

        };
        handleEventTask.execute(bluetoothEvent);
    }


    /**
     * Calls {#link #handleRequest} in a separate new {@link android.os.AsyncTask}.
     *
     * @param bluetoothRequest
     *      The Bluetooth request to process
     */
    public void startRequestHandler(BluetoothRequest bluetoothRequest) {
        Log.d(TAG, "Starting request handler");

        AsyncTask handleRequestTask = new AsyncTask<Object, Void, Void>() {

            @Override
            protected Void doInBackground(Object... bluetoothRequests) {
                handleRequest((BluetoothRequest) bluetoothRequests[0]);
                return null;
            }
        };
        handleRequestTask.execute(bluetoothRequest);
    }


    /**
     * After an event is processed, this function sends it back to the {@link com.plantronics.appcore.service.bluetooth.BluetoothManagerService}
     * so that it can propagate it further to external modules.
     *
     * @param context
     *      Context of the caller
     * @param bluetoothEvent
     *      The Bluetooth event that has just been processed
     */
    protected void sendProcessedEventToService(Context context, BluetoothEvent bluetoothEvent) {
//        FileLogger.appendLog("Processed event: " + bluetoothEvent.getType() + " BDA: " + bluetoothEvent.getBluetoothDevice().getAddress(), FileLogger.EVENT_LOCATION_LOG);
        Intent sendToServiceIntent = new Intent(BluetoothManagerService.Intents.getProcessedEventAction(context.getApplicationContext()));
        sendToServiceIntent.putExtra(BluetoothManagerService.EVENT_EXTRA, bluetoothEvent);
        context.startService(sendToServiceIntent);

    }


    /**
     * After a request is processed, this function sends a constructed response to the {@link com.plantronics.appcore.service.bluetooth.BluetoothManagerService}
     * which will propagate it further to the party that originally sent the request.
     *
     * @param context
     *      Context of the caller
     * @param bluetoothResponse
     *      The constructed Bluetooth response object (that matched the request object that triggered it)
     */
    protected void sendResponseToService(Context context, BluetoothResponse bluetoothResponse){
        Intent sendToServiceIntent = new Intent(BluetoothManagerService.Intents.getResponseAction(context.getApplicationContext()));
        sendToServiceIntent.putExtra(Response.RESPONSE_EXTRA, bluetoothResponse);
        context.startService(sendToServiceIntent);
    }

}



