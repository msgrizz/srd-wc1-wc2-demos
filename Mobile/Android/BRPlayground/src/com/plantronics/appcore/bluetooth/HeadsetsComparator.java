/*
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.bluetooth;

import java.util.Comparator;

import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.bluetooth.beans.HeadsetModelBean;
import com.plantronics.appcore.debug.CoreLogTag;
import com.plantronics.appcore.service.bluetooth.utilities.PlantronicsDeviceResolver;

/**
 * The class that provides comparison amongst two Bluetooth devices for the purpose of ordering them in a list.
 * The comparison favours the connected headset, then gives presedence to Plantronics headsets over non-Plantronics, and in the end,
 * compares the headsets by display name. A lot of the code has been taken from a similar DeviceComparator class in FMHS.
 * 
 * @author Vladimir Petric
 *
 */
public class HeadsetsComparator implements Comparator<BluetoothDevice> {	
	private static final String TAG = CoreLogTag.getGlobalTagPrefix() + "HeadsetsComparator";
	
	protected BluetoothDevice mConnectedPlantronicsDevice;
	protected IHeadsetModelInfoProvider mHeadsetModelInfoProvider;
	
	protected HeadsetsComparator() { }
	
	/**
	 * Creates a new instance of HeadsetsComparator
	 * @param connectedPlantronicsDevice
	 * 		The connected Plantronics Bluetooth headset device or null if there is no such device
	 * @param iHeadsetModelInfoProvider
	 * 		The provider of headset model info
	 */
	public HeadsetsComparator(BluetoothDevice connectedPlantronicsDevice, IHeadsetModelInfoProvider iHeadsetModelInfoProvider) {
		if (iHeadsetModelInfoProvider == null) {
			throw new IllegalArgumentException("The IHeadsetModelInfoProvider parameter must not be null");
		}
		this.mConnectedPlantronicsDevice = connectedPlantronicsDevice;
		this.mHeadsetModelInfoProvider = iHeadsetModelInfoProvider;		
	}
	
	/**	 
	 * @return
	 * 		The connected Plantronics Bluetooth device or null if there is none
	 */
	public BluetoothDevice getConnectedPlantronicsDevice() {
		return mConnectedPlantronicsDevice;
	}

	/**
	 * Sets the connected Plantronics Bluetooth device
	 * @param connectedPlantronicsDevice
	 * 		The connected Plantronics Bluetooth device or null if there is none
	 */
	public void setConnectedPlantronicsDevice(BluetoothDevice connectedPlantronicsDevice) {
		this.mConnectedPlantronicsDevice = connectedPlantronicsDevice;
	}	

	/**	 
	 * @return
	 * 		The provider of headset model info that is set inside the constructor
	 */
	public IHeadsetModelInfoProvider getHeadsetModelInfoProvider() {
		return mHeadsetModelInfoProvider;
	}

	/**
	 * Sets the provider for the headset model data
	 * @param iHeadsetModelInfoProvider
	 * 		The provider of headset model info
	 */
	public void setHeadsetModelInfoProvider(IHeadsetModelInfoProvider iHeadsetModelInfoProvider) {
		this.mHeadsetModelInfoProvider = iHeadsetModelInfoProvider;
	}

	@Override
	public int compare(BluetoothDevice device1, BluetoothDevice device2) {	
		if (device1 == null || device2 == null) {
			throw new IllegalArgumentException("HeadsetsComparator.compare(): Both arguments must not be null.");
		}
		
		// First see if the headset addresses are the same perhaps
		if (device1.getAddress().equals(device2.getAddress())) {
			return 0;
		}

		// If there is a connected device
		if (mConnectedPlantronicsDevice != null) {
			
			/*
			 *  Conected device should be shown first
			 */
			if (device1.getAddress().equals(mConnectedPlantronicsDevice.getAddress())) {
				return -1;			
			} 
			
			if (device2.getAddress().equals(mConnectedPlantronicsDevice.getAddress())) {
				return 1;
			}
		}

		/*
		 * In current design, we do not give precedence to Plantronics headsets over competitor's
		 */		
//		// Check if some of them is plantronics
//		if (PlantronicsDeviceResolver.isPlantronicsDevice(device1) && !PlantronicsDeviceResolver.isPlantronicsDevice(device2)) {			
//			return -1;
//		}
//
//		if (!PlantronicsDeviceResolver.isPlantronicsDevice(device1) && PlantronicsDeviceResolver.isPlantronicsDevice(device2)) {
//			return 1;
//		}
		
		/*
		 *  If devices were the same in previous checks check by display name
		 */
		HeadsetModelBean infoOnDevice1 = mHeadsetModelInfoProvider.getInfoOnHeadsetModel(device1);
		HeadsetModelBean infoOnDevice2 = mHeadsetModelInfoProvider.getInfoOnHeadsetModel(device2);
		
		// Tries to get the display name, if it fails, then it takes the raw, "friendly" name
		String displayNameOfDevice1 = infoOnDevice1 != null ? infoOnDevice1.getDisplayName() : device1.getName();
		String displayNameOfDevice2 = infoOnDevice2 != null ? infoOnDevice2.getDisplayName() : device2.getName();		
		
		// Return the comparison of the headset names 		
        return displayNameOfDevice1.compareTo(displayNameOfDevice2);
	}
}
