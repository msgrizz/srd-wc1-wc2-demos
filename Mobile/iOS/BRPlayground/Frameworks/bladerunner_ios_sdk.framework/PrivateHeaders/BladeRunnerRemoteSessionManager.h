//
//  BladeRunnerRemoteSessionManager.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 8/5/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__BladeRunnerRemoteSessionManager__
#define __bladerunner_ios_sdk__BladeRunnerRemoteSessionManager__

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
    class BladeRunnerRemoteSessionManager
    {

    public:
        BladeRunnerRemoteSessionManager(BladeRunnerDevice* device, BlockingQueue<OutputPacketWithResultPtr>* requestQueue, BlockingQueue<InputPacketPtr>* responseQueue, void* session);
        ~BladeRunnerRemoteSessionManager();
        BRError openSession(byte port);
        void sendCloseMessage();
        void closeSession();
        void* getSession();
        
        
    private:
        //        void* impl;
        BladeRunnerDevice* pDevice;
        BlockingQueue<InputPacketPtr>* pDeviceResponseQueue;
        BlockingQueue<OutputPacketWithResultPtr>* pDeviceRequestQueue;
        std::mutex mLock;
    };
};

#endif /* defined(__bladerunner_ios_sdk__BladeRunnerRemoteSessionManager__) */
