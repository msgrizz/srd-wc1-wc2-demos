//
//  PacketWithMarshalledData.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/24/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_PacketWithMarshalledData_h
#define bladerunner_ios_sdk_PacketWithMarshalledData_h

#include <vector>
#include "CommonDefinitions.h"

namespace bladerunner
{
    class PacketWithMarshalledData
    {

    public:
        virtual BRError getMarshalledData(std::vector<BRType>& types, std::vector<BRProtocolElement> &result) = 0;
    };
}

#endif
