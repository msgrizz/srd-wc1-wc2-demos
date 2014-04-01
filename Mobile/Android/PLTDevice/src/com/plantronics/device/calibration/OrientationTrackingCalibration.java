package com.plantronics.device.calibration;

import com.plantronics.device.info.EulerAngles;
import com.plantronics.device.info.Quaternion;

/**
 * Created by mdavis on 1/16/14.
 */
public class OrientationTrackingCalibration extends Calibration {

	private Quaternion 		_referenceQuaternion;


	public OrientationTrackingCalibration(EulerAngles angles) {
		_referenceQuaternion = new Quaternion(angles);
	}

	public OrientationTrackingCalibration(Quaternion quaternion) {
		_referenceQuaternion = quaternion;
	}

	public EulerAngles getReferenceEulerAngles() {
		return new EulerAngles(_referenceQuaternion);
	}

	public Quaternion getReferenceQuaternion() {
		return _referenceQuaternion;
	}

	@Override
	public String toString() {
		return this.getClass().getName() + ": referenceQuaternion=" + getReferenceQuaternion() + ", referenceEulerAngles=" + getReferenceEulerAngles();
	}
}
