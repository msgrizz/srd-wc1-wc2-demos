package com.plantronics.PLTDevice.info;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class TapsInfo extends com.plantronics.PLTDevice.info.Info
{
	public static final int TAP_DIRECTION_X_UP =	1;
	public static final int TAP_DIRECTION_X_DOWN = 	2;
	public static final int TAP_DIRECTION_Y_UP = 	3;
	public static final int TAP_DIRECTION_Y_DOWN =	4;
	public static final int TAP_DIRECTION_Z_UP = 	5;
	public static final int TAP_DIRECTION_Z_DOWN =	6;

	private int _taps;
	private int _direction;

	public TapsInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, int taps, int direction)
	{
		super(requestType, timestamp, calibration);
//		_requestType = requestType;
//		_timestamp = timestamp;
//		_calibration = calibration;
		_taps = taps;
		_direction = direction;
	}

	public int getTaps()
	{
		return _taps;
	}

	public int getDirection()
	{
		return _direction;
	}

	private static String StringFromTapDirection(int direction) {
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
	public String toString()
	{
		return "";
	}
}