/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothPluginHandler;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public class GetAllBondedDevicesRequest extends BluetoothRequest{
    /**
	 * 
	 */
	private static final long serialVersionUID = -7843871341047411904L;
	
	public static final String REQUEST_TYPE = "getAllBondedDevicesRequest";

    @Override
    public String getRequestPluginHandlerName() {
        return NativeBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getRequestType() {
        return REQUEST_TYPE;
    }
}
