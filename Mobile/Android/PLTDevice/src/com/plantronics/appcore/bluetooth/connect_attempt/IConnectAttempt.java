/*
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.bluetooth.connect_attempt;

import android.bluetooth.BluetoothDevice;

public interface IConnectAttempt {

	/**
     * Object that listens for a time out of a connection attempt
     */
    public interface OnTimedOutListener {

        /**
         * Actions done upon an unsuccessful connection attempt that has timed out
         * @param bluetoothAddress
         *      The address of the device that we are trying to connect to
         */
        void onConnectionAttemptTimedOut(final String bluetoothAddress);
    }    
    
    /**
     * Cancel connection attempt if one is in progress.
     */
    void cancel();

    /**
     * Attempt to connect with bluetooth device.
     *
     * @param bluetoothDevice
     *      The bluetooth device to connect with.     
     */
    void attemptConnection(BluetoothDevice bluetoothDevice);

    /**
     * Retrieves if connection attempt is in progress.
     *
     * @return
     *      <b>true</b> - if connectio attempt is in progress. False otherwise.
     */
    boolean isAttemptInProgress();   
    
    /**
     * Registers a listener to be notified upon an attempt-timed-out event.
     * <br><b>NOTE:</b> This would typically be called inside a Fragment's onResume()
     * @param onTimedOutListener
     * 		The on-attempt-timed-out listener. The listener that shall be called in the case of attempt timing out 
     */
    void registerOnTimedOutListener(OnTimedOutListener onTimedOutListener);
    
    /**
     * Unregisters an on-attempt-timed-out listener.
     * <br><b>NOTE:</b> This would typically be called inside a Fragment's onPause()
     */
    void unregisterOnTimedOutListener();
}
