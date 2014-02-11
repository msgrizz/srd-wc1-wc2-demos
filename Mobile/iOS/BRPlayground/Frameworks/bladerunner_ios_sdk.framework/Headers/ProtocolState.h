//
//  ProtocolState.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/23/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_ProtocolState_h
#define bladerunner_ios_sdk_ProtocolState_h

namespace bladerunner
{
    enum ProtocolState
    {
        ProtocolState_Opening,
        ProtocolState_AwaitDeviceProtocolRange,
        ProtocolState_AwaitDeviceMetadata,
        ProtocolState_ConnectionEstablished,
        ProtocolState_AwaitCommandReply,
        ProtocolState_AwaitSettingReply,
        ProtocolState_Closed,
    };
}

#endif
