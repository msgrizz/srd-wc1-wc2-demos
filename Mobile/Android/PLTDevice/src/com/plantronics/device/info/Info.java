package com.plantronics.device.info;

import com.plantronics.device.calibration.Calibration;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class Info
{
	public static final byte REQUEST_TYPE_SUBSCRIPTION = 	0;
	public static final byte REQUEST_TYPE_QUERY =			1;
	public static final byte REQUEST_TYPE_CACHED = 			2;

	protected byte											_requestType;
	protected Date 											_timestamp;
	protected Calibration									_calibration;


	public Info(byte requestType, Date timestamp, Calibration calibration) {
		_requestType = requestType;
		_timestamp = timestamp;
		_calibration = calibration;
	}

	public int getRequestType() {
		return _requestType;
	}

	public Date getTimestamp() {
		return _timestamp;
	}

	public void setRequestType(byte requestType) {
		_requestType = requestType;
	}

	public void setTimestamp(Date timestamp) {
		_timestamp = timestamp;
	}

	@Override
	public String toString() {
		return getClass().getName() + ": requestType=" + _requestType + ", timestamp=" + _timestamp + ", calibration=" + _calibration;
	}
}
