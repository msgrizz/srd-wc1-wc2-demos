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
public class GetConnectedDeviceRequest extends BluetoothRequest {
    /**
	 * 
	 */
	private static final long serialVersionUID = 8223078416218274983L;
	
	public static final String REQUEST_TYPE = "getConnectedDeviceRequest";

    @Override
    public String getRequestPluginHandlerName() {
        return NativeBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getRequestType() {
        return REQUEST_TYPE;
    }
}
