//
//  BRError.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/22/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_BRError_h
#define bladerunner_ios_sdk_BRError_h

namespace bladerunner
{
    enum BRError
    {
        BRError_Success = 0,
        BRError_NotImplemented = 1,
        
        BRError_FailGetValue = 10,
        BRError_ArrayOutOfBounds = 11,
        BRError_DeviceIsNull = 12,

        BRError_InvalidPacketType = 20,
        BRError_UnknownPacket = 21,
        BRError_UnsupportedEvent = 22,
        BRError_UnsupportedCommand = 23,
        BRError_UnsupportedSetting = 24,
        BRError_ProtocolVersionMismatch = 25,
        BRError_ProtocolVersionNegotiationRejection = 26,

        BRError_PortNotAvailable = 30,
        BRError_DeviceNotOpen = 31,
        BRError_DeviceAlreadyOpen = 32,
        BRError_FailCreateSession = 33,

        BRError_TransactionTimeout = 40,
        BRError_PerformCommandFailure = 41,
        BRError_FetchSettingFailure = 42,
    };
}

#endif
