/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothBroadcastReceiver;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events.ConnectedEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events.DisconnectedEvent;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/8/12
 */
public class NativeBluetoothBroadcastReceiver extends BluetoothBroadcastReceiver {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + NativeBluetoothBroadcastReceiver.class.getSimpleName();

    /** Key for extracting the STATE extra from the Intent */
    private static final String EXTRA_STATE = "android.bluetooth.profile.extra.STATE";

    @Override
    public void onReceive(Context context, Intent intent) {

        //==========================================================================================
        // Ugi says that all this code does actually nothing useful
        // (Maybe only wakes the Service up)
        // .........................................................................................
        // |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        //==========================================================================================

        Log.d(TAG, "Action " + intent.getAction());
        String action = intent.getAction();
        Bundle extrasBundle = intent.getExtras();

        // Construct a new Connected Event and send it to BluetoothManagerService
        if (action.equals(BluetoothDevice.ACTION_ACL_CONNECTED)){
            ConnectedEvent connectedEvent = new ConnectedEvent();
            connectedEvent.setBluetoothDevice((BluetoothDevice) extrasBundle.getParcelable(BluetoothDevice.EXTRA_DEVICE));
            sendEventToService(context, connectedEvent);
        }

        // Construct a new Disconnected event and send it to BluetoothManagerService
        if (action.equals(BluetoothDevice.ACTION_ACL_DISCONNECTED)){
            DisconnectedEvent disconnectedEvent = new DisconnectedEvent();
            disconnectedEvent.setBluetoothDevice((BluetoothDevice) extrasBundle.getParcelable(BluetoothDevice.EXTRA_DEVICE));
            sendEventToService(context, disconnectedEvent);
        }




        if (action.equals("android.bluetooth.a2dp.profile.action.CONNECTION_STATE_CHANGED")){
            Log.v(TAG, "Intent arrived for which the BMS does not have the handling logic.");

            /*
             Produces a NullPointerException in the BMS
              */

//            int state = intent.getIntExtra(EXTRA_STATE, -1);
//            BluetoothDevice bluetoothDevice = extrasBundle.getParcelable(BluetoothDevice.EXTRA_DEVICE);
//            BluetoothEvent event = null;
//
//            // Construct a new "A2DP Profile Connected" Event
//            if (state == (ProfileConnectionState.STATE_CONNECTED.getValue())){
//                A2dpProfileConnectedEvent a2dpProfileConnectedEvent = new A2dpProfileConnectedEvent();
//                a2dpProfileConnectedEvent.setBluetoothDevice(bluetoothDevice);
//                event = a2dpProfileConnectedEvent;
//            }
//
//            // Construct a new "A2DP Profile Disconnected" Event
//            if (state == (ProfileConnectionState.STATE_DISCONNECTED.getValue())){
//                A2dpProfileDisconnectedEvent a2dpProfileDisconnectedEvent = new A2dpProfileDisconnectedEvent();
//                a2dpProfileDisconnectedEvent.setBluetoothDevice(bluetoothDevice);
//                event = a2dpProfileDisconnectedEvent;
//            }
//
//            // Send event to BluetoothManagerService
//            sendEventToService(context, event);
        }




        if (action.equals("android.bluetooth.headset.profile.action.CONNECTION_STATE_CHANGED")){
            Log.v(TAG, "Intent arrived for whose handling the BMS creates a broadcast receiver dynamically during runtime.");

            /*
             TODO I just added this commented out piece of code below - see if works or introduces a bug (Vlada)
              */
//            int extra = intent.getIntExtra(BluetoothHeadset.EXTRA_STATE, -1);
//            if (extra >= 0) {
//                if (extra == BluetoothHeadset.STATE_CONNECTED) {
//                    ConnectedEvent connectedEvent = new ConnectedEvent();
//                    connectedEvent.setBluetoothDevice((BluetoothDevice) extrasBundle.getParcelable(BluetoothDevice.EXTRA_DEVICE));
//                    sendEventToService(context, connectedEvent);
//
//                } else if (extra == BluetoothHeadset.STATE_DISCONNECTED) {
//                    DisconnectedEvent disconnectedEvent = new DisconnectedEvent();
//                    disconnectedEvent.setBluetoothDevice((BluetoothDevice) extrasBundle.getParcelable(BluetoothDevice.EXTRA_DEVICE));
//                    sendEventToService(context, disconnectedEvent);
//                }
//            }
        }

    }
}
