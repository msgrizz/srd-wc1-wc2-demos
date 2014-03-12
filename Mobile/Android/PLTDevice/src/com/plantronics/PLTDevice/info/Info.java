package com.plantronics.PLTDevice.info;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class Info
{
	public static final int REQUEST_TYPE_SUBSCRIPTION = 0;
	public static final int REQUEST_TYPE_QUERY =		1;

	protected int _requestType;
	protected Date _timestamp;
	protected com.plantronics.PLTDevice.calibration.Calibration _calibration;

	public Info(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration)
	{
		_requestType = requestType;
		_timestamp = timestamp;
		_calibration = calibration;
	}

	public int getRequestType()
	{
		return _requestType;
	}

	public Date getTimestamp()
	{
		return _timestamp;
	}

	@Override
	public String toString() {
		return "";
	}
}
