package com.plantronics.PLTDevice.info;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class ProximityInfo extends com.plantronics.PLTDevice.info.Info
{
	public static final int PROXIMITY_FAR =		0;
	public static final int PROXIMITY_NEAR =	1;
	public static final int PROXIMITY_UNKNOWN =	2;

	private int _pcProximity;
	private int _mobileProximity;

	public ProximityInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, int pcProximity, int mobileProximity) {
		super(requestType, timestamp, calibration);
		_pcProximity = pcProximity;
		_mobileProximity = mobileProximity;
	}

	public int getPCProximity() {
		return _pcProximity;
	}

	public int getMobileProximity() {
		return _mobileProximity;
	}

	public static String StringFromProximity(int proximity) {
		switch (proximity) {
			case PROXIMITY_FAR:
				return "far";
			case PROXIMITY_NEAR:
				return "near";
			case PROXIMITY_UNKNOWN:
				return "unknown";
			default:
				return "";
		}
	}

	@Override
	public String toString() {
		return getClass().getName() + ": requestType=" + _requestType + ", timestamp=" + _timestamp + ", calibration=" + _calibration
				+ ", pcProximity=" + StringFromProximity(_pcProximity) + ", mobileProximity=" + StringFromProximity(_mobileProximity);
	}
}
