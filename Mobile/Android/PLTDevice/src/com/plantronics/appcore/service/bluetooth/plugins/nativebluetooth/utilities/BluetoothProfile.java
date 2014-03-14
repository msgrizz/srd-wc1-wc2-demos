/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities;

/**
* Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
* Date: 5/22/12
*/
public enum BluetoothProfile {
    HSPHFP(1),
    A2DP(2);

    private final int value;

    BluetoothProfile(int value){
        this.value = value;
    }
    public int getValue() {
        return value;
    }

}
