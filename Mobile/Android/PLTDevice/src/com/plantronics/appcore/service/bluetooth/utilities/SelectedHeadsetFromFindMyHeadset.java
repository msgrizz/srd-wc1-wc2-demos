/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.utilities;

import android.bluetooth.BluetoothDevice;
import android.content.Context;

import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 * This class was made to be used in Find MyHeadset app. At first, some Bluetooth Manager modules were using the getOrRelaunch() function.
 * Since then there has been some effort to omit using it and pass the device as a parameter correctly.
 * 
 * Created by: Vladimir Petric
 * Date: 13/06/12
 */
@Deprecated
public class SelectedHeadsetFromFindMyHeadset {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + SelectedHeadsetFromFindMyHeadset.class.getSimpleName();


//    private static BluetoothDevice sSelectedDevice = null;

    /**
     * Retrieves the currently selected headset device
     * or relaunches the whole app from the beginning.
     * @param context
     *      The surrounding Context, we need it to relaunch the app
     * @return
     *      The BluetoothDevice object of the currently selected device or null if no device is selected
     */
    public static BluetoothDevice getOrRelaunch(Context context) {
    	
//        if (sSelectedDevice == null) {
//            Log.d(TAG, "Null device! Restarting!" );
//            // Relaunch the Splash Activity
//            Intent i = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
//            i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//            context.startActivity(i);
//        }
//        return sSelectedDevice;
    	
    	throw new UnsupportedOperationException("*** Used only in FMHS, makes no sence in other apps!");
    }

//    /**
//     * Simple null check of the selected headset
//     * @return
//     *      True if the the selected headset is null
//     */
//    public static boolean isNull() {
//        return sSelectedDevice == null;
//    }
//
//    public static boolean isThereASelectedHeadset() { // Better call this then do !isNull()
//        return sSelectedDevice != null;
//    }
//
//    public static void reset() {
//        sSelectedDevice = null;
//    }
//
//    public static void set(BluetoothDevice selectedDevice) {
//        sSelectedDevice = selectedDevice;
//    }
}
