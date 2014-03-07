package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests;
/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 * 
 * Created by: Vladimir Petric
 * Date: 12/4/12 
 */

import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

public class DisconnectDeviceRequest extends BluetoothRequest {
    /**
	 * 
	 */
	private static final long serialVersionUID = -7479116046772797438L;

	private static final String TAG = LogTag.getBluetoothPackageTagPrefix() + DisconnectDeviceRequest.class.getSimpleName();

    public static final String REQUEST_TYPE = "disconnectDeviceRequest";

    private DisconnectDeviceRequest() {}

    /**
     * This request must contain bluetooth device for which we are querying, so we disallow creation without that
     */
    public DisconnectDeviceRequest(BluetoothDevice deviceToConnectTo){
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
