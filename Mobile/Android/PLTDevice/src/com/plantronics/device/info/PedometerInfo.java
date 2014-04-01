package com.plantronics.device.info;

import com.plantronics.device.calibration.Calibration;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class PedometerInfo extends Info {

	private int 	_steps;


	public PedometerInfo(int requestType, Date timestamp, Calibration calibration, int steps) {
		super(requestType, timestamp, calibration);
		_steps = steps;
	}

	public int getSteps() {
		return _steps;
	}

	@Override
	public String toString() {
		return getClass().getName() + ": requestType=" + _requestType + ", timestamp=" + _timestamp + ", calibration=" + _calibration
				+ ", steps=" + _steps;
	}
}
