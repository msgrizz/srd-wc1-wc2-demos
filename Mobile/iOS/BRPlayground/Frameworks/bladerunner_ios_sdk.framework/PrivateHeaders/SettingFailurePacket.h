//
//  SettingFailurePacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/27/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__SettingFailurePacket__
#define __bladerunner_ios_sdk__SettingFailurePacket__

#include "SettingResultPacket.h"

namespace bladerunner
{
    class SettingFailurePacket : public SettingResultPacket
    {
        
    public:
        bool operator==(const SettingFailurePacket& packet);
        int16_t getExceptionType() { return mExceptionType; }
        static SettingFailurePacket* fromBytes(const std::vector<byte>& packet, PacketType packetType);
        
        virtual int hashCode();
        
        
    private:
        SettingFailurePacket(int messageType, int16_t settingID, int16_t exceptionType, const std::vector<byte>& marshalledData);
        
        int16_t mExceptionType;
    };
}

#endif /* defined(__bladerunner_ios_sdk__SettingFailurePacket__) */
