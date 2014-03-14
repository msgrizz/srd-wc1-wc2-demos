/*
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.bluetooth.beans;

import com.plantronics.appcore.debug.CoreLogTag;

/**
 * Data on each headset type.
 */
public class HeadsetModelBean {
	private static final String TAG = CoreLogTag.getGlobalTagPrefix() + "HeadsetModelBean";

	/**
	 * Headset name as displayed in UX.  This may differ
	 * from friendly name, which is what the headset returns.
	 * E.g., Voyager Legend
	 */
	protected String mDisplayName;
	
	/**
	 * Name of headset returned by the headset itself
	 * E.g., PLT_Legend.
	 */
	protected String mRawName;	
	
	/**
	 * Whether the headset supports the XEvent protocol.
	 */
	protected boolean mSupportsXEvent;
	
	/**
	 * Whether the headset supports the XEvent Don/Doff wearing status.
	 */
	protected boolean mHasWearingSensorDonDoffData;
	
	/**
	 * Whether the headset can in theory support the BladeRunner protocol. Whether it really will depends upon its firmware
	 */
	protected boolean mMaySupportBladeRunnerInTheory;

	/**
	 * Creates an instance of HeadsetTypeInfoBean.
	 * @param displayName
	 * 		The display-name of the headset, its full name
	 * @param rawName
	 * 		The raw String literal representing the headset's "friendly" name	
	 * @param supportsXEvent
	 * 		Whether the headset supports the XEvent protcol
	 * @param maySupportBladeRunnerInTheory
	 * 		Whether the headset can in theory support the BladeRunner protocol. Whether it really will depends upon its firmware
	 */
	public HeadsetModelBean(String displayName, String rawName, boolean supportsXEvent, boolean maySupportBladeRunnerInTheory) {		
		this.mDisplayName = displayName;
		this.mRawName = rawName;	
		this.mSupportsXEvent = supportsXEvent;
		this.mMaySupportBladeRunnerInTheory = maySupportBladeRunnerInTheory;
	}
	
	/**
	 * Creates an instance of HeadsetTypeInfoBean as a duplicate of another HeadsetTypeInfoBean.
	 * @param headsetTypeInfoBean
	 * 		An instance of HeadsetTypeInfoBean, which is a superclass of MasterListHeadsetBean
	 */
	public HeadsetModelBean(HeadsetModelBean headsetTypeInfoBean) {
		this(headsetTypeInfoBean.getDisplayName(), headsetTypeInfoBean.getRawName(), headsetTypeInfoBean.supportsXEvent(), 
				headsetTypeInfoBean.maySupportBladeRunnerInTheory());		
	}
	
	/**
	 * Empty constructor that creates an empty HeadsetTypeInfoBean.
	 */
	public HeadsetModelBean() { }

	/**
	 * Retrieves the display-name of the headset
	 * @return
	 * 		The display-name of the headset, its full name
	 */
	public String getDisplayName() {
		return mDisplayName;
	}

	/**
	 * Sets the display-name of the headset, its full name
	 * @param displayName
	 * 		The mentioned display-name of the headset
	 */
	public void setDisplayName(String displayName) {
		this.mDisplayName = displayName;
	}

	/**	 
	 * @return
	 * 		The raw String literal representing the headset's "friendly" name
	 */
	public String getRawName() {
		return mRawName;
	}

	/**
	 * Sets the raw String literal representing the headset's "friendly" name
	 * @param rawName
	 * 		Headset's "friendly" name
	 */
	public void setRawName(String rawName) {
		this.mRawName = rawName;
	}

	/**	 
	 * @return
	 * 		Whether the headset supports the XEvent protcol
	 */
	public boolean supportsXEvent() {
		return mSupportsXEvent;
	}

	/**
	 * Sets whether the headset type supports the XEvent protocol
	 * @param supportsXEvent
	 * 		Whether the headset supports the XEvent protocol
	 */
	public void setSupportsXEvent(boolean supportsXEvent) {
		this.mSupportsXEvent = supportsXEvent;
	}

	/**
	 * Tells whether the headset may in theory support BladeRunner.
	 * @return
	 * 		Whether the headset can in theory support the BladeRunner protocol. Whether it really will depends upon its firmware
	 */
	public boolean maySupportBladeRunnerInTheory() {
		return mMaySupportBladeRunnerInTheory;
	}

	/**
	 * Sets whether the headset in theory can support BladeRunner
	 * @param maySupportBladeRunnerInTheory
	 * 		Whether the headset can in theory support the BladeRunner protocol. Whether it really will depends upon its firmware
	 */
	public void setMaySupportBladeRunnerInTheory(boolean maySupportBladeRunnerInTheory) {
		this.mMaySupportBladeRunnerInTheory = maySupportBladeRunnerInTheory;
	}

	/**	 
	 * @return
	 * 		Whether the headset has wearing sensor Don/Doff data	
	 */
	public boolean hasWearingSensorData() {
		return mHasWearingSensorDonDoffData;
	}

	/**
	 * Sets whether the headset supports wearing status Don/Doff reports (whether it has wearing sensor data)
	 * @param supportsDonDoffWearingStatus
	 * 		Whether the headset has wearing sensor Don/Doff data
	 */
	public void setHasWearingSensorData(boolean supportsDonDoffWearingStatus) {
		this.mHasWearingSensorDonDoffData = supportsDonDoffWearingStatus;
	}	
}
