package com.plantronics.device;

/**
 * Created by mdavis on 3/11/14.
 */

public interface ConnectionListener {

	public void onConnectionOpen(Device device);
	public void onConnectionFailedToOpen(Device device, int error);
	public void onConnectionClosed(Device device);
}
