//
//  DeviceEventListener.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/13/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_DeviceEventListener_h
#define bladerunner_ios_sdk_DeviceEventListener_h

#include "DeviceEvent.h"

namespace bladerunner
{
    class DeviceEventListener
    {

    public:
        virtual void receiveEvent(DeviceEvent& deviceEvent) = 0;
    };
}

#endif
