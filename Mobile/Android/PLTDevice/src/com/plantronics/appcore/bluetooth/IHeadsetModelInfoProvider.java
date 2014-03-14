/*
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.bluetooth;

import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.bluetooth.beans.HeadsetModelBean;

public interface IHeadsetModelInfoProvider {
	
	/**
	 * For a specific instance of {@link BluetoothDevice} retrieves a headset model bean that contains all relevant master-list information.
	 * <p><b>NOTE:</b>
	 * 		The BluetoothDevice object must return a valid raw "friendly" name when its {@link BluetoothDevice#getName()} method is called, 
	 * since this value will probably be used as a key for finding the matching headset model bean
	 * 
	 * @param bluetoothDevice
	 * 		The BluetoothDevice for which we need information on
	 * @return
	 * 		The HeadsetModelBean with data on the headset or null if no information is found on the given BluetoothDevice instance
	 */
	HeadsetModelBean getInfoOnHeadsetModel(BluetoothDevice bluetoothDevice);
	
}
