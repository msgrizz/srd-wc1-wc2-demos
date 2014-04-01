package com.plantronics.device;

/**
 * Created by mdavis on 3/27/14.
 */
public interface PairingListener {

		public void onDevicePaired(Device device);
		public void onDeviceUnpaired(Device device);
}
