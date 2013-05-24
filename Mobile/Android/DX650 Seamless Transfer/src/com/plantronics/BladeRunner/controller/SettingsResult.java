/**
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.BladeRunner.controller;

import com.plantronics.headsetdataservice.io.DeviceSetting;
import com.plantronics.headsetdataservice.io.RemoteResult;

public class SettingsResult {

    RemoteResult mResult;
    DeviceSetting mSetting;

    public SettingsResult(RemoteResult result, DeviceSetting setting) {
        mResult = result;
        mSetting = setting;
    }

    public RemoteResult getResult() {
        return mResult;
    }

    public void setResult(RemoteResult result) {
        mResult = result;
    }

    public DeviceSetting getSetting() {
        return mSetting;
    }

    public void setSetting(DeviceSetting setting) {
        mSetting = setting;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof SettingsResult)) {
            return false;
        }

        SettingsResult that = (SettingsResult)o;

        if (mResult != null ? !mResult.equals(that.mResult) : that.mResult != null) {
            return false;
        }
        if (mSetting != null ? !mSetting.equals(that.mSetting) : that.mSetting != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = mResult != null ? mResult.hashCode() : 0;
        result = 31 * result + (mSetting != null ? mSetting.hashCode() : 0);
        return result;
    }

    @Override
    public String toString() {
        return "SettingsResult{" +
                "mResult=" + mResult +
                ", mSetting=" + mSetting +
                '}';
    }
}

