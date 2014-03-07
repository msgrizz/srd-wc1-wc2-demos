/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.xevent.events;

import android.bluetooth.BluetoothDevice;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.plugins.xevent.XEventBluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.XEventType;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

import java.util.HashMap;
import java.util.Map;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/15/12
 */
public class ConnectedEvent extends XEvent {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + ConnectedEvent.class.getSimpleName();

    private Map<String, Integer> mDeviceNameProfileMap;

    public ConnectedEvent(BluetoothDevice bluetoothDevice, Object [] args){
        mBluetoothDevice = bluetoothDevice;
        mDeviceNameProfileMap = new HashMap<String, Integer>();

        // Precaution
        if (args == null || args.length == 0) {
            Log.w(TAG, "Empty args array (or null). Exiting the constructor.");
            return; // --->  Exit point.
        }

        // The length of the args array
        int n = args.length;
        boolean isArgsArrayLengthEven = (n % 2) == 0;

        // Fix for the TT 22056
        if (!isArgsArrayLengthEven) {
            n--;
        }

        for (int i = 0; i < n; i += 2) {

            // Unnecessary paranoid check, thus commented out
//            if (i + 1 >= args.length) {
//                Log.e(TAG, "This would lead to an ArrayIndexOutOfBoundsException");
//                break;
//            }

            Log.d(TAG, "Connected device name: " + args[i] + " profile: " + args[i + 1]); // This line was producing TT 22056 (because array had 3 elements)
            if (args[i] instanceof String && args[i + 1] instanceof Integer) {
                String deviceName = (String) args[i];
                int profile = (Integer) args[i + 1];
                mDeviceNameProfileMap.put(deviceName, profile);
            } else {
                Log.w(TAG, "Conversion from the array elements to <String, int> (device name & profile) pairs failed. Index of String : " + i + ", index of int: " + (i + 1));
            }
        }
    }

    @Override
    public String getEventPluginHandlerName() {
        return XEventBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getType() {
        return XEventType.CONNECTED.toString();
    }

    public Map<String, Integer> getDeviceNameProfileMap() {
        return mDeviceNameProfileMap;
    }

    public void setDeviceNameProfileMap(Map<String, Integer> mDeviceNameProfileMap) {
        this.mDeviceNameProfileMap = mDeviceNameProfileMap;
    }
}
