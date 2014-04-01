package com.plantronics.device.info;

import com.plantronics.device.calibration.Calibration;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class FreeFallInfo extends Info {

	private boolean 	_isInFreeFall;


	public FreeFallInfo(int requestType, Date timestamp, Calibration calibration, boolean isInFreeFall) {
		super(requestType, timestamp, calibration);
		_isInFreeFall = isInFreeFall;
	}

	public boolean getIsInFreeFall() {
		return _isInFreeFall;
	}

	@Override
	public boolean equals(Object other) {
		FreeFallInfo info = (FreeFallInfo)other;
		return _isInFreeFall == info.getIsInFreeFall();
	}

	@Override
	public String toString() {
		return getClass().getName() + ": requestType=" + _requestType + ", timestamp=" + _timestamp + ", calibration=" + _calibration
				+ ", isInFreeFall=" + (_isInFreeFall ? "yes" : "no");
	}
}
