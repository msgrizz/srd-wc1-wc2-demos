package com.plantronics.PLTDevice.info;

import com.plantronics.PLTDevice.Info;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class FreeFallInfo extends Info
{
	private boolean _isInFreeFall;

	public FreeFallInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, boolean isInFreeFall)
	{
		super(requestType, timestamp, calibration);
//		_requestType = requestType;
//		_timestamp = timestamp;
//		_calibration = calibration;
		_isInFreeFall = isInFreeFall;
	}

	public boolean getIsInFreeFall()
	{
		return _isInFreeFall;
	}

	@Override
	public boolean equals(Object other)
	{
		FreeFallInfo info = (FreeFallInfo)other;
		return this._isInFreeFall == info.getIsInFreeFall();
	}

	@Override
	public String toString()
	{
		return "";
	}
}
