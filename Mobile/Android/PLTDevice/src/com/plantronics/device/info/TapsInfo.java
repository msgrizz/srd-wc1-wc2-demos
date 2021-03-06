package com.plantronics.device.info;

import com.plantronics.device.calibration.Calibration;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class TapsInfo extends Info {

	public static final int TAP_DIRECTION_X_UP =	1;
	public static final int TAP_DIRECTION_X_DOWN = 	2;
	public static final int TAP_DIRECTION_Y_UP = 	3;
	public static final int TAP_DIRECTION_Y_DOWN =	4;
	public static final int TAP_DIRECTION_Z_UP = 	5;
	public static final int TAP_DIRECTION_Z_DOWN =	6;

	private byte 									_count;
	private byte 									_direction;


	public TapsInfo(byte requestType, Date timestamp, Calibration calibration, byte count, byte direction) {
		super(requestType, timestamp, calibration);
		_count = count;
		_direction = direction;
	}

	public int getCount() {
		return _count;
	}

	public int getDirection() {
		return _direction;
	}

	public static String getStringForTapDirection(int direction) {
		switch (direction) {
			case TAP_DIRECTION_X_UP:
				return "x up";
			case TAP_DIRECTION_X_DOWN:
				return "x down";
			case TAP_DIRECTION_Y_UP:
				return "y up";
			case TAP_DIRECTION_Y_DOWN:
				return "y down";
			case TAP_DIRECTION_Z_UP:
				return "z up";
			case TAP_DIRECTION_Z_DOWN:
				return "z down";
		}
		return "";
	}

	@Override
	public String toString() {
		return getClass().getName() + ": requestType=" + _requestType + ", timestamp=" + _timestamp + ", calibration=" + _calibration
				+ ", count=" + _count + ", direction=" + getStringForTapDirection(_direction);
	}
}
