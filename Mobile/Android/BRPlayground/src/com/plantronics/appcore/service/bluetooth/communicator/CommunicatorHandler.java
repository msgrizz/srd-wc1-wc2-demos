/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.appcore.service.bluetooth.communicator;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 4/11/12
 */
public interface CommunicatorHandler {

    boolean isHandling(String origin);

    void startHandler(Object message);

    void addParentCommunicator(Communicator communicator);

    /**
     * Called inside its Communicator's onResume().
     * Override to add behaviour.
     */
    void onResume();

    /**
     * Called inside its Communicator's onPause().
     * Override to add behaviour.
     */
    void onPause();
}
