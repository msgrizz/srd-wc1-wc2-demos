/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.responses;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothPluginHandler;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.HashSet;
import java.util.Set;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public class GetAllBondedDevicesResponse extends BluetoothResponse {
    /**
	 * 
	 */
	private static final long serialVersionUID = -8980881392056232311L;

	public static final String RESPONSE_TYPE = "getAllBondedDevicesResponse";

    private transient Set<BluetoothDevice> mBondedDevices;

    public GetAllBondedDevicesResponse(int requestId){
        super(requestId);
    }

    @Override
    public String getResponsePluginHandlerName() {
        return NativeBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getResponseType() {
        return RESPONSE_TYPE;
    }

    @Override
    public boolean hasStableId() {
        return true; // We assume that the caller will not destroy the Communicator object
    }

    public Set<BluetoothDevice> getBondedDevices() {
        return mBondedDevices;
    }

    public void setBondedDevices(Set<BluetoothDevice> mBondedDevices) {
        this.mBondedDevices = mBondedDevices;
    }

    private void writeObject(ObjectOutputStream out) throws IOException
    {
        out.defaultWriteObject();
        out.writeInt(mBondedDevices.size());
        for (BluetoothDevice bluetoothDevice : mBondedDevices){
            out.writeObject(bluetoothDevice.getAddress());
        }
    }

    private void readObject(ObjectInputStream in) throws ClassNotFoundException, IOException {
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        in.defaultReadObject();
        int setSize = in.readInt();
        mBondedDevices = new HashSet<BluetoothDevice>();
        for (int i = 0; i < setSize ; i++){
            mBondedDevices.add(bluetoothAdapter.getRemoteDevice((String)in.readObject()));
        }

    }
}
