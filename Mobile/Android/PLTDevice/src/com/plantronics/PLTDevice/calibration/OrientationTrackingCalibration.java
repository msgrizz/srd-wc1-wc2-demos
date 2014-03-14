package com.plantronics.PLTDevice.calibration;

import com.plantronics.PLTDevice.info.EulerAngles;
import com.plantronics.PLTDevice.info.Quaternion;

/**
 * Created by mdavis on 1/16/14.
 */
public class OrientationTrackingCalibration extends com.plantronics.PLTDevice.calibration.Calibration
{
	private Quaternion _referenceQuaternion;

	public OrientationTrackingCalibration(EulerAngles angles)
	{

	}

	public OrientationTrackingCalibration(Quaternion quaternion)
	{
		_referenceQuaternion = quaternion;
	}

	public EulerAngles getReferenceEulerAngles()
	{
		return null;
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
