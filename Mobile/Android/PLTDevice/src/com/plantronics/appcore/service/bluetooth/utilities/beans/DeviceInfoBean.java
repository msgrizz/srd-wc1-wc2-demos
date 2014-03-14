package com.plantronics.appcore.service.bluetooth.utilities.beans;

import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

public class DeviceInfoBean {
	public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + DeviceInfoBean.class.getSimpleName();

	private String mFriendlyName;
	private String mFullName;

	// Device constraints
	private boolean mScoOnly;
	private boolean mA2dpOnly;

	// XEvent
	private boolean mSupportsXevent;

	public DeviceInfoBean(String friendlyName, String fullName, boolean scoOnly, boolean a2dpOnly) {
		mFriendlyName = friendlyName;
		mFullName = fullName;
		mScoOnly = scoOnly;
		mA2dpOnly = a2dpOnly;
	}

	public boolean doesSupportXevents() {
		return mSupportsXevent;
	}

	public DeviceInfoBean setSupportsXevent(boolean supportsXevent) {
		this.mSupportsXevent = supportsXevent;
		return this;
	}

	public boolean isScoOnly() {
		return mScoOnly;
	}

	public void setScoOnly(boolean scoOnly) {
		mScoOnly = scoOnly;
	}

	public boolean isA2dpOnly() {
		return mA2dpOnly;
	}

	public void setA2dpOnly(boolean a2dpOnly) {
		mA2dpOnly = a2dpOnly;
	}

	public String getFriendlyName() {
		return mFriendlyName;
	}

	public void setFriendlyName(String friendlyName) {
		mFriendlyName = friendlyName;
	}

	public String getFullName() {
		return mFullName;
	}

	public void setFullName(String fullName) {
		mFullName = fullName;
	}
}
