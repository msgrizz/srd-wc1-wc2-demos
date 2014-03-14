/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth;

import android.bluetooth.BluetoothDevice;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.appcore.service.bluetooth.communicator.CommunicatorHandler;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events.ConnectedEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events.DeviceBondStateChangedEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events.DisconnectedEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests.*;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.responses.GetAllBondedDevicesResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.responses.GetBondStateResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.responses.GetConnectedDeviceResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.responses.GetConnectionStateResponse;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

import java.util.Set;

/**
 * This class provides event/request/response method that Native Bluetooth plugin supports <br/>
 * Any subsytem using Communicator utility, and has a need to communicate with Native Bluetooth Plugin should <br/>
 * implement the abstract methods this class provices.
 * <p/>
 * <p/>
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs) <br/>
 * Date: 5/4/12
 */
public abstract class NativeBluetoothCommunicatorHandler implements CommunicatorHandler {
    private static final String TAG = LogTag.getBluetoothPackageTagPrefix() + NativeBluetoothCommunicatorHandler.class.getSimpleName();

    Communicator mCommunicator;

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
    public boolean isHandling(String pluginName) {
        return pluginName.equals(NativeBluetoothPluginHandler.PLUGIN_NAME);
    }


    @Override
    public void onPause() {
    }

    @Override
    public void onResume() {
    }

    /**
     * Call appropriate method for response received
     *
     * @param bluetoothResponse response received by this handler
     */
    private void handleResponse(BluetoothResponse bluetoothResponse) {
        if (bluetoothResponse.getResponseType().equals(GetAllBondedDevicesResponse.RESPONSE_TYPE)) {
            GetAllBondedDevicesResponse response = (GetAllBondedDevicesResponse) bluetoothResponse;
            onGetAllBondedDevicesResponse(response.getBondedDevices(), response.getResponseId());
        }
        if (bluetoothResponse.getResponseType().equals(GetBondStateResponse.RESPONSE_TYPE)) {
            GetBondStateResponse response = (GetBondStateResponse) bluetoothResponse;
            onGetBondStateResponse(response.getBluetoothDevice(), response.getBondState(), response.getResponseId());
        }
        if (bluetoothResponse.getResponseType().equals(GetConnectedDeviceResponse.RESPONSE_TYPE)) {
            GetConnectedDeviceResponse response = (GetConnectedDeviceResponse) bluetoothResponse;
            onGetConnectedDeviceResponse(response.getBluetoothDevice(), response.getResponseId());
        }
        if (bluetoothResponse.getResponseType().equals(GetConnectionStateResponse.RESPONSE_TYPE)) {
            GetConnectionStateResponse response = (GetConnectionStateResponse) bluetoothResponse;
            onGetConnectionStateResponse(response.getBluetoothDevice(), response.isConnected(), response.getResponseId());
        }
    }

    /**
     * Call appropriate method to handle event
     *
     * @param bluetoothEvent event received
     */
    private void handleEvent(BluetoothEvent bluetoothEvent) {
        if (bluetoothEvent.getType().equals(ConnectedEvent.EVENT_TYPE)) {
            ConnectedEvent connectedEvent = (ConnectedEvent) bluetoothEvent;
            onDeviceConnectedEvent(connectedEvent.getBluetoothDevice());
        }
        if (bluetoothEvent.getType().equals(DisconnectedEvent.EVENT_TYPE)) {
            DisconnectedEvent disconnectedEvent = (DisconnectedEvent) bluetoothEvent;
            onDeviceDisconnectedEvent(disconnectedEvent.getBluetoothDevice());
        }
        if (bluetoothEvent.getType().equals(DeviceBondStateChangedEvent.EVENT_TYPE)) {
            DeviceBondStateChangedEvent deviceBondStateChangedEvent = (DeviceBondStateChangedEvent) bluetoothEvent;
            if (deviceBondStateChangedEvent.getBondState() == BluetoothDevice.BOND_BONDED) {
                onBondedEvent(deviceBondStateChangedEvent.getBluetoothDevice());
            }
            if (deviceBondStateChangedEvent.getBondState() == BluetoothDevice.BOND_NONE) {
                onUnbondedEvent(deviceBondStateChangedEvent.getBluetoothDevice());
            }
        }

    }

    public void addParentCommunicator(Communicator communicator) {
        this.mCommunicator = communicator;
    }


    //-------------------------------------
    //Request methods
    //-------------------------------------

    /**
     * Sends a request to Bluetooth Manager, response will include a list of all bonded devices
     */
    public final int getAllBondedDevicesRequest() {
        GetAllBondedDevicesRequest getAllBondedDevicesRequest = new GetAllBondedDevicesRequest();
        mCommunicator.request(getAllBondedDevicesRequest);
        return getAllBondedDevicesRequest.getRequestId();
    }

    /**
     * Sends a request to Bluetooth Manager, response will include connected bluetooth device
     */
    public final int getConnectedDeviceRequest() {
        GetConnectedDeviceRequest getConnectedDeviceRequest = new GetConnectedDeviceRequest();
        mCommunicator.request(getConnectedDeviceRequest);
        return getConnectedDeviceRequest.getRequestId();
    }

    /**
     * Sends a request to Bluetooth Manager, response will include bluetooth device and connection state for that device
     *
     * @param bluetoothDevice for which we want to receive connection state
     */
    public final int getConnectionStateRequest(BluetoothDevice bluetoothDevice) {
        GetConnectionStateRequest getConnectionStateRequest = new GetConnectionStateRequest(bluetoothDevice);
        mCommunicator.request(getConnectionStateRequest);
        return getConnectionStateRequest.getRequestId();
    }

    /**
     * Sends a request to Bluetooth Manager, response will include bluetooth device and bond state for that device
     *
     * @param bluetoothDevice for which we want to receive bond state
     */
    public final int getBondStateRequest(BluetoothDevice bluetoothDevice) {
        GetBondStateRequest getBondStateRequest = new GetBondStateRequest(bluetoothDevice);
        mCommunicator.request(getBondStateRequest);
        return getBondStateRequest.getRequestId();
    }

    public final int connectToDeviceRequest(BluetoothDevice bluetoothDevice){
        ConnectToDeviceRequest connectToDeviceRequest = new ConnectToDeviceRequest(bluetoothDevice);
        mCommunicator.request(connectToDeviceRequest);
        return connectToDeviceRequest.getRequestId();
    }

    public final int disconnectDeviceRequest(BluetoothDevice bluetoothDevice) {
        DisconnectDeviceRequest disconnectDeviceRequest = new DisconnectDeviceRequest(bluetoothDevice);
        mCommunicator.request(disconnectDeviceRequest);
        return disconnectDeviceRequest.getRequestId();
    }

    public final int connectA2dpRequest(BluetoothDevice bluetoothDevice){
        ConnectA2dpRequest connectA2dpRequest = new ConnectA2dpRequest(bluetoothDevice);
        mCommunicator.request(connectA2dpRequest);
        return connectA2dpRequest.getRequestId();
    }

    //-------------------------------------
    // Response methods
    //-------------------------------------

    /**
     * called when Communicator receives a response for getAllBondedDevices request
     *
     * @param bondedDevices a list of bonded devices
     */
    public void onGetAllBondedDevicesResponse(Set<BluetoothDevice> bondedDevices, int responseId){
        Log.i(TAG, "onGetAllBondedDevices received, but method not overridden");
    }

    /**
     * Called when Communicator receives a response for getConnectedDevice request
     *
     * @param connectedDevice connected bluetooth device
     */
    public void onGetConnectedDeviceResponse(BluetoothDevice connectedDevice, int responseId){
        Log.i(TAG, "onGetAllBondedDevices received, but method not overridden");
    }

    /**
     * Called when Communicator receives a response for getConnectionStatus request
     *
     * @param bluetoothDevice bluetooth device for which we are reporting connection state
     * @param connected       connection state
     */
    public void onGetConnectionStateResponse(BluetoothDevice bluetoothDevice, Boolean connected, int responseId){
        Log.i(TAG, "onGetAllBondedDevices received, but method not overridden");
    }

    /**
     * Called when Communicator receives a response for getBondState request
     *
     * @param bluetoothDevice bluetooth device for which we are reporting bond state
     * @param bondState       bond state see {@link android.bluetooth.BluetoothDevice} for state list
     */
    public void onGetBondStateResponse(BluetoothDevice bluetoothDevice, Integer bondState, int responseId){
        Log.i(TAG, "onGetAllBondedDevices received, but method not overridden");
    }

    //-------------------------------------
    //Event methods
    //-------------------------------------

    public void onDeviceConnectedEvent(BluetoothDevice bluetoothDevice){
        Log.i(TAG, "onDeviceConnected event received, but method not overridden");
    }

    public void onDeviceDisconnectedEvent(BluetoothDevice bluetoothDevice){
        Log.i(TAG, "onDeviceDisconnected event received, but method not overridden");
    }

    public void onBondedEvent(BluetoothDevice bluetoothDevice){
        Log.i(TAG, "onBonded event received, but method not overridden");
    }

    public void onUnbondedEvent(BluetoothDevice bluetoothDevice){
        Log.i(TAG, "onUnbonded event received, but method not overridden");
    }




}
