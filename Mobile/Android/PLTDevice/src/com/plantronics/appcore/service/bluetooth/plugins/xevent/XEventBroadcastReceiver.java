/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.xevent;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothBroadcastReceiver;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.*;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.XEventType;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 * Broadcast receiver for XEvent messages, responsible for receiving, resolving, and repackaging into appropriate form
 *
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/14/12
 */
public class XEventBroadcastReceiver extends BluetoothBroadcastReceiver {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + XEventBroadcastReceiver.class.getSimpleName();

    /**
     * The equivalent of the constant <tt>android.bluetooth.BluetoothHeadset.ACTION_VENDOR_SPECIFIC_HEADSET_EVENT</tt>.
     */
    public static final String ACTION_VENDOR_SPECIFIC_HEADSET_EVENT = "android.bluetooth.headset.action.VENDOR_SPECIFIC_HEADSET_EVENT";

    /**
     * The equivalent of the constant <tt>android.bluetooth.BluetoothHeadset.ACTION_VENDOR_SPECIFIC_HEADSET_EVENT_CMD</tt>.
     */
    public static final String EXTRA_VENDOR_SPECIFIC_HEADSET_EVENT_CMD = "android.bluetooth.headset.extra.VENDOR_SPECIFIC_HEADSET_EVENT_CMD";
    /**
     * The equivalent of the constant <tt>android.bluetooth.BluetoothHeadset.EXTRA_VENDOR_SPECIFIC_HEADSET_EVENT_ARGS</tt>.
     */
    public static final String EXTRA_VENDOR_SPECIFIC_HEADSET_EVENT_ARGS = "android.bluetooth.headset.extra.VENDOR_SPECIFIC_HEADSET_EVENT_ARGS";

    /**
     * The equivalent of the constant <tt>android.bluetooth.BluetoothHeadset.VENDOR_SPECIFIC_HEADSET_EVENT_COMPANY_ID_CATEGORY</tt>, plus
     * a period and the Plantronics ID.
     */
    public static final String VENDOR_SPECIFIC_HEADSET_EVENT_COMPANY_ID_PLANTRONICS_CATEGORY = "android.bluetooth.headset.intent.category.companyid.85";


    @Override
    public void onReceive(Context context, Intent intent) {
        Object[] eventArgs = (Object[])intent.getExtras().get(EXTRA_VENDOR_SPECIFIC_HEADSET_EVENT_ARGS);
        BluetoothDevice originDevice = (BluetoothDevice) intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        XEventType xEventType = XEventType.valueOf(((String) eventArgs[0]).replace("-","_"));

        Log.d(TAG, "XEventType: " + xEventType.toString());


        for (Object object: eventArgs){
            Log.d(TAG, "ARGS: " + object.toString());
        }


        BluetoothEvent bluetoothEvent = null;
        switch(xEventType){
            case USER_AGENT:
                bluetoothEvent = UserAgentEvent.workaroundConstructor(originDevice, stripEventType(eventArgs));

                break;
            case SENSORSTATUS:
                bluetoothEvent = new SensorStatusEvent(originDevice, stripEventType(eventArgs));
                break;
            case CONNECTED:
                bluetoothEvent = new ConnectedEvent(originDevice, stripEventType(eventArgs));
                break;
            case AUDIO:
                //TODO causes force close when using moorea, since we don't have them, I'll just disable this until we can test with moorea
//                bluetoothEvent = new AudioEvent(originDevice, stripEventType(eventArgs));
                break;
            case DON:
                bluetoothEvent = new DonDoffEvent(originDevice,true);
                break;
            case DOFF:
                bluetoothEvent = new DonDoffEvent(originDevice,false);
                break;
            case BATTERY:
                bluetoothEvent = new BatteryEvent(originDevice, stripEventType(eventArgs));
                break;
            default:
                Log.d(TAG, "Unknown XEvent:");
                for (Object object: eventArgs){
                    Log.d(TAG, "ARGS: " + object.toString());
                }
        }


        if (bluetoothEvent != null){
            sendEventToService(context, bluetoothEvent);
        }
    }

    /**
     * Creates a new array of objects out of the XEvent args array, but without the last array element which holds the
     * event type info. For some reason necessary.
     * @param xevent
     *      The XEvent event arguments array
     * @return  \
     *      The new array with event type element stripped off
     */
    private Object[] stripEventType(Object [] xevent){
        Object [] stripped = new Object[xevent.length-1];
        for (int i = 1 ; i < xevent.length ; i++){
            stripped[i-1] = xevent[i];
        }
        return stripped;
    }



}
