/*
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.service.bluetooth.communicator;

import android.bluetooth.BluetoothDevice;
import android.util.Log;

import com.plantronics.appcore.debug.CoreLogTag;

import com.plantronics.appcore.service.bluetooth.plugins.xevent.XEventCommunicatorHandler;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.BatteryEvent;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.DonDoffEvent;

public abstract class XEventListener extends XEventCommunicatorHandler  {
	private static final String TAG = CoreLogTag.getGlobalTagPrefix() + "XEventListener";
			
	private BatteryEvent mLastBatteryEvent;
	private DonDoffEvent mLastDonDoffEvent;
	
	@Override
	public void onResume() {
		super.onResume();
        Log.d(TAG, "onResume(). Sending XEvent requests to the BluetoothManagerService.");
        
        /*
         *  Send requests
         */
        getBatteryStateRequest();
        getWearingStateRequest();
	}
	
	@Override
	public void onDonDoffEvent(DonDoffEvent donDoffEvent) {
		if (donDoffEvent == null) {
			return; // paranoid check
		}
		mLastDonDoffEvent = donDoffEvent;

	}
	
	@Override
	public void onGetBatteryStateResponse(BatteryEvent lastBatteryEvent) {	
		Log.d(TAG, "onGetBatteryStateResponse(). Last battery event: " + lastBatteryEvent);
		mLastBatteryEvent = lastBatteryEvent;	
		if (mLastDonDoffEvent != null) {

		}
	}
	
	@Override
	public void onGetWearingStateResponse(DonDoffEvent donDoffEvent) {
		Log.d(TAG, "onGetWearingStateResponse(). Last Don/Doff event: " + donDoffEvent);
		this.mLastDonDoffEvent = donDoffEvent;
		if (mLastBatteryEvent != null) {

		}
	}
	
	@Override
	protected void onBatteryEvent(BatteryEvent batteryEvent) {
		mLastBatteryEvent = batteryEvent;

	}	

	public boolean isDonned() {
		return hasWearingStatus() && mLastDonDoffEvent.IsDon();
	}

	public BatteryEvent getLastBatteryEvent() {
		return mLastBatteryEvent;
	}
	
	public DonDoffEvent getLastDonDoffEvent() {
		return mLastDonDoffEvent;
	}

	public boolean hasWearingStatus() {
		return mLastDonDoffEvent != null;
	}

	public BluetoothDevice getDonnedOrDoffedDevice() {
		if (mLastDonDoffEvent == null) {
			return null;
		}
		return mLastDonDoffEvent.getBluetoothDevice();
	}
	
	public BluetoothDevice getBatteryEventDevice() {
		if (mLastBatteryEvent == null) {
			return null;
		}
		return mLastBatteryEvent.getBluetoothDevice();
	}
}
