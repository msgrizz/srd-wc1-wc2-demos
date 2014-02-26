//
//  DeviceListenerImpl.cpp
//  TestHarnessApp
//
//  Created by AndreyKozlov on 6/21/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#include "DeviceListenerImpl.h"

namespace bladerunner
{    
    void DeviceListenerImpl::foundDevice(BladeRunnerDevice &device)
    {
        deviceCount++;
        
        [delegate listenerFoundDevice:device];
    }
    
    void DeviceListenerImpl::discoveryStopped(bool success)
    {
        //[(id)delegate setValue:[NSNumber numberWithInt:deviceCount] forKey:@"deviceCount"];
        //[delegate listenerCallBackWithSuccess:success];
        
        [delegate listenerDiscoveryStopped:success];
    }
}