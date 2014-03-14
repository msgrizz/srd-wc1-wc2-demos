/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.xevent.events;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/14/12
 */
public abstract class XEvent extends BluetoothEvent {

    /**
	 * 
	 */
	private static final long serialVersionUID = -5161658341088100082L;

	public static final String PLT_EVENT = "+XEVENT";

    protected transient BluetoothDevice mBluetoothDevice;

    protected boolean mIsAvailable;

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

    public boolean isAvailable() {
        return mIsAvailable;
    }

    public void setIsAvailable(boolean mIsAvailable) {
        this.mIsAvailable = mIsAvailable;
    }
}
