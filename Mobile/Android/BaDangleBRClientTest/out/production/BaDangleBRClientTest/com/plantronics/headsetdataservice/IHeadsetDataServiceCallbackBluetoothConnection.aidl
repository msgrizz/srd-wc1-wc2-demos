/**
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.headsetdataservice;

/**
 * Example of a callback interface used by IRemoteService to send
 * synchronous notifications back to its clients.  Note that this is a
 * one-way interface so the server does not block waiting for the client.
 */
interface IHeadsetDataServiceCallbackBluetoothConnection {  

	/**
     * Callback when a bluetooth device gets connected
     * @param deviceBluetoothAddress 
     * 		The currently connected Bluetooth Device
     */	  
    void onBluetoothDeviceConnected(String deviceBluetoothAddress);
    
    /**
     * Callback when a bluetooth device gets disconnected
     * @param deviceBluetoothAddress 
     * 		The Bluetooth Device that has just been disconnected
     */
	void onBluetoothDeviceDisconnected(String deviceBluetoothAddress);
}