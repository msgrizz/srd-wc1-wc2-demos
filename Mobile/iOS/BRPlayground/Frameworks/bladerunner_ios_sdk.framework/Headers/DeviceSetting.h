//
//  DeviceSetting.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/13/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__DeviceSetting__
#define __bladerunner_ios_sdk__DeviceSetting__

#include <iostream>
#include <vector>
#include <mutex>
#include "DeviceSettingType.h"
#include "BRProtocolElement.h"

namespace bladerunner
{
    enum FetchSettingSuccess
    {
        FetchSettingSuccess_Unknown = 0,
        FetchSettingSuccess_Success,
        FetchSettingSuccess_Failure,
    };

    class BladeRunnerDevice;

    class DeviceSetting
    {

    public:
        DeviceSetting(BladeRunnerDevice* device, const DeviceSettingType& type);
        bool operator==(const DeviceSetting& setting);
        DeviceSettingType getType() const { return mType; }
        bool isSet();
        bool isInputSet();
        BRError getValue(BRProtocolElement& value);
        std::vector<BRProtocolElement>& getValues();
        std::vector<BRProtocolElement>& getInputValues();
        void internalSetValue(const std::vector<BRProtocolElement>& value);
        void setInputValue(const std::vector<BRProtocolElement>& value);
        BladeRunnerDevice* getDevice() { return mDevice; }
        int hashCode();
        BRError fetch();
        FetchSettingSuccess isSuccess() { return mSuccess; }
        void setSuccsess(FetchSettingSuccess success) { mSuccess = success; }
        void setExceptionData(int16_t id, std::vector<BRProtocolElement>& data);
        BRError getExceptionData(int16_t& id, std::vector<BRProtocolElement>& data);


    private:
        BladeRunnerDevice* mDevice;
        DeviceSettingType mType;
        bool mSet;
        bool mInputSet;
        std::vector<BRProtocolElement> mValue;
        std::vector<BRProtocolElement> mInputValue;
        std::mutex mLock;
        FetchSettingSuccess mSuccess;
        int16_t mExceptionID;
        std::vector<BRProtocolElement> mExceptionData;
    };
}

#endif /* defined(__bladerunner_ios_sdk__DeviceSetting__) */
