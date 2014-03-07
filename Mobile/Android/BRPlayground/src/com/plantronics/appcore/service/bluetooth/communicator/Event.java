/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.communicator;

import java.io.Serializable;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 7/5/12
 */
public interface Event extends Serializable {
    /**
     * Returns the type of this event (i.e. ACL_CONNECT, XEVENT_BATTERY ...)
     * @return .
     */
    String getType();
}
