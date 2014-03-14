/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.plantronics.appcore.service.bluetooth.BluetoothManagerService;

/**
 * BroadcastReceiver that is capable of starting the {@link com.plantronics.appcore.service.bluetooth.BluetoothManagerService} in order to process received Bluetooth events.
 *
 * <p><br>Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public abstract class BluetoothBroadcastReceiver extends BroadcastReceiver {

    /**
     * Packs a {@link BluetoothEvent} into an Intent ant starts the {@link com.plantronics.appcore.service.bluetooth.BluetoothManagerService}
     * in order for this event to be processed.
     *
     * @param context
     *      The context of the caller
     * @param bluetoothEvent
     *      The Bluetooth event to be processed
     */
    protected void sendEventToService(Context context, BluetoothEvent bluetoothEvent) {
        Intent sendToServiceIntent = new Intent(BluetoothManagerService.Intents.getEventFromReceiverAction(context.getApplicationContext()));
        sendToServiceIntent.putExtra(BluetoothManagerService.EVENT_EXTRA, bluetoothEvent);
        context.startService(sendToServiceIntent);
    }

}
