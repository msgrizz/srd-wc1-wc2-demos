//
//  DeviceOpenListenerImpl.cpp
//  TestHarnessApp
//
//  Created by AndreyKozlov on 7/1/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#include "DeviceOpenListenerImpl.h"
#include "bladerunner_ios_sdk/BladeRunnerDevice.h"
#include <Foundation/Foundation.h>

namespace bladerunner
{
    void DeviceOpenListenerImpl::deviceOpen(BladeRunnerDevice &device)
    {
        [delegate openListenerCallBackWithError:BRError_Success];
    }
    
    void DeviceOpenListenerImpl::openFailed(BladeRunnerDevice &device, BRError error)
    {
        [delegate openListenerCallBackWithError:error];
    }
}
