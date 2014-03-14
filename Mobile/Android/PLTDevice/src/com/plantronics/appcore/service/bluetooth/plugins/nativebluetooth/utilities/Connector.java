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

import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothCommunicatorHandler;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

import java.lang.reflect.*;

/**
 * A helper class that provides access to connect and disconnect private API methods in BluetoothA2dp and BluetoothHeadset
 * classes
 *
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/15/12
 */
public class Connector {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + Connector.class.getSimpleName();

    Context mContext;


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

    private Method mBluetoothA2dpConnectMethod;
    private Method mBluetoothA2dpDisconnectMethod;

    private Method mBluetoothHeadsetConnectMethod;
    private Method mBluetoothHeadsetDisconnectMethod;

    private boolean mIsA2dpProfileConnected;
    private boolean mIsHeadsetProfileConnected;


    public Connector(Context context){
        Log.d(TAG, "Connnector instantiated");
        mContext = context;

        mCommunicator = new Communicator(mContext);



        if (Build.VERSION.SDK_INT < 11){



            try {

                mBluetoothA2dpClass = Class.forName("android.bluetooth.BluetoothA2dp");
                mBluetoothHeadsetClass = Class.forName("android.bluetooth.BluetoothHeadset");

                mBluetoothHeadsetServiceListenerInterfaces = mBluetoothHeadsetClass.getClasses();

                Constructor[] bluetoothA2dpConstructors = mBluetoothA2dpClass.getConstructors();
                Constructor[] bluetoothHeadsetConstructors = mBluetoothHeadsetClass.getConstructors();

                mBluetoothA2dpConstructor = bluetoothA2dpConstructors[0];
                mBluetoothHeadsetConstructor = bluetoothHeadsetConstructors[0];

//                mBluetoothA2dpObject = bluetoothA2dpConstructors[0].newInstance(mContext);



                mBluetoothA2dpConnectMethod = mBluetoothA2dpClass.getMethod("connectSink", BluetoothDevice.class);
                mBluetoothA2dpDisconnectMethod = mBluetoothA2dpClass.getMethod("disconnectSink", BluetoothDevice.class);

                mBluetoothHeadsetConnectMethod = mBluetoothHeadsetClass.getMethod("connectHeadset", BluetoothDevice.class);
                if (Build.VERSION.SDK_INT <= 8){
                    mBluetoothHeadsetDisconnectMethod = mBluetoothHeadsetClass.getMethod("disconnectHeadset");
                } else {
                    mBluetoothHeadsetDisconnectMethod = mBluetoothHeadsetClass.getMethod("disconnectHeadset", BluetoothDevice.class);
                }

            } catch (ClassNotFoundException e) {
                Log.e(TAG, "Class not found", e);
            } catch (NoSuchMethodException e) {
                Log.e(TAG, "Method not found", e);
            }
        }

    }

    public boolean connectToDevice(final BluetoothDevice bluetoothDevice){
        if (Build.VERSION.SDK_INT < 11){

            connectToDevicePreSDK11(bluetoothDevice);
            return true;

        } else {
            connectToDevicePostSDK11(bluetoothDevice);
            return true;
        }

    }

    public boolean disconnectFromDevice(final BluetoothDevice bluetoothDevice){
        if (Build.VERSION.SDK_INT < 11){
            disconnectFromDevicePreSDK11(bluetoothDevice);
        } else{
            disconnectFromDevicePostSDK11(bluetoothDevice);
        }

        return false;
    }


    /**
     * Try to connect both A2DP and Headset profiles
     * @param bluetoothDevice to connect to
     * @return nothing right now
     */
    public boolean connectToDevicePreSDK11(final BluetoothDevice bluetoothDevice){
        try {
            mBluetoothA2dpObject = mBluetoothA2dpConstructor.newInstance(mContext);
            mBluetoothA2dpConnectMethod.invoke(mBluetoothA2dpObject, bluetoothDevice);


            Object proxy = Proxy.newProxyInstance(mBluetoothHeadsetClass.getClassLoader(), mBluetoothHeadsetServiceListenerInterfaces, new InvocationHandler() {
                @Override
                public Object invoke(Object o, Method method, Object[] objects) throws Throwable {

                    Log.d(TAG, "Invoked: " + method.getName());
                    if (method.getName().equals("onServiceConnected")){
                        Log.d(TAG, "Pre sdk 11 bluetooth service connected");
                        Log.d(TAG, "Requesting connect");
                        mBluetoothHeadsetConnectMethod.invoke(mBluetoothHeadsetObject, bluetoothDevice);



                    }
                    if (method.getName().equals("onServiceConnected")){
                        Log.d(TAG, "Pre sdk 11 service disconnected");

                    }

                    return null;
                }
            });

            mBluetoothHeadsetObject = mBluetoothHeadsetConstructor.newInstance(mContext, mBluetoothHeadsetServiceListenerInterfaces[0].cast(proxy));


            return (Boolean) mBluetoothA2dpConnectMethod.invoke(mBluetoothA2dpObject, bluetoothDevice);
        } catch (IllegalAccessException e) {
            Log.e(TAG, "Illegal access", e);
        } catch (InvocationTargetException e) {
            Log.e(TAG, "Invocation exception", e);
        } catch (InstantiationException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

        return false;
    }

    /**
     * Try to connect both A2DP and Headset profiles
     * @param bluetoothDevice to connect to
     * @return nothing right now
     */
    public boolean disconnectFromDevicePreSDK11(final BluetoothDevice bluetoothDevice){
        try {
            mBluetoothA2dpObject = mBluetoothA2dpConstructor.newInstance(mContext);
            mBluetoothA2dpDisconnectMethod.invoke(mBluetoothA2dpObject,bluetoothDevice);

            Object proxy = Proxy.newProxyInstance(mBluetoothHeadsetClass.getClassLoader(), mBluetoothHeadsetServiceListenerInterfaces, new InvocationHandler() {
                @Override
                public Object invoke(Object o, Method method, Object[] objects) throws Throwable {

                    Log.d(TAG, "Invoked: " + method.getName());
                    if (method.getName().equals("onServiceConnected")){
                        Log.d(TAG, "Pre sdk 11 bluetooth service connected");
                        Log.d(TAG, "Requesting disconnect");
                        if (Build.VERSION.SDK_INT <= 8){
                            mBluetoothHeadsetDisconnectMethod.invoke(mBluetoothHeadsetObject);
                        } else {
                            mBluetoothHeadsetDisconnectMethod.invoke(mBluetoothHeadsetObject, bluetoothDevice);
                        }


                    } else {
                        Log.d(TAG, "Pre sdk 11 service disconnected");

                    }

                    return null;
                }
            });

            mBluetoothHeadsetObject = mBluetoothHeadsetConstructor.newInstance(mContext, mBluetoothHeadsetServiceListenerInterfaces[0].cast(proxy));


            return (Boolean) mBluetoothA2dpConnectMethod.invoke(mBluetoothA2dpObject, bluetoothDevice);
        } catch (IllegalAccessException e) {
            Log.e(TAG, "Illegal access", e);
        } catch (InvocationTargetException e) {
            Log.e(TAG, "Invocation exception", e);
        } catch (InstantiationException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

        return false;
    }




    public void connectToDevicePostSDK11(final BluetoothDevice bluetoothDevice){
        Log.d(TAG, "Starting PostSDK11 method");

        try {
            BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            final Class bluetoothAdapterClass = bluetoothAdapter.getClass();
            final Class bluetoothProfileClass = Class.forName("android.bluetooth.BluetoothProfile");
            final Class bluetoothA2dpClass = Class.forName("android.bluetooth.BluetoothA2dp");
            final Class bluetoothHeadsetClass = Class.forName("android.bluetooth.BluetoothHeadset");
            final Class[] bluetoothProfileInnerClasses = bluetoothProfileClass.getDeclaredClasses();
            for (Class clazz: bluetoothProfileInnerClasses){
                Log.d(TAG, "Class: " + clazz.getName());
            }


            Object proxy = Proxy.newProxyInstance(bluetoothProfileClass.getClassLoader(), bluetoothProfileInnerClasses, new InvocationHandler() {
                @Override
                public Object invoke(Object o, Method method, Object[] objects) throws Throwable {

                    Log.d(TAG, "Invoked: " + method.getName());
                    Method connect = null;
                    if (bluetoothA2dpClass.isInstance(objects[1])){
                        connect = bluetoothA2dpClass.getMethod("connect", BluetoothDevice.class);
                        Log.d(TAG, "is A2DP class");
                    }
                    if (bluetoothHeadsetClass.isInstance(objects[1])){
                        connect = bluetoothHeadsetClass.getMethod("connect", BluetoothDevice.class);
                        Log.d(TAG, "is Headset class");
                    }
                    //Wait for connection and the get connected devices
                    Log.d(TAG, "Proxy method called: " + method.getName());
                    if (method.getName().equals("onServiceConnected")) {
                        Log.d(TAG, "POST SDK 11 service connected");
                        connect.invoke(objects[1], bluetoothDevice);
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
            getProfileProxyMethod.invoke(bluetoothAdapter, mContext.getApplicationContext(), bluetoothProfileInnerClasses[0].cast(proxy), 1);
            //Consider only devices with HSP/HFP connected.
//            getProfileProxyMethod.invoke(mBluetoothAdapter, mContext.getApplicationContext(), bluetoothProfileInnerClasses[0].cast(proxy), 2);




        } catch (ClassNotFoundException e) {
            Log.d(TAG,"Bluetooth profile class not found (Post SDK 11 method) ", e);
        } catch (InvocationTargetException e) {
            Log.d(TAG,"Couldn't invoke getProfileProxyMethod (Post SDK 11 method) ", e);
        } catch (IllegalAccessException e) {
            Log.d(TAG,"Illegal access (Post SDK 1 method) ", e);
        }
    }

    public void disconnectFromDevicePostSDK11(final BluetoothDevice bluetoothDevice){
        Log.d(TAG, "Starting PostSDK11 method");

        try {
            BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            final Class bluetoothAdapterClass = bluetoothAdapter.getClass();
            final Class bluetoothProfileClass = Class.forName("android.bluetooth.BluetoothProfile");
            final Class bluetoothA2dpClass = Class.forName("android.bluetooth.BluetoothA2dp");
            final Class bluetoothHeadsetClass = Class.forName("android.bluetooth.BluetoothHeadset");
            final Class[] bluetoothProfileInnerClasses = bluetoothProfileClass.getDeclaredClasses();
            for (Class clazz: bluetoothProfileInnerClasses){
                Log.d(TAG, "Class: " + clazz.getName());
            }


            Object proxy = Proxy.newProxyInstance(bluetoothProfileClass.getClassLoader(), bluetoothProfileInnerClasses, new InvocationHandler() {
                @Override
                public Object invoke(Object o, Method method, Object[] objects) throws Throwable {

                    Log.d(TAG, "Invoked: " + method.getName());
                    Method disconnect = null;
                    if (bluetoothA2dpClass.isInstance(objects[1])){
                        disconnect = bluetoothA2dpClass.getMethod("disconnect", BluetoothDevice.class);
                        Log.d(TAG, "is A2DP class");
                    }
                    if (bluetoothHeadsetClass.isInstance(objects[1])){
                        disconnect = bluetoothHeadsetClass.getMethod("disconnect", BluetoothDevice.class);
                        Log.d(TAG, "is Headset class");
                    }
                    //Wait for connection and the get connected devices
                    Log.d(TAG, "Proxy method called: " + method.getName());
                    if (method.getName().equals("onServiceConnected")) {
                        Log.d(TAG, "POST SDK 11 service connected");
                        disconnect.invoke(objects[1], bluetoothDevice);
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
            getProfileProxyMethod.invoke(bluetoothAdapter, mContext.getApplicationContext(), bluetoothProfileInnerClasses[0].cast(proxy), 1);
            getProfileProxyMethod.invoke(bluetoothAdapter, mContext.getApplicationContext(), bluetoothProfileInnerClasses[0].cast(proxy), 2);




        } catch (ClassNotFoundException e) {
            Log.d(TAG,"Bluetooth profile class not found (Post SDK 11 method) ", e);
        } catch (InvocationTargetException e) {
            Log.d(TAG,"Couldn't invoke getProfileProxyMethod (Post SDK 11 method) ", e);
        } catch (IllegalAccessException e) {
            Log.d(TAG,"Illegal access (Post SDK 1 method) ", e);
        }



    }



}
