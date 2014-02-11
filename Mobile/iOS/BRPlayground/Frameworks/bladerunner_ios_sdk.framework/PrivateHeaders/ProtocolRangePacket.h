//
//  ProtocolRangePacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/3/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__ProtocolRangePacket__
#define __bladerunner_ios_sdk__ProtocolRangePacket__

#include "InputPacket.h"
#include "ProtocolRange.h"

namespace bladerunner
{
    class ProtocolRangePacket : public InputPacket
    {

    public:
        bool operator==(const ProtocolRangePacket& packet);
        static ProtocolRangePacket* fromBytes(std::vector<byte>& packet, PacketType packetType);
        ProtocolRange getProtocolRange() { return mProtocolRange; }

        virtual int hashCode();


    private:
        ProtocolRangePacket(ProtocolRange range);

        ProtocolRange mProtocolRange;
    };
}

#endif /* defined(__bladerunner_ios_sdk__ProtocolRangePacket__) */
