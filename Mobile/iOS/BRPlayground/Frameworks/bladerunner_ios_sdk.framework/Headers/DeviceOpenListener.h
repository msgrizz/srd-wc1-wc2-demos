//
//  DeviceOpenListener.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/13/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_DeviceOpenListener_h
#define bladerunner_ios_sdk_DeviceOpenListener_h

#include "BRError.h"

namespace bladerunner
{
    class BladeRunnerDevice;

    class DeviceOpenListener
    {

    public:
        virtual void deviceOpen(BladeRunnerDevice& device) = 0;
        virtual void openFailed(BladeRunnerDevice& device, BRError error) = 0;
    };
}

#endif
