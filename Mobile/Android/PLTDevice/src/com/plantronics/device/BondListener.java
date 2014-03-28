package com.plantronics.device;

/**
 * Created by mdavis on 3/27/14.
 */
public interface BondListener {

		public void onDeviceBonded(Device device);
		public void onDeviceUnbonded(Device device);
}
