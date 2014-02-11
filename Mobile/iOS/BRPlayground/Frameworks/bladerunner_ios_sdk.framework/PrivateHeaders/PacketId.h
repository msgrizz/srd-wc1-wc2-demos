//
//  PacketId.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/28/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_PacketId_h
#define bladerunner_ios_sdk_PacketId_h

namespace bladerunner
{
    enum PacketId
    {
        PacketId_Unknown = 0,
        PacketId_Packet = 1,
        PacketId_InputPacket = 2,
        PacketId_OutputPacket = 3,

        PacketId_ProtocolRange = 100,
        PacketId_SettingResult = 101,
        PacketId_SettingFailure = 102,
        PacketId_CommandResult = 103,
        PacketId_CommandFailure = 104,
        PacketId_Metadata = 105,
        PacketId_Event = 106,
        PacketId_HostProtocolNegotiationRejection = 107,

        PacketId_CloseSession = 200,
        PacketId_Command = 201,
        PacketId_GetSetting = 202,
        PacketId_HostProtocolVersion = 203,
    };
}

#endif
