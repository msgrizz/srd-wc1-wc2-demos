/**
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.BladeRunner.listener;

/**
 * Interface to which App interested in discovering bladerunner device
 * can bind to.
 * SDK can only discover bladerunner devices among the bonded Bluetooth devices.
 * <p/>
 * SDK gets a list of bonded bluetooth devices on the phone and iterates through the list to
 * identify which of them implement Bladerunner protocol.
 */
public interface DiscoveryListener {

    /**
     * Discovery operation found a Bluetooth device which implements
     * bladerunner protocol
     *
     * @param name Bluetooth address of the device
     */
    void foundDevice(String name);

    /**
     * Called when the discovery process has stopped.
     *
     * @param res boolean success if a result was found
     */
    void discoveryStopped(int res);
}

