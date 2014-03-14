/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ConcurrentModificationException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/21/12
 */
public class PostSDK11InternalBluetoothService extends InternalBluetoothService{
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + PostSDK11InternalBluetoothService.class.getSimpleName();

    // This constants are added in order to have values used in class BluetoothProfile that exist from API 11
    private static final int android_bluetooth_BluetoothProfile_HEADSET = 1;
    private static final int android_bluetooth_BluetoothProfile_A2DP = 2;   
    private static final int android_bluetooth_BluetoothProfile_HEALTH = 3;
    
    private Context mContext;


    BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    private Class mBluetoothAdapterClass;
    private Class mBluetoothProfileClass;
    private Class mBluetoothA2dpClass;
    private Class mBluetoothHeadsetClass;

    private Class[] mBluetoothProfileInnerClasses;

    private Object mA2dpProfileProxy;
    private Object mHeadsetProfileProxy;

    private Method mA2dpConnectMethod;
    private Method mA2dpDisconnectMethod;
    private Method mA2dpGetConnectionStateMethod;
    private Method mA2dpGetConnectedDevicesMethod;

    private Method mHeadsetConnectMethod;
    private Method mHeadsetDisconnectMethod;
    private Method mHeadsetGetConnectionStateMethod;
    private Method mHeadsetGetConnectedDevicesMethod;


    private boolean mIsLocked;
    private boolean mIsHeadsetProfileConnected;
    private boolean mIsA2dpProfileConnected;

    private Set<DelayedOperation> mDelayedHeadsetProfileOperations;
    private Set<DelayedOperation> mDelayedA2dpProfileOperations;

    public PostSDK11InternalBluetoothService(Context context){
        mContext = context;

        mDelayedA2dpProfileOperations = new HashSet<DelayedOperation>();
        mDelayedHeadsetProfileOperations = new HashSet<DelayedOperation>();

        try {
            mBluetoothAdapterClass = mBluetoothAdapter.getClass();
            mBluetoothProfileClass = Class.forName("android.bluetooth.BluetoothProfile");
            mBluetoothA2dpClass = Class.forName("android.bluetooth.BluetoothA2dp");
            mBluetoothHeadsetClass = Class.forName("android.bluetooth.BluetoothHeadset");
            mBluetoothProfileInnerClasses = mBluetoothProfileClass.getDeclaredClasses();

            mA2dpConnectMethod = mBluetoothA2dpClass.getMethod("connect", BluetoothDevice.class);
            mA2dpDisconnectMethod = mBluetoothA2dpClass.getMethod("disconnect", BluetoothDevice.class);
            mA2dpGetConnectionStateMethod = mBluetoothA2dpClass.getMethod("getConnectionState", BluetoothDevice.class);
            mA2dpGetConnectedDevicesMethod = mBluetoothA2dpClass.getMethod("getConnectedDevices", null);

            mHeadsetConnectMethod = mBluetoothHeadsetClass.getMethod("connect", BluetoothDevice.class);
            mHeadsetDisconnectMethod = mBluetoothHeadsetClass.getMethod("disconnect", BluetoothDevice.class);
            mHeadsetGetConnectionStateMethod = mBluetoothHeadsetClass.getMethod("getConnectionState", BluetoothDevice.class);
            mHeadsetGetConnectedDevicesMethod = mBluetoothHeadsetClass.getMethod("getConnectedDevices", null);
            DelayedOperation constructorConnectAttempt = new DelayedOperation() {
                @Override
                public boolean execute() {
                    Log.d(TAG, "Constructor connect attempt done");
                    return false;
                }
            };

            connectAndExecute(BluetoothProfile.A2DP, constructorConnectAttempt);
            connectAndExecute(BluetoothProfile.HSPHFP, constructorConnectAttempt);

        } catch (ClassNotFoundException e) {
            Log.e(TAG, "", e);
        } catch (NoSuchMethodException e) {
            Log.e(TAG, "", e);
        }


    }


    private void connectAndExecute(final BluetoothProfile bluetoothProfile, final DelayedOperation delayedOperation){
        Log.d(TAG, "Starting PostSDK11 method, Thread: " + Thread.currentThread());
        Log.d(TAG, "Profile: " + bluetoothProfile.name());
        try {



            Object proxy = Proxy.newProxyInstance(mBluetoothProfileClass.getClassLoader(), mBluetoothProfileInnerClasses, new InvocationHandler() {

                @Override
                public Object invoke(Object o, Method method, Object[] objects) throws Throwable {
                    Log.d(TAG, "Invoked: " + method.getName() + ", Thread: " + Thread.currentThread());
                    Log.d(TAG, "Proxy method called: " + method.getName());

                    // This variable is not used, therefore we commented it out
//                    Method getConnectedDevices = mBluetoothProfileClass.getMethod("getConnectedDevices", null);

                    // Null check
                    if (objects == null) {
                        Log.e(TAG, "Object[] == null.");
                        synchronized (this) {
                            mIsLocked = false; // Copied this from the bottom of the function
                        }
                        return null;
                    }

                    if (method.getName().equals("onServiceConnected")) {
                        Log.d(TAG, "POST SDK 11 service connected");
                        Set<DelayedOperation> delayedOperationsSet = null;
                        if (objects.length > 1 && mBluetoothA2dpClass.isInstance(objects[1])){
                            Log.d(TAG, "A2DP Profile proxy connected");
                            mIsA2dpProfileConnected = true;
                            mA2dpProfileProxy = objects[1];
                            delayedOperationsSet = mDelayedA2dpProfileOperations;
                        }

                        if (objects.length > 1 && mBluetoothHeadsetClass.isInstance(objects[1])){
                            Log.d(TAG, "Headset Profile proxy connected");
                            mIsHeadsetProfileConnected = true;
                            mHeadsetProfileProxy = objects[1];
                            delayedOperationsSet = mDelayedHeadsetProfileOperations;
                        }
                        delayedOperation.execute();
                        if (!delayedOperationsSet.isEmpty()){
                            try {
                                Set<DelayedOperation> tempDelayedOperationsSet = new HashSet<DelayedOperation>(delayedOperationsSet);

                                for (DelayedOperation operation: tempDelayedOperationsSet){
                                    Log.d(TAG, "----------Executing operation after service connected: " + Integer.toHexString(operation.hashCode()));
                                    operation.execute();
                                    delayedOperationsSet.remove(operation);
                                }
                            } catch (ConcurrentModificationException exception){
                                Log.e(TAG, "Concurrent access to delayed operations set!",exception);
                                //It seems I have solved this in PreSDK11. TODO Fix later
                            }
                            if (objects.length > 1 && mBluetoothA2dpClass.isInstance(objects[1])){
                                mDelayedA2dpProfileOperations = new HashSet<DelayedOperation>();
                            }
                            if (objects.length > 1 && mBluetoothHeadsetClass.isInstance(objects[1])){
                                mDelayedHeadsetProfileOperations = new HashSet<DelayedOperation>();
                            }
                        }
                    }

                    if (method.getName().equals("onServiceDisconnected")) {
                        Log.d(TAG, "POST SDK 11 service disconnected");

                        // There are at least two elements of object array
                        if (objects.length > 1) {
                            Log.v(TAG, "Received onServiceDisconnected() call with two parameters");
                            if (mBluetoothA2dpClass.isInstance(objects[1])){  // Here was an ArrayIndexOutOfBoundsException (TT 22010)
                                mIsA2dpProfileConnected = false;
                            }
                            if (mBluetoothHeadsetClass.isInstance(objects[1])){
                                mIsHeadsetProfileConnected = false;
                            }

                        // Fix for TT 22010, handling the case of only one int parameter
                        } else if (objects.length == 1) {
                            Log.v(TAG, "Received onServiceDisconnected() call with only one parameter. ");
                            Object objectParameter = objects[0];
                            int profile;
                            try {
                                profile = (Integer) objectParameter;
                                switch (profile) {
                                    case android_bluetooth_BluetoothProfile_A2DP:
                                        mIsA2dpProfileConnected = false;
                                        break;

                                    case android_bluetooth_BluetoothProfile_HEADSET:
                                        mIsHeadsetProfileConnected = false;
                                        break;

                                    case android_bluetooth_BluetoothProfile_HEALTH:
                                        Log.d(TAG, "Received android.bluetooth.BluetoothProfile.HEALTH as profile integer parameter.");
                                        break;

                                    default:
                                        Log.w(TAG, "Unrecognized profile integer parameter received: " + profile);
                                }
                            } catch (Exception e) {
                                Log.e(TAG, "Wasn't able to extract the profile integer parameter from the objects array and process it.", e);
                            }

                        } else {
                            Log.e(TAG, "Received onServiceDisconnected() call with " + objects.length + " parameters. This should (probably) never happen.");
                        }
                    }

                    synchronized (this) {
                        mIsLocked = false;
                    }

                    return null;
                }

            });

            Method[] profileProxyMethods = mBluetoothAdapterClass.getMethods();
            Method getProfileProxyMethod = null;
            for (Method method: profileProxyMethods){
                if (method.getName().equals("getProfileProxy")){
                    Log.d(TAG, "Method found: " +method.getName());
                    getProfileProxyMethod = method;
                }
            }

            if (getProfileProxyMethod != null) {
                getProfileProxyMethod.invoke(mBluetoothAdapter, mContext.getApplicationContext(), mBluetoothProfileInnerClasses[0].cast(proxy), bluetoothProfile.getValue());
            } else {
                Log.e(TAG, "getProfileProxyMethod == null");
            }


        } catch (InvocationTargetException e) {
            Log.w(TAG,"Couldn't invoke getProfileProxyMethod (Post SDK 11 method) ", e);
        } catch (IllegalAccessException e) {
            Log.w(TAG,"Illegal access (Post SDK 1 method) ", e);
        }
    }

    @Override
    public void connect(final BluetoothDevice bluetoothDevice, final BluetoothProfile bluetoothProfile,final Callback callback) {
        executeOrDelayOperation(bluetoothProfile, new DelayedOperation() {
            @Override
            public boolean execute() {
                if(!super.execute()) {
                    return false;
                }
                Log.d(TAG, "Executing connect for: " + bluetoothDevice.getAddress());
                try {
                    Method connectMethod = null;
                    Object proxyObject = null;
                    if (bluetoothProfile == BluetoothProfile.A2DP){
                        connectMethod = mA2dpConnectMethod;
                        proxyObject = mA2dpProfileProxy;
                    }
                    if (bluetoothProfile == BluetoothProfile.HSPHFP){
                        connectMethod = mHeadsetConnectMethod;
                        proxyObject = mHeadsetProfileProxy;
                    }
                    boolean result = (Boolean) connectMethod.invoke(proxyObject, bluetoothDevice);

                    callback.onOperationCompleted(result);
                } catch (IllegalAccessException e) {
                    Log.e(TAG, "", e);
                } catch (InvocationTargetException e) {
                    Log.e(TAG, "", e);
                }
                return false;
            }
        });

    }

    @Override
    public void disconnect(final BluetoothDevice bluetoothDevice, final BluetoothProfile bluetoothProfile, final Callback callback) {
        executeOrDelayOperation(bluetoothProfile, new DelayedOperation() {
            @Override
            public boolean execute() {
                if(!super.execute()) {
                    return false;
                }
                Log.d(TAG, "Executing disconnect for: " + bluetoothDevice.getAddress());
                try {
                    Method disconnectMethod = null;
                    Object proxyObject = null;
                    if (bluetoothProfile == BluetoothProfile.A2DP){
                        disconnectMethod = mA2dpDisconnectMethod;
                        proxyObject = mA2dpProfileProxy;
                    }
                    if (bluetoothProfile == BluetoothProfile.HSPHFP){
                        disconnectMethod = mHeadsetDisconnectMethod;
                        proxyObject = mHeadsetProfileProxy;
                    }
                    boolean result = (Boolean) disconnectMethod.invoke(proxyObject, bluetoothDevice);
                    callback.onOperationCompleted(result);
                } catch (IllegalAccessException e) {
                    Log.e(TAG, "", e);
                } catch (InvocationTargetException e) {
                    Log.e(TAG, "", e);
                }
                return false;
            }
        });
    }

    @Override
    public void getConnectionStatus(final BluetoothDevice bluetoothDevice, final BluetoothProfile bluetoothProfile, final Callback callback) {
        executeOrDelayOperation(bluetoothProfile, new DelayedOperation() {
            @Override
            public boolean execute() {
                if(!super.execute()) {
                    return false;
                }
                Log.d(TAG, "Executing connection status for: " + bluetoothDevice.getAddress());
                try {
                    Method getConnectionStateMethod = null;
                    Object proxyObject = null;
                    if (bluetoothProfile == BluetoothProfile.A2DP){
                        getConnectionStateMethod = mA2dpGetConnectionStateMethod;
                        proxyObject = mA2dpProfileProxy;
                    }
                    if (bluetoothProfile == BluetoothProfile.HSPHFP){
                        getConnectionStateMethod = mHeadsetGetConnectionStateMethod;
                        proxyObject = mHeadsetProfileProxy;
                    }
                    int result = (Integer) getConnectionStateMethod.invoke(proxyObject, bluetoothDevice);

                    callback.onOperationCompleted(result == ProfileConnectionState.STATE_CONNECTED.getValue());
                } catch (IllegalAccessException e) {
                    Log.e(TAG, "", e);
                } catch (InvocationTargetException e) {
                    Log.e(TAG, "", e);
                }
                return false;
            }
        });
    }

    @Override
    public void getConnectedDevice(final BluetoothProfile bluetoothProfile, final Callback callback) {
        executeOrDelayOperation(bluetoothProfile, new DelayedOperation() {
            @Override
            public boolean execute() {
                if(!super.execute()) {
                    return false;
                }

                Log.d(TAG, "Getting connected device for: " + bluetoothProfile.name());
                try {
                    Method getConnectedDevicesMethod = null;
                    Object proxyObject = null;
                    if (bluetoothProfile == BluetoothProfile.A2DP){
                        getConnectedDevicesMethod = mA2dpGetConnectedDevicesMethod;
                        proxyObject = mA2dpProfileProxy;
                    }
                    if (bluetoothProfile == BluetoothProfile.HSPHFP){
                        getConnectedDevicesMethod = mHeadsetGetConnectedDevicesMethod;
                        proxyObject = mHeadsetProfileProxy;
                    }
                    List<BluetoothDevice> resultList = (List<BluetoothDevice>) getConnectedDevicesMethod.invoke(proxyObject, null);
                    if (resultList.isEmpty()){
                        callback.onOperationCompleted(null);
                        return false;
                    }
                    BluetoothDevice result = resultList.get(0);

                    callback.onOperationCompleted(result);
                } catch (IllegalAccessException e) {
                    Log.e(TAG, "", e);
                } catch (InvocationTargetException e) {
                    Log.e(TAG, "", e);
                }
                return false;
            }
        });
    }

    private void executeOrDelayOperation(BluetoothProfile bluetoothProfile, DelayedOperation delayedOperation){
        if (mIsLocked) {
            if (bluetoothProfile == BluetoothProfile.HSPHFP){
                if (mIsHeadsetProfileConnected){
                    mDelayedHeadsetProfileOperations.remove(delayedOperation);
                    Log.d(TAG, "----------Executing operation after service connected: " + Integer.toHexString(delayedOperation.hashCode()));
                    delayedOperation.execute();
                } else {
                    synchronized (this){
                        Log.d(TAG, " Locked, delaying Headset operation. Thread: " + Thread.currentThread().getId());
                        mDelayedHeadsetProfileOperations.add(delayedOperation);
                    }
                    return;
                }
            }
            if (bluetoothProfile == BluetoothProfile.A2DP){
                if (mIsA2dpProfileConnected){
                    mDelayedA2dpProfileOperations.remove(delayedOperation);
                    Log.d(TAG, "----------Executing operation after service connected: " + Integer.toHexString(delayedOperation.hashCode()));
                    delayedOperation.execute();
                } else {
                    synchronized (this){
                        Log.d(TAG, " Locked, delaying A2DP operation. Thread: " + Thread.currentThread().getId());
                        mDelayedA2dpProfileOperations.add(delayedOperation);
                    }
                    return;
                }
            }


        }
        synchronized (this){
            mIsLocked = true;
            Log.d(TAG, " Acquired, locking. Thread: " +Thread.currentThread().getId());
        }
        connectAndExecute(bluetoothProfile, delayedOperation);
    }
}
