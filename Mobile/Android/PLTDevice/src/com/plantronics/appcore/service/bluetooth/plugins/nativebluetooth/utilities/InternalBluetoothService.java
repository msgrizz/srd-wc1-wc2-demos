/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities;

import android.bluetooth.BluetoothDevice;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/21/12
 */
public abstract class InternalBluetoothService {

    public interface Callback{
        void onOperationCompleted(Object result);
    }

    public abstract void connect(BluetoothDevice bluetoothDevice, BluetoothProfile bluetoothProfile, Callback callback);

    public abstract void disconnect(BluetoothDevice bluetoothDevice, BluetoothProfile bluetoothProfile,  Callback callback);

    public abstract void getConnectionStatus(BluetoothDevice bluetoothDevice, BluetoothProfile bluetoothProfile, Callback callback);

    public abstract void getConnectedDevice(BluetoothProfile bluetoothProfile, Callback callback);


}
