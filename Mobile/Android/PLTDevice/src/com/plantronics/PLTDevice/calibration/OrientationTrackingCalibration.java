package com.plantronics.PLTDevice.calibration;

/**
 * Created by mdavis on 1/16/14.
 */
public class OrientationTrackingCalibration extends com.plantronics.PLTDevice.calibration.Calibration
{
	private Quaternion _referenceQuaternion;

	public OrientationTrackingCalibration(EulerAngles angles)
	{
		_referenceQuaternion = Quaternion.QuaternionFromEulerAngles(angles);
	}

	public OrientationTrackingCalibration(Quaternion quaternion)
	{
		_referenceQuaternion = quaternion;
	}

	public EulerAngles getReferenceEulerAngles()
	{
		return EulerAngles.EulerAnglesFromQuaternion(_referenceQuaternion);
	}

	public Quaternion getReferenceQuaternion()
	{
		return _referenceQuaternion;
	}

	@Override
	public String toString()
	{
		return "";
	}
}
