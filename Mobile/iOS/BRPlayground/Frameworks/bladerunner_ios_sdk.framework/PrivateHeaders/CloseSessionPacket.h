//
//  CloseSessionPacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/28/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__CloseSessionPacket__
#define __bladerunner_ios_sdk__CloseSessionPacket__

#include "OutputPacketWithResult.h"

namespace bladerunner
{
    class CloseSessionPacket : public OutputPacketWithResult
    {

    public:
        CloseSessionPacket(PacketType type);
        
        virtual void write(std::vector<byte>& packet);
        virtual ProtocolState nextState() { return ProtocolState_Closed; }
    };
}

#endif /* defined(__bladerunner_ios_sdk__CloseSessionPacket__) */
