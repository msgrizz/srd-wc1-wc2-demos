/**
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.example.listeners;

import com.plantronics.headsetdataservice.io.DeviceEvent;

public interface HeadsetServiceEventListener {

    public void eventReceived(DeviceEvent de);
}

