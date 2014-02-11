//
//  HostProtocolNegotiationRejectionPacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/24/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__HostProtocolNegotiationRejectionPacket__
#define __bladerunner_ios_sdk__HostProtocolNegotiationRejectionPacket__

#include "InputPacket.h"

namespace bladerunner
{
    class HostProtocolNegotiationRejectionPacket : public InputPacket
    {

    public:
        HostProtocolNegotiationRejectionPacket();
        HostProtocolNegotiationRejectionPacket(int messageType);

        /**
         * Creates a new HostProtocolNegotiationRejectionPacket from the partial packet in the byte array.
        */
        static HostProtocolNegotiationRejectionPacket* fromBytes(const std::vector<byte>& packet, PacketType packetType);
    };
}

#endif /* defined(__bladerunner_ios_sdk__HostProtocolNegotiationRejectionPacket__) */
