package com.plantronics.device;

/**
 * Created by mdavis on 3/20/14.
 */
public class Subscription {

	private int 		_service;
	private int 		_mode;
	private int			_period;


	public Subscription(int service, int mode, int period) {
		_service = service;
		_mode = mode;
		_period = period;
	}

	public int getService() {
		return _service;
	}

	public int getMode() {
		return _mode;
	}

	public int getPeriod() {
		return _period;
	}

	@Override
	public String toString() {
		return getClass().getName() + ": service=" + _service + ", mode=" + _mode + ", period=" + _period;
	}
}
