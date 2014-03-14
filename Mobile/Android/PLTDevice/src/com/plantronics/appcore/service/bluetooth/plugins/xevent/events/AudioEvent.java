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

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/15/12
 */
public class AudioEvent extends XEvent {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + AudioEvent.class.getSimpleName();

    private Integer mCodec;
    private Integer mDirection;
    private Integer mSpeakerGain;
    private Integer mMicGain;

    public AudioEvent(BluetoothDevice bluetoothDevice, Object [] args){
        this(bluetoothDevice,
                (Integer) args[0],
                (Integer) args[1],
                (Integer) args[2],
                (Integer) args[3]
                );

        Log.d(TAG,
                "Codec: " + (Integer) args[0] +
                        " Direction: " + (Integer) args[1] +
                        " Speaker gain: " + (Integer) args[2] +
                        " Mic gain: " + (Integer) args[3]);
    }

    public AudioEvent(BluetoothDevice bluetoothDevice ,Integer mCodec, Integer mDirection,Integer mSpeakerGain, Integer mMicGain) {
        mBluetoothDevice = bluetoothDevice;
        this.mCodec = mCodec;
        this.mDirection = mDirection;
        this.mSpeakerGain = mSpeakerGain;
        this.mMicGain = mMicGain;
    }

    @Override
    public String getEventPluginHandlerName() {
        return XEventBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getType() {
        return XEventType.BATTERY.toString();
    }
}
