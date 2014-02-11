//
//  HostProtocolVersionPacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/27/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__HostProtocolVersionPacket__
#define __bladerunner_ios_sdk__HostProtocolVersionPacket__

#include "OutputPacketWithResult.h"
#include "ProtocolRange.h"

namespace bladerunner
{
    class HostProtocolVersionPacket : public OutputPacketWithResult
    {

    public:
        HostProtocolVersionPacket(ProtocolRange range, PacketType type);
        bool operator==(const HostProtocolVersionPacket& packet);

        virtual void write(std::vector<byte>& packet);
        virtual ProtocolState nextState() { return ProtocolState_AwaitDeviceProtocolRange; }
        virtual int hashCode();


    private:
        ProtocolRange mRange;
    };
}

#endif /* defined(__bladerunner_ios_sdk__HostProtocolVersionPacket__) */
