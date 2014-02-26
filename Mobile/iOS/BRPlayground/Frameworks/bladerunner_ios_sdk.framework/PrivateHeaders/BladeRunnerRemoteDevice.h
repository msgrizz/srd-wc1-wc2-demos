//
//  BladeRunnerRemoteDevice.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/27/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__BladeRunnerRemoteDevice__
#define __bladerunner_ios_sdk__BladeRunnerRemoteDevice__

#include "BladeRunnerDevice.h"
#include "BlockingQueue.h"
#include "BladeRunnerRemoteSessionManager.h"
#include "InputPacket.h"
#include "OutputPacketWithResult.h"

namespace bladerunner
{
    class BladeRunnerRemoteDevice : public BladeRunnerDevice
    {
        
    public:
        BladeRunnerRemoteDevice(BladeRunnerDevice* currentDevice, byte port);
        virtual std::string& getBladeRunnerDeviceAddress();
        virtual BRError open(byte& port);
        virtual BRError openOnPort(byte port);
        virtual BRError open(PacketType packetType, byte& port);
        virtual BRError close();
        virtual BRError perform(DeviceCommand& command, std::vector<BRProtocolElement> args);
        virtual BRError fetch(DeviceSetting& setting);
        virtual bool discoverBladeRunnerDevices(DeviceListener* listener);
        virtual std::set<BladeRunnerDevice*> getBladeRunnerDevices();
        virtual void* getDeviceSession();
        virtual int hashCode();
        
        
    protected:
        BladeRunnerDevice* mConnectorDevice;
        byte mPort;
        std::shared_ptr<BladeRunnerRemoteSessionManager> mSessionManager;
        BlockingQueue<InputPacketPtr> mResponseQueue;
        BlockingQueue<OutputPacketWithResultPtr> mRequestQueue;
    };
}

#endif /* defined(__bladerunner_ios_sdk__BladeRunnerRemoteDevice__) */
