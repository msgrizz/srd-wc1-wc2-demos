package com.plantronics.PLTDevice.info;

import com.plantronics.labs.Info;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class GyroscopeCalInfo extends Info
{
	private boolean _isCalibrated;

	public GyroscopeCalInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, boolean isCalibrated)
	{
		super(requestType, timestamp, calibration);
//		_requestType = requestType;
//		_timestamp = timestamp;
//		_calibration = calibration;
		_isCalibrated = isCalibrated;
	}

	public boolean getIsCalibrated()
	{
		return _isCalibrated;
	}

	@Override
	public String toString()
	{
		return "";
	}
}
