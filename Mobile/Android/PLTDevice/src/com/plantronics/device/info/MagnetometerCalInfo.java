package com.plantronics.device.info;

import com.plantronics.device.calibration.Calibration;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class MagnetometerCalInfo extends com.plantronics.device.info.Info {

	private boolean 	_isCalibrated;


	public MagnetometerCalInfo(byte requestType, Date timestamp, Calibration calibration, boolean isCalibrated) {
		super(requestType, timestamp, calibration);
		_isCalibrated = isCalibrated;
	}

	public boolean getIsCalibrated() {
		return _isCalibrated;
	}

	@Override
	public String toString() {
		return getClass().getName() + ": requestType=" + _requestType + ", timestamp=" + _timestamp + ", calibration=" + _calibration
				+ ", isCalibrated=" + (_isCalibrated ? "true" : "false");
	}
}
