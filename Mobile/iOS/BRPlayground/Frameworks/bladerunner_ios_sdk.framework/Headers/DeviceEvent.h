//
//  DeviceEvent.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/13/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__DeviceEvent__
#define __bladerunner_ios_sdk__DeviceEvent__

#include <iostream>
#include "DeviceEventType.h"
#include "BRProtocolElement.h"

namespace bladerunner
{
    class DeviceEvent
    {

    public:
        DeviceEvent(DeviceEventType& eventType, std::vector<BRProtocolElement>& data);
        std::vector<BRProtocolElement>& getEventData() { return mData; }
        DeviceEventType getType() const { return mType; }


    private:
        std::vector<BRProtocolElement> mData;
        DeviceEventType mType;
    };
}

#endif /* defined(__bladerunner_ios_sdk__DeviceEvent__) */
