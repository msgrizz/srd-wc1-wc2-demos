/**
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.headsetdataservice;
import com.plantronics.headsetdataservice.io.HeadsetDataDevice;

/**
 * Example of a callback interface used by IRemoteService to send
 * synchronous notifications back to its clients.  Note that this is a
 * one-way interface so the server does not block waiting for the client.
 */

import com.plantronics.headsetdataservice.io.DeviceEvent;
import com.plantronics.headsetdataservice.io.DeviceCommandType;
import com.plantronics.headsetdataservice.io.DeviceSettingType;
import com.plantronics.headsetdataservice.io.DeviceEventType;
import com.plantronics.headsetdataservice.io.SessionErrorException;

oneway interface IHeadsetDataServiceCallbackOpen {

    void deviceOpen(in HeadsetDataDevice hdDevice);

    void openFailed(in HeadsetDataDevice hdDevice, in SessionErrorException s);
}
