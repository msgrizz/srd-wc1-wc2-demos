/**
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.headsetdataservice;
import com.plantronics.headsetdataservice.io.HeadsetDataDevice;
import com.plantronics.headsetdataservice.io.SessionErrorException;

/**
 * Example of a callback interface used by IRemoteService to send
 * synchronous notifications back to its clients.  Note that this is a
 * one-way interface so the server does not block waiting for the client.
 */
oneway interface IHeadsetDataServiceCallbackSession {

    void deviceClose(in HeadsetDataDevice hdDevice, in SessionErrorException s);
}
