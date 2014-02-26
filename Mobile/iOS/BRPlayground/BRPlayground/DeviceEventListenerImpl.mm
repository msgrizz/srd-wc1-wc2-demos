//
//  DeciceEventListenerImpl.cpp
//  TestHarnessApp
//
//  Created by AndreyKozlov on 8/9/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#include "DeviceEventListenerImpl.h"

namespace bladerunner
{
    void DeviceEventListenerImpl::receiveEvent(DeviceEvent& deviceEvent)
    {
        [delegate eventListenerCallBackWithEvent:deviceEvent];
    }
}