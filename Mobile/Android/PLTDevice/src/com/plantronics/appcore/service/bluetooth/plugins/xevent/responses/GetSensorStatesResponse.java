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
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.SensorType;

import java.util.Map;

/**
 * Response carrying a map of enables sensors
 *
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/18/12
 */
public class GetSensorStatesResponse extends BluetoothResponse{
    /**
	 * 
	 */
	private static final long serialVersionUID = 8353106550756786681L;
	
	public static final String RESPONSE_TYPE = "getSensorStatesResponse";
	
    private Map<SensorType, Boolean> mSensorStatusMap;

    public GetSensorStatesResponse(int requestId) {
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
        return false; // just in case
    }

    public BluetoothDevice getBluetoothDevice() {
        return mBluetoothDevice;
    }

    public void setBluetoothDevice(BluetoothDevice bluetoothDevice) {
        mBluetoothDevice = bluetoothDevice;
    }

    public Map<SensorType, Boolean> getSensorStatusMap() {
        return mSensorStatusMap;
    }

    public void setSensorStatusMap(Map<SensorType, Boolean> sensorStatusMap) {
        mSensorStatusMap = sensorStatusMap;
    }
}
