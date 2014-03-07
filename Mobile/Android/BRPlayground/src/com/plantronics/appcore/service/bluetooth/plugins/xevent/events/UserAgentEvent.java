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
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.XEventType;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/15/12
 */
public class UserAgentEvent extends XEvent {
    /**
	 * 
	 */
	private static final long serialVersionUID = 4811895013681449755L;

	public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + UserAgentEvent.class.getSimpleName();

    ///
    //// User agent
    ///

    public static final String USER_AGENT = "USER-AGENT";

    public static final int NUM_USER_AGENT_ARGS = 6;

    public static final String MANUFACTURER_EXTRA = "MANUFACTURER";

    public static final String PRODUCT_NAME_EXTRA = "PRODUCT_NAME";

    public static final String FIRMWARE_ID_EXTRA = "FIRMWARE_ID";

    public static final String USB_PID_EXTRA = "USB_PID";

    public static final String SERIAL_NUMBER_EXTRA = "SERIAL_NUMBER";


    private String mManufacturerId;
    private String mProductId;
    private String mFirmwareId;
    private String mUsbPid;
    private String mSerialNumber;


    public static UserAgentEvent workaroundConstructor(BluetoothDevice bluetoothDevice,Object[] args) {

        // Logging: ==============================================================================================
        Log.i(TAG, "workaroundConstructor(device, args). Args [2]: " + args[2] + ", args [3]: " + args[3]);
        if (args[2] != null) {
            Log.i(TAG, "workaroundConstructor(device, args). Args [2].getClass: " + args[2].getClass());
        } else {
            Log.w(TAG, "workaroundConstructor(device, args). Args [2] == null.");
        }
        if (args[3] != null) {
            Log.i(TAG, "workaroundConstructor(device, args). Args [3].getClass: " + args[3].getClass());
        } else {
            Log.w(TAG, "workaroundConstructor(device, args). Args [3] == null.");
        } //=====================================================================================================

        /*
        Ugi: "It might be best to completely ignore these two"
         */
        String usbPid = null;
        String firmwareId = null;

        /*
        If args[2] is a String
         */
        if (args[2] instanceof String) {
            Log.d(TAG, "UsbPid parameter is a string! Maybe it's empty");
            String args2String = (String) args[2];          // Helper variable to see if it's empty

            // If args[2] String is empty
            if (args2String.length() == 0) {
                Log.d(TAG, "UsbPid is empty, ok, no usb ID");
                usbPid = "-1";
                firmwareId = "" + args[3];                  // *** Solution for crash on C720, TT21487) ***

            // If args[2] String is not empty
            } else {
                Log.d(TAG, "UsbPid is not empty, headset probably has wrong XEvent implementation (switching usbId and firmware ID");
                firmwareId = (String) args[2];              // Safely cast it to String (since we already checked)
                usbPid = "" + args[3];                      // *** Solution for crash on C720, TT21487) ***
            }

        /*
        If args[2] is an Integer
         */
        }  else if (args[2] instanceof Integer) {
            usbPid = "" + args[2];
            firmwareId = "" + args[3];                      // *** Solution for crash on C720, TT21487) ***
        }

        return new UserAgentEvent(bluetoothDevice, (String) args[0], (String) args[1], usbPid, firmwareId , (String) args[4]);
    }

    public UserAgentEvent(BluetoothDevice bluetoothDevice ,String manufacturerId, String productId, String usbPid, String firmwareId, String serialNumber) {
        mBluetoothDevice = bluetoothDevice;
        mManufacturerId = manufacturerId;
        mProductId = productId;
        mUsbPid = usbPid;
        mFirmwareId = firmwareId;
        mSerialNumber = serialNumber;
        Log.d(TAG, "UA event - MID: " + mManufacturerId + " PID: " + mProductId + " UID: " + mUsbPid + " FID: " + firmwareId + " SN: " + serialNumber);
    }

    @Override
    public String getEventPluginHandlerName() {
        return XEventBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getType() {
        return XEventType.USER_AGENT.toString();
    }

    public String getManufacturerId() {
        return mManufacturerId;
    }

    public void setManufacturerId(String manufacturerId) {
        mManufacturerId = manufacturerId;
    }

    public String getProductId() {
        return mProductId;
    }

    public void setProductId(String productId) {
        mProductId = productId;
    }

    public String getUsbPid() {
        return mUsbPid;
    }

    public void setUsbPid(String usbPid) {
        mUsbPid = usbPid;
    }

    public String getFirmwareId() {
        return mFirmwareId;
    }

    public void setFirmwareId(String firmwareId) {
        mFirmwareId = firmwareId;
    }

    public String getSerialNumber() {
        return mSerialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        mSerialNumber = serialNumber;
    }
}
