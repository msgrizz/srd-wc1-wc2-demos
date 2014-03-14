/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.xevent;

import java.util.HashMap;
import java.util.Map;

import android.content.Context;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothRequest;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.BatteryEvent;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.DonDoffEvent;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.SensorStatusEvent;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.XEvent;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.requests.GetBatteryStateRequest;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.requests.GetSensorStatesRequest;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.requests.GetWearingStateRequest;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.responses.GetBatteryStateResponse;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.responses.GetSensorStatesResponse;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.responses.GetWearingStateResponse;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.XEventType;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 *
 * <p/>
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public class XEventBluetoothPluginHandler extends BluetoothPluginHandler {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + XEventBluetoothPluginHandler.class.getSimpleName();
    public static final String PLUGIN_NAME = "XeventPlugin";

    //Map containing last XEVENT
    //Note: consider this to be sufficient for now, but later on, we might want to track more than one XEvent per XEvent type
    //Example for that would b: (When the headset is connected it sends 2 Connected XEvents (one per bluetooth profile).
    // We don't need that at the moment but if we wanted to, we would need to track more than one event
    //Also we only store XEevents for the connected bluetooth device.
    private Map<XEventType, XEvent> typeToEventMap;


    public XEventBluetoothPluginHandler(Context context) {
        super(context);
    }

    @Override
    public void initPlugin() {
       typeToEventMap = new HashMap<XEventType, XEvent>();
    }

    @Override
    public boolean isHandlingEvent(String eventOrigin) {
        return eventOrigin.equals(PLUGIN_NAME);
    }

    @Override
    public void handleEvent(BluetoothEvent bluetoothEvent) {
        XEvent xEvent = (XEvent) bluetoothEvent;
        XEventType xEventType = XEventType.valueOf(xEvent.getType());
        Log.i(TAG, "Handling XEvent: " + xEvent);
        switch (xEventType) {
            //We don't want to keep DOFF, cause it's state is retained in DONDOFF. DOFF is just used by broadcast receiver
            //to detect XEvent, and then its converted to DON
            case DOFF:
                break;
            default:
                typeToEventMap.put(xEventType, xEvent);
        }

        Log.d(TAG, "Event!: " + bluetoothEvent.getType());
        sendProcessedEventToService(mContext, bluetoothEvent);
    }

    @Override
    public boolean isHandlingRequest(String requestOrigin) {
        return requestOrigin.equals(PLUGIN_NAME);
    }

    @Override
    public void handleRequest(BluetoothRequest request) {
    	Log.v(TAG, "handleRequest(): " + request.getRequestType());
        if (request.getRequestType().equals(GetWearingStateRequest.REQUEST_TYPE)) {
            GetWearingStateResponse getWearingStateResponse = new GetWearingStateResponse(request.getRequestId());
            if (typeToEventMap.containsKey(XEventType.DON)) {
                DonDoffEvent donDoffEvent = (DonDoffEvent) typeToEventMap.get(XEventType.DON);
                getWearingStateResponse.setLastDonDoffEvent(donDoffEvent);
            } else {
                getWearingStateResponse.setLastDonDoffEvent(null);
            }
            sendResponseToService(mContext, getWearingStateResponse); // send response
        
        } else if (request.getRequestType().equals(GetSensorStatesRequest.REQUEST_TYPE)) {
            GetSensorStatesResponse getSensorStatesResponse = new GetSensorStatesResponse(request.getRequestId());
            if (typeToEventMap.containsKey(XEventType.SENSORSTATUS)) {
                SensorStatusEvent sensorStatusEvent = (SensorStatusEvent) typeToEventMap.get(XEventType.SENSORSTATUS);
                getSensorStatesResponse.setSensorStatusMap(sensorStatusEvent.getSensorStatusMap());
            } else {
                getSensorStatesResponse.setSensorStatusMap(null);
            }
            sendResponseToService(mContext, getSensorStatesResponse); // send response
            
        } else if (request.getRequestType().equals(GetBatteryStateRequest.REQUEST_TYPE)) {        	
        	GetBatteryStateResponse getBatteryStateResponse = new GetBatteryStateResponse(request.getRequestId());
        	if (typeToEventMap.containsKey(XEventType.BATTERY)) {
        		BatteryEvent lastBatteryEvent = (BatteryEvent) typeToEventMap.get(XEventType.BATTERY);
        		getBatteryStateResponse.setLastBatteryEvent(lastBatteryEvent);
        	} 
        	sendResponseToService(mContext, getBatteryStateResponse); // send response
        }
    }
}
