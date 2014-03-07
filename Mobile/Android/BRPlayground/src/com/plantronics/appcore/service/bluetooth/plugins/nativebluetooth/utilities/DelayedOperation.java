/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities;

import android.util.Log;

import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

/**
* Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
* Date: 5/22/12
*/
abstract class DelayedOperation {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + DelayedOperation.class.getSimpleName();
    private boolean mExecuted = false;


    /**
     *
     * @return if true proceed, if false stop
     */
    public boolean execute(){
        if (!isExecuted()){
            setExecuted(true);
            return true;
        } else {
            Log.d(TAG, "Operation already executed" + Integer.toHexString(this.hashCode()));
            return false;
        }
    }

    public boolean isExecuted() {
        return mExecuted;
    }

    public void setExecuted(boolean executed) {
        this.mExecuted = executed;
    }
}
