/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins;

import android.content.Context;

import com.plantronics.appcore.service.bluetooth.BluetoothManagerService;
import com.plantronics.appcore.service.bluetooth.communicator.Request;

/**
 *
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public abstract class BluetoothRequest extends BluetoothDeviceHelper  implements Request {
    /**
	 * 
	 */
	private static final long serialVersionUID = -6439820239620240380L;

    //ID of this request. This ID will be used in response so that only the designated activity receives the response
    //In some cases response ID won't be specified so that all communicators process response
    private int mRequestId;

    @Override
    public int getRequestId() {
        return mRequestId;
    }

    public BluetoothRequest(){
        mRequestId = (int)(Math.random()*Integer.MAX_VALUE);
    }

    @Override
    public String getRequestTargetServiceAction(Context context) {
        return BluetoothManagerService.Intents.getRequestAction(context.getApplicationContext());
    }

    public abstract String getRequestPluginHandlerName();


}
