/**
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.BladeRunner.controller;

import com.plantronics.headsetdataservice.io.DeviceSetting;
import com.plantronics.headsetdataservice.io.HeadsetDataDevice;

public class HeadsetDeviceSetting  {

    DeviceSetting setting;
    HeadsetDataDevice device;

    public HeadsetDeviceSetting(DeviceSetting setting, HeadsetDataDevice device) {
        this.setting = setting;
        this.device = device;
    }

    public DeviceSetting getSetting() {
        return setting;
    }

    public void setSetting(DeviceSetting setting) {
        this.setting = setting;
    }

    public HeadsetDataDevice getDevice() {
        return device;
    }

    public void setDevice(HeadsetDataDevice device) {
        this.device = device;
    }

    @Override
    public String toString() {
        return "HeadsetDeviceSetting{" +
                "setting=" + setting +
                ", device=" + device +
                '}';
    }
}

