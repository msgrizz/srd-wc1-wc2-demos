/*
 * Copyright 2013 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.general;

import android.util.Log;

import com.plantronics.appcore.debug.CoreLogTag;

public class ClassUtilities {	
	private static final String TAG = CoreLogTag.getGlobalTagPrefix() + "ClassUtilities";
	
	/**
	 * Instantiates an object of a specified class
	 * @param classObject
	 * 		Class of the object that we want to instantiate
	 * @return
	 * 		An object of specifed class or null if exceptions were thrown
	 */
	@SuppressWarnings("rawtypes")
	public static Object fromClass(Class classObject) {
		Object object = null;
		try {		
			object = classObject.newInstance(); 
			
		} catch (IllegalAccessException iae) {
			Log.e(TAG, "Could not allocate an object of class: " + classObject, iae);
		} catch (InstantiationException ie) {
			Log.e(TAG, "Could not allocate an object of class: " + classObject, ie);
		} 
		return object;
	}
}
