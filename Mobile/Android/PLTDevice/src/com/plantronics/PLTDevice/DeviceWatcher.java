package com.plantronics.PLTDevice;

/**
 * Created by mdavis on 3/11/14.
 */
public class DeviceWatcher {

	public Device[] _devices;

	private static DeviceWatcher _instance;

	public DeviceWatcher getInstance() {
		if (_instance==null) {
			_instance = new DeviceWatcher();
		}
		return _instance;
	}

	public static Device[] findDevices(Device.AvailableDevicesCallback callback) {
		return null;
	}
}
