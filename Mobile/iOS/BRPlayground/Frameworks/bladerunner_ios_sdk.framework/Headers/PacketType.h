//
//  PacketType.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/23/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_PacketType_h
#define bladerunner_ios_sdk_PacketType_h

#include "CommonDefinitions.h"

namespace bladerunner
{
    enum PacketType
    {
        PacketType_AddressBased = (byte)0x1,
        PacketType_PointToPoint = (byte)0x2,
    };
}

#endif
