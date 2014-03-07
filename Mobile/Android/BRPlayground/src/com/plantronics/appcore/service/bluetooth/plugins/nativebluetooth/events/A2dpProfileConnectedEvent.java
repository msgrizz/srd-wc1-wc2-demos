/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothPluginHandler;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/21/12
 */
public class A2dpProfileConnectedEvent extends BluetoothEvent {
    /**
	 * 
	 */
	private static final long serialVersionUID = -2296610333983075649L;
	
	public static final String EVENT_TYPE = "a2dpProfileConnected";

    @Override
    public String getEventPluginHandlerName() {
        return NativeBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getType() {
        return EVENT_TYPE;
    }
}
