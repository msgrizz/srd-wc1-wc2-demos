/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.xevent.responses;

import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothResponse;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.XEventBluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.DonDoffEvent;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/24/12
 */
public class GetWearingStateResponse extends BluetoothResponse {
    /**
	 * 
	 */
	private static final long serialVersionUID = 5770395098294891908L;

	public static final String RESPONSE_TYPE = "GetWearingStateResponse";

    private DonDoffEvent mLastDonDoffEvent;

    public GetWearingStateResponse(int requestId) {
        super(requestId);
    }

    @Override
    public String getResponsePluginHandlerName() {
        return XEventBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getResponseType() {
        return RESPONSE_TYPE;
    }

    @Override
    public boolean hasStableId() {
        return true; // just in case
    }

    public DonDoffEvent getLastDonDoffEvent() {
        return mLastDonDoffEvent;
    }

    public void setLastDonDoffEvent(DonDoffEvent lastDonDoffEvent) {
        this.mLastDonDoffEvent = lastDonDoffEvent;
    }
}
