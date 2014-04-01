package com.plantronics.device.calibration;

/**
 * Created by mdavis on 3/28/14.
 */
public class PedometerCalibration extends Calibration {

	private boolean		_reset;


	public PedometerCalibration() {
		_reset = true;
	}

	public void setReset(boolean reset) {
		_reset = reset;
	}

	public boolean getReset() {
		return _reset;
	}
}
