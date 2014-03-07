package com.plantronics.appcore.service.bluetooth.utilities.log;

import com.plantronics.appcore.debug.CoreLogTag;
import com.plantronics.appcore.service.bluetooth.BluetoothManagerService;

public class LogTag {

    private static final String TAG_PREFIX = CoreLogTag.getGlobalTagPrefix() + "Bms";

    public static String getBluetoothPackageTagPrefix() {
        return TAG_PREFIX;
    }
}
