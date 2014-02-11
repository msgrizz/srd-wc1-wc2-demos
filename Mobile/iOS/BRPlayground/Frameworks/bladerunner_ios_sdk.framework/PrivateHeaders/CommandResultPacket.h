//
//  CommandResultPacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/24/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__CommandResultPacket__
#define __bladerunner_ios_sdk__CommandResultPacket__

#include "InputPacket.h"

namespace bladerunner
{
    class CommandResultPacket : public InputPacket
    {

    public:
        bool operator==(const CommandResultPacket& packet);
        int16_t getCommandID() { return mCommandID; }
        bool isSuccess() { return getMessageType() == PERFORM_COMMAND_RESULT_SUCCESS_MSG; }
        static CommandResultPacket* fromBytes(const std::vector<byte>& packet, PacketType packetType);


    protected:
        CommandResultPacket(int messageType, int16_t commandID);
        int16_t mCommandID;
    };
}

#endif /* defined(__bladerunner_ios_sdk__CommandResultPacket__) */
