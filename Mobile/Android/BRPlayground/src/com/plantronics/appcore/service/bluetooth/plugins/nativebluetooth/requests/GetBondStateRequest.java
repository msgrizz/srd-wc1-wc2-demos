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
public class GetBondStateRequest extends BluetoothRequest {    
	/**
	 * 
	 */
	private static final long serialVersionUID = -8500372815477650784L;
	
	public static final String REQUEST_TYPE = "getBondStateRequest";

    @Override
    public String getRequestPluginHandlerName() {
        return NativeBluetoothPluginHandler.PLUGIN_NAME;
    }

    /**
     * This request must contain bluetooth device. We disallow creation without that.
     */
    private GetBondStateRequest() {}


    public GetBondStateRequest(BluetoothDevice bluetoothDevice){
        //Set the request ID
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
