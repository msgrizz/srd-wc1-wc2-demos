//
//  MetadataPacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/3/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__MetadataPacket__
#define __bladerunner_ios_sdk__MetadataPacket__

#include <set>
#include "InputPacket.h"
#include "DeviceCommandType.h"
#include "DeviceEventType.h"
#include "DeviceSettingType.h"

namespace bladerunner
{
    class MetadataPacket : public InputPacket
    {

    public:
        bool operator==(const MetadataPacket& packet);
        static MetadataPacket* fromBytes(std::vector<byte>& packet, PacketType packetType);
        std::set<DeviceCommandType>& getCommands() { return mCommands; }
        std::set<DeviceSettingType>& getSettings() { return mSettings; }
        std::set<DeviceEventType>& getEvents() { return mEvents; }
        std::set<byte>& getPorts() { return mPorts; }

        virtual int hashCode();


    private:
        MetadataPacket(const std::set<DeviceCommandType>& commands, const std::set<DeviceSettingType>& settings, const std::set<DeviceEventType>& events, const std::set<byte>& ports);


        std::set<DeviceCommandType> mCommands;
        std::set<DeviceSettingType> mSettings;
        std::set<DeviceEventType> mEvents;
        std::set<byte> mPorts;
    };
}

#endif /* defined(__bladerunner_ios_sdk__MetadataPacket__) */
