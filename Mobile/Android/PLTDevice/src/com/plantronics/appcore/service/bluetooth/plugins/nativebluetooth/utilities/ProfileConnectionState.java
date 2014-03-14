/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities;

/**
* Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
* Date: 5/23/12
*/
public enum ProfileConnectionState {
    STATE_CONNECTED(2),
    STATE_CONNECTING(1),
    STATE_DISCONNECTED(0),
    STATE_DISCONNECTING(3);

    private final int value;

    ProfileConnectionState(int value){
        this.value = value;
    }
    public int getValue() {
        return value;
    }
}
