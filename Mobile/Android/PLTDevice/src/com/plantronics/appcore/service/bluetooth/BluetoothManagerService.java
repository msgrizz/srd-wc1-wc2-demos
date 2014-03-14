/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth;

import java.util.LinkedList;
import java.util.List;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.appcore.service.bluetooth.communicator.Request;
import com.plantronics.appcore.service.bluetooth.communicator.Response;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothRequest;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.XEventBluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 * Service responsible for Bluetooth-related information and operations.
 * Logs all calls and delegates them to internal specific designated modules to be handled. The supported operations:
 * <ul>
 *     <li>Bluetooth events handling</li>
 *     <li>Broadcasting processed Bluetooth events</li>
 *     <li>Receiving requests (get connected device, get paired devices...)</li>
 *     <li>Sending responses (get connected device, get paired devices...)</li>
 * </ul>
 * BMS is the abbreviation.
 *
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public class BluetoothManagerService extends Service {

    public static final String TAG = BluetoothManagerService.class.getSimpleName();

    //-------------------------------
    // Incoming event and extra name
    //------------------------------
    
    public static final String EVENT_EXTRA = "eventExtra";
    
    public static class Intents {
    	
    	public static String getEventFromReceiverAction(Context applicationContext) {
    		return AppTag.getPackageName(applicationContext) + ".service.bluetooth.EVENT_FROM_RECEIVER_ACTION";
    	}    	
    	
    	/** Action contained in processed-event Intents */
    	public static String getProcessedEventAction(Context applicationContext) {
    		return AppTag.getPackageName(applicationContext) + ".service.bluetooth.PROCESSED_EVENT_ACTION";
    	}
    	
    	/** Action contained in incoming request Intents */
    	public static String getRequestAction(Context applicationContext) {
    		return AppTag.getPackageName(applicationContext) + ".service.bluetooth.REQUEST_ACTION";
    	}
    	
    	/** Action contained in outgoing response Intents */
    	public static String getResponseAction(Context applicationContext) {
    		return AppTag.getPackageName(applicationContext) + ".service.bluetooth.RESPONSE_ACTION";
    	}
    	
    	/** Action sent from onCreate() */
    	public static String getServiceCreatedAction(Context applicationContext) {
    		return AppTag.getPackageName(applicationContext) + ".service.bluetooth.ACTION_ON_CREATE";
    	}
    	
    }
       
//    public static final String EVENT_FROM_RECEIVER_ACTION = "com.plantronics.service.bluetooth." + AppTag.getPackageName(applicationContext) + ".EVENT_FROM_RECEIVER_ACTION";
//    
//
//    /** Action contained in processed-event Intents */
//    public static final String PROCESSED_EVENT_ACTION = "com.plantronics.service.bluetooth." + AppTag.getPackageName(applicationContext) + ".PROCESSED_EVENT_ACTION";
//
//    /** Action contained in incoming request Intents */
//    public static final String REQUEST_ACTION = "com.plantronics.service.bluetooth." + AppTag.getPackageName(applicationContext) + ".REQUEST_ACTION";
//
//    /** Action contained in outgoing response Intents */
//    public static final String RESPONSE_ACTION = "com.plantronics.service.bluetooth." + AppTag.getPackageName(applicationContext) + ".RESPONSE_ACTION";

    private Communicator mCommunicator;


    /**
     * Plugins list.
     * A plugin is a module that handles a certain Bluetooth-related chunk of work, delegated by the Bluetooth Manager Service.
     * (Plugin = whole package dedicated to handling one type of work, PluginHandler = module for handling work issued by BMS).
     */
    private static List<BluetoothPluginHandler> mBluetoothPluginHandlers;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        mCommunicator = new Communicator(this);

        // Notify the outside world of the restart after crash.
        sendBroadcast(new Intent(Intents.getServiceCreatedAction(getApplicationContext())));
        Log.i(TAG, "Sent the ACTION_RECREATED intent to notify all modules to register their communicators.");

        if (mBluetoothPluginHandlers == null) {
            mBluetoothPluginHandlers = new LinkedList<BluetoothPluginHandler>();

            // Register plugin handlers
            mBluetoothPluginHandlers.add(new NativeBluetoothPluginHandler(this.getApplicationContext()));
            mBluetoothPluginHandlers.add(new XEventBluetoothPluginHandler(this.getApplicationContext()));
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.w(TAG, "onDestroy() is called. Firing the KeepBmsAlive's Blueetooth Manager Service restarting alarm.");        
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // TODO check if lifecycle is as expected.

        /*
        If the Service has been started without any command - this happens if the Service is restarted after a crash
        (after the application's process being silently killed by the system).
         */
        if (intent == null || intent.getAction() == null) {
            Log.w(TAG, "Service started for a null intent.");

//            stopSelf(); // Not good idea to stop here, because we want the service to be alive at all times.
                          // Also we want all the modules subscribed for this service's broadcasts
                          // to stay registered onto this new instance, that is up and running.

            return START_STICKY;
        }

        Log.i(TAG, "Received start command, intent messageType: " + intent.getAction());

        // Handle a new event
        if (intent.getAction().equals(Intents.getEventFromReceiverAction(getApplicationContext()))) {
            handleEvent((BluetoothEvent) intent.getSerializableExtra(EVENT_EXTRA));
        }

        // Broadcast a processed event
        else if (intent.getAction().equals(Intents.getProcessedEventAction(getApplicationContext()))) {
            broadcastProcessedEvent((BluetoothEvent) intent.getSerializableExtra(EVENT_EXTRA));
        }

        // Handle a request
        else if (intent.getAction().equals(Intents.getRequestAction(getApplicationContext()))) {
            handleRequest((BluetoothRequest) intent.getSerializableExtra(Request.REQUEST_EXTRA));
        }

        // Send a response after a request is handled
        else if (intent.getAction().equals(Intents.getResponseAction(getApplicationContext()))) {
            sendResponse((BluetoothResponse) intent.getSerializableExtra(Response.RESPONSE_EXTRA));
        }

        return START_STICKY;
    }

    /**
     * Find the appropriate handler and start handling event
     *
     * @param bluetoothEvent received event
     */
    private void handleEvent(BluetoothEvent bluetoothEvent) {
        Log.d(TAG, "Event! Origin:  " + bluetoothEvent.getEventPluginHandlerName() + " Type: " + bluetoothEvent.getType() + " Dev: " + bluetoothEvent.getBluetoothDevice().getAddress());

        // Go through all plugins and for all those who declare that they handle this type of event -
        // start a handler to process the event
        for (BluetoothPluginHandler bluetoothPluginHandler : mBluetoothPluginHandlers) {
            if (bluetoothPluginHandler.isHandlingEvent(bluetoothEvent.getEventPluginHandlerName())) {
                bluetoothPluginHandler.startEventHandler(bluetoothEvent);
            }
        }
    }

    /**
     * Find the appropriate handler and start handling request
     *
     * @param bluetoothRequest request received
     */
    private void handleRequest(BluetoothRequest bluetoothRequest) {
        Log.d(TAG, "Request! Origin:  " + bluetoothRequest.getRequestPluginHandlerName() + " Type: " + bluetoothRequest.getRequestType());

        // Go through all plugins and for all those who declare that they handle this type of request -
        // start a handler to process the request
        for (BluetoothPluginHandler bluetoothPluginHandler : mBluetoothPluginHandlers) {
            if (bluetoothPluginHandler.isHandlingRequest(bluetoothRequest.getRequestPluginHandlerName())) {
                bluetoothPluginHandler.startRequestHandler(bluetoothRequest);
            }
        }

//        stopSelf();
    }

    /**
     * Send response (broadcast it actually)
     *
     * @param bluetoothResponse response being sent
     */
    public void sendResponse(BluetoothResponse bluetoothResponse) {
        Log.d(TAG, "Response! Origin: " + bluetoothResponse.getResponsePluginHandlerName() + " Type: " + bluetoothResponse.getResponseType());
        mCommunicator.sendResponse(bluetoothResponse);

//        stopSelf();
    }

    /**
     * Broadcast an event that was processed by one of the plugins
     * @param bluetoothEvent event that was processed, and is now being passed on to listening communicators
     */
    private void broadcastProcessedEvent(BluetoothEvent bluetoothEvent){
        Log.d(TAG, "Broadcasting processed event! Origin:  " + bluetoothEvent.getEventPluginHandlerName() + " Type: " + bluetoothEvent.getType() + " Dev: " + bluetoothEvent.getBluetoothDevice().getAddress());
        mCommunicator.broadcastEvent(bluetoothEvent);

//        stopSelf();
    }


}
