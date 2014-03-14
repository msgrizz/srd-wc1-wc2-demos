/*
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.bluetooth.beans;

import android.bluetooth.BluetoothDevice;
import android.util.Log;

import com.plantronics.appcore.bluetooth.HeadsetUtilities;
import com.plantronics.appcore.debug.CoreLogTag;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.BatteryEvent;


/**
 * Class that represents current status of a particular specific headset device.
 * @author Vladimir Petric
 *
 */
public class RuntimeHeadsetStateBean {	
	private static final String TAG = CoreLogTag.getGlobalTagPrefix() + "HeadsetBean";
	
	protected BluetoothDevice mBluetoothDeviceObject;	
	
	// Bluetooth data
	protected boolean mIsConnected;
	protected boolean mIsPaired;
	
	// XEvent / BladeRunner data 
	protected int mTalkTimeInMinutes;	
	protected boolean mIsLackingTalkTimeAccuracy;	
	protected boolean mIsCharging;
	protected boolean mIsOnEar;
	
	// Whether it has received the Bluetooth / XEvent / BladeRunner data or is still waiting for it
	protected boolean mHasReceivedTalkTimeAndChargingInfo;
	protected boolean mHasReceivedConnectedInfo;
	protected boolean mHasReceivedPairedInfo;
	protected boolean mHasReceivedOnEarInfo;	
	
	private boolean mConnectedViaBladeRunner;
	
	/**
	 * Creates a HeadsetBean by stating its BluetoothDevice object only, with rest of the parameters set to default values.
	 * @param bluetoothDeviceObject
	 * 		The BluetoothDevice object which has the address and raw name information
	 */
	public RuntimeHeadsetStateBean(BluetoothDevice bluetoothDeviceObject) {	
		if (bluetoothDeviceObject == null) {
			throw new IllegalArgumentException("HeadsetBean constructor: the bluetoothDeviceObject may not be null");
		}
		this.mBluetoothDeviceObject = bluetoothDeviceObject;		
	}
	
	/**
	 * Creates an emty HeadsetBean with all the parameters set to default values.
	 */
	public RuntimeHeadsetStateBean() { // Empty constructor		
	}
	
	/**
	 * Resets all values to default.
	 */
	public void clear() {
		Log.v(TAG, "Calling clear() on the runtime state bean.");
		mBluetoothDeviceObject = null;
		mHasReceivedConnectedInfo = false;
		mHasReceivedOnEarInfo = false;
		mHasReceivedPairedInfo = false;
		mHasReceivedTalkTimeAndChargingInfo = false;
		mIsCharging = false;
		mIsConnected = false;
		mIsLackingTalkTimeAccuracy = false;
		mIsOnEar = false;
		mIsPaired = false;
		mTalkTimeInMinutes = 0;
	}
	
	/**
	 * Extracts the values of the BatteryEvent into this bean
	 * @param batteryEvent
	 * 		The battery event for the device which sent the XEvent
	 */
	public void extractBatteryEventData(BatteryEvent batteryEvent) {		
		BluetoothDevice deviceThatSentXEvent = batteryEvent.getBluetoothDevice();
		
		// Exit if the selected headset is not the connected one
		// or if the addresses of the XEvent sending device differs from this one
		if (!isConnected() || !HeadsetUtilities.areDevicesEqual(deviceThatSentXEvent, getBluetoothDeviceObject())) {
			Log.v(TAG, "extractBatteryEventData(): the headset bean refers to a headset different from the one which sent the XEvent, thus we are exiting the method.");
			return;
		}
		
		// Extract the values from the battery event
		int batteryLevel = batteryEvent.getLevel();
        int numberOfLevels = batteryEvent.getNumberOfLevels();
        int batteryPercentage = BatteryEvent.getBatteryPercentage(batteryLevel, numberOfLevels);
		boolean isCharging = batteryEvent.isCharging();
		int rawTalkTimeInMinutes = batteryEvent.getMinutesOfTalkTime();
		boolean isAccuracyLost = rawTalkTimeInMinutes < 0;
		String deviceName = deviceThatSentXEvent.getName();
		
		// Log the battery event
		Log.d(TAG, "Received a BatteryEvent: is charging? " + isCharging + ", talk time: " + rawTalkTimeInMinutes
				+ " minutes, percentage: " + batteryPercentage + "%, level: " + batteryLevel 
				+ ", numLevels: " + numberOfLevels + ", accuracy lost: " + isAccuracyLost + ", headset: " + deviceName);
		
		// Mark that the values will be valid
		setHasReceivedTalkTimeAndChargingInfo(true);
		
		// Insert the values into the bean
		setTalkTimeInMinutes(rawTalkTimeInMinutes);
		setCharging(isCharging);	
	}

	/**	 
	 * @return
	 * 		The backing BluetoothDevice object which has the address and raw name information, or null
	 * 		if this object has not been set yet
	 */
	public BluetoothDevice getBluetoothDeviceObject() {
		return mBluetoothDeviceObject;
	}

	/**
	 * Sets the backing BluetoothDevice object
	 * @param bluetoothDeviceObject
	 * 		The backing BluetoothDevice object which has the address and raw name information
	 */
	public void setBluetoothDeviceObject(BluetoothDevice bluetoothDeviceObject) {
		this.mBluetoothDeviceObject = bluetoothDeviceObject;
	}

	/**	 
	 * @return
	 * 		The talk time in minutes (absolute value, always positive!)
	 */
	public int getTalkTimeInMinutes() {
		return mTalkTimeInMinutes;
	}

	/**
	 * Sets the talk time in minutes. Will call Math.abs() on the argument to ensure it is always positive.
	 * If the original value is negative it will also call setLackingOnTalkTimeAccuracy(false)
	 * 
	 * @param talkTimeInMinutes
	 * 		The talk time in minutes. Will call Math.abs() on it to ensure it is always positive.	
	 */
	public void setTalkTimeInMinutes(int talkTimeInMinutes) {		
		this.mTalkTimeInMinutes = Math.abs(talkTimeInMinutes);
		setLackingOnTalkTimeAccuracy(talkTimeInMinutes < 0);
	}

	/**
	 * @return
	 * 		Whether the raw talk time received via XEvent is negative, which suggests that there is a certain loss in accuracy.
	 */
	public boolean isLackingOnTalkTimeAccuracy() {
		return mIsLackingTalkTimeAccuracy;
	}

	/**
	 * Sets whether there is a loss in accuracy of talk time, this is portrayed when the raw talk time retrieved via XEvent is negative
	 * @param isLackingTalkTimeAccuracy
	 * 		True if it is lacking on accuracy, false otherwise
	 */
	public void setLackingOnTalkTimeAccuracy(boolean isLackingTalkTimeAccuracy) {
		this.mIsLackingTalkTimeAccuracy = isLackingTalkTimeAccuracy;
	}

	/**	 
	 * @return
	 * 		Whether the headset is Bluetooth-connected
	 */
	public boolean isConnected() {
		return mIsConnected;
	}
	
	/**	 
	 * @return
	 * 		Whether the headset is Bluetooth-connected
	 */
	public Boolean getIsConnectedObject() {
		return mIsConnected;
	}

	/**
	 * Sets whether the headset is Bluetooth-connected
	 * @param isConnected
	 * 		Whether the headset is Bluetooth-connected
	 */
	public void setConnected(boolean isConnected) {
		this.mIsConnected = isConnected;
	}

	/**	 
	 * @return
	 * 		Whether the headset is charging
	 */
	public boolean isCharging() {
		return mIsCharging;
	}

	/**
	 * Sets whether the headset is Bluetooth-connected
	 * @param isCharging
	 * 		Whether the headset is Bluetooth-connected
	 */
	public void setCharging(boolean isCharging) {
		this.mIsCharging = isCharging;
	}

	/**	
	 * @return
	 * 		Whether the headset is currently on the user's ear, being worn
	 */
	public boolean isBeingWorn() {
		return mIsOnEar;
	}

	/**
	 * Sets whether the headset is currently on the user's ear, being worn
	 * @param isOnEar
	 * 		Whether the headset is currently on the user's ear, being worn
	 */
	public void setBeingWorn(boolean isOnEar) {
		this.mIsOnEar = isOnEar;
	}

	/**
	 * @return
	 * 		Whether the headset has any talk time info or not
	 */
	public boolean hasReceivedTalkTimeAndChargingInfo() {
		return mHasReceivedTalkTimeAndChargingInfo;
	}

	/**
	 * Sets whether the headset has any talk time info or not
	 * @param hasTalkTimeInfo
	 * 		Whether the headset has any talk time info or not
	 */
	public void setHasReceivedTalkTimeAndChargingInfo(boolean hasTalkTimeInfo) {
		this.mHasReceivedTalkTimeAndChargingInfo = hasTalkTimeInfo;
	}

	/**
	 * @return
	 * 		Whether the headset has any connected status info or not
	 */
	public boolean hasReceivedConnectedInfo() {
		return mHasReceivedConnectedInfo;
	}

	/**
	 * Sets whether the headset has any connected status info or not
	 * @param hasConnectedInfo
	 * 		Whether the headset has any connected status info or not
	 */
	public void setHasReceivedConnectedInfo(boolean hasConnectedInfo) {
		this.mHasReceivedConnectedInfo = hasConnectedInfo;
	}

	/**
	 * @return
	 * 		Whether the headset has any wearing status info or not
	 */
	public boolean hasReceivedBeingWornInfo() {
		return mHasReceivedOnEarInfo;
	}

	/**
	 * Sets whether the headset has any wearing status info or not
	 * @param hasOnEarInfo
	 * 		Whether the headset has any wearing status info or not
	 */
	public void setHasReceivedBeingWornInfo(boolean hasOnEarInfo) {
		this.mHasReceivedOnEarInfo = hasOnEarInfo;
	}	
	
	public boolean isPaired() {
		return mIsPaired;
	}
	
	public Boolean getIsPairedObject() {
		return mIsPaired;
	}

	public void setPaired(boolean mIsPaired) {
		this.mIsPaired = mIsPaired;
	}

	public boolean hasReceivedPairedInfo() {
		return mHasReceivedPairedInfo;
	}

	public void setHasReceivedPairedInfo(boolean mHasReceivedPairedInfo) {
		this.mHasReceivedPairedInfo = mHasReceivedPairedInfo;
	}

	public boolean isConnectedViaBladeRunner() {
		return mConnectedViaBladeRunner;
	}

	public void setConnectedViaBladeRunner(boolean mConnectedViaBladeRunner) {
		this.mConnectedViaBladeRunner = mConnectedViaBladeRunner;
	}

	
}
