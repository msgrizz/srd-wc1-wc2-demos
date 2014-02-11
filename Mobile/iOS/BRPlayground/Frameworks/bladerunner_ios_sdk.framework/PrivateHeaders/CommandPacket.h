//
//  CommandPacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/31/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__CommandPacket__
#define __bladerunner_ios_sdk__CommandPacket__

#include "OutputPacketWithResult.h"

namespace bladerunner
{
    class CommandPacket : public OutputPacketWithResult
    {
        
    public:
        CommandPacket(int16_t commandID, const std::vector<BRProtocolElement>& objects);
        bool operator==(const CommandPacket& packet);
        
        virtual void write(std::vector<byte>& packet);
        virtual ProtocolState nextState() { return ProtocolState_AwaitCommandReply; }
        virtual int hashCode();
        
        
    private:
        int16_t mCommandID;
        std::vector<BRProtocolElement> data;
    };
}

#endif /* defined(__bladerunner_ios_sdk__CommandPacket__) */
