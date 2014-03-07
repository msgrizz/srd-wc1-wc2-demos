/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.os.Build;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothCommunicatorHandler;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

import java.lang.reflect.*;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/21/12
 */
public class PreSDK11InternalBluetoothService extends InternalBluetoothService {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + PreSDK11InternalBluetoothService.class.getSimpleName();

    Context mContext;

    private Object mLock = new Object();


    private Communicator mCommunicator;
    private NativeBluetoothCommunicatorHandler mNativeBluetoothCommunicatorHandler;


    private Class mBluetoothA2dpClass;
    private Class mBluetoothHeadsetClass;

    //Pre SDK 11

    //BluetoothHeadset.ServiceListener
    private Class[] mBluetoothHeadsetServiceListenerInterfaces;

    //Parameter: (Context)
    private Constructor mBluetoothA2dpConstructor;

    //Parameters: (Context, BluetoothHeadset.ServiceListener)
    private Constructor mBluetoothHeadsetConstructor;

    private Object mBluetoothA2dpObject;
    private Object mBluetoothHeadsetObject;

    //A2DP methods
    private Method mBluetoothA2dpConnectMethod;
    private Method mBluetoothA2dpDisconnectMethod;
    private Method mBluetoothA2dpIsConnectedMethod;
    private Method mBluetoothA2dpGetConnectedSinks;

    //Headset profile methods
    private Method mBluetoothHeadsetConnectMethod;
    private Method mBluetoothHeadsetDisconnectMethod;
    private Method mBluetoothHeadsetIsConnectedMethod;
    private Method mBluetoothHeadsetDisconnectInternalServiceMethod;
    private Method mBluetoothHeadsetGetCurrentHeadsetMethod;

    private boolean mIsLocked = false;

    private List<DelayedOperation> delayedOperations;


    private boolean mIsA2dpProfileConnected = true; //A2DP profile doesn't report if it's connected or not on pre-11 devices
    private boolean mIsHeadsetProfileConnected;


    public PreSDK11InternalBluetoothService(Context context){
        Log.d(TAG, "Connnector instantiated " +this.toString());
        mContext = context;

        delayedOperations = new LinkedList<DelayedOperation>();

        mCommunicator = new Communicator(mContext);

        try {

            mBluetoothA2dpClass = Class.forName("android.bluetooth.BluetoothA2dp");
            mBluetoothHeadsetClass = Class.forName("android.bluetooth.BluetoothHeadset");

            mBluetoothHeadsetServiceListenerInterfaces = mBluetoothHeadsetClass.getClasses();

            Constructor[] bluetoothA2dpConstructors = mBluetoothA2dpClass.getConstructors();
            Constructor[] bluetoothHeadsetConstructors = mBluetoothHeadsetClass.getConstructors();

            mBluetoothA2dpConstructor = bluetoothA2dpConstructors[0];
            mBluetoothHeadsetConstructor = bluetoothHeadsetConstructors[0];

            mBluetoothA2dpObject = mBluetoothA2dpConstructor.newInstance(mContext);



            mBluetoothA2dpConnectMethod = mBluetoothA2dpClass.getMethod("connectSink", BluetoothDevice.class);
            mBluetoothA2dpDisconnectMethod = mBluetoothA2dpClass.getMethod("disconnectSink", BluetoothDevice.class);
            mBluetoothA2dpIsConnectedMethod = mBluetoothA2dpClass.getMethod("isSinkConnected", BluetoothDevice.class);
            mBluetoothA2dpGetConnectedSinks = mBluetoothA2dpClass.getMethod("getConnectedSinks", null);

            mBluetoothHeadsetConnectMethod = mBluetoothHeadsetClass.getMethod("connectHeadset", BluetoothDevice.class);
            if (Build.VERSION.SDK_INT <= 8){
                mBluetoothHeadsetDisconnectMethod = mBluetoothHeadsetClass.getMethod("disconnectHeadset");
            } else {
                mBluetoothHeadsetDisconnectMethod = mBluetoothHeadsetClass.getMethod("disconnectHeadset", BluetoothDevice.class);
            }
            mBluetoothHeadsetIsConnectedMethod = mBluetoothHeadsetClass.getMethod("isConnected", BluetoothDevice.class);
            mBluetoothHeadsetDisconnectInternalServiceMethod = mBluetoothHeadsetClass.getMethod("close");
            mBluetoothHeadsetGetCurrentHeadsetMethod = mBluetoothHeadsetClass.getMethod("getCurrentHeadset", null);

            DelayedOperation constructorConnectAttempt = new DelayedOperation() {
                @Override
                public boolean execute() {
                    Log.d(TAG, "Constructor connect attempt done");
                    return false;
                }
            };

            connectAndExecute(constructorConnectAttempt);


        } catch (ClassNotFoundException e) {
            Log.e(TAG, "Class not found", e);
        } catch (NoSuchMethodException e) {
            Log.e(TAG, "Method not found", e);
        } catch (InvocationTargetException e) {
            Log.e(TAG, "Invocation target exception", e);
        } catch (InstantiationException e) {
            Log.e(TAG, "", e);
        } catch (IllegalAccessException e) {
            Log.e(TAG, "", e);
        }


    }

    private void connectAndExecute(final DelayedOperation delayedOperation){
        try {

            Object proxy = Proxy.newProxyInstance(mBluetoothHeadsetClass.getClassLoader(), mBluetoothHeadsetServiceListenerInterfaces, new InvocationHandler() {
                @Override
                public Object invoke(Object o, Method method, Object[] objects) throws Throwable {

                    Log.d(TAG, "Invoked: " + method.getName());
                    if (method.getName().equals("onServiceConnected")) {

                        Log.d(TAG, "Pre sdk 11 bluetooth service connected");
                        Field serviceField = mBluetoothHeadsetClass.getDeclaredField("mService");
                        serviceField.setAccessible(true);
                        if (serviceField.get(mBluetoothHeadsetObject) == null){
                            Log.d(TAG, "Service not really connected. AAAAAAARGH");

                            synchronized (mLock){
                                mIsLocked = false;
                                Log.d(TAG, " Unlocking. Thread: " +Thread.currentThread().getId());
                            }
                            delayedOperations.add(delayedOperation);
                            return null;


                        } else {
                            Log.d(TAG, "Service connected");
                        }
                        mIsHeadsetProfileConnected = true;
                        Log.d(TAG, "Thread in listener: " + Thread.currentThread().getId());


                        delayedOperation.execute();
                        synchronized (mLock){
                            if (!delayedOperations.isEmpty()){
                                for(DelayedOperation operation: delayedOperations){
                                    Log.d(TAG, "Executing delayed operation");
                                    operation.execute();
                                }
                                delayedOperations = new LinkedList<DelayedOperation>();
                            }
                        }

                        disconnectFromInternalService();

                        synchronized (mLock){
                            mIsLocked = false;
                            Log.d(TAG, " Unlocking. Thread: " +Thread.currentThread().getId());
                        }


                    }
                    if (method.getName().equals("onServiceDisconnected")) {
                        Log.d(TAG, "Pre sdk 11 service disconnected");
                        mIsHeadsetProfileConnected = false;

                    }

                    return null;
                }
            });

            mBluetoothHeadsetObject = mBluetoothHeadsetConstructor.newInstance(mContext, mBluetoothHeadsetServiceListenerInterfaces[0].cast(proxy));


        } catch (IllegalAccessException e) {
            Log.e(TAG, "Illegal access", e);
        } catch (InvocationTargetException e) {
            Log.e(TAG, "Invocation exception", e);
        } catch (InstantiationException e) {
            Log.e(TAG, "Instantiation exception", e);
        }
    }

    private void disconnectFromInternalService(){
        try {
            mBluetoothHeadsetDisconnectInternalServiceMethod.invoke(mBluetoothHeadsetObject,null);
        } catch (IllegalAccessException e) {
            Log.e(TAG, "", e);
        } catch (InvocationTargetException e) {
            Log.e(TAG, "", e);
        }
    }

    @Override
    public void connect(final BluetoothDevice bluetoothDevice, BluetoothProfile bluetoothProfile, final Callback callback) {
            if (bluetoothProfile == BluetoothProfile.A2DP){
                Log.d(TAG, "Trying to connect A2DP");
                getConnectionStatus(bluetoothDevice, bluetoothProfile, new Callback() {
                    @Override
                    public void onOperationCompleted(Object result) {
                        boolean isConnected = (Boolean) result;
                        try {
                            if (!isConnected) {
                                //Returns true if connect didn't IMMEDIATELY fail. It could still fail later
                                callback.onOperationCompleted(mBluetoothA2dpConnectMethod.invoke(mBluetoothA2dpObject, bluetoothDevice));
                            } else {
                                //Profile already connected to this device, don't try to connect again,
                                // (This may be redundant but I've learned not to trust Android on anything bluetooth related)
                                callback.onOperationCompleted(false);
                            }

                        } catch (IllegalAccessException e) {
                            Log.e(TAG, "", e);
                        } catch (InvocationTargetException e) {
                            Log.e(TAG, "", e);
                        }
                    }
                });

            }

        if (bluetoothProfile == BluetoothProfile.HSPHFP){
            getConnectionStatus(bluetoothDevice, bluetoothProfile, new Callback() {
                @Override
                public void onOperationCompleted(Object result) {
                    boolean isConnected = (Boolean) result;
                    if (!isConnected){
                        executeOrDelayOperation(new DelayedOperation() {
                            @Override
                            public boolean execute() {
                                if(!super.execute()){
                                    return false;
                                }
                                try {
                                    callback.onOperationCompleted(mBluetoothHeadsetConnectMethod.invoke(mBluetoothHeadsetObject, bluetoothDevice));
                                } catch (IllegalAccessException e) {
                                    Log.e(TAG, "", e);
                                } catch (InvocationTargetException e) {
                                    Log.e(TAG, "", e);
                                }
                                return false;
                            }

                        });
                    } else {
                        //Profile already connected to this device, don't try to connect again,

                        callback.onOperationCompleted(false);
                    }
                }
            });

        }

    }

    @Override
    public void disconnect(final BluetoothDevice bluetoothDevice, BluetoothProfile bluetoothProfile, final Callback callback) {

        if (bluetoothProfile == BluetoothProfile.A2DP){
            getConnectionStatus(bluetoothDevice, bluetoothProfile, new Callback() {
                @Override
                public void onOperationCompleted(Object result) {
                    boolean isConnected = (Boolean) result;
                    try {
                        if (isConnected) {
                            //Returns true if disconnect didn't IMMEDIATELY fail. It could still fail later
                            callback.onOperationCompleted(mBluetoothA2dpDisconnectMethod.invoke(mBluetoothA2dpObject, bluetoothDevice));
                        } else {
                            //Profile already disconnected to this device, don't try to disconnect again,

                            callback.onOperationCompleted(false);
                        }

                    } catch (IllegalAccessException e) {
                        Log.e(TAG, "", e);
                    } catch (InvocationTargetException e) {
                        Log.e(TAG, "", e);
                    }
                }
            });
        }

        if (bluetoothProfile == BluetoothProfile.HSPHFP){
            getConnectionStatus(bluetoothDevice, bluetoothProfile, new Callback() {
                @Override
                public void onOperationCompleted(Object result) {
                    boolean isConnected = (Boolean) result;
                    if (isConnected){
                        executeOrDelayOperation(new DelayedOperation() {
                            @Override
                            public boolean execute() {
                                if(!super.execute()){
                                    return false;
                                }
                                try {
                                    callback.onOperationCompleted(mBluetoothHeadsetDisconnectMethod.invoke(mBluetoothHeadsetObject, bluetoothDevice));
                                } catch (IllegalAccessException e) {
                                    Log.e(TAG, "", e);
                                } catch (InvocationTargetException e) {
                                    Log.e(TAG, "", e);
                                }
                                return false;
                            }
                        });
                    } else {
                        //Profile already disconnected from this device, don't try to disconnect again,

                        callback.onOperationCompleted(false);
                    }
                }
            });

        }
    }

    @Override
    public void getConnectionStatus(final BluetoothDevice bluetoothDevice, BluetoothProfile bluetoothProfile,final Callback callback) {
        Log.d(TAG, "Requesting connection status, object:" + this.toString());
        Boolean connectionState;
        try {
            if (bluetoothProfile == BluetoothProfile.A2DP){
                connectionState = (Boolean) mBluetoothA2dpIsConnectedMethod.invoke(mBluetoothA2dpObject, bluetoothDevice);
                Log.d(TAG, "A2DP Profile: Device: " + bluetoothDevice.getAddress() + " connectionState: " + connectionState);
                callback.onOperationCompleted(connectionState);

            }

            if (bluetoothProfile == BluetoothProfile.HSPHFP){
               executeOrDelayOperation(new DelayedOperation() {
                   @Override
                   public boolean execute() {
                       if(!super.execute()){
                           return false;
                       }
                       try {
                           boolean result = (Boolean) mBluetoothHeadsetIsConnectedMethod.invoke(mBluetoothHeadsetObject, bluetoothDevice);
                           callback.onOperationCompleted(result);
                       } catch (IllegalAccessException e) {
                           Log.e(TAG, "", e);
                       } catch (InvocationTargetException e) {
                           Log.e(TAG, "", e);
                       }
                       return false;
                   }
               });
                    return;

            }



        } catch (IllegalAccessException e) {
            Log.e(TAG, "", e);
        } catch (InvocationTargetException e) {
            Log.e(TAG, "", e);
        }

    }

    @Override
    public void getConnectedDevice(final BluetoothProfile bluetoothProfile, final Callback callback) {

        try {
            if (bluetoothProfile == BluetoothProfile.A2DP){
                Set<BluetoothDevice> connectedSinks = (Set<BluetoothDevice>) mBluetoothA2dpGetConnectedSinks.invoke(mBluetoothA2dpObject);
                BluetoothDevice connectedDevice = null;
                if (!connectedSinks.isEmpty()){
                     connectedDevice = (connectedSinks).iterator().next();
                }
                if (connectedDevice == null){
                    callback.onOperationCompleted(null);
                    return;
                }
                Log.d(TAG, "A2DP connected Device: " + connectedDevice.getAddress());
                callback.onOperationCompleted(connectedDevice);

            }

            if (bluetoothProfile == BluetoothProfile.HSPHFP){
                executeOrDelayOperation(new DelayedOperation() {
                    @Override
                    public boolean execute() {
                        if(!super.execute()){
                            return false;
                        }
                        try {
                            BluetoothDevice connectedDevice = (BluetoothDevice) mBluetoothHeadsetGetCurrentHeadsetMethod.invoke(mBluetoothHeadsetObject);
                            callback.onOperationCompleted(connectedDevice);
                        } catch (IllegalAccessException e) {
                            Log.e(TAG, "", e);
                        } catch (InvocationTargetException e) {
                            Log.e(TAG, "", e);
                        }
                        return false;
                    }
                });
                return;

            }



        } catch (IllegalAccessException e) {
            Log.e(TAG, "", e);
        } catch (InvocationTargetException e) {
            Log.e(TAG, "", e);
        }
    }

    private void executeOrDelayOperation(DelayedOperation delayedOperation){
        if (!mIsLocked) {
            if (mIsHeadsetProfileConnected){
                delayedOperation.execute();
            } else {
                synchronized (mLock){
                    Log.d(TAG, " Locked, delaying. Thread: " +Thread.currentThread().getId());
                    delayedOperations.add(delayedOperation);
                }
                return;
            }


        }
        synchronized (mLock){
            mIsLocked = true;
            Log.d(TAG, " Acquired, locking. Thread: " +Thread.currentThread().getId());
        }
        connectAndExecute(delayedOperation);
    }






}
