//
//  GetSettingPacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/28/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__GetSettingPacket__
#define __bladerunner_ios_sdk__GetSettingPacket__

#include "OutputPacketWithResult.h"

namespace bladerunner
{
    class GetSettingPacket : public OutputPacketWithResult
    {

    public:
        GetSettingPacket(int16_t settingID, const std::vector<BRProtocolElement>& objects);
        bool operator==(const GetSettingPacket& packet);
        
        virtual void write(std::vector<byte>& packet);
        virtual ProtocolState nextState() { return ProtocolState_AwaitSettingReply; }
        virtual int hashCode();


    private:
        int16_t mSettingID;
        std::vector<BRProtocolElement> data;
    };
}

#endif /* defined(__bladerunner_ios_sdk__GetSettingPacket__) */
