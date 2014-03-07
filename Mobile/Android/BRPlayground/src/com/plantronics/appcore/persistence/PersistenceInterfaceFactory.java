package com.plantronics.appcore.persistence;
/*
* Copyright 2012 Plantronics, Inc.  All rights reserved.
* This code is confidential and proprietary information belonging
* to Plantronics, Inc. and may not be copied, modified or distributed
* without the express written consent of Plantronics, Inc.
*
* Created by: Zivorad Baralic
* Date: 11/5/12
*/

/**
 * The static factory class for obtaining {@link PersistenceInterface} implementations
 */

public class PersistenceInterfaceFactory {

    private static PersistenceInterface sInstance;

    /**
     * Static-factory method for retrieving a PersistenceInterface object
     * @return
     *      The PersistenceInterface object to work with
     */
    public static PersistenceInterface get() {
        if (sInstance == null) {
            sInstance = new SharedPreferencesPersistence();
        }
        return sInstance;
    }
}

