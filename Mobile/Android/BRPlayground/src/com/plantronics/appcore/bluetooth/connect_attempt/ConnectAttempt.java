/*
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.bluetooth.connect_attempt;

import java.util.Timer;
import java.util.TimerTask;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.util.Log;

import com.plantronics.appcore.bluetooth.HeadsetUtilities;
import com.plantronics.appcore.debug.CoreLogTag;
import com.plantronics.appcore.general.TimeUtility;
import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothCommunicatorHandler;

public class ConnectAttempt implements IConnectAttempt {	
	private static final String TAG = CoreLogTag.getGlobalTagPrefix() + "ConnectAttempt";
	private static final long CONNECTION_TIMEOUT = 17 * TimeUtility.SECOND;
	
	/**
	 * The one and only instance of this class
	 */
	private static IConnectAttempt sInstance;


	
    //======================================================================================================================
    // Members
    //======================================================================================================================

	

    /**
     * The timer that checks whether the connection attempt has timed out
     */
	protected Timer mConnectionTimer;
    
    /**
     * Handler for sending native Communicator requests and receiving responses (and events also)
     */
    protected NativeBluetoothCommunicatorHandler mNativeBluetoothCommunicatorHandler;
    
    /**
     * The device for which we are attempting connection
     */
    protected BluetoothDevice mDevice;
    
    /**
     * The registered listener for the attempt-timed-out screnario
     */
    protected OnTimedOutListener mOnTimedOutListener;


    
    //======================================================================================================================
    // Constructors
    //======================================================================================================================


    
    /**
     * Creates a new instance of the ConnectAttempt class
     * @param context
     * 		The caller's context
     */
    private ConnectAttempt(Context context) {
    	setUpBluetoothCommunicator(context);
    }


    
    //======================================================================================================================
    // Public interface
    //======================================================================================================================
    
    

    @Override
    public void attemptConnection(BluetoothDevice bluetoothDevice) {
        Log.i(TAG, "Called attemptConnection.");
        if (bluetoothDevice == null) {
            Log.e(TAG, "Called attemptConnection() for a null device");
            return;
        }

        // Set the timer to detect a time-out of an unsuccessful connection attempt
        scheduleConnectionTimeoutTimer(bluetoothDevice);
        
        // Memorize the device
        this.mDevice = bluetoothDevice;

        // Send request for connecting to bluetooth device
        mNativeBluetoothCommunicatorHandler.connectToDeviceRequest(bluetoothDevice);
    }

    @Override
    public void cancel() {
        Log.i(TAG, "Called cancel().");

        // Cancel and release Timeout Timer
        cancelTimer();
        releaseTimer();
    }

    @Override
    public boolean isAttemptInProgress() {
        return mConnectionTimer != null;
    }
    
    @Override
	public void registerOnTimedOutListener(OnTimedOutListener onTimedOutListener) {
    	Log.d(TAG, "Registering a on-connection-attempt-timed-out listener");
		this.mOnTimedOutListener = onTimedOutListener;
	}

	@Override
	public void unregisterOnTimedOutListener() {
		Log.d(TAG, "Unregistering the on-connection-attempt-timed-out listener");
		this.mOnTimedOutListener = null;
	}

    /**
     * There should always be only one instance of the IConnectAttempt in progress. Therefore it will be a Singleton.
     * This method is not thread-safe.
     * @param context
     * 		The caller's context
     * @return
     * 		The one and only instance of the IConnectAttempt implementation.
     */
    public static IConnectAttempt getInstance(Context context) {
    	if (sInstance == null) {
    		sInstance = new ConnectAttempt(context);
    	}
    	return sInstance;
    }

    

    //======================================================================================================================
    // Utility methods
    //======================================================================================================================

    
    
    private void onAttemptSucceeded(BluetoothDevice bluetoothDevice) {
        Log.i(TAG, "Called onAttemptSucceeded().");
        cancel();
    }
    
    /**
     * Initialize all the structures needed for later calling of the connection attempt Bluetooth Service methods
     * @param context 
     * 		The surrounding context
     */
    protected void setUpBluetoothCommunicator(Context context) {
        mNativeBluetoothCommunicatorHandler = new NativeBluetoothCommunicatorHandler() {
        	
        	@Override
        	public void onDeviceConnectedEvent(BluetoothDevice bluetoothDevice) {
        		
        		// If an attempt was in progress, note that it was successful
        		if (isAttemptInProgress() && HeadsetUtilities.areDevicesEqual(mDevice, bluetoothDevice)) {
        			onAttemptSucceeded(bluetoothDevice);
        		}
        	}
        	
        };
        
        /*
        The Communicator for receiving events from the Bluetooth Manager Service
         */
        Communicator communicator = new Communicator(context);
        communicator.addHandler(mNativeBluetoothCommunicatorHandler);
    }
    

    /**
     * Call the cancel method for the timer object
     */
    private void cancelTimer() {
        if (mConnectionTimer != null) {
            mConnectionTimer.cancel();
        }
    }

    /**
     * Release the timer object
     */
    private void releaseTimer() {
        mConnectionTimer = null;
    }

    /**
     * Sets a timer to fire if connection attempt times out.
     * @param bluetoothDevice
     *      The device to which we wish to connect    
     */
    private void scheduleConnectionTimeoutTimer(BluetoothDevice bluetoothDevice) {
    	final String addressOfBluetoothDevice = bluetoothDevice.getAddress();
    	
        // Cancel old one if exists
        cancelTimer(); // no need to release old timer since we shall create a new one in the next line

        // Create the new timer and schedule a timer task
        mConnectionTimer = new Timer();        
        mConnectionTimer.schedule(new TimerTask() {

            @Override
            public void run() {
                if (isAttemptInProgress()) {
                	
                	// Release the timer object, so that the calling modules will know that no
                    // connection attempt is in progress (see the isAttemptInProgress() method)
                	ConnectAttempt.this.cancel();	
                	
                    Log.i(TAG, "Connection timeout expired, unable to connect!");
                    if (mOnTimedOutListener != null) {
                    	mOnTimedOutListener.onConnectionAttemptTimedOut(addressOfBluetoothDevice);
                    } else {
                    	Log.w(TAG, "No timed-out listeners were registered, so no client classes were notified of the attempt timing out.");
                    }

                } else {
                    Log.w(TAG, "The connection attempt was cancelled, so we are not responding to connection time out.");
                }
            }

        }, CONNECTION_TIMEOUT);
    }	
}
