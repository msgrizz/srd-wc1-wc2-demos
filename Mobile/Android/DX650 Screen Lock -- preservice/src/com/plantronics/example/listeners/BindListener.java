/**
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.example.listeners;

/**
 * Interface defines the events generated from binding/unbinding and
 * Connect/Disconnect to the {@link com.plantronics.headsetdataservice.HeadsetDataService}
 */
public interface BindListener {

    /**
     * Bind to the {@link com.plantronics.headsetdataservice.HeadsetDataService} was successful
     */
    public void bindSuccess();

    /**
     * Bind to the {@link com.plantronics.headsetdataservice.HeadsetDataService} was un-successful
     */
    public void bindFailed();

    /**
     * App has initiated un-bind to the {@link com.plantronics.headsetdataservice.HeadsetDataService}
     */
    public void unbind();

    /**
     * App is now connected to the {@link com.plantronics.headsetdataservice.HeadsetDataService} and a
     * {@link android.content.ServiceConnection} object is  created
     */
    public void serviceConnected();

    /**
     * App is now dis-connected to the {@link com.plantronics.headsetdataservice.HeadsetDataService} and a
     * {@link android.content.ServiceConnection} object is not valid
     */
    public void serviceDisconnected();

}



