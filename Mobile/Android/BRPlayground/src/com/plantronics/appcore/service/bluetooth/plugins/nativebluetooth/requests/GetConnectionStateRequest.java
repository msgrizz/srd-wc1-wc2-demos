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
 * Date: 5/4/12
 */
public class GetConnectionStateRequest extends BluetoothRequest {
    /**
	 * 
	 */
	private static final long serialVersionUID = -928110766787336325L;
	
	public static final String REQUEST_TYPE = "getConnectionStateRequest";

    @Override
    public String getRequestPluginHandlerName() {
        return NativeBluetoothPluginHandler.PLUGIN_NAME;
    }

    /**
     * This request must contain bluetooth device for which we are querying, so we disallow creation without that
     */
    private GetConnectionStateRequest() {}

    public GetConnectionStateRequest(BluetoothDevice bluetoothDevice){
        super();
        this.mBluetoothDevice = bluetoothDevice;
    }



    @Override
    public String getRequestType() {
        return REQUEST_TYPE;
    }

    public BluetoothDevice getBluetoothDevice() {
        return mBluetoothDevice;
    }
}
