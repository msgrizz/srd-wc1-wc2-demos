/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/18/12
 */
public class BluetoothDeviceHelper implements Serializable {
    /**
	 * 
	 */
	private static final long serialVersionUID = -3945623718525607972L;

	/** In case there is no device connected - this is the object written, to support this special case. */
    protected static final String NO_DEVICE = "noDevice";

    //---------------------------------------------------------------------------
    // Transient member so that it does not get serialized.
    // We use special logic for it (MAC address string mapping and retrieving)
    //---------------------------------------------------------------------------
    protected transient BluetoothDevice  mBluetoothDevice;

    public BluetoothDevice getBluetoothDevice() {
        return mBluetoothDevice;
    }

    public void setBluetoothDevice(BluetoothDevice bluetoothDevice) {
        mBluetoothDevice = bluetoothDevice;
    }


    //................................................................................................................
    // Writing and reading the object solely by using the MAC address string mapping
    //................................................................................................................


    private void writeObject(ObjectOutputStream out) throws IOException {

        // Write object without the transient member
        out.defaultWriteObject();

        // Write transient member
        if (mBluetoothDevice == null){
            out.writeObject(NO_DEVICE); // as "noDevice" string if null
        } else {
            out.writeObject(mBluetoothDevice.getAddress()); // As Bluetooth MAC address if not null
        }
    }

    private void readObject(ObjectInputStream in) throws ClassNotFoundException, IOException {

        // Read object without the transient member
        in.defaultReadObject();

        // Extract Bluetooth MAC address
        String address = (String) in.readObject();

        // Read transient member using the Bluetooth MAC address string
        if (address.equals(NO_DEVICE)){
            mBluetoothDevice = null; // if address is "noDevice" string, then the transient member is null
        } else {
            mBluetoothDevice = BluetoothAdapter.getDefaultAdapter().getRemoteDevice(address); // Get object by Bluetooth MAC address
        }
    }

}
