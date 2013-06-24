package com.plantronics.example.controller;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.*;

import android.util.Log;
import android.widget.Toast;
import com.plantronics.example.listener.BindListener;
import com.plantronics.example.listener.DiscoveryListener;
import com.plantronics.example.listener.HeadsetServiceBluetoothListener;
import com.plantronics.example.listener.HeadsetServiceConnectionListener;
import com.plantronics.example.listener.HeadsetServiceEventListener;
import com.plantronics.example.listener.HeadsetServiceResponseListener;
import com.plantronics.headsetdataservice.*;
import com.plantronics.headsetdataservice.io.DeviceCommand;
import com.plantronics.headsetdataservice.io.DeviceCommandType;
import com.plantronics.headsetdataservice.io.DeviceEvent;
import com.plantronics.headsetdataservice.io.DeviceEventType;
import com.plantronics.headsetdataservice.io.DeviceSetting;
import com.plantronics.headsetdataservice.io.DeviceSettingType;
import com.plantronics.headsetdataservice.io.HeadsetDataDevice;
import com.plantronics.headsetdataservice.io.RemoteResult;
import com.plantronics.headsetdataservice.io.SessionErrorException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Example of binding and unbinding to the remote service.
 * This demonstrates the implementation of a service which the client will
 * bind to, interacting with it through an aidl interface.</p>
 * <p/>
 * <p>Note that this is implemented as an inner class only keep the sample
 * all together; typically this code would appear in some separate class.
 */
public class HeadsetDataController {

    private static final String TAG = "HeadsetDataController";

    /**
     * The primary interface which will be on the HeadsetData service.
     */
    private IHeadsetDataService mService = null;

    private static HeadsetDataController mHeadsetDataController;
    static Context mContext;
    static Context mBindContext;
    private boolean bIsBound;
    protected boolean bServiceConnectionOpen;

    private boolean bHeadsetServiceCallbacksRegistered = false;

    // Bladerunner device object - The Headset
    private HeadsetDataDevice mLocalDevice;
    // Bladerunner device object - remote phone also connected to the headset
    private HeadsetDataDevice mRemoteDevice;

    Map<HeadsetDataDevice, HeadsetServiceConnectionListener> mDeviceToConnectionListeners = new HashMap<HeadsetDataDevice, HeadsetServiceConnectionListener>();
    Map<HeadsetDataDevice, Boolean> mDeviceToOpen = new HashMap<HeadsetDataDevice, Boolean>();
    Map<HeadsetDataDevice, HeadsetServiceResponseListener> mCommandListener = new HashMap<HeadsetDataDevice, HeadsetServiceResponseListener>();
    Map<HeadsetDataDevice, HeadsetServiceResponseListener> mSettingListener = new HashMap<HeadsetDataDevice, HeadsetServiceResponseListener>();
    Map<HeadsetDataDevice, HeadsetServiceEventListener> mEventListener = new HashMap<HeadsetDataDevice, HeadsetServiceEventListener>();
    HeadsetServiceBluetoothListener mBluetoothListener;

    /**
     * Singleton access method
     *
     * @param context
     * @return
     */
    public static HeadsetDataController getHeadsetControllerSingleton(Context context) {

        // update the context to the latest once called from
        mContext = context;
        if (mHeadsetDataController == null) {
            synchronized (HeadsetDataController.class) {
                if (mHeadsetDataController == null) {
                    mHeadsetDataController = new HeadsetDataController(context);
                }
            }
        }
        return mHeadsetDataController;
    }

    /**
     * Constructor is private to make this class a singleton
     *
     * @param context
     */
    private HeadsetDataController(Context context) {

        // Bind to the headsetDataService
        boolean ret = context.bindService(new Intent(IHeadsetDataService.class.getName()), mConnection, Context.BIND_AUTO_CREATE);
        if (!ret) {
            Log.e(TAG, "Failed to bind to the IHeadsetDataService");
            bIsBound = false;
            ((BindListener)context).bindFailed();
        } else {
            bIsBound = true;
            ((BindListener)context).bindSuccess();
            // save the context of the activity bound with the service.
            mBindContext = context;
        }
    }

    /**
     * Class for interacting with the main interface of the service.
     */
    private ServiceConnection mConnection = new ServiceConnection() {
        public void onServiceConnected(ComponentName className, IBinder service) {
            // This is called when the connection with the service has been
            // established, giving us the service object we can use to
            // interact with the service.  We are communicating with our
            // service through an IDL interface, so get a client-side
            // representation of that from the raw service object.
            mService = IHeadsetDataService.Stub.asInterface(service);
            bServiceConnectionOpen = true;

            // As part of the sample, tell the user what happened.
            //Toast.makeText(mContext, "headset data service connected.", Toast.LENGTH_SHORT).show();

            // Call the asynchronous listener to tell that the service is connected
            ((BindListener)mContext).serviceConnected();
        }

        public void onServiceDisconnected(ComponentName className) {
            // This is called when the connection with the service has been
            // unexpectedly disconnected -- that is, its process crashed.
            mService = null;
            bServiceConnectionOpen = false;

            // As part of the sample, tell the user what happened.
            //Toast.makeText(mContext, "Headset data service disconnected.", Toast.LENGTH_SHORT).show();

            ((BindListener)mContext).serviceDisconnected();
        }
    };

    public boolean isbServiceConnectionOpen() {
        return bServiceConnectionOpen;
    }


    /**
     * Register callback to get the discovered devices
     * Only needed if App has called getConnectedBladeRunnerBluetoothDevice() or
     * discoverHeadsetDataServiceDevices()
     *
     * @return
     */
    public boolean registerDiscoveryCallback() {
        try {
            mService.registerDiscoveryCallback(mCallbackDiscovery);
        } catch (RemoteException e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    /**
     * Unregister callback to get the discovered devices
     * Only needed if App has called getConnectedBladeRunnerBluetoothDevice() or
     * discoverHeadsetDataServiceDevices()
     *
     * @return
     */
    public boolean unregisterDiscoveryCallback() {
        try {
            mService.unregisterDiscoveryCallback(mCallbackDiscovery);
        } catch (RemoteException e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }


    /**
     * Utility method to register all other callback listeners
     * MetadataCallback is not necessary, but its better to register remaining.
     */
    public void registerServiceCallbacks() {
        Log.i(TAG, "register Service callbacks");
        if (!bHeadsetServiceCallbacksRegistered) {
            try {
                if (mService != null) {
                    mService.registerOpenCallback(mCallbackOpen);
                    mService.registerEventsCallback(mCallbackEvents);
                    mService.registerSessionCallback(mCallbackSession);
                    mService.registerMetadataCallback(mCallbackMetadata);
                    mService.registerBluetoothConnectionCallback(mCallbackBluetoothConnection);

                    // record that the callbacks to the service is done. Multiple registrations will result in
                    // multiple callbacks to the App
                    bHeadsetServiceCallbacksRegistered = true;
                } else {
                    Log.e(TAG, "mService is null; failed to register service");
                }
            } catch (RemoteException e) {
            }
        } else {
            Log.e(TAG, "Service Callbacks already registered");
        }

    }

    public void unregisterServiceCallbacks() {
        Log.i(TAG, "Unregister Service callbacks");
        try {
            if (mService != null) {
                mService.unregisterOpenCallback(mCallbackOpen);
                mService.unregisterEventsCallback(mCallbackEvents);
                mService.unregisterSessionCallback(mCallbackSession);
                mService.unregisterMetadataCallback(mCallbackMetadata);
                mService.unregisterBluetoothConnectionCallback(mCallbackBluetoothConnection);

                // record the unregister of the Service Callbacks.
                bHeadsetServiceCallbacksRegistered = false;
            } else {
                Log.e(TAG, "mService is null; failed to un-register service");
            }
        } catch (RemoteException e) {

        }
    }


    /**
     * Utility method to register listeners - these listeners are registered per connection basis
     *
     * @param listener
     */
    public void registerConnectionListeners( HeadsetDataDevice device, HeadsetServiceConnectionListener listener) {
        Log.e(TAG, "Register Connection listeners=" + listener);
		if (!mDeviceToConnectionListeners.containsKey(device)) {
			if (mDeviceToConnectionListeners.get(device) != listener) {
				mDeviceToConnectionListeners.put(device, listener);
				try {
					mService.addDeviceOpenListener(device);
					mService.addDeviceSessionListener(device);
					mService.addDeviceEventListener(device);
					mService.addMetadataListener(device);
				} catch (RemoteException e) {
					e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
				}
			}
			else {
				Log.e(TAG, "Already registered.");
			}
		}
		else {
			Log.e(TAG, "Already registered.");
		}
    }

    public void unregisterConnectionListeners(HeadsetDataDevice device) {
        Log.e(TAG, "Unregister Connection listeners");

        try {
            mService.removeDeviceOpenListener(device);
            mService.removeDeviceSessionListener(device);
            mService.removeDeviceEventListener(device);
            mService.removeMetadataListener(device);
        } catch (RemoteException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

        mDeviceToConnectionListeners.remove(device);
    }


    /**
     * Bind to the HeadsetDataService
     *
     * @param context
     * @return
     */
    public int bindHeadsetDataService(Context context) {

        int status = -1;

        if (!bIsBound) {
            boolean ret = context.bindService(new Intent(IHeadsetDataService.class.getName()), mConnection, Context.BIND_AUTO_CREATE);
            if (!ret) {
                Log.e(TAG, "Failed to bind to the IHeadsetDataService");
                bIsBound = false;
                ((BindListener)context).bindFailed();
                status = -1;
            } else {
                bIsBound = true;
                ((BindListener)context).bindSuccess();
                mBindContext = context;
                // bindService is called which will result in asynchronous call to onServiceConnected()
                status = 1;
            }
        } else {
            // Service is already bound, so service connection event onServiceConencted() will not be called
            status = 2;
        }

        return status;
    }

    public boolean unbindHeadsetDataService(Context context) {

        if (bIsBound) {
            // If we have received the service, and hence registered with
            // it, then now is the time to unregister.
            if (mService != null) {
                unregisterServiceCallbacks();
            }

            Log.e(TAG, "Calling unbindService " + mConnection);
            // Detach our existing connection.
            if (context != null) {
                context.unbindService(mConnection);
                // let the listener know that service is now unbound
                ((BindListener)context).unbind();
            }
            bIsBound = false;
        }
        bServiceConnectionOpen = false;

        return bIsBound;
    }


    /**
     * Discover the bluetooth devices which supports Bladerunner protocol
     * among the paired Bluetooth devices. Its a asynchronous API call and the
     * actual discovery results are returned as callback
     *
     * @return
     * @exception RemoteException
     */
    public int getBladeRunnerDevices() throws RemoteException {
        return mService.discoverHeadsetDataServiceDevices();
    }


    /**
     * Create a new Device object to represent Bluetooth headset
     *
     * @param addr
     * @param btListener
     * @return
     */
    public boolean newDevice(String addr, HeadsetServiceBluetoothListener btListener) {
        try {
            mService.newDevice(addr);
        } catch (RemoteException e) {
            e.printStackTrace();
            return false;
        }

        mLocalDevice = new HeadsetDataDevice(addr);
        if (mLocalDevice == null) {
            Log.e(TAG, "Error: localDevice is null");
            return false;
        } else {
            Log.e(TAG, "LocalDevice: " + mLocalDevice);
            mBluetoothListener = btListener;
        }
        return true;
    }


    /**
     * Create a new Device object to represent Bluetooth headset
     *
     * @param addr
     * @param btListener
     * @return
     */
    public boolean newDevice(String addr, byte port,  HeadsetServiceBluetoothListener btListener) {
        try {
            mService.newRemoteDevice(addr, port);
        } catch (RemoteException e) {
            e.printStackTrace();
            return false;
        }

        mRemoteDevice = new HeadsetDataDevice(addr, port);
        if (mRemoteDevice == null) {
            Log.e(TAG, "Error: remoteDevice is null");
            return false;
        } else {
            Log.e(TAG, "remoteDevice: " + mRemoteDevice);
            mBluetoothListener = btListener;
        }
        return true;
    }


    /**
     * Open bladerunner connection with the Bluetooth headset
     * Its a asynchronous API and result is returned via callbacks deviceOpen()/ openFailed()
     *
     * @param listener
     */
    public int open(HeadsetDataDevice device, HeadsetServiceConnectionListener listener) {

        // register bladerunner listeners
        registerConnectionListeners(device,  listener);
        int ret = -1;

        try {
            Log.e(TAG, "calling open()");
            ret = mService.open(device);
            if (ret == 1) {
                Log.e(TAG, "BR connection is already open for " + device);

                mDeviceToOpen.put(device, true);
                //bDeviceOpen = true;

                // call the deviceOpen callback from here itself
                HeadsetServiceConnectionListener clistener = mDeviceToConnectionListeners.get(device);
                if (clistener != null) {
                    clistener.deviceOpen(device);
                } else {
                    Log.e(TAG, "deviceOpen(): connectionListener is null for device " + device);
                }
            }
        } catch (RemoteException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        return ret;
    }

    /**
     * Close the Bladerunner Connection to the bluetooth headset
     */
    public void close(HeadsetDataDevice device)  {
        try {
            unregisterConnectionListeners(device);
            mService.close(device);
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }

    /**
     * @return
     */
    public boolean isbDeviceOpen(HeadsetDataDevice device) {
        if (mDeviceToOpen.get(device) != null) {
            return mDeviceToOpen.get(device);
        }  else {
            return false;
        }
    }


    /**
     * Another API to register for a Events later than the connection open time
     *
     * @param listener
     * @return
     */
    public boolean registerEventListener(HeadsetDataDevice device,  HeadsetServiceEventListener listener) {
        /*if (!bDeviceOpen )  {
            return false;
        } */
		if (!mEventListener.containsKey(device)) {
			if (mEventListener.get(device) != listener) {
        		mEventListener.put(device, listener);
			}
			else {
				Log.e(TAG, "Already registered.");
			}
		}
		else {
			Log.e(TAG, "Already registered.");
		}
        return true;
    }


    /**
     *
     * @param device
     * @param id
     * @param objs
     * @return
     */
    public DeviceCommand getCommand(HeadsetDataDevice device, short id, Object[] objs) {

        DeviceCommandType dct;
        DeviceCommand dc = null;

        try {
            dct = mService.getCommandType(device, id);

            if (dct != null) {
                // the device command is available on the headset
                dc = mService.getCommand(device, dct);
                if (objs != null) {
                    dc.internalSetValue(objs);
                } else {
                    dc.internalSetValue(new Object[0]);
                }
            }
        } catch (RemoteException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        } finally {
            return dc;
        }
    }


    /**
     *
     * @param device
     * @param command
     * @param result
     * @param listener
     * @return
     */
    public int perform(HeadsetDataDevice device, DeviceCommand command, RemoteResult result, HeadsetServiceResponseListener listener) {

        int res = 0;
        mCommandListener.put(device, listener);

        try {
            res = mService.perform(device, command, result);
            listener.result(res, result);
        } catch (RemoteException e) {
            e.printStackTrace();
        }
        return res;
    }


    public DeviceSetting getSetting(HeadsetDataDevice device, short id, Object[] objs) {

        DeviceSettingType dst;
        DeviceSetting ds = null;

        try {
            dst = mService.getSettingType(device, id);

            if (dst != null) {
                // the device setting is available on the headset
                ds = mService.getSetting(device, dst);
                if ((objs != null) && (objs.length > 0)) {
                    ds.setDeviceSettingInputValue(objs);
                }
            }
			else {
				Log.i(TAG, "Device setting type null in API.");
			}
        } catch (RemoteException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        } finally {
            return ds;
        }
    }

    /**
     *
     * @param device
     * @param setting
     * @param result
     * @param listener
     * @return
     */
    public int fetch(HeadsetDataDevice device, DeviceSetting setting, RemoteResult result, HeadsetServiceResponseListener listener) {

        int res = 0;
        mSettingListener.put(device, listener);
        try {

            res = mService.fetch(device, setting, result);
            if (res >= 0) {
                SettingsResult settingsResult = new SettingsResult(result, setting);
                listener.settingResult(res, settingsResult);
            } else {
                listener.result(res, result);
            }
        } catch (RemoteException e) {
            e.printStackTrace();
        }
        return res;
    }

    /**
     * @param device HeadsetDataDevice object for the Bluetooth headset
     * @return
     */
    public List<DeviceSettingType> getSupportedSettings(HeadsetDataDevice device) {
        try {
            return mService.getSupportedSettings(device);
        } catch (RemoteException e) {
            e.printStackTrace();
            return null;
        }

    }

    /**
     * @param device HeadsetDataDevice object for the Bluetooth headset
     * @return
     */
    public List<DeviceCommandType> getSupportedCommands(HeadsetDataDevice device) {
        try {
            return mService.getSupportedCommands(device);
        } catch (RemoteException e) {
            e.printStackTrace();
            return null;
        }
    }


    /**
     * @param device HeadsetDataDevice object for the Bluetooth headset
     * @return
     */
    public List<DeviceEventType> getSupportedEvents(HeadsetDataDevice device) {
        try {
            return mService.getSupportedEvents(device);
        } catch (RemoteException e) {
            e.printStackTrace();
            return null;
        }
    }

    // ----------------------------------------------------------------------
    // Code showing how to deal with callbacks.
    // All Callbacks are implemented.
    // ----------------------------------------------------------------------

    /**
     * This implementation is used to receive callbacks from the remote
     * service.
     */
    private IHeadsetDataServiceCallbackDiscovery mCallbackDiscovery = new IHeadsetDataServiceCallbackDiscovery.Stub() {
        /**
         * This is called by the remote service in response to the call
         * Note that IPC calls are dispatched through a thread
         * pool running in each process, so the code executing here will
         * NOT be running in our main thread like most other things -- so,
         * to update the UI, we need to use a Handler to hop over there.
         */
        @Override
        public void foundDevice(String bdaddr) throws RemoteException {
            ((DiscoveryListener)mContext).foundDevice(bdaddr);
        }

        @Override
        public void discoveryStopped(int result) throws RemoteException {
            ((DiscoveryListener)mContext).discoveryStopped(result);
        }
    };

    private IHeadsetDataServiceCallbackOpen mCallbackOpen = new IHeadsetDataServiceCallbackOpen.Stub() {

        @Override
        public void deviceOpen(HeadsetDataDevice hdDevice) throws RemoteException {
            mDeviceToOpen.put(hdDevice, true);
            //bDeviceOpen = true;
            HeadsetServiceConnectionListener listener = mDeviceToConnectionListeners.get(hdDevice);
            if (listener != null) {
                listener.deviceOpen(hdDevice);
            } else {
                Log.e(TAG, "deviceOpen(): connectionListener is null for device " + hdDevice);
            }
        }

        @Override
        public void openFailed(HeadsetDataDevice hdDevice, SessionErrorException s) throws RemoteException {
            HeadsetServiceConnectionListener listener = mDeviceToConnectionListeners.get(hdDevice);
            if (listener != null) {
                listener.openFailed(hdDevice);
            } else {
                Log.e(TAG, "openFailed(): mConnectionListener is null for device " + hdDevice);
            }
            Log.e(TAG, "Setting device open to false");
            //bDeviceOpen = false;
            mDeviceToOpen.put(hdDevice, false);
            unregisterConnectionListeners(hdDevice);
        }
    };

    private IHeadsetDataServiceCallbackSession mCallbackSession = new IHeadsetDataServiceCallbackSession.Stub() {
        @Override
        public void deviceClose(HeadsetDataDevice hdDevice, SessionErrorException s) throws RemoteException {
            HeadsetServiceConnectionListener listener = mDeviceToConnectionListeners.get(hdDevice);
            if (listener != null) {
                listener.deviceClosed(hdDevice);
            } else {
                Log.e(TAG, "deviceClose(): mConnectionListener is null");
            }
            Log.e(TAG, "Setting device open to false");
            //bDeviceOpen = false;
            mDeviceToOpen.put(hdDevice, false);

			if (isbDeviceOpen(hdDevice)) {
				Log.i("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&", "open");
			}
			else {
				Log.i("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&", "znot open");
			}

            unregisterConnectionListeners(hdDevice);
        }
    };


    private IHeadsetDataServiceCallbackEvents mCallbackEvents = new IHeadsetDataServiceCallbackEvents.Stub() {
        @Override
        public void receiveEvent(HeadsetDataDevice hdDevice, DeviceEvent de) throws RemoteException {
            Log.e(TAG, "received event " + de);
            HeadsetServiceEventListener eventListener =  mEventListener.get(hdDevice);
            if (eventListener != null) {
                eventListener.eventReceived(de);
            } else {
                Log.e(TAG, "receiveEvent(): event listener is null for device " + hdDevice);
            }
        }
    };


    private IHeadsetDataServiceCallbackBluetoothConnection mCallbackBluetoothConnection = new IHeadsetDataServiceCallbackBluetoothConnection.Stub() {

        @Override
        public void onBluetoothDeviceConnected(String deviceBluetoothAddress) throws RemoteException {
            if (mBluetoothListener != null) {
                mBluetoothListener.onBluetoothConnected(deviceBluetoothAddress);
            }
        }

        @Override
        public void onBluetoothDeviceDisconnected(String deviceBluetoothAddress) throws RemoteException {
            if (mBluetoothListener != null) {
                mBluetoothListener.onBluetoothDisconnected(deviceBluetoothAddress);
            }
        }
    };

    /**
     * Callback to receive the metadata. The metadata is received each time time a new session is opened with the
     * headset device.
     * This callback can be ignored if App is not interested in parsing/saving this event data.
     * The information received in this event is also stored under SDK and can be retrieved by calling
     */
    private IHeadsetDataServiceCallbackMetadata mCallbackMetadata = new IHeadsetDataServiceCallbackMetadata.Stub() {
        @Override
        public void metadataReceived(HeadsetDataDevice hdDevice, List<DeviceCommandType> commands, List<DeviceSettingType> settings, List<DeviceEventType> events) throws RemoteException {
            //To change body of implemented methods use File | Settings | File Templates.
        }
    };


}





