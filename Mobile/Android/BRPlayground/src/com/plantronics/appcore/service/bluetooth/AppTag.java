package com.plantronics.appcore.service.bluetooth;

import android.content.Context;

public class AppTag {

	/**
	 * @param applicationContext
	 * 		The surrounding application's context
	 * @return
     * 		The package identifier of the surrounding particular app     
     */
    public static String getPackageName(Context applicationContext) {
		return applicationContext.getPackageName();    	
    }
}
