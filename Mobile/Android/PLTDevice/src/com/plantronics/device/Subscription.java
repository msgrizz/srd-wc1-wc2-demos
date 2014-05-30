package com.plantronics.device;

/**
 * Created by mdavis on 3/20/14.
 */
public class Subscription {

	private short 		_service;
	private byte 		_mode;
	private short		_period;


	public Subscription(short service, byte mode, short period) {
		_service = service;
		_mode = mode;
		_period = period;
	}

	public short getService() {
		return _service;
	}

	public byte getMode() {
		return _mode;
	}

	public short getPeriod() {
		return _period;
	}

	@Override
	public String toString() {
		return getClass().getName() + ": service=" + _service + ", mode=" + _mode + ", period=" + _period;
	}
}
