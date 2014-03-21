package com.plantronics.PLTDevice.info;

import com.plantronics.PLTDevice.calibration.OrientationTrackingCalibration;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class OrientationTrackingInfo extends com.plantronics.PLTDevice.info.Info
{
	private Quaternion						_rawQuaternion;

	public OrientationTrackingInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, Quaternion rawQuaternion) {
		super(requestType, timestamp, calibration);
		_rawQuaternion = rawQuaternion;
	}

	public OrientationTrackingInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, EulerAngles eulerAngles) {
		super(requestType, timestamp, calibration);
		_requestType = requestType;
		_timestamp = timestamp;
		_calibration = calibration;
		_rawQuaternion = new Quaternion(eulerAngles);
	}

	public Quaternion getQuaternion() {
		// apply cal
		return _rawQuaternion;
	}

	public EulerAngles getEulerAngles() {
		return new EulerAngles(getQuaternion());
	}

	@Override
	public String toString() {
		return this.getClass().getName() + ": requestType=" + _requestType + ", timestamp=" + _timestamp + ", calibration=" + _calibration
				+ ", quaternion=" + getQuaternion() + ", eulerAngles=" + getEulerAngles();
	}
}
