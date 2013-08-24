//
//  WebSocketTest1-Defines.h
//  WebSocketTest1
//
//  Created by Antony Bayley on 25/04/2012.
//  Copyright (c) 2012 Plantronics Limited. All rights reserved.
//

// This file contains application helper definitions and macros

#ifndef BLE_Scanner_BLEScannerDefines_h
#define BLE_Scanner_BLEScannerDefines_h


// Control debug printing of NSLog messages by defining DEBUG_PRINT_ENABLED,
// either in the project's preprocessor macro configuration settings or by
// #define statements in individual files.

#if (DEBUG_PRINT_ENABLED == 1)
#define debugLog(...) NSLog(__VA_ARGS__)
#define debugPrintf(...) printf(__VA_ARGS__)
#else
#define debugLog(...) do {} while (0)     // optimized out by the compiler
#define debugPrintf(...) do {} while (0)  // optimized out by the compiler
#endif

#endif
