//
//  DeviceSessionListener.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/13/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_DeviceSessionListener_h
#define bladerunner_ios_sdk_DeviceSessionListener_h

#include "BRError.h"

namespace bladerunner
{
    class BladeRunnerDevice;

    class DeviceSessionListener
    {
        
    public:
        virtual void deviceClose(BladeRunnerDevice& device, BRError error) = 0;
    };
}

#endif
