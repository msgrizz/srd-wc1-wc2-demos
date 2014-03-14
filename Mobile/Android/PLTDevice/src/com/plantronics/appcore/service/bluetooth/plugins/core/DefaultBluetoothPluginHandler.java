/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.core;

import android.content.Context;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothRequest;
import com.plantronics.appcore.service.bluetooth.plugins.core.requests.TurnBluetoothOnRequest;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public class DefaultBluetoothPluginHandler extends BluetoothPluginHandler{
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + DefaultBluetoothPluginHandler.class.getSimpleName();

    public static final String PLUGIN_NAME = "DefaultCorePlugin";

    public DefaultBluetoothPluginHandler(Context mContext) {
        super(mContext);
    }

    @Override
    public void initPlugin() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean isHandlingEvent(String eventOrigin) {
        return eventOrigin.equals(PLUGIN_NAME);
    }

    @Override
    public void handleEvent(BluetoothEvent bluetoothEvent) {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public boolean isHandlingRequest(String requestOrigin) {
        return requestOrigin.equals(PLUGIN_NAME);
    }

    @Override
    public void handleRequest(BluetoothRequest request) {
        if (request instanceof TurnBluetoothOnRequest){

        }
    }
}
