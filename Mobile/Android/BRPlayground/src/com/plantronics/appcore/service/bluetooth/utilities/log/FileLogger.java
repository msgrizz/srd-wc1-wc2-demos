/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.utilities.log;

import android.os.Environment;
import android.util.Log;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 7/25/12
 */
public class FileLogger {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + FileLogger.class.getSimpleName();


    public static final String EVENT_LOCATION_LOG = "BluetoothManagerServiceEvents.log";
    public static final String GENERAL = "BluetoothManagerServiceGeneral.log";


    public static void appendLog(String text, String fileName)
    {
        File logFile = new File(Environment.getExternalStorageDirectory() + File.separator + fileName);
        Log.i(TAG, "Logging to : " + Environment.getExternalStorageDirectory() + File.separator + fileName);
        if (!logFile.exists())
        {
            try
            {
                logFile.createNewFile();
            }
            catch (IOException e)
            {
                Log.w(TAG, "", e);
            }
        }
        try
        {
            //BufferedWriter for performance, true to set append to file flag
            BufferedWriter buf = new BufferedWriter(new FileWriter(logFile, true));
            buf.append((new Date()).toLocaleString() + " " + text);
            buf.newLine();
            buf.close();
        }
        catch (IOException e)
        {
            Log.w(TAG, "", e);
        }
    }



}
