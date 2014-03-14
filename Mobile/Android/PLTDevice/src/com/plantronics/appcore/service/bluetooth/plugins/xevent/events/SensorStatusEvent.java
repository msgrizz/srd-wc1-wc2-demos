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
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.SensorType;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.XEventType;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

import java.util.HashMap;
import java.util.Map;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/15/12
 */
public class SensorStatusEvent extends XEvent {
    /**
	 * 
	 */
	private static final long serialVersionUID = -8685306902723465893L;

	public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + "SensorStatusEvent";

    private Map<SensorType, Boolean> mSensorStatusMap;

    public SensorStatusEvent(BluetoothDevice bluetoothDevice,Object [] args){
        mBluetoothDevice = bluetoothDevice;
        mSensorStatusMap = new HashMap<SensorType, Boolean>();
        for (Object arg: args){
            String sensorName = ((String) arg).split("=")[0];
            Boolean enabled = ((String)arg).split("=")[1].equals("1");
            Log.d(TAG, "Sensor name: " + sensorName + " enabled: " + enabled);
            mSensorStatusMap.put(SensorType.valueOf(sensorName), enabled);
        }
    }

    @Override
    public String getEventPluginHandlerName() {
        return XEventBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getType() {
        return XEventType.SENSORSTATUS.toString();
    }

    public Map<SensorType, Boolean> getSensorStatusMap() {
        return mSensorStatusMap;
    }

    public void setSensorStatusMap(Map<SensorType, Boolean> mSensorStatusMap) {
        this.mSensorStatusMap = mSensorStatusMap;
    }
}
