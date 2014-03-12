package com.plantronics.PLTDevice.info;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class PedometerInfo extends com.plantronics.PLTDevice.info.Info
{
	private int _steps;

	public PedometerInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, int steps)
	{
		super(requestType, timestamp, calibration);
//		_requestType = requestType;
//		_timestamp = timestamp;
//		_calibration = calibration;
		_steps = steps;
	}

	public int getSteps()
	{
		return _steps;
	}

	@Override
	public String toString()
	{
		return "";
	}
}
