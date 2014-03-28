package com.plantronics.device.info;

import com.plantronics.device.calibration.OrientationTrackingCalibration;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class OrientationTrackingInfo extends com.plantronics.device.info.Info {

	private Quaternion	_rawQuaternion;


	public OrientationTrackingInfo(int requestType, Date timestamp, com.plantronics.device.calibration.Calibration calibration, Quaternion rawQuaternion) {
		super(requestType, timestamp, calibration);
		_rawQuaternion = rawQuaternion;
	}

	public OrientationTrackingInfo(int requestType, Date timestamp, com.plantronics.device.calibration.Calibration calibration, EulerAngles eulerAngles) {
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


//PLTQuaternion inverseReferenceQuaternion = InverseQuaternion(self.referenceQuaternion);
//PLTQuaternion calibratedQuaternion = MultipliedQuaternions(self.rawQuaternion, inverseReferenceQuaternion);
//return calibratedQuaternion;
//
//
//		PLTQuaternion MultipliedQuaternions(PLTQuaternion q, PLTQuaternion p)
//		{
//		double *mulQuat = malloc(sizeof(double)*4);
//		memset(mulQuat, 0, sizeof(double)*4);
//
//		double quatmat[4][4] =
//		{   { p.w, -p.x, -p.y, -p.z },
//		{ p.x, p.w, -p.z, p.y },
//		{ p.y, p.z, p.w, -p.x },
//		{ p.z, -p.y, p.x, p.w },
//		};
//
//		for (int i = 0; i < 4; i++) {
//		for (int j = 0; j < 4; j++) {
//		double *qq = (double *)&q;
//		mulQuat[i] += quatmat[i][j] * qq[j];
//		}
//		}
//
//		return (PLTQuaternion){ mulQuat[0], mulQuat[1], mulQuat[2], mulQuat[3] };
//		}
//
//		PLTQuaternion InverseQuaternion(PLTQuaternion q)
//		{
//		return (PLTQuaternion){ q.w, -q.x, -q.y, -q.z };
//		}
//
