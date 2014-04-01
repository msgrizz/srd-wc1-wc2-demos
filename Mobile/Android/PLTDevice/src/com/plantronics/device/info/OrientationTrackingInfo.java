package com.plantronics.device.info;

import com.plantronics.device.calibration.Calibration;
import com.plantronics.device.calibration.OrientationTrackingCalibration;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class OrientationTrackingInfo extends Info {

	private Quaternion		_rawQuaternion;


	public OrientationTrackingInfo(int requestType, Date timestamp, Calibration calibration, Quaternion rawQuaternion) {
		super(requestType, timestamp, calibration);
		_rawQuaternion = rawQuaternion;
	}

	public OrientationTrackingInfo(int requestType, Date timestamp, Calibration calibration, EulerAngles eulerAngles) {
		super(requestType, timestamp, calibration);
		_rawQuaternion = new Quaternion(eulerAngles);
	}

	public Quaternion getQuaternion() {
		// apply cal
		OrientationTrackingCalibration calibration = (OrientationTrackingCalibration)_calibration;
		if (calibration!=null) {
			Quaternion inverse = calibration.getReferenceQuaternion().getInverse();
			Quaternion calibrated = _rawQuaternion.getMultiplied(inverse);
			return calibrated;
		}
		return _rawQuaternion;
	}

	public EulerAngles getEulerAngles() {
		return new EulerAngles(getQuaternion());
	}

	public Quaternion getUncalibratedQuaternion() {
		return _rawQuaternion;
	}

	public EulerAngles getUncalibratedEulerAngles() {
		return new EulerAngles(_rawQuaternion);
	}

	@Override
	public String toString() {
		return this.getClass().getName() + ": requestType=" + _requestType + ", timestamp=" + _timestamp + ", calibration=" + _calibration
				+ ", quaternion=" + getQuaternion() + ", eulerAngles=" + getEulerAngles();
	}
}
