/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.xevent;

import java.util.Map;

import android.bluetooth.BluetoothDevice;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.appcore.service.bluetooth.communicator.CommunicatorHandler;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothResponse;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.BatteryEvent;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.events.DonDoffEvent;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.requests.GetBatteryStateRequest;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.requests.GetSensorStatesRequest;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.requests.GetWearingStateRequest;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.responses.GetBatteryStateResponse;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.responses.GetSensorStatesResponse;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.responses.GetWearingStateResponse;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.SensorType;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.XEventType;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/24/12
 */
public abstract class XEventCommunicatorHandler implements CommunicatorHandler {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + XEventCommunicatorHandler.class.getSimpleName();

    Communicator mCommunicator;

    @Override
    public boolean isHandling(String origin) {
        if (origin.equals(XEventBluetoothPluginHandler.PLUGIN_NAME)) {
            return true;
        }
        return false;
    }

    @Override
    public void startHandler(Object message) {
        if (message instanceof BluetoothResponse) {
            handleResponse((BluetoothResponse) message);
        }

        if (message instanceof BluetoothEvent) {
            handleEvent((BluetoothEvent) message);
        }
    }

    @Override
    public void addParentCommunicator(Communicator communicator) {
        this.mCommunicator = communicator;
    }

    private void handleResponse(BluetoothResponse response) {
        if (response.getResponseType().equals(GetSensorStatesResponse.RESPONSE_TYPE)) {
            GetSensorStatesResponse getSensorStatesResponse = (GetSensorStatesResponse) response;
            onGetSensorStatesResponse(getSensorStatesResponse.getSensorStatusMap());
        } else if (response.getResponseType().equals(GetWearingStateResponse.RESPONSE_TYPE)) {
            GetWearingStateResponse getWearingStateResponse = (GetWearingStateResponse) response;
            onGetWearingStateResponse(getWearingStateResponse.getLastDonDoffEvent());
        } else if (response.getResponseType().equals(GetBatteryStateResponse.RESPONSE_TYPE)) {
        	GetBatteryStateResponse getBatteryStateResponse = (GetBatteryStateResponse) response;
        	onGetBatteryStateResponse(getBatteryStateResponse.getLastBatteryEvent());
        }
    }

    protected void handleEvent(BluetoothEvent event) {
        Log.d(TAG, "handleEvent() " + event);
        Log.i(TAG, "event.getType() " + event.getType());
        if (event.getType().equalsIgnoreCase(XEventType.BATTERY.toString())) {
            	BatteryEvent batteryEvent = (BatteryEvent) event;
//            onChargingEvent(event.getBluetoothDevice(), batteryEvent.isCharging());

	            //=====================================================================
	            // Ion has changed behaviour of this method           ////////////////
	            // in its own class BatteryXEventCommunicatorHandler  ////////////////
	            //=====================================================================
	            onBatteryEvent(batteryEvent);     
	            
            } else if (event.getType().equalsIgnoreCase(XEventType.DON.toString())) {
            	DonDoffEvent donDoffEvent = (DonDoffEvent) event;
            	onDonDoffEvent(donDoffEvent);
            	
	            if (donDoffEvent.IsDon()) {
	                onDonEvent(donDoffEvent.getBluetoothDevice());
	            } else {
	                onDoffEvent(donDoffEvent.getBluetoothDevice());
	            }
        	}
    }

    /**
     * Whenever an Xevent is received regarding the battery, a BatteryEvent object will be delivered to the
     * client modules who have this communicator handler implemented
     * @param batteryEvent
     *      The battery event object
     */
    protected abstract void onBatteryEvent(BatteryEvent batteryEvent);

    //-------------------------------------
    //Response methods
    //-------------------------------------



    /**
     * Called when this communicator receives wearing status response
     * @param donDoffEvent 
     * 		The last don/doff event
     * 		NULL if no status available (not received, or doesn't support)
     */
    public void onGetWearingStateResponse(DonDoffEvent donDoffEvent) {

    }

    /**
     * Called when this communicator receives a map of sensor and their enabled/disabled states
     * @param sensorStatusMap sensor status map, NULL if not available
     */
    public void onGetSensorStatesResponse(Map<SensorType, Boolean> sensorStatusMap) {

    }
    
    /**
     * Called when a GetBatteryStateResponse is received
     * @param lastBatteryEvent
     * 		The last received battery event
     */
    public void onGetBatteryStateResponse(BatteryEvent lastBatteryEvent) {
    	
    }

//    /**
//     * Called when communicator receives charging event
//     * @param isCharging
//     */
//    public void onChargingEvent(BluetoothDevice bluetoothDevice, boolean isCharging) {
//        Log.w(TAG, "This method should never get called actually... Weird.");
//    }

    public void onDonEvent(BluetoothDevice bluetoothDevice) {
    	
    }

    public void onDoffEvent(BluetoothDevice bluetoothDevice) {

    }
    
    public void onDonDoffEvent(DonDoffEvent donDoffEvent) {
    	
    }

    //-------------------------------------
    //Request methods
    //-------------------------------------

    public void getSensorStatesRequest(BluetoothDevice bluetoothDevice){
        GetSensorStatesRequest getSensorStatesRequest = new GetSensorStatesRequest(bluetoothDevice);
        mCommunicator.request(getSensorStatesRequest);
    }

    public void getWearingStateRequest() {
        GetWearingStateRequest getWearingStateRequest = new GetWearingStateRequest();
        mCommunicator.request(getWearingStateRequest);
    }
    
    public void getBatteryStateRequest() {
    	GetBatteryStateRequest getBatteryStateRequest = new GetBatteryStateRequest();
    	mCommunicator.request(getBatteryStateRequest);    	
    }

    @Override
    public void onPause() {
    }

    @Override
    public void onResume() {
    }
}
