/*
* Copyright 2012 Plantronics, Inc.  All rights reserved.
* This code is confidential and proprietary information belonging
* to Plantronics, Inc. and may not be copied, modified or distributed
* without the express written consent of Plantronics, Inc.
*
* Created by: Zivorad Baralic
* Date: 11/5/12
*/

package com.plantronics.appcore.persistence;
import com.plantronics.appcore.debug.CoreLogTag;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * The implementation of the PersistenceInterface by using the {@link SharedPreferences} class
 */

public class SharedPreferencesPersistence implements PersistenceInterface {

    private static final String TAG = CoreLogTag.getGlobalTagPrefix() + SharedPreferencesPersistence.class.getSimpleName();

    /**
     * The name of the Shared Preferences file
     */
    private static final String NAME_OF_SHARED_PREFERENCES_FILE = "com.plantronics.widget.ion.SharedPreferences";

    private static SharedPreferences get(Context context) {
        return context.getSharedPreferences(NAME_OF_SHARED_PREFERENCES_FILE, Context.MODE_PRIVATE);
    }

    private static SharedPreferences.Editor edit(Context context) {
        return get(context).edit();
    }

    // Implementation ==================================================================================================

    @Override
    public void putString(Context context, String key, String value) {
        SharedPreferences.Editor editor = edit(context);
        editor.putString(key, value);
        editor.commit();
    }

    @Override
    public String getString(Context context, String key, String defaultValueToReturnIfValueNotFound) {
        return get(context).getString(key, defaultValueToReturnIfValueNotFound);
    }

    @Override
    public void putInt(Context context, String key, int value) {
        SharedPreferences.Editor editor = edit(context);
        editor.putInt(key, value);
        editor.commit();
    }

    @Override
    public int getInt(Context context, String key, int defaultValueToReturnIfValueNotFound) {
        return get(context).getInt(key, defaultValueToReturnIfValueNotFound);
    }

    @Override
    public void putLong(Context context, String key, long value) {
        SharedPreferences.Editor editor = edit(context);
        editor.putLong(key, value);
        editor.commit();
    }

    @Override
    public long getLong(Context context, String key, long defaultValueToReturnIfValueNotFound) {
        return get(context).getLong(key, defaultValueToReturnIfValueNotFound);
    }

    @Override
    public void putBoolean(Context context, String key, boolean value) {
        SharedPreferences.Editor editor = edit(context);
        editor.putBoolean(key, value);
        editor.commit();
    }

    @Override
    public boolean getBoolean(Context context, String key, boolean defaultValueToReturnIfValueNotFound) {
        return get(context).getBoolean(key, defaultValueToReturnIfValueNotFound);
    }

    @Override
    public boolean contains(Context context, String key) {
        return get(context).contains(key);
    }

    @Override
    public void remove(Context context, String key) {
        SharedPreferences.Editor editor = edit(context);
        editor.remove(key);
        editor.commit();
    }
}
