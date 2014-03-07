package com.plantronics.appcore.persistence; /*
* Copyright 2012 Plantronics, Inc.  All rights reserved.
* This code is confidential and proprietary information belonging
* to Plantronics, Inc. and may not be copied, modified or distributed
* without the express written consent of Plantronics, Inc.
*
* Created by: Zivorad Baralic
* Date: 11/5/12
*/

import android.content.Context;

/**
 * The interface for persistent storage classes (shared preferences implementation or similar)
 */
public interface PersistenceInterface {

    /**
     * Puts a String into persistent storage
     * @param context
     *      The surrounding Context
     * @param key
     *      The key for later retrieving of the value
     * @param value
     *      The String value to be kept in storage
     */
    void putString(Context context, String key, String value);

    /**
     * Retrieves a String from the persistent storage
     * @param context
     *      The surrounding Context
     * @param key
     *      The key that matches the desired value we want to retrieve
     * @param defaultValueToReturnIfValueNotFound
     *      The value to return if no matched value for the specified key was found in persistent storage
     * @return
     *      The desired String value for the given key
     */
    String getString(Context context, String key, String defaultValueToReturnIfValueNotFound);

    /**
     * Puts an integer into persistent storage
     * @param context
     *      The surrounding Context
     * @param key
     *      The key for later retrieving of the value
     * @param value
     *      The integer value to be kept in storage
     */
    void putInt(Context context, String key, int value);

    /**
     * Retrieves an integer from the persistent storage
     * @param context
     *      The surrounding Context
     * @param key
     *      The key that matches the desired value we want to retrieve
     * @param defaultValueToReturnIfValueNotFound
     *      The value to return if no matched value for the specified key was found in persistent storage
     * @return
     *      The desired integer value for the given key
     */
    int getInt(Context context, String key, int defaultValueToReturnIfValueNotFound);

    /**
     * Removes a value that corresponds to the specified key in persistent storage
     * @param context
     *      The surrounding Context
     * @param key
     *      The key whose matching value we're removing
     */
    void remove(Context context, String key);

    /**
     * Puts an long into persistent storage
     * @param context
     *      The surrounding Context
     * @param key
     *      The key for later retrieving of the value
     * @param value
     *      The long value to be kept in storage
     */
    void putLong(Context context, String key, long value);


    /**
     * Retrieves an long from the persistent storage
     * @param context
     *      The surrounding Context
     * @param key
     *      The key that matches the desired value we want to retrieve
     * @param defaultValueToReturnIfValueNotFound
     *      The value to return if no matched value for the specified key was found in persistent storage
     * @return
     *      The desired long value for the given key
     */
    long getLong(Context context, String key, long defaultValueToReturnIfValueNotFound);

    /**
     * Puts an boolean into persistent storage
     * @param context
     *      The surrounding Context
     * @param key
     *      The key that matches the desired value we want to retrieve
     * @param value
     *      The boolean value to be kept in storage
     */
    void putBoolean(Context context, String key, boolean value);

    /**
     * Retrieves an boolean from the persistent storage
     * @param context
     *      The surrounding Context
     * @param key
     *      The key that matches the desired value we want to retrieve
     * @param defaultValueToReturnIfValueNotFound
     *      The value to return if no matched value for the specified key was found in persistent storage
     * @return
     *      The desired boolean value for the given key
     */
    boolean getBoolean(Context context, String key, boolean defaultValueToReturnIfValueNotFound);


    /**
     * Tests if a value that corresponds to the specified key is present in persistent storage
     * @param context
     *      The surrounding Context
     * @param key
     *      The key for later retrieving of the value
     * @return
     *      The boolean value that is outcome of test operation
     */
    boolean contains(Context context, String key);
}
