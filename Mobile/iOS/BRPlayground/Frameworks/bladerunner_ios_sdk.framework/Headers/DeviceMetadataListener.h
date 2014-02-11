//
//  DeviceMetadataListener.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/13/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_DeviceMetadataListener_h
#define bladerunner_ios_sdk_DeviceMetadataListener_h

#include <set>
#include "DeviceCommandType.h"
#include "DeviceEventType.h"
#include "DeviceSettingType.h"

namespace bladerunner
{
    class BladeRunnerDevice;

    class DeviceMetadataListener
    {
        
    public:
        virtual void metadataReceived(BladeRunnerDevice& device, const std::set<DeviceCommandType>& commands, const std::set<DeviceSettingType>& settings, const std::set<DeviceEventType>& events) = 0;
    };
}

#endif
