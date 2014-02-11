//
//  DeviceCommand.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/13/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__DeviceCommand__
#define __bladerunner_ios_sdk__DeviceCommand__

#include <iostream>
#include <vector>
#include <mutex>
#include "DeviceCommandType.h"
#include "BRProtocolElement.h"

namespace bladerunner
{
    enum PerformCommandSuccess
    {
        PerformCommandSuccess_Unknown = 0,
        PerformCommandSuccess_Success,
        PerformCommandSuccess_Failure
    };

    class BladeRunnerDevice;

    class DeviceCommand
    {

    public:
        DeviceCommand(BladeRunnerDevice* device, const DeviceCommandType& type);
        bool operator==(const DeviceCommand& command);
        DeviceCommandType getType() const { return mType; }
        int hashCode();
        BRError perform(std::vector<BRProtocolElement> args);
        PerformCommandSuccess isSuccess() { return mSuccess; }
        void setSuccsess(PerformCommandSuccess success) { mSuccess = success; }
        void setExceptionData(int16_t id, std::vector<BRProtocolElement>& data);
        BRError getExceptionData(int16_t& id, std::vector<BRProtocolElement>& data);


    private:
        BladeRunnerDevice* mDevice;
        DeviceCommandType mType;
        std::vector<BRProtocolElement> mExceptionData;
        std::mutex mLock;
        PerformCommandSuccess mSuccess;
        int16_t mExceptionID;
    };
}

#endif /* defined(__bladerunner_ios_sdk__DeviceCommand__) */
