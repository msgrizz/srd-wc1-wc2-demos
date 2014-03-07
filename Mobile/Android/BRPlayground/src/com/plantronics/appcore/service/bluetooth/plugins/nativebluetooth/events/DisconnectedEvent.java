/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothPluginHandler;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public class DisconnectedEvent extends BluetoothEvent {
    /**
	 * 
	 */
	private static final long serialVersionUID = 7901423267201005183L;

	public static final String EVENT_TYPE = "DisconnectedEvent";

    private transient BluetoothDevice mBluetoothDevice;

    @Override
    public String getEventPluginHandlerName() {
        return NativeBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getType() {
        return EVENT_TYPE;
    }

    public BluetoothDevice getBluetoothDevice() {
        return mBluetoothDevice;
    }

    public void setBluetoothDevice(BluetoothDevice mBluetoothDevice) {
        this.mBluetoothDevice = mBluetoothDevice;
    }

    private void writeObject(ObjectOutputStream out) throws IOException
    {
        out.defaultWriteObject();
        out.writeObject(mBluetoothDevice.getAddress());
    }

    private void readObject(ObjectInputStream in) throws ClassNotFoundException, IOException {
        in.defaultReadObject();
        mBluetoothDevice = BluetoothAdapter.getDefaultAdapter().getRemoteDevice((String)in.readObject());

    }
}
