/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.communicator;

import java.io.Serializable;

import android.content.Context;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 7/5/12
 */
public interface Request extends Serializable {
    String REQUEST_EXTRA = "requestExtra";

    int getRequestId();

    String getRequestType();

    String getRequestTargetServiceAction(Context context);
}
