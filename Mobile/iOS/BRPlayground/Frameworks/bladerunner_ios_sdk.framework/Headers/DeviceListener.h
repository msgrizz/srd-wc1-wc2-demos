//
//  DeviceListener.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/13/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_DeviceListener_h
#define bladerunner_ios_sdk_DeviceListener_h

namespace bladerunner
{
    class BladeRunnerDevice;

    class DeviceListener
    {
        
    public:
        virtual void foundDevice(BladeRunnerDevice& device) = 0;
        virtual void discoveryStopped(bool success) = 0;
    };
}

#endif
