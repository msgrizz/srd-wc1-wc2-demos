/*
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.bluetooth;

import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.debug.CoreLogTag;
import com.plantronics.appcore.service.bluetooth.utilities.PlantronicsDeviceResolver;

public class HeadsetUtilities {	
	private static final String TAG = CoreLogTag.getGlobalTagPrefix() + "HeadsetUtilities";
	
	/**
	 * Was the device manufactured by Plantronics? We determine this by checking the device address (BD_ADDR). Plantronics devices' addresses are in these ranges:
	 * <ul>
	 * <li>00:23:7F</li>
	 * <li>48:C1:AC</li>
	 * <li>00:03:89</li>
	 * <li>00:19:7F</li>
	 * </ul>
	 * You must update this method if we add new address ranges.
	 * <p>
	 * As a special case, BackBeat 903+ headsets appear to have addresses in several non-Plantronics address ranges (00:1C:EF, F0:65:DD, others?), 
	 * with friendly names starting with "PLT_BB903".
	 * </p>
	 * 
	 * @param bluetoothDevice
	 *            the Bluetooth device in question
	 * @return true if its address belongs to one of the ranges Plantronics controls, or otherwise resembles a Plantronics device (see note about BB903+ above).
	 */
	public static boolean isAPlantronicsDevice(BluetoothDevice bluetoothDevice) {
		return PlantronicsDeviceResolver.isPlantronicsDevice(bluetoothDevice);		
	}
	
	/**
	 * Compares the addresses of two devices and tells whether they refer to the same BluetoothDevice.
	 * In case of at least one headset being null - it returns true <b>only</b> in the case of both headsets being null, and false in all other cases.
	 * <p>TODO This could have also been done by extending the BluetoothDevice and overriding the equals() method.
	 * @param bluetoothDevice1
	 * 		The first device
	 * @param bluetoothDevice2
	 * 		The second device
	 * @return
	 * 		True if these two objects refer to the same physical headset (addresses match)
	 */
	public static boolean areDevicesEqual(BluetoothDevice bluetoothDevice1, BluetoothDevice bluetoothDevice2) {
		boolean isOnlyOneNull = bluetoothDevice1 == null && bluetoothDevice2 != null || bluetoothDevice1 != null && bluetoothDevice2 == null;
		boolean areBothNull = bluetoothDevice1 == null && bluetoothDevice2 == null;		
		return areBothNull || (!isOnlyOneNull && bluetoothDevice1.getAddress().equals(bluetoothDevice2.getAddress()));		
	}
	
	
}
