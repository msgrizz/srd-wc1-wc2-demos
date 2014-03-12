package com.plantronics.PLTDevice.info;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class WearingStateInfo extends com.plantronics.PLTDevice.info.Info
{
	private boolean _isBeingWorn;

	public WearingStateInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, boolean isBeingWorn)
	{
		super(requestType, timestamp, calibration);
//		_requestType = requestType;
//		_timestamp = timestamp;
//		_calibration = calibration;
		_isBeingWorn = isBeingWorn;
	}

	public boolean getIsBeingWorn()
	{
		return _isBeingWorn;
	}

	@Override
	public String toString()
	{
		return "";
	}
}
