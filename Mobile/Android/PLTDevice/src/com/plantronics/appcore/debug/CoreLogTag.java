/*
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.debug;

import android.util.Log;

public class CoreLogTag {
	
	private static final String CORE_LOG_TAG = "Core";

    /**     
     * @return
     * 	The prefix to each log tag that corresponds to the app name
     */
    public static String getGlobalTagPrefix() {
        return CORE_LOG_TAG;
    }

    /**
     * Forms a final log tag based on the class
     * @param object
     *      The caller object
     * @return
     *      The Tag String
     */
    public static String getTag(Object object) {
        return getGlobalTagPrefix() + object.getClass().getSimpleName();
    }

    /**
     * The method that calls {@link Log#d(String, String)} using the class name as the log tag}
     * @param object
     * 		The object that is calling this method
     * @param string
     * 		The  message string that should be logged
     */
    public static void d(Object object, String string) {
        Log.d(getTag(object), string);
    }
    
    /**
     * The method that calls {@link Log#i(String, String)} using the class name as the log tag}
     * @param object
     * 		The object that is calling this method
     * @param string
     * 		The  message string that should be logged
     */
    public static void i(Object object, String string) {
        Log.i(getTag(object), string);
    }
    
    /**
     * The method that calls {@link Log#w(String, String)} using the class name as the log tag}
     * @param object
     * 		The object that is calling this method
     * @param string
     * 		The  message string that should be logged
     */
    public static void w(Object object, String string) {
        Log.w(getTag(object), string);
    }
    
    /**
     * The method that calls {@link Log#e(String, String)} using the class name as the log tag}
     * @param object
     * 		The object that is calling this method
     * @param string
     * 		The  message string that should be logged
     */
    public static void e(Object object, String string) {
        Log.e(getTag(object), string);
    }
    
    /**
     * The method that calls {@link Log#v(String, String)} using the class name as the log tag}
     * @param object
     * 		The object that is calling this method
     * @param string
     * 		The  message string that should be logged
     */
    public static void v(Object object, String string) {
        Log.v(getTag(object), string);
    }
    
    /**
     * The method that calls {@link Log#w(String, String, Throwable)} using the class name as the log tag}
     * @param object
     * 		The object that is calling this method
     * @param string
     * 		The  message string that should be logged
     * @param throwable
     * 		The throwable whose stack trace will be printed out to the log
     */
    public static void w(Object object, String string, Throwable throwable) {
        Log.w(getTag(object), string);
    }
    
    /**
     * The method that calls {@link Log#e(String, String, Throwable)} using the class name as the log tag}
     * @param object
     * 		The object that is calling this method
     * @param string
     * 		The  message string that should be logged
     * @param throwable
     * 		The throwable whose stack trace will be printed out to the log
     */
    public static void e(Object object, String string, Throwable throwable) {
        Log.e(getTag(object), string);
    }

}
