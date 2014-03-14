package com.plantronics.appcore.bluetooth;
/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 * 
 * Created by: Vladimir Petric
 * Date: 11/20/12 
 */

import com.plantronics.appcore.debug.CoreLogTag;

import android.bluetooth.BluetoothAdapter;

public class BluetoothAvailability {

    private static final String TAG = CoreLogTag.getGlobalTagPrefix() + BluetoothAvailability.class.getSimpleName();

    //===================================================================================================================================
    // Public interface methods
    //===================================================================================================================================

    /**
     * Retrieve information is bluetooth enabled or disabled.
     * <br><br><b><i>BE CAREFUL</i></b> - this method will raise an Exception if not called from a thread that has not called Looper.prepare().
     * Safest way is to call it from the UI thread.
     *
     * @return <b>true</b> - if bluetooth is enabled <br/>
     *         <b>false</b> - if bluetooth is not supported or disabled
     */
    public static boolean isBluetoothEnabled() {
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        return bluetoothAdapter != null && bluetoothAdapter.isEnabled();
    }       
}
