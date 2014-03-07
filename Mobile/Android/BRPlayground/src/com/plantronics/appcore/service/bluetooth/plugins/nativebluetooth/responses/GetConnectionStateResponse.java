/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.responses;

import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothPluginHandler;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public class GetConnectionStateResponse extends BluetoothResponse {
    /**
	 * 
	 */
	private static final long serialVersionUID = -3941641553180631345L;

	public static final String RESPONSE_TYPE = "getConnectionStateResponse";

    private boolean mConnected;

    public GetConnectionStateResponse(int requestId) {
        super(requestId);
    }

    @Override
    public String getResponsePluginHandlerName() {
        return NativeBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getResponseType() {
        return RESPONSE_TYPE;
    }

    @Override
    public boolean hasStableId() {
        return true; // We assume that the caller will not destroy the Communicator object
    }

    public BluetoothDevice getBluetoothDevice() {
        return mBluetoothDevice;
    }

    public void setBluetoothDevice(BluetoothDevice mBluetoothDevice) {
        this.mBluetoothDevice = mBluetoothDevice;
    }

    public boolean isConnected() {
        return mConnected;
    }

    public void setIsConnected(boolean mIsConnected) {
        this.mConnected = mIsConnected;
    }


}
