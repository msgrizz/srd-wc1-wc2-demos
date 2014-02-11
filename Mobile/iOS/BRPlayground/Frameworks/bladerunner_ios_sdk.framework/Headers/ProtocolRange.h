//
//  ProtocolRange.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/28/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_ProtocolRange_h
#define bladerunner_ios_sdk_ProtocolRange_h

#include "CommonDefinitions.h"

namespace bladerunner
{
    struct ProtocolRange
    {
        byte minVersion;
        byte maxVersion;
        
        bool operator==(const ProtocolRange& range)
        {
            return minVersion == range.minVersion && maxVersion == range.maxVersion;
        }

        int hashCode()
        {
            return 17 * minVersion + 31 * maxVersion;
        }
    };
}

#endif
