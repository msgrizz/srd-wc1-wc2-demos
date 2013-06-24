/**
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.example.listener;


import com.plantronics.headsetdataservice.io.HeadsetDataDevice;

public interface HeadsetServiceConnectionListener {

    public void deviceOpen(HeadsetDataDevice device);
    public void openFailed(HeadsetDataDevice device);
    public void deviceClosed(HeadsetDataDevice device);

}

