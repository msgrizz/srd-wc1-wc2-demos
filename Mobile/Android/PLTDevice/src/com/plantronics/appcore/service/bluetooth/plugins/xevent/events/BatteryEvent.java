/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.plugins.xevent.events;

import android.bluetooth.BluetoothDevice;

import com.plantronics.appcore.service.bluetooth.plugins.xevent.XEventBluetoothPluginHandler;
import com.plantronics.appcore.service.bluetooth.plugins.xevent.utilities.XEventType;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 5/15/12
 */
public class BatteryEvent  extends XEvent {

    ///
    //// Battery level
    ///

    public static final String BATTERY = "BATTERY";

    public static final int NUM_BATTERY_ARGS = 5;

    public static final String CHARGE_LEVEL_EXTRA = "CHARGE_LEVEL";

    public static final String NUM_CHARGE_LEVELS_EXTRA = "NUM_CHARGE_LEVELS";

    public static final String TALK_TIME_MINUTES_REMAINING_EXTRA = "TALK_TIME_MINUTES_REMAINING_EXTRA";

    public static final String HEADSET_IS_CHARGING_EXTRA = "HEADSET_IS_CHARGING_EXTRA";


    private int mLevel;
    private int mNumberOfLevels;
    private int mMinutesOfTalkTime;
    private boolean isCharging;

    public BatteryEvent(BluetoothDevice bluetoothDevice, Object[] args){
        this(bluetoothDevice, (Integer) args[0], (Integer) args[1], (Integer) args[2], (1==((Integer) args[3])) );
    }


    public BatteryEvent(BluetoothDevice bluetoothDevice,
                        int mLevel,
                        int mNumberOfLevels,
                        int mMinutesOfTalkTime,
                        boolean charging) {
        mBluetoothDevice = bluetoothDevice;
        this.mLevel = mLevel;
        this.mNumberOfLevels = mNumberOfLevels;
        this.mMinutesOfTalkTime = mMinutesOfTalkTime;
        isCharging = charging;
    }



    @Override
    public String getEventPluginHandlerName() {
        return XEventBluetoothPluginHandler.PLUGIN_NAME;
    }

    @Override
    public String getType() {
        return XEventType.BATTERY.toString();
    }

    public int getLevel() {
        return mLevel;
    }

    public void setLevel(int mLevel) {
        this.mLevel = mLevel;
    }

    public int getNumberOfLevels() {
        return mNumberOfLevels;
    }

    public void setNumberOfLevels(int mNumberOfLevels) {
        this.mNumberOfLevels = mNumberOfLevels;
    }

    public int getMinutesOfTalkTime() {
        return mMinutesOfTalkTime;
    }

    public void setMinutesOfTalkTime(int mMinutesOfTalkTime) {
        this.mMinutesOfTalkTime = mMinutesOfTalkTime;
    }

    public boolean isCharging() {
        return isCharging;
    }

    public void setCharging(boolean charging) {
        isCharging = charging;
    }

    @Deprecated
    public static int getBatteryLevelIconIndex(int currentLevel, int numIcons, int numLevels) {
        float conversionFactor = (float)numIcons / (float)numLevels;
        int result = Math.round(conversionFactor * (currentLevel + 1)) - 1;
        return result;
    }

    /**
     * Code copied from MyHeadset app. Does the percentage = 100% * level / (numLevels - 1) calculation.
     * <p>numLevels - 1 is there because of the zero level, it is actually a redundant one, to display only the
     * completely discharged headset.
     *
     * @param currentLevel
     *      The current level of the headset's battery
     * @param numLevels
     *      The maximum number of levels of headset's battery
     * @return
     *      The battery level converted to percentages 0 - 100%
     */
    public static int getBatteryPercentage(int currentLevel, int numLevels) {
        float fraction = currentLevel / (float) (numLevels - 1);
        return Math.round(100f * fraction);
    }
}
