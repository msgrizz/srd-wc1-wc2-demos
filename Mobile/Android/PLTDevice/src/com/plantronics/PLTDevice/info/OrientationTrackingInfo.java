package com.plantronics.PLTDevice.info;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class OrientationTrackingInfo extends com.plantronics.PLTDevice.info.Info
{
	private Quaternion _rawQuaternion;

	public OrientationTrackingInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, Quaternion rawQuaternion)
	{
		super(requestType, timestamp, calibration);
//		_requestType = requestType;
//		_timestamp = timestamp;
//		_calibration = calibration;
		_rawQuaternion = rawQuaternion;
	}

	public OrientationTrackingInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, EulerAngles eulerAngles)
	{
		super(requestType, timestamp, calibration);
//		_requestType = requestType;
//		_timestamp = timestamp;
//		_calibration = calibration;
//		_rawQuaternion = Quaternion.QuaternionFromEulerAngles(eulerAngles);
	}

	@Override
	public String toString()
	{
		return "";
	}
}
