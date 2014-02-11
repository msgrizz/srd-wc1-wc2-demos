//
//  SettingResultPacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/27/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__SettingResultPacket__
#define __bladerunner_ios_sdk__SettingResultPacket__

#include "InputPacket.h"
#include "PacketWithMarshalledData.h"

namespace bladerunner
{
    class SettingResultPacket : public InputPacket, public PacketWithMarshalledData
    {
        
    public:
        bool operator==(const SettingResultPacket& packet);
        int16_t getSettingID() { return mSettingID; }
        std::vector<byte>& getRawMarshalledData() { return mRawMarchalledData; }
        static SettingResultPacket* fromBytes(const std::vector<byte>& packet, PacketType packetType);
        
        virtual BRError getMarshalledData(std::vector<BRType>& types, std::vector<BRProtocolElement> &result);
        virtual int hashCode();


    protected:
        SettingResultPacket(int messageType, int16_t settingID, const std::vector<byte>& marshalledData);
        
        int16_t mSettingID;
        std::vector<byte> mRawMarchalledData;
    };
}

#endif /* defined(__bladerunner_ios_sdk__SettingResultPacket__) */
