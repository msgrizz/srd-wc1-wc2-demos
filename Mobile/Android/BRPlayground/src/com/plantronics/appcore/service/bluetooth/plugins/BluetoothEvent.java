/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins;

import com.plantronics.appcore.service.bluetooth.communicator.Event;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs) *
 */
public abstract class BluetoothEvent extends BluetoothDeviceHelper implements Event {
    /**
	 * 
	 */
	private static final long serialVersionUID = 4155613310873837312L;

	/**
     * Returns the origin of the event by which BluetoothManager can call the
     * appropriate handler
     *
     * @return type name (xevent, bladerunner, native...)
     */
    public abstract String getEventPluginHandlerName();

}
