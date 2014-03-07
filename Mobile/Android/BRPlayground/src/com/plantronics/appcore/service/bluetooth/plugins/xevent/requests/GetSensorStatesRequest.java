/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.xevent.requests;

import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothRequest;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.XEventBluetoothPluginHandler;

/**
 * Requests a map of enabled sensors for a specific device, senor types are available in SensorStatus
 * enum {@link com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.SensorType}
 * </br>
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/18/12
 */
public class GetSensorStatesRequest extends BluetoothRequest {
    /**
	 * 
	 */
	private static final long serialVersionUID = 5127886231801406650L;
	
	public static final String REQUEST_TYPE = "GetSensorStatesRequest";

    public GetSensorStatesRequest(BluetoothDevice bluetoothDevice) {
        mBluetoothDevice = bluetoothDevice;
    }

    @Override
    public String getRequestPluginHandlerName() {
        return XEventBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getRequestType() {
        return REQUEST_TYPE;
    }

    public BluetoothDevice getBluetoothDevice() {
        return mBluetoothDevice;
    }

    public void setBluetoothDevice(BluetoothDevice bluetoothDevice) {
        mBluetoothDevice = bluetoothDevice;
    }


}
