/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins;

import com.plantronics.appcore.service.bluetooth.communicator.Response;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public abstract class BluetoothResponse extends BluetoothDeviceHelper  implements Response {
    /**
	 * 
	 */
	private static final long serialVersionUID = -6438260094967427651L;

	public static final int BROADCAST_ID = -1;

    //Each  response should have appropriate ID that is same as the corresponding request ID
    //If response id is set to BROADCAST_ID, all active Communicators will process this ID
    protected int mResponseId;

    @Override
    public int getResponseId() {
        return mResponseId;
    }

    @Override
    public void setResponseId(int mResponseId) {
        this.mResponseId = mResponseId;
    }

    /**
     * Create response object, with supplied id from the request object
     * @param requestId the id of the request for which this response is created, use BROADCAST_ID to send to all communicators
     */
    public BluetoothResponse(int requestId){
        mResponseId = requestId;
    }



    public abstract String getResponsePluginHandlerName();


}
