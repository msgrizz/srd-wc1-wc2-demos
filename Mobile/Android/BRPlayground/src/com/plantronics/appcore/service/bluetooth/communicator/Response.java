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
public interface Response extends Serializable {
    String RESPONSE_EXTRA = "responseExtra";

    int getResponseId();

    void setResponseId(int mResponseId);

    String getResponseType();

    /**
     * Addition to behaviour in Cabot project (FindMyHeadset). There we had a workaround for the LocationResponse.
     * It basically returns false if the request will be automatically accepted for processing, and true if the Communicator
     * will first check if it has its ID in its own private Map.
     * @return
     *      Whether the IDs will be preserved from the time the request is sent until the time the response is received.
     */
    boolean hasStableId();
}
