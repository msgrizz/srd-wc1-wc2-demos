//
//  MetadataListenerImpl.cpp
//  TestHarnessApp
//
//  Created by AndreyKozlov on 7/23/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#include "DeviceMetadataListenerImpl.h"

namespace bladerunner
{
    void DeviceMetadataListenerImpl::metadataReceived(BladeRunnerDevice& device, const std::set<DeviceCommandType>& commands, const std::set<DeviceSettingType>& settings, const std::set<DeviceEventType>& events)
    {
        [delegate metadataListenerCallBackWithCommands:commands Settings:settings Events:events];
    }
}