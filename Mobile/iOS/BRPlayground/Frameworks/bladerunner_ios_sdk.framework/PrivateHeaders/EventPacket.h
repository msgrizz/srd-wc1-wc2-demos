//
//  EventPacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/24/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__EventPacket__
#define __bladerunner_ios_sdk__EventPacket__

#include "InputPacket.h"
#include "PacketWithMarshalledData.h"

namespace bladerunner
{
    class EventPacket : public InputPacket, public PacketWithMarshalledData
    {

    public:
        bool operator==(const EventPacket& packet);
        int16_t getEventID() { return mEventID; }
        std::vector<byte>& getRawMarshalledData() { return mRawMarchalledData; }
        static EventPacket* fromBytes(const std::vector<byte>& packet, PacketType packetType);

        virtual BRError getMarshalledData(std::vector<BRType>& types, std::vector<BRProtocolElement> &result);
        virtual int hashCode();
        
    private:
        EventPacket(int16_t eventID, const std::vector<byte>& marshalledData);
        
        int16_t mEventID;
        std::vector<byte> mRawMarchalledData;
    };
}

#endif /* defined(__bladerunner_ios_sdk__EventPacket__) */
