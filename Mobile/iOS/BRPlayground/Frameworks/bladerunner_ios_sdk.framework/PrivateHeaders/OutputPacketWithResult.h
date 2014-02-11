//
//  OutputPacketWithResult.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/23/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__OutputPacketWithResult__
#define __bladerunner_ios_sdk__OutputPacketWithResult__

#include <condition_variable>
#include "OutputPacketInterface.h"
#include "Packet.h"
#include "InputPacket.h"
#include "PacketType.h"

#define RETURN_PORT_DEFAULT -1

namespace bladerunner
{
    class OutputPacketWithResult : public Packet, public OutputPacketInterface
    {

    public:
        OutputPacketWithResult();
        OutputPacketWithResult(int messageType);
        bool operator==(const OutputPacketWithResult& packet);
        void setPacketType(PacketType type) { mPacketType = type; }
        void setResponse(InputPacketPtr packet) { mInputPacket = packet; }
        InputPacketPtr getResponse() { return mInputPacket; }
        int getFirstReturnAddress();
        std::vector<byte>& getReturnAddress() { return mReturnAddress; }
        void setReturnAddress(const std::vector<byte>& address) { mReturnAddress = address; }
        int getReturnAddressPort() { return mReturnPort; }
        void setReturnAddressPort(int port) { mReturnPort = port; }
        std::vector<byte>& getInputAddress() { return mInputAddress; }
        void setInputAddress(const std::vector<byte>& address) { mInputAddress = address; }
        std::shared_ptr<std::condition_variable> getWaitObject() { return mWaitObject; }

        virtual int hashCode();


    protected:
        std::shared_ptr<std::condition_variable> mWaitObject;
        InputPacketPtr mInputPacket;
        std::vector<byte> mInputAddress;
        std::vector<byte> mReturnAddress;
        int mReturnPort;
    };

    typedef std::shared_ptr<OutputPacketWithResult> OutputPacketWithResultPtr;
}

#endif /* defined(__bladerunner_ios_sdk__OutputPacketWithResult__) */
