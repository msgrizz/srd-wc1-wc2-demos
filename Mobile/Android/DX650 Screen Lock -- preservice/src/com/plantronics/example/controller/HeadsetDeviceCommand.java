/**
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.example.controller;


import com.plantronics.headsetdataservice.io.DeviceCommand;
import com.plantronics.headsetdataservice.io.HeadsetDataDevice;

/**
 * Class defined to group together HeadsetDataDevice with the Device Command which is
 * executed on it.
 */
public class HeadsetDeviceCommand {

    DeviceCommand command;
    HeadsetDataDevice device;

    public HeadsetDeviceCommand(DeviceCommand command, HeadsetDataDevice device) {
        this.command = command;
        this.device = device;
    }

    public void setDevice(HeadsetDataDevice device) {
        this.device = device;
    }

    public void setCommand(DeviceCommand command) {
        this.command = command;
    }

    public DeviceCommand getCommand() {
        return command;
    }

    public HeadsetDataDevice getDevice() {
        return device;
    }

    @Override
    public String toString() {
        return "HeadsetDeviceCommand{" +
                "command=" + command +
                ", device=" + device +
                '}';
    }
}

