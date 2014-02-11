//
//  BladeRunnerDeviceManager.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/5/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__BladeRunnerDeviceManager__
#define __bladerunner_ios_sdk__BladeRunnerDeviceManager__

#include <mutex>
#include <iostream>
#include <set>
#include "BRError.h"
#include "CommonTypes.h"
#include "BladeRunnerDevice.h"
#include "SignatureDefinitions.h"

namespace bladerunner
{
    class DeviceListener;

    class BladeRunnerDeviceManager
    {

    public:
        static BladeRunnerDeviceManager* getManager();
        BladeRunnerDevice* newDevice(std::string address);
        BRError newDevice(BladeRunnerDevice& remoteDevice, byte port, BladeRunnerDevice** newDevice);
        bool discoverBladeRunnerDevices(DeviceListener* listener);
        std::set<BladeRunnerDevice*> getBladeRunnerDevices();
        void removeBladeRunnerDevice(BladeRunnerDevice* device);


    private:
        BladeRunnerDeviceManager();

        static BladeRunnerDeviceManager* sInstance;
        static std::recursive_mutex sLock;
        std::set<BladeRunnerDevicePtr> mDeviceSet;
        BladeRunnerDevicePtr mLocalBladeRunnerDevice;
    };
}

#endif /* defined(__bladerunner_ios_sdk__BladeRunnerDeviceManager__) */
