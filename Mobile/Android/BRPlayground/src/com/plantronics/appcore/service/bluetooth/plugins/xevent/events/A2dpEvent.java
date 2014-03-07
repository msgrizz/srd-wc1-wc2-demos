/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.xevent.events;

import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.service.bluetooth.plugins.xevent.XEventBluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.XEventType;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/15/12
 */
public class A2dpEvent extends XEvent {
    private boolean mIsEnabled;

    public A2dpEvent(BluetoothDevice bluetoothDevice,boolean mIsEnabled) {
        mBluetoothDevice = bluetoothDevice;
        this.mIsEnabled = mIsEnabled;
    }

    @Override
    public String getEventPluginHandlerName() {
        return XEventBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getType() {
        return XEventType.A2DP.toString();
    }

    public boolean IsEnabled() {
        return mIsEnabled;
    }

    public void setIsEnabled(boolean mIsEnabled) {
        this.mIsEnabled = mIsEnabled;
    }
}