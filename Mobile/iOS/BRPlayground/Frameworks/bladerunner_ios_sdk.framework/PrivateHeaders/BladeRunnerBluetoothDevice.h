//
//  BladeRunnerBluetoothDevice.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/25/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__BladeRunnerBluetoothDevice__
#define __bladerunner_ios_sdk__BladeRunnerBluetoothDevice__

#include <iostream>
#include "BladeRunnerDevice.h"
#include "BlockingQueue.h"
#include "BladeRunnerSessionManager.h"
#include "InputPacket.h"
#include "OutputPacketWithResult.h"

namespace bladerunner
{
    class BladeRunnerBluetoothDevice : public BladeRunnerDevice
    {

    public:
        BladeRunnerBluetoothDevice(const std::string& address);
        virtual std::string& getBladeRunnerDeviceAddress() { return mAddress; }
        virtual BRError open(byte& port);
        virtual BRError open(PacketType packetType, byte& port);
        virtual BRError close();
        virtual BRError perform(DeviceCommand& command, std::vector<BRProtocolElement> args);
        virtual BRError fetch(DeviceSetting& setting);
        virtual bool discoverBladeRunnerDevices(DeviceListener* listener);
        virtual std::set<BladeRunnerDevice*> getBladeRunnerDevices();
        virtual void* getDeviceSession();
        virtual int hashCode();


    protected:
        std::string mAddress;
        std::shared_ptr<BladeRunnerSessionManager> mSessionManager;
        BlockingQueue<InputPacketPtr> mResponseQueue;
        BlockingQueue<OutputPacketWithResultPtr> mRequestQueue;
    };
}

#endif /* defined(__bladerunner_ios_sdk__BladeRunnerBluetoothDevice__) */
