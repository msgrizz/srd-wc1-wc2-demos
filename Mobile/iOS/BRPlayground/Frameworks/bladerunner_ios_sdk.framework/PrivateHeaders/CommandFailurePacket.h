//
//  CommandFailurePacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/27/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__CommandFailurePacket__
#define __bladerunner_ios_sdk__CommandFailurePacket__

#include "CommandResultPacket.h"
#include "PacketWithMarshalledData.h"

namespace bladerunner
{
    class CommandFailurePacket : public CommandResultPacket, public PacketWithMarshalledData
    {

    public:
        bool operator==(const CommandFailurePacket& packet);
        int16_t getExceptionType() { return mExceptionType; }
        std::vector<byte>& getRawMarshalledData() { return mRawMarchalledData; }
        static CommandFailurePacket* fromBytes(const std::vector<byte> &packet, bladerunner::PacketType packetType);

        virtual BRError getMarshalledData(std::vector<BRType>& types, std::vector<BRProtocolElement> &result);
        virtual int hashCode();

    private:
        CommandFailurePacket(int16_t commandID, int16_t exceptionType, const std::vector<byte>& rawMarshalledData);


        std::vector<byte> mRawMarchalledData;
        int16_t mExceptionType;
    };
}

#endif /* defined(__bladerunner_ios_sdk__CommandFailurePacket__) */
