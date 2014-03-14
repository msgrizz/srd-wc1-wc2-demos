/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities;

import android.content.Context;
import android.os.Build;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/21/12
 */
public class InternalBluetoothServiceFactory {

    private static InternalBluetoothService internalBluetoothServiceSingleton;

    public static InternalBluetoothService getInternalBluetoothService(Context context){
        if (internalBluetoothServiceSingleton == null){
            if (Build.VERSION.SDK_INT < 11){
                internalBluetoothServiceSingleton = new PreSDK11InternalBluetoothService(context);
            } else {
                internalBluetoothServiceSingleton = new PostSDK11InternalBluetoothService(context);
            }
        }

        return internalBluetoothServiceSingleton;
    }


}
