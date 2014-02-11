//
//  Timeouts.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 7/16/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_Timeouts_h
#define bladerunner_ios_sdk_Timeouts_h

/**
 * If the device does not respond to connection open request,  time out and reset the state machine
 */
#define CONNECTION_OPEN_TIMEOUT_MSEC (uint64_t)14000

/**
 * If the device does not respond to a request within this period of time, consider it dead and disconnect.
 */
#define TRANSACTION_TIMEOUT_MSEC (uint64_t)8000

/**
 * timeout interval for the discovery process to end
 */
#define DISCOVERY_STOP_TIMEOUT (uint64_t)10000

#endif
