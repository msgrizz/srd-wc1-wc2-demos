//
//  DeviceCommandType.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/3/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_DeviceCommandType_h
#define bladerunner_ios_sdk_DeviceCommandType_h

#include "DeviceEntityType.h"

namespace bladerunner
{
    class DeviceCommandType : public DeviceEntityType
    {
        
    public:
        DeviceCommandType(int16_t id) : DeviceEntityType(id) {}
        virtual int hashCode() { return mID; }
    };
}

#endif
