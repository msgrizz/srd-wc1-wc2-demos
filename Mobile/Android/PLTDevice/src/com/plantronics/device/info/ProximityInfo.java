package com.plantronics.device.info;

import com.plantronics.device.calibration.Calibration;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class ProximityInfo extends Info {

	public static final int PROXIMITY_FAR =			0;
	public static final int PROXIMITY_NEAR =		1;
	public static final int PROXIMITY_UNKNOWN =		2;

	private int 									_localProximity;
	private int 									_remoteProximity;


	public ProximityInfo(int requestType, Date timestamp, Calibration calibration, int localProximity, int remoteProximity) {
		super(requestType, timestamp, calibration);
		_localProximity = localProximity;
		_remoteProximity = remoteProximity;
	}

	public int getLocalProximity() {
		return _localProximity;
	}

	public int getRemoteProximity() {
		return _remoteProximity;
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
				+ ", localProximity=" + StringFromProximity(_localProximity) + ", remoteProximity=" + StringFromProximity(_remoteProximity);
	}
}
