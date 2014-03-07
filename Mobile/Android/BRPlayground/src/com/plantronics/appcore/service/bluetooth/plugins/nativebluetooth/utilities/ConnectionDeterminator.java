/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.os.Build;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

import java.lang.reflect.*;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * This utility connection determinator is used to determine which bluetooth device is connected without the need to track ACL events
 * It uses reflection and Java Dynamic Proxy API to access Android bluetooth manager, and should be used only when the connection states are unknown
 * I.e. after first installation *
 *
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/8/12
 */
public class ConnectionDeterminator {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + ConnectionDeterminator.class.getSimpleName();

    //When retrieveing profile proxy for post sdk 11 android we use this value
    private static final int HEADSET_PROFILE = 1;


    private Object lock = new Object();

    private boolean locked = false;

    private Context mContext;

    //Used by pre 11 sdk method
    private Object mBluetoothHeadsetObject;

    private Set<BluetoothDevice> mConnectedBluetoothDevices;

    private static ConnectionDeterminator mSingleton;

    private Set<BluetoothDevice> mBluetoothDevicesToCheck;

    private DeterminatorCallback mDeterminatorCallback;

    public interface DeterminatorCallback{

        void determinedConnections(Set<BluetoothDevice> bluetoothDevice);

    }

    private ConnectionDeterminator(Context context, DeterminatorCallback determinatorCallback){
        this.mContext = context;
        mConnectedBluetoothDevices = new HashSet<BluetoothDevice>();
        mDeterminatorCallback = determinatorCallback;
    }


    public static ConnectionDeterminator getSingleton(Context context, DeterminatorCallback determinatorCallback){
        if (mSingleton == null){
            mSingleton = new ConnectionDeterminator(context, determinatorCallback);
        }
        return mSingleton;
    }


    public void addDevicesToCheck(Set<BluetoothDevice> bluetoothDeviceList){
        mBluetoothDevicesToCheck = bluetoothDeviceList;
    }


    public void getConnectedDevices(){

        if (locked) return;
        synchronized (lock){
           locked = true;
        }


            Thread thread = new Thread(new Runnable() {
                @Override
                public void run() {

                        if (Build.VERSION.SDK_INT < 11){
                            determineConnectionStatesPreSDK11();
                        } else {
                            determineConnectionStatesPostSDK11();
                        }
                    }

            });

            thread.start();




    }

    public void determineConnectionStatesPreSDK11(){
        Log.d(TAG, "Starting PreSDK11 method");
        try {

            final Class bluetoothHeadsetClass = Class.forName("android.bluetooth.BluetoothHeadset");


            Constructor[] bluetoothHeadsetConstructors = bluetoothHeadsetClass.getConstructors();
            Constructor bluetoothHeadsetConstructor = bluetoothHeadsetConstructors[0];

            Class [] serviceListenerInterfaces = bluetoothHeadsetClass.getClasses();

            for (Class clazz : serviceListenerInterfaces){
                Log.d(TAG, "ClassName: " + clazz.getName());
            }

            /**
             * We need to implement listener interface. That is the reason we are using Dynamic Proxy API
             */
            Object proxy = Proxy.newProxyInstance(bluetoothHeadsetClass.getClassLoader(), serviceListenerInterfaces, new InvocationHandler() {
                @Override
                public Object invoke(Object o, Method method, Object[] objects) throws Throwable {

                    Log.d(TAG, "Invoked: " + method.getName());
                    if (method.getName().equals("onServiceConnected")){
                        Log.d(TAG, "Pre sdk 11 service connected");
                        Method isConnectedMethod = bluetoothHeadsetClass.getMethod("isConnected", BluetoothDevice.class);

                        for (BluetoothDevice device : mBluetoothDevicesToCheck){
                            if ((Boolean) isConnectedMethod.invoke(mBluetoothHeadsetObject, device)){
                                mConnectedBluetoothDevices.add(device);
                            }
                        }

                        mDeterminatorCallback.determinedConnections(mConnectedBluetoothDevices);
                        //Close the connection to service
                        bluetoothHeadsetClass.getMethod("close", null).invoke(mBluetoothHeadsetObject);
                        mSingleton = null; //dispose of this, the state is at best sketchy
                        synchronized (lock){
                            locked = false;
                        }
                    } else {
                        Log.d(TAG, "Pre sdk 11 service disconnected");

                    }

                    return null;
                }
            });

            //Instantiate the bluetoothHeadset object
            mBluetoothHeadsetObject = bluetoothHeadsetConstructor.newInstance(mContext,serviceListenerInterfaces[0].cast(proxy));

        } catch (ClassNotFoundException e) {
            Log.e(TAG, "Bluetooth headset class not found (pre-11 SDK method called)", e);
        } catch (InvocationTargetException e) {
            Log.e(TAG, "Could not invoke method (pre-11 SDK method called)", e);
        } catch (InstantiationException e) {
            Log.e(TAG, "Could not instantiate object (pre-11 SDK method called)", e);
        } catch (IllegalAccessException e) {
            Log.e(TAG, "Illegal access! (pre-11 SDK method called)", e);
        }

    }


    public void determineConnectionStatesPostSDK11(){
        Log.d(TAG, "Starting PostSDK11 method");

        try {
            BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            final Class bluetoothAdapterClass = bluetoothAdapter.getClass();
            final Class bluetoothProfileClass = Class.forName("android.bluetooth.BluetoothProfile");
            final Class[] bluetoothProfileInnerClasses = bluetoothProfileClass.getDeclaredClasses();
            for (Class clazz: bluetoothProfileInnerClasses){
                Log.d(TAG, "Class: " + clazz.getName());
            }


            Object proxy = Proxy.newProxyInstance(bluetoothProfileClass.getClassLoader(), bluetoothProfileInnerClasses, new InvocationHandler() {
                @Override
                public Object invoke(Object o, Method method, Object[] objects) throws Throwable {

                    Log.d(TAG, "Invoked: " + method.getName());
                    Method getConnectedDevices = bluetoothProfileClass.getMethod("getConnectedDevices", null);
                    //Wait for connection and the get connected devices
                    Log.d(TAG, "Proxy method called: " + method.getName());
                    if (method.getName().equals("onServiceConnected")){
                        Log.d(TAG, "POST SDK 11 service connected");
                        mConnectedBluetoothDevices = new HashSet<BluetoothDevice>((List<BluetoothDevice>) getConnectedDevices.invoke(objects[1],null));

                        mDeterminatorCallback.determinedConnections(mConnectedBluetoothDevices);

                        mSingleton = null; //dispose of this, the state is at best sketchy
                        synchronized (lock){
                            locked = false;
                        }
                    } else {

                    }

                    return null;
                }
            });

            Method[] profileProxyMethods = bluetoothAdapterClass.getMethods();
            Method getProfileProxyMethod = null;
            for (Method method: profileProxyMethods){
                if (method.getName().equals("getProfileProxy")){
                    Log.d(TAG, "Method found: " +method.getName());
                    getProfileProxyMethod = method;
                }
            }
            //TODO Test if we will need to do this for A2DP also (only if we don't get all results for headset)
            getProfileProxyMethod.invoke(bluetoothAdapter, mContext.getApplicationContext(), bluetoothProfileInnerClasses[0].cast(proxy), HEADSET_PROFILE);





        } catch (ClassNotFoundException e) {
            Log.d(TAG,"Bluetooth profile class not found (Post SDK 11 method) ", e);
        } catch (InvocationTargetException e) {
            Log.d(TAG,"Couldn't invoke getProfileProxyMethod (Post SDK 11 method) ", e);
        } catch (IllegalAccessException e) {
            Log.d(TAG,"Illegal access (Post SDK 1 method) ", e);
        }



    }










}
