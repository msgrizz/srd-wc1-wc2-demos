package com.plantronics.appcore.service.bluetooth.plugins.xevent.requests;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothRequest;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.XEventBluetoothPluginHandler;

public class GetBatteryStateRequest extends BluetoothRequest {
	
	public static final String REQUEST_TYPE = "GetBatteryStateRequest";

	private static final long serialVersionUID = 8856117799430045852L;	
	
	@Override
	public String getRequestType() {
		return REQUEST_TYPE;
	}

	@Override
	public String getRequestPluginHandlerName() {
		return XEventBluetoothPluginHandler.PLUGIN_NAME;
	}

}