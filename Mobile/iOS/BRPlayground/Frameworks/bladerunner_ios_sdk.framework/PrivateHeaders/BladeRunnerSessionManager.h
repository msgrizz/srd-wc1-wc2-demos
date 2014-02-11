//
//  BladeRunnerSessionManager.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/28/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__BladeRunnerSessionManager__
#define __bladerunner_ios_sdk__BladeRunnerSessionManager__

#include <iostream>
#include <vector>
#include <set>
#include <map>
#include "BRError.h"
#include "CommonTypes.h"
#include "BlockingQueue.h"
#include "InputPacket.h"
#include "OutputPacketWithResult.h"

namespace bladerunner
{
    class BladeRunnerDevice;
    class DeviceListener;

    class BladeRunnerSessionManager
    {

    public:
        BladeRunnerSessionManager(BladeRunnerDevice* device, BlockingQueue<OutputPacketWithResultPtr>* requestQueue, BlockingQueue<InputPacketPtr>* responseQueue);
        ~BladeRunnerSessionManager();
        BRError openSession(std::string& address);
        void sendCloseMessage();
        void closeSession();
        void setResponseQueueMap(std::map<byte, BlockingQueue<InputPacketPtr>*>* map);
        static std::set<BladeRunnerDevice*> getBladeRunnerDevices();
        static bool discoverBladerRunnerDevices(DeviceListener* listener);
        void* getSession();


    private:
//        void* impl;
        BladeRunnerDevice* pDevice;
        BlockingQueue<InputPacketPtr>* pDeviceResponseQueue;
        BlockingQueue<OutputPacketWithResultPtr>* pDeviceRequestQueue;
        std::mutex mLock;
    };
}

#endif /* defined(__bladerunner_ios_sdk__BladeRunnerSessionManager__) */
