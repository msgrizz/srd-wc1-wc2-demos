//
//  DeviceSettingType.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/3/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_DeviceSettingType_h
#define bladerunner_ios_sdk_DeviceSettingType_h

#include "DeviceEntityType.h"

namespace bladerunner
{
    class DeviceSettingType : public DeviceEntityType
    {
        
    public:
        DeviceSettingType(int16_t id) : DeviceEntityType(id) {}
        virtual int hashCode() { return mID; }
    };
}

#endif
