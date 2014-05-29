package com.plantronics.device.info;

import com.plantronics.device.calibration.Calibration;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class WearingStateInfo extends Info {

	private boolean 	_isBeingWorn;


	public WearingStateInfo(byte requestType, Date timestamp, Calibration calibration, boolean isBeingWorn) {
		super(requestType, timestamp, calibration);
		_isBeingWorn = isBeingWorn;
	}

	public boolean getIsBeingWorn() {
		return _isBeingWorn;
	}

	@Override
	public String toString() {
		return getClass().getName() + ": requestType=" + _requestType + ", timestamp=" + _timestamp + ", calibration=" + _calibration
				+ ", isBeingWorn=" + (_isBeingWorn ? "true" : "false");
	}
}
