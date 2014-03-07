package com.plantronics.appcore.service.bluetooth.plugins.xevent.responses;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothResponse;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.XEventBluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.BatteryEvent;

public class GetBatteryStateResponse extends BluetoothResponse {

	public static final String RESPONSE_TYPE = "GetBatteryStateResponse";
	
	private static final long serialVersionUID = 5264815812167905674L;
	
	private BatteryEvent mLastBatteryEvent;
	
	/**
	 * Creates a new instance of GetBatteryStateResponse
	 * @param requestId
	 * 		the request's id
	 */
	public GetBatteryStateResponse(int requestId) {
		super(requestId);
	}

	@Override
	public String getResponseType() {
		return RESPONSE_TYPE;
	}

	@Override
	public boolean hasStableId() {
		return true;
	}

	@Override
	public String getResponsePluginHandlerName() {
		return XEventBluetoothPluginHandler.PLUGIN_NAME;
	}

	/**
	 * @return
	 * 		The last received battery event
	 */
	public BatteryEvent getLastBatteryEvent() {
		return mLastBatteryEvent;
	}

	/**
	 * Sets the last received battery event
	 * @param lastBatteryEvent
	 * 		The battery event received last
	 */
	public void setLastBatteryEvent(BatteryEvent lastBatteryEvent) {
		this.mLastBatteryEvent = lastBatteryEvent;
	}
}
