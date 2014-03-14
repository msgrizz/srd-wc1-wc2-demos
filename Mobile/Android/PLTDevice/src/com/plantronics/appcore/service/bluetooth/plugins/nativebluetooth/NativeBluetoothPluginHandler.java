/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth;

import java.util.HashSet;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothClass;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import com.plantronics.appcore.persistence.PersistenceInterface;
import com.plantronics.appcore.persistence.PersistenceInterfaceFactory;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothEvent;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.plugins.BluetoothRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events.ConnectedEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events.DeviceBondStateChangedEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events.DisconnectedEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events.HeadsetProfileConnectedEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.events.HeadsetProfileDisconnectedEvent;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests.ConnectA2dpRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests.ConnectToDeviceRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests.DisconnectDeviceRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests.GetAllBondedDevicesRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests.GetBondStateRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests.GetConnectedDeviceRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.requests.GetConnectionStateRequest;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.responses.GetAllBondedDevicesResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.responses.GetBondStateResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.responses.GetConnectedDeviceResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.responses.GetConnectionStateResponse;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities.BluetoothProfile;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities.ConnectionDeterminator;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities.InternalBluetoothService;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities.InternalBluetoothServiceFactory;
import com.plantronics.appcore.service.bluetooth.utilities.PersistenceKeys;
import com.plantronics.appcore.service.bluetooth.utilities.PlantronicsDeviceResolver;
import com.plantronics.appcore.service.bluetooth.utilities.SelectedHeadsetFromFindMyHeadset;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;


/**
 * This class handles all bluetooth events that Android OS itself sends, it also provides request/response mechanism for
 * <ul>
 * <li>retrieving all bonded devices</li>
 * <li>retrieving connected device</li>
 * <li>retrieving device connection state</li>
 * <li>retrieving device bond state</li>
 * </ul>
 * <p/>
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/4/12
 */
public class NativeBluetoothPluginHandler extends BluetoothPluginHandler {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + NativeBluetoothPluginHandler.class.getSimpleName();

    public static final String PLUGIN_NAME = "NativeBluetooth";

    private static final int PAIRING_PERMISSION_DELAY = 10000;//TODO determine the right value for this
    //---- INTERNAL BROADCAST RECEIVER CONSTANTS ------
    public static final String ACTION_HSP_CHANGED_PRE_11 = "android.bluetooth.headset.action.STATE_CHANGED";
    public static final String ACTION_HSP_CHANGED_POST_11 = "android.bluetooth.headset.profile.action.CONNECTION_STATE_CHANGED";
    public static final String HSP_DEVICE_EXTRA = "android.bluetooth.device.extra.DEVICE";
    public static final String HSP_STATE_PRE11_EXTRA = "android.bluetooth.headset.extra.STATE";
    public static final String HSP_STATE_POST11_EXTRA = "android.bluetooth.profile.extra.STATE";

    public static final String HSP_PREVIOUS_STATE_PRE11 = "android.bluetooth.headset.extra.PREVIOUS_STATE";
    public static final String HSP_PREVIOUS_STATE_POST11 =  "android.bluetooth.profile.extra.PREVIOUS_STATE";


    private static final long DISCONNECT_SLEEP_TIME_IN_SECONDS = 5000l;
    private static final long CONNECT_SLEEP_TIME_IN_SECONDS = 1000l;


    public static final int STATE_DISCONNECTED = 0;
    public static final int STATE_CONNECTING    = 1;
    public static final int STATE_CONNECTED    = 2;



    //TODO also determine if we should deviate from the default behavior based on the phone model


    private BluetoothAdapter mBluetoothAdapter;

    private static Set<BluetoothDevice> sPairedDevices;
    private static Set<BluetoothDevice> sConnectedDevices;
    private static Set<BluetoothDevice> sPairingDevices;

    private BluetoothDevice mA2dpProfileConnectedDevice;
    private BluetoothDevice mHeadsetProfileConnectedDevice;

    private boolean mDisconnectA2dpRequested;
    private boolean mDisconnectHeadsetRequested;

    private boolean mConnectHeadsetRequested;
    private boolean mConnectA2dpRequested;

    private boolean mIsFirstRun = false;

    private InternalBluetoothService mInternalBluetoothService;


    private static Set<BluetoothDevice> sUnprocessedConnectEvent;

    private ConnectionDeterminator mConnectionDeterminator;

    private static boolean sDeterminatorFinished = false;

    private static int sNumberOfDevicesToCheck = 0;

    private int mA2DPConnectionAttemptCounter;


    public NativeBluetoothPluginHandler(Context context) {
        super(context);

        PersistenceInterface persistenceInterface = PersistenceInterfaceFactory.get();
        //Get first run marker from persistence
        int firstRunValue = persistenceInterface.getInt(context, PersistenceKeys.FIRST_RUN_AFTER_INSTALLATION, -1);
        if (firstRunValue == -1){
            Log.d(TAG, "First run detected!");
            mIsFirstRun = true;
            //Mark that we were run once
            persistenceInterface.putInt(context, PersistenceKeys.FIRST_RUN_AFTER_INSTALLATION, 1);
        }



    }

    @Override
    public void initPlugin() {
        //Setup
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        sPairingDevices = new HashSet<BluetoothDevice>();
        sUnprocessedConnectEvent = new HashSet<BluetoothDevice>();
        
        // Get the internal Bluetooth service module
        mInternalBluetoothService = InternalBluetoothServiceFactory.getInternalBluetoothService(mContext);

        if (sPairedDevices == null) {
        	sPairedDevices = new HashSet<BluetoothDevice>();
        	if (mBluetoothAdapter != null) {
	            sPairedDevices.addAll(removeNonHeadsetsAndNonPltHeadsets(mBluetoothAdapter.getBondedDevices()));
	            for (BluetoothDevice pairedDevice : sPairedDevices) {
	                Log.d(TAG, "PD: " + pairedDevice.getName());
	            }
        	} 
        }
        if (sConnectedDevices == null) {
            sConnectedDevices = new HashSet<BluetoothDevice>();

//            //Determine what devices are connected
//            mConnectionDeterminator = ConnectionDeterminator.getSingleton(mContext, new ConnectionDeterminator.DeterminatorCallback() {
//                @Override
//                public void determinedConnections(Set<BluetoothDevice> connectedBluetoothDevices) {
//
//                    sConnectedDevices.addAll(connectedBluetoothDevices);
//                    sDeterminatorFinished = true;
//                    Log.d(TAG, "Received connected devices!");
//                }
//            });
//            mConnectionDeterminator.addDevicesToCheck(sPairedDevices);
//            mConnectionDeterminator.getConnectedDevices();


//            sNumberOfDevicesToCheck = sPairedDevices.size(); TODO Test with 0
            sNumberOfDevicesToCheck = 0; //TODO FOR TESTING ONLY !!!!!!!!!!!!!!!!!
            Log.d(TAG, "Paired set size: " + sPairedDevices.size());
            if (sNumberOfDevicesToCheck > 0) {
                for (final BluetoothDevice bluetoothDevice : sPairedDevices) {
                    Log.d(TAG, "Started checking for: " + bluetoothDevice.getAddress());
                    mInternalBluetoothService.getConnectionStatus(bluetoothDevice, BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
                        @Override
                        public void onOperationCompleted(Object result) {
                            sNumberOfDevicesToCheck--;
                            if ((Boolean) result) {

                                //Don't consider non paired devices (THAT INCLUDES PHONES AND NON PLT NOW!) as connected
                                if (sPairedDevices.contains(bluetoothDevice)){
                                    Log.d(TAG, "-------Determinator--------: " + bluetoothDevice.getName() + " HSP/HFP connected");
                                    sConnectedDevices.add(bluetoothDevice);
                                    mHeadsetProfileConnectedDevice = bluetoothDevice;
                                }
                                Log.d(TAG, "Device HSPHFP profile connected: " + bluetoothDevice.getAddress() + " name: " + bluetoothDevice.getName());



                                sDeterminatorFinished = true;
                            } else {
                                Log.d(TAG, "Device HSPHFP profile disconnected: " + bluetoothDevice.getAddress());
                            }

                            mInternalBluetoothService.getConnectionStatus(bluetoothDevice, BluetoothProfile.A2DP, new InternalBluetoothService.Callback() {
                                @Override
                                public void onOperationCompleted(Object result) {
                                    if (result != null){
                                        if ((Boolean) result){
                                            if (sPairedDevices.contains(bluetoothDevice)){
                                                Log.d(TAG, "-------Determinator--------: " + bluetoothDevice.getName() + " A2DP connected");


                                                mA2dpProfileConnectedDevice = bluetoothDevice;

                                                if (mHeadsetProfileConnectedDevice != null && mHeadsetProfileConnectedDevice == mA2dpProfileConnectedDevice){
                                                    Log.d(TAG, "HSP and A2DP connected devices are the same, no need to add A2DP");

                                                }

                                                if (mHeadsetProfileConnectedDevice == null){
                                                    Log.d(TAG, "A2DP connection only");
                                                    sConnectedDevices.add(bluetoothDevice);

                                                }

                                                if (mHeadsetProfileConnectedDevice != null && mHeadsetProfileConnectedDevice != mA2dpProfileConnectedDevice){
                                                    Log.d(TAG, "HSP and A2DP connected devices are NOT the same, removing A2DP device from connected set!");
                                                    sConnectedDevices.remove(bluetoothDevice);

                                                }
                                            }
                                        }
                                    }
                                }
                            });

                            Log.d(TAG, "Remaining checks: " + sNumberOfDevicesToCheck);

                            if (sNumberOfDevicesToCheck == 0) {
                                sDeterminatorFinished = true;
                            }
                        }
                    });
                }
            } else {
                sDeterminatorFinished = true;
            }
            //Well this log looks pointless now. Determinator is async, probably won't finish before this log is called.
            for (BluetoothDevice bluetoothDevice : sConnectedDevices) {
                Log.d(TAG, "Connected: " + bluetoothDevice.getAddress());
            }



        }

        /**
         * Important! Receiver for Headset profile events! Must be here because android manifest doesn't support these events
         */
        BroadcastReceiver headsetProfileReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                Log.d(TAG, "------------ Profile listener action: " + intent.getAction());
                if (intent.getAction().equalsIgnoreCase(ACTION_HSP_CHANGED_POST_11) || intent.getAction().equalsIgnoreCase(ACTION_HSP_CHANGED_PRE_11)){
                    int state = intent.getIntExtra(HSP_STATE_PRE11_EXTRA, -1);
                    int previousState = intent.getIntExtra(HSP_PREVIOUS_STATE_PRE11, -1);

                    if (state == -1){
                        state = intent.getIntExtra(HSP_STATE_POST11_EXTRA, -1);
                    }

                    if (previousState == -1){
                        previousState = intent.getIntExtra(HSP_PREVIOUS_STATE_POST11, -1);
                    }
                    BluetoothDevice bluetoothDevice = intent.getParcelableExtra(HSP_DEVICE_EXTRA);
                    Log.d(TAG, "State: " + state);


                    if (state == STATE_CONNECTED){
                        HeadsetProfileConnectedEvent headsetProfileConnectedEvent = new HeadsetProfileConnectedEvent();
                        headsetProfileConnectedEvent.setState(state);
                        headsetProfileConnectedEvent.setBluetoothDevice(bluetoothDevice);
                        handleEvent(headsetProfileConnectedEvent);
                    }
                    if (state == STATE_DISCONNECTED && !(previousState == STATE_CONNECTING)){
                        HeadsetProfileDisconnectedEvent headsetProfileDisconnectedEvent = new HeadsetProfileDisconnectedEvent();
                        headsetProfileDisconnectedEvent.setState(state);
                        headsetProfileDisconnectedEvent.setBluetoothDevice(bluetoothDevice);
                        handleEvent(headsetProfileDisconnectedEvent);
                    }


                }


            }
        };

        IntentFilter headsetProfileIntentFilter = new IntentFilter();
        headsetProfileIntentFilter.addAction(ACTION_HSP_CHANGED_POST_11);
        headsetProfileIntentFilter.addAction(ACTION_HSP_CHANGED_PRE_11);



        mContext.registerReceiver(headsetProfileReceiver, headsetProfileIntentFilter);


    }

    @Override
    public boolean isHandlingEvent(String eventOrigin) {
        return PLUGIN_NAME.equals(eventOrigin);
    }

    @Override
    public void handleEvent(final BluetoothEvent bluetoothEvent) {
        //Always refresh bonded devices
        sPairedDevices = removeNonHeadsetsAndNonPltHeadsets(mBluetoothAdapter.getBondedDevices());
        Log.d(TAG, "Event:" + bluetoothEvent.getType());

//        /**
//         * Acl connected event
//         */
//        if (bluetoothEvent.getType().equals(ConnectedEvent.EVENT_TYPE)) {
//            ConnectedEvent connectedEvent = (ConnectedEvent) bluetoothEvent;
//            final BluetoothDevice connectedDevice = connectedEvent.getBluetoothDevice();
//            Log.d(TAG, "ACL Connected: " + connectedDevice.getAddress());
//            Log.d(TAG, "Give a second for HSP to be established: " + connectedDevice.getAddress());
//
//            try {
//                Thread.sleep(1000);
//            } catch (InterruptedException e) {
//                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
//            }
//
//            //We are going to check connection status by using internal bluetooth service
//            mInternalBluetoothService.getConnectionStatus(connectedDevice, BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
//                @Override
//                public void onOperationCompleted(Object result) {
//                    if (result != null){
//                        if ((Boolean) result){
//                            //TODO TEMP
//                            boolean found = false;
//                            for (BluetoothDevice pairedDevice : sPairedDevices){
//
//                                Log.d(TAG, "PD: " + pairedDevice.getName());
//                                if (pairedDevice.getAddress().equalsIgnoreCase(connectedDevice.getAddress())){
//                                    found = true;
//                                }
//                            }
//                            if (!found){
//                                return;
//                            }
//
//                            Log.d(TAG, "Device connected to HSP: " + connectedDevice.getAddress());
//                            sConnectedDevices.add(connectedDevice);
//                            sendProcessedEventToService(mContext, bluetoothEvent);
//                        } else {
//                            Log.d(TAG, "Device not connected, may be in bonding state, will check after a pause: " + connectedDevice.getAddress());
//                            //Maybe the device is bonding, we shall wait some time and then check again
//                            Timer checkIfPairedTimer = new Timer();
//                            checkIfPairedTimer.schedule(new TimerTask() {
//                                @Override
//                                public void run() {
//                                    mInternalBluetoothService.getConnectionStatus(connectedDevice, BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
//                                        @Override
//                                        public void onOperationCompleted(Object result) {
//                                            if (result != null){
//                                                if ((Boolean) result){
//                                                    Log.d(TAG, "Device connected after second check: " + connectedDevice.getAddress());
//                                                    sendProcessedEventToService(mContext, bluetoothEvent);
//                                                } else {
//                                                    Log.d(TAG, "Device not connected even after second check: " + connectedDevice.getAddress());
//                                                }
//                                            }
//                                        }
//                                    });
//                                }
//                            }, PAIRING_PERMISSION_DELAY);
//
//                        }
//                    }
//                }
//            });
//        }
//
//        /**
//         * Acl disconnected event
//         */
//        if (bluetoothEvent.getType().equals(DisconnectedEvent.EVENT_TYPE)) {
//            Log.d(TAG, "Disconnect event device: " + bluetoothEvent.getBluetoothDevice().getAddress());
//            if (!sConnectedDevices.isEmpty()){
//                Log.d(TAG, "Connected device: " + sConnectedDevices.iterator().next().getAddress());
//            }
//
//            mInternalBluetoothService.getConnectedDevice(BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
//                @Override
//                public void onOperationCompleted(Object result) {
//                    if (result != null){
//                        Log.d(TAG, "Connected device: " + ((BluetoothDevice) result).getAddress());
//                        Log.d(TAG, "Disconnecting device: " + bluetoothEvent.getBluetoothDevice().getAddress());
//                        if (sConnectedDevices.size() >1){
//                            Log.d(TAG, "More than one connected device, we are probably switching headsets, and it is happening too fast, so this is how we handle it");
//                            sConnectedDevices.remove(bluetoothEvent.getBluetoothDevice());
//                            sendProcessedEventToService(mContext, bluetoothEvent);
//                        }
//
//                        if (bluetoothEvent.getBluetoothDevice().getAddress().equalsIgnoreCase(((BluetoothDevice) result).getAddress())){
//                            sConnectedDevices.remove(bluetoothEvent.getBluetoothDevice());
//                            sendProcessedEventToService(mContext, bluetoothEvent);
//                        }
//                    } else {
//                        sConnectedDevices.remove(bluetoothEvent.getBluetoothDevice());
//                        sendProcessedEventToService(mContext, bluetoothEvent);
//                    }
//                }
//            });
//
//            if (sConnectedDevices.isEmpty()) {
//                Log.d(TAG, "No connected HSPHFP device, lets check that");
//                mInternalBluetoothService.getConnectedDevice(BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
//                    @Override
//                    public void onOperationCompleted(Object result) {
//                        if (result != null && sPairedDevices.contains(result)) {
//                            sConnectedDevices.add((BluetoothDevice) result);
//                            ConnectedEvent connectedEvent = new ConnectedEvent();
//                            connectedEvent.setBluetoothDevice((BluetoothDevice) result);
//                            sendProcessedEventToService(mContext, connectedEvent);
//                        }
//                    }
//                });
//            }
//
//        }
//
//        if (bluetoothEvent.getType().equals(A2dpProfileConnectedEvent.EVENT_TYPE)) {
//            Log.d(TAG, "Device A2dP connected: " + bluetoothEvent.getBluetoothDevice().getName());
//        }



        //------------------------------------
        // New approach
        //------------------------------------
        if (bluetoothEvent.getType().equalsIgnoreCase(HeadsetProfileConnectedEvent.EVENT_TYPE)){
            BluetoothDevice bluetoothDevice = bluetoothEvent.getBluetoothDevice();
            if (bluetoothDevice == null){
                Log.d(TAG, "We probably on android version pre-11, let's find what device is HSPHFP connected");
                mInternalBluetoothService.getConnectedDevice(BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
                    @Override
                    public void onOperationCompleted(Object result) {
                        if (result != null){
                            if (sPairedDevices.contains((BluetoothDevice) result)){
                                sConnectedDevices.add(((BluetoothDevice) result));
                            }
                            ConnectedEvent connectedEvent = new ConnectedEvent();
                            connectedEvent.setBluetoothDevice((BluetoothDevice) result);
                            sendProcessedEventToService(mContext, connectedEvent);
                        }
                    }
                });
            } else {
                if (sPairedDevices.contains(bluetoothDevice)){
                    sConnectedDevices.add(bluetoothDevice);
                }
                ConnectedEvent connectedEvent = new ConnectedEvent();
                connectedEvent.setBluetoothDevice(bluetoothDevice);
                sendProcessedEventToService(mContext, connectedEvent);
            }
        }

        if (bluetoothEvent.getType().equalsIgnoreCase(HeadsetProfileDisconnectedEvent.EVENT_TYPE)){
            BluetoothDevice bluetoothDevice = bluetoothEvent.getBluetoothDevice();
            if (bluetoothDevice == null){
                Log.d(TAG, "On android version pre-11, we probably won't know what device was disconnected");
                mInternalBluetoothService.getConnectedDevice(BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
                    @Override
                    public void onOperationCompleted(Object result) {
                        if (result != null){
                            sConnectedDevices.remove((BluetoothDevice) result);
                            DisconnectedEvent disconnectedEvent = new DisconnectedEvent();
                            disconnectedEvent.setBluetoothDevice((BluetoothDevice) result);
                            sendProcessedEventToService(mContext, disconnectedEvent);
                        } else {
                            Log.d(TAG, "Meh, disconnected anyways.");
                            sConnectedDevices.clear();
                            DisconnectedEvent disconnectedEvent = new DisconnectedEvent();
                            sendProcessedEventToService(mContext, disconnectedEvent);
                        }
                    }
                });
            } else {
                DisconnectedEvent disconnectedEvent = new DisconnectedEvent();
                disconnectedEvent.setBluetoothDevice(bluetoothDevice);
                sConnectedDevices.remove(bluetoothDevice);
                sendProcessedEventToService(mContext, disconnectedEvent);
            }
        }

        if (bluetoothEvent.getType().equalsIgnoreCase(DisconnectedEvent.EVENT_TYPE) && mIsFirstRun){
            sendProcessedEventToService(mContext, bluetoothEvent);
        }

        if (bluetoothEvent.getType().equalsIgnoreCase(DeviceBondStateChangedEvent.EVENT_TYPE)) {
            BluetoothDevice bluetoothDevice = bluetoothEvent.getBluetoothDevice();
            if (bluetoothDevice != null) {
                if (PlantronicsDeviceResolver.isPlantronicsDevice(bluetoothDevice)) {
                    sendProcessedEventToService(mContext, bluetoothEvent);
                } else {
                    Log.w(TAG, "Not a Plantronics device. Exiting.");
                }
            } else {
                Log.e(TAG, "bluetoothDevice == nul");
            }
        }

        mIsFirstRun = false;
    }

    @Override
    public boolean isHandlingRequest(String requestOrigin) {
        return PLUGIN_NAME.equals(requestOrigin);
    }

    @Override
    public void handleRequest(final BluetoothRequest request) {
        //Always refresh bonded devices
        sPairedDevices = removeNonHeadsetsAndNonPltHeadsets(mBluetoothAdapter.getBondedDevices());

        if (request instanceof GetAllBondedDevicesRequest) {

            GetAllBondedDevicesResponse getAllBondedDevicesResponse = new GetAllBondedDevicesResponse(request.getRequestId());
            getAllBondedDevicesResponse.setBondedDevices(sPairedDevices);
            sendResponseToService(mContext, getAllBondedDevicesResponse);
        }

        if (request instanceof GetBondStateRequest) {
            GetBondStateRequest getBondStateRequest = (GetBondStateRequest) request;
            GetBondStateResponse getBondStateResponse = new GetBondStateResponse(request.getRequestId());
            getBondStateResponse.setBluetoothDevice(getBondStateRequest.getBluetoothDevice());
            if (sPairedDevices.contains(getBondStateRequest.getBluetoothDevice())) {
                getBondStateResponse.setBondState(BluetoothDevice.BOND_BONDED);
            } else {
                getBondStateResponse.setBondState(BluetoothDevice.BOND_NONE);
            }
            sendResponseToService(mContext, getBondStateResponse);
        }

        if (request instanceof GetConnectedDeviceRequest) {
            final GetConnectedDeviceResponse getConnectedDeviceResponse = new GetConnectedDeviceResponse(request.getRequestId());

            //Make sure determinator finished!
            while (!sDeterminatorFinished) {
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Log.e(TAG, "", e);
                }
            }

            mInternalBluetoothService.getConnectedDevice(BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
            	
                @Override
                public void onOperationCompleted(Object scoConnectedDeviceObject) {
                    if (scoConnectedDeviceObject != null) {
                        Log.d(TAG, "Returning HFPHSP connected device: " + ((BluetoothDevice) scoConnectedDeviceObject).getAddress());
                    } else {
                        Log.d(TAG, "HSPHSF not connected");
                    }
                    
                    // Set the hsp connected device as the connected device in the response
                    final BluetoothDevice hspConnectedDevice = (BluetoothDevice) scoConnectedDeviceObject;
                    getConnectedDeviceResponse.setBluetoothDevice((hspConnectedDevice));                    
                    
                    // Check if we have connected HFP/HFP profile on the same headset as A2DP profile
                    // If not - the code was disconnecting the A2DP profile, but now not any more, until next future decisions - we commented it out
                    if (scoConnectedDeviceObject != null) {
                    	                    	
                    	/*
                         * This piece of code was disconnecting the A2DP-connected device when there was
                         * a different device connected to HSPHFP
                         */
                    	
//                        mInternalBluetoothService.getConnectedDevice(BluetoothProfile.A2DP, new InternalBluetoothService.Callback() {
//                            
//                        	@Override
//                            public void onOperationCompleted(Object result) {
//                                if (result != null) {
//                                    Log.d(TAG, "Got A2DP connected device: " + ((BluetoothDevice) result).getAddress());
//                                    BluetoothDevice a2dpConnectedDevice = (BluetoothDevice) result;
//                                    if (!hspConnectedDevice.getAddress().equals(a2dpConnectedDevice.getAddress())) {
//                                        Log.w(TAG, "A2DP and HSPHFP(" + hspConnectedDevice.getAddress() + ") connected to different devices");                                        
//                                        Log.d(TAG, "disconnecting: (" + a2dpConnectedDevice.getAddress() + ")");
//                    	
//                                        mInternalBluetoothService.disconnect(a2dpConnectedDevice, BluetoothProfile.A2DP, new InternalBluetoothService.Callback() {
//                                            @Override
//                                            public void onOperationCompleted(Object result) {
//
//                                            }
//                                        });                                        
//                                    }
//                                }
//
//                            }
//                        });
                        
                    // There are no devices connected to HSPHFP    
                    // (hspConnectedDevice == null)
                    } else {
                        Log.d(TAG, "Checking for A2DP only connected devices");
                        mInternalBluetoothService.getConnectedDevice(BluetoothProfile.A2DP, new InternalBluetoothService.Callback() {
                            
                        	@Override
                            public void onOperationCompleted(Object result) {
                        		
                        		// If there is a device connected to A2DP only
                                if (result != null) {
                                    final BluetoothDevice a2dpConnectedDevice = (BluetoothDevice) result;                                    
                                    
                                    // A2DP-only connected device is not amongst paired headsets
                                    if (!sPairedDevices.contains(a2dpConnectedDevice)) {
                                    	
                                    	// Send the empty response
                                        Log.e(TAG, "A2DP-only connected device is not contained in paired devices.");                                        
                                        getConnectedDeviceResponse.setBluetoothDevice(null);
                                        sendResponseToService(mContext, getConnectedDeviceResponse);                               
                                    
                                    // We found an A2DP-only connected device
                                    } else {
	                                    Log.d(TAG, "Got A2DP-only connected device: " + a2dpConnectedDevice.getAddress());
	                                    Log.i(TAG, "We shall now try to connect the A2DP-only connected device to SCO (HSPHFP) as well.");
	                                    mInternalBluetoothService.connect(a2dpConnectedDevice, BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {

											@Override
											public void onOperationCompleted(Object result) {
												boolean isResultNull = result == null;
												boolean isSuccessful = !isResultNull && (Boolean) result;
												if (isSuccessful) {
													Log.i(TAG, "Now we have connected to SCO (HSPHFP) the device which was formerly connected only to A2DP.");
													final BluetoothDevice deviceConnectedToBothProfiles = a2dpConnectedDevice;													
													getConnectedDeviceResponse.setBluetoothDevice(deviceConnectedToBothProfiles);
													sendResponseToService(mContext, getConnectedDeviceResponse);  													
												
												// We were not able to connect the A2DP-only connected device to SCO (HSPHFP) as well
												} else {
													
													// Send the empty response
				                                    Log.w(TAG, "We were not able to connect the A2DP-only connected device to SCO (HSPHFP) as well");                                        
				                                    getConnectedDeviceResponse.setBluetoothDevice(null);
				                                    sendResponseToService(mContext, getConnectedDeviceResponse); 
												}
											}
											
										});
                                    }
                                
                                // There is no device connected to A2DP, as well
                                } else {
                                	
                                	// Send the empty response
                                    Log.w(TAG, "There is no connected device to A2DP profile (and neither to HSPHFP).");                                        
                                    getConnectedDeviceResponse.setBluetoothDevice(null);
                                    sendResponseToService(mContext, getConnectedDeviceResponse); 
                                }
                            }
                        });
                    }    
                    
                    // No device was connected to SCO (HSPHFP) profile
                    if (scoConnectedDeviceObject == null) {
                    	// do not do anything... 
                    	// We have to wait to try to see if there is any device connected to A2DP and try to connect it to SCO as well
                    	Log.v(TAG, "Waiting for A2DP profile connection data...");
                    	
                    // There was a SCO-connected device detected
                    } else {
                    	BluetoothDevice connectedDeviceInsideResponse = getConnectedDeviceResponse.getBluetoothDevice();
                        if (connectedDeviceInsideResponse != null && sPairedDevices.contains(connectedDeviceInsideResponse)) {
                            sendResponseToService(mContext, getConnectedDeviceResponse);
                        } else {
                            getConnectedDeviceResponse.setBluetoothDevice(null);
                            sendResponseToService(mContext, getConnectedDeviceResponse);
                        }
                    }                    
                }
                
            });


        }

        if (request instanceof GetConnectionStateRequest) {
            final GetConnectionStateResponse getConnectionStateResponse = new GetConnectionStateResponse(request.getRequestId());
            GetConnectionStateRequest getConnectionStateRequest = (GetConnectionStateRequest) request;
            final BluetoothDevice device = getConnectionStateRequest.getBluetoothDevice();
            getConnectionStateResponse.setBluetoothDevice(device);
            mInternalBluetoothService.getConnectionStatus(device, BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
                @Override
                public void onOperationCompleted(Object result) {
                    if ((Boolean) result) {
                        Log.d(TAG, "HSP/HFP Connection status for: " + device.getAddress() + " is " + (((Boolean) result) ? "connected" : "disconnected"));
                        getConnectionStateResponse.setIsConnected((Boolean) result);
                        sendResponseToService(mContext, getConnectionStateResponse);
                        return;
                    } else {
                        mInternalBluetoothService.getConnectionStatus(device, BluetoothProfile.A2DP, new InternalBluetoothService.Callback() {
                            @Override
                            public void onOperationCompleted(Object result) {
                                if ((Boolean) result) {
                                    Log.d(TAG, "A2DP Connection status for: " + device.getAddress() + " is " + (((Boolean) result) ? "connected" : "disconnected"));
                                    getConnectionStateResponse.setIsConnected((Boolean) result);
                                    sendResponseToService(mContext, getConnectionStateResponse);
                                    return;
                                } else {
                                    getConnectionStateResponse.setIsConnected(false);
                                    sendResponseToService(mContext, getConnectionStateResponse);
                                }
                            }
                        });
                    }
                }
            });


        }

        if (request instanceof ConnectToDeviceRequest) {
            Log.d(TAG, " Connect to device request received. Thread: " + Thread.currentThread());
            final Timer timer = new Timer();

            //If there is a connected device, on HSPHFP disconnect it!
            mInternalBluetoothService.getConnectedDevice(BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {

                @Override
                public void onOperationCompleted(Object result) {
                    // From this point on everything is done on the main thread unfortunately :(
                    if (result != null && !((BluetoothDevice) result).getAddress().equalsIgnoreCase(request.getBluetoothDevice().getAddress())) {
                        final BluetoothDevice connectedDevice = (BluetoothDevice) result;
                        Log.d(TAG, "Trying to disconnect connected device " + connectedDevice.getAddress() + ", Thread: " + Thread.currentThread());
                        mInternalBluetoothService.disconnect(connectedDevice, BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {

                            @Override
                            public void onOperationCompleted(Object result) {
                                Log.d(TAG, "Trying to disconnect A2DP if it is connected " + connectedDevice.getAddress() + ", Thread: " + Thread.currentThread());

//                                internalSleep(1000);
                                // Instead of calling internalSleep() we put in a timer task

                                timer.schedule(new TimerTask() {

                                    @Override
                                    public void run() {
                                        mInternalBluetoothService.disconnect(connectedDevice, BluetoothProfile.A2DP, new InternalBluetoothService.Callback() {

                                            @Override
                                            public void onOperationCompleted(Object result) {
                                                Log.d(TAG, "Trying to connect after disconnecting device " + request.getBluetoothDevice().getAddress() + ", Thread: " + Thread.currentThread());
                                                Log.d(TAG, "Wait a second before trying to connect" + ", Thread: " + Thread.currentThread());

//                                                internalSleep(2000);
                                                // Instead of calling interalSleep() we put in a timer task
                                                timer.schedule(new TimerTask() {

                                                    @Override
                                                    public void run() {
                                                        mInternalBluetoothService.connect(request.getBluetoothDevice(), BluetoothProfile.A2DP, new InternalBluetoothService.Callback() {

                                                            @Override
                                                            public void onOperationCompleted(Object result) {
                                                                mInternalBluetoothService.connect(request.getBluetoothDevice(), BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {

                                                                    @Override
                                                                    public void onOperationCompleted(Object result) {
                                                                        Log.d(TAG, "Connection request finished: " + request.getBluetoothDevice().getAddress() + ", Thread: " + Thread.currentThread());
                                                                    }

                                                                });
                                                            }
                                                        });
                                                    }
                                                }, CONNECT_SLEEP_TIME_IN_SECONDS);
                                            }
                                        });
                                    }
                                }, CONNECT_SLEEP_TIME_IN_SECONDS);
                            }
                        });

                    } else {
                        mInternalBluetoothService.connect(request.getBluetoothDevice(), BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
                            @Override
                            public void onOperationCompleted(Object result) {
                                mInternalBluetoothService.connect(request.getBluetoothDevice(), BluetoothProfile.A2DP, new InternalBluetoothService.Callback() {

                                    @Override
                                    public void onOperationCompleted(Object result) {
                                        //TODO determine if we need to react to this at all;
                                    }
                                });
                            }
                        });
                    }
                }
            });
        }

        // Added in order to have disconnect functionality
        if (request instanceof DisconnectDeviceRequest) {
            final BluetoothDevice deviceToDisconnect = request.getBluetoothDevice();
            Log.i(TAG, " Disconnect device request received. Thread: " + Thread.currentThread() + ", device: " + deviceToDisconnect);
            if (deviceToDisconnect == null) {
                Log.w(TAG, "Received a request to disconnect a null device");
                return;
            }

            Log.d(TAG, "Trying to disconnect A2DP if it is connected, device " + deviceToDisconnect.getAddress() + ", Thread: " + Thread.currentThread());
            mInternalBluetoothService.disconnect(deviceToDisconnect, BluetoothProfile.A2DP, new InternalBluetoothService.Callback() {

                @Override
                public void onOperationCompleted(Object result) {
                    Log.d(TAG, "Trying to disconnect HSPHFP for device " + deviceToDisconnect.getAddress() + ", Thread: " + Thread.currentThread());
                    final Timer timer = new Timer();

                    // Instead of calling internalSleep(1000) we put in a timer task
                    timer.schedule(new TimerTask() {

                        @Override
                        public void run() {
                            mInternalBluetoothService.disconnect(deviceToDisconnect, BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {

                                @Override
                                public void onOperationCompleted(Object result) {
                                    Log.d(TAG, "Disconnect request finished: " + request.getBluetoothDevice() + ", Thread: " + Thread.currentThread());
                                }

                            });
                        }
                    }, DISCONNECT_SLEEP_TIME_IN_SECONDS);
                }

            });
        }

        if (request instanceof ConnectA2dpRequest) {
            Log.d(TAG, "Connect A2DP request received");
            connectA2DP();
        }


    }

    private void connectA2DP(){
        Log.d(TAG,"A2DP not ON on sensor device!");
        Log.d(TAG, "A2DP connection counter: "+ mA2DPConnectionAttemptCounter);
        mA2DPConnectionAttemptCounter++;
        final InternalBluetoothService internalBluetoothService = InternalBluetoothServiceFactory.getInternalBluetoothService(mContext);
        internalBluetoothService.connect(SelectedHeadsetFromFindMyHeadset.getOrRelaunch(mContext), BluetoothProfile.A2DP, new InternalBluetoothService.Callback() {
            @Override
            public void onOperationCompleted(Object result) {

                // Not really connected, just bluetooth service confirmed connection request
                if ((Boolean) result){
                    Log.d(TAG, "Connected");
//                    internalBluetoothService.connect(SelectedHeadset.getOrRelaunch(mContext), BluetoothProfile.HSPHFP, new InternalBluetoothService.Callback() {
//                        @Override
//                        public void onOperationCompleted(Object result) {
////                            mCommunicatorHelper.onResume();
//                        }
//                    });

                } else {
                    Log.d(TAG, "Failed");
                    try {
                        Thread.sleep(200);
                    } catch (InterruptedException e) {
                        Log.w(TAG, "Interrupted while sleeping", e);
                    }
                    if (mA2DPConnectionAttemptCounter <= 10){
                        connectA2DP();
                    } else {
                        Log.d(TAG, "Completely failed");
                    }
                }
            }
        });
    }

    private HashSet<BluetoothDevice> removeNonHeadsetsAndNonPltHeadsets(Set<BluetoothDevice> inputSet){
        HashSet<BluetoothDevice> resultSet = new HashSet<BluetoothDevice>();
        for (BluetoothDevice bluetoothDevice : inputSet) {
            Log.d(TAG, "Checking: " + bluetoothDevice.getAddress() + " name: " + bluetoothDevice.getName());
            BluetoothClass deviceBluetoothClass = bluetoothDevice.getBluetoothClass();
            if (deviceBluetoothClass != null) {
                Log.d(TAG, "Class: " + deviceBluetoothClass.getDeviceClass());
            }
            //Because we are allowing only plantronics devices, I will comment out the check for device class
//            if (
//                    (deviceBluetoothClass.getDeviceClass() == BluetoothClass.Device.AUDIO_VIDEO_HANDSFREE ||
//                            deviceBluetoothClass.getDeviceClass() == BluetoothClass.Device.AUDIO_VIDEO_HEADPHONES ||
//                            deviceBluetoothClass.getDeviceClass() == BluetoothClass.Device.AUDIO_VIDEO_WEARABLE_HEADSET) &&
//                            isPlantronicsDevice(bluetoothDevice)
//                    ) {
//                resultSet.add(bluetoothDevice);
//            }

            if (PlantronicsDeviceResolver.isPlantronicsDevice(bluetoothDevice)){
                resultSet.add(bluetoothDevice);
            }

        }
        return resultSet;
    }

    private void internalSleep(long millis){
        Log.d(TAG, "Calling internal sleep for " + millis + "ms on thread: " + Thread.currentThread());
        try {
            Thread.sleep(millis);
        } catch (InterruptedException e) {
            Log.e(TAG, "Interrupted");
        }
    }
}
