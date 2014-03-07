/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests;

import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothPluginHandler;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 7/9/12
 */
public class ConnectToDeviceRequest extends BluetoothRequest {
    /**
	 * 
	 */
	private static final long serialVersionUID = -1438750083609067731L;
	
	public static final String REQUEST_TYPE = "connectToDeviceRequest";

    private ConnectToDeviceRequest() {}

    /**
     * This request must contain bluetooth device for which we are querying, so we disallow creation without that
     */
    public ConnectToDeviceRequest(BluetoothDevice deviceToConnectTo){
        super();
        this.mBluetoothDevice = deviceToConnectTo;
    }

    @Override
    public String getRequestPluginHandlerName() {
        return NativeBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getRequestType() {
        return REQUEST_TYPE;
    }
}
