/**
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.example.listeners;

import com.plantronics.example.controller.SettingsResult;
import com.plantronics.headsetdataservice.io.RemoteResult;

import java.security.PublicKey;

public interface HeadsetServiceResponseListener {

    /**
     *
     * @param res
     * @param result
     */
    public void result(int res, RemoteResult result);

    public void settingResult(int res, SettingsResult settingsResult);
}

