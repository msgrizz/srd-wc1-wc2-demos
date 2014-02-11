//
//  Packet.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/13/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__Packet__
#define __bladerunner_ios_sdk__Packet__

#include <iostream>
#include <vector>
#include "CommonDefinitions.h"
#include "PacketType.h"
#include "BRProtocolElement.h"
#include "PacketId.h"

namespace bladerunner
{
    class Packet
    {
        
    public:
        Packet();
        Packet(int messageType);
        bool operator==(const Packet& packet);
        int getMessageType() { return mMessageType; }
        void setRemotePort(byte port) { mRemotePort = port; }
        byte getRemotePort() { return mRemotePort; }
        void setAddress(const std::vector<byte>& address) { mPortAddress = address; }
        void setReturnPath(const std::vector<byte>& path) { mReturnPath = path; }
        std::vector<byte>& getReturnPath() { return mReturnPath; }
        PacketId getPacketId() { return mPacketId; }
        
        virtual int hashCode() = 0;


    protected:
        static int sizeInBytes(const BRProtocolElement& value);
        static int writeToPacket(std::vector<byte>& packet, int offset, const BRProtocolElement& value);
//        static void writeToStream(std::ostream& os, const BRProtocolElement& value);

        
    private:
        static int sizeInBytes(bool b) { return BOOLEAN_BYTES; }
        static int sizeInBytes(byte b) { return BYTE_BYTES; }
        static int sizeInBytes(int16_t s) { return SHORT_BYTES; }
        static int sizeInBytes(int32_t i) { return INT_BYTES; }
        static int sizeInBytes(int64_t l) { return LONG_BYTES; }
        static int sizeInBytes(const std::vector<byte>& b) { return BYTE_ARRAY_OVERHEAD_BYTES + b.size(); }
        static int sizeInBytes(const std::vector<int16_t>& s) { return SHORT_ARRAY_OVERHEAD_BYTES + (s.size() << 1); }
        static int sizeInBytes(string s) { return STRING_OVERHEAD_BYTES + (s.length() << 1); }
        
        // Output to byte array
        static int writeToPacket(std::vector<byte>&, int offset, bool value);
        static int writeToPacket(std::vector<byte>&, int offset, byte value);
        static int writeToPacket(std::vector<byte>&, int offset, int16_t value);
        static int writeToPacket(std::vector<byte>&, int offset, int32_t value);
        static int writeToPacket(std::vector<byte>&, int offset, int64_t value);
        static int writeToPacket(std::vector<byte>&, int offset, std::vector<byte>& value);
        static int writeToPacket(std::vector<byte>&, int offset, std::vector<int16_t>& value);
        static int writeToPacket(std::vector<byte>&, int offset, string& value);
        
        // Output to stream
//        static void writeToStream(std::ostream& os, bool value);
//        static void writeToStream(std::ostream& os, byte value);
//        static void writeToStream(std::ostream& os, int16_t value);
//        static void writeToStream(std::ostream& os, int32_t value);
//        static void writeToStream(std::ostream& os, int64_t value);
//        static void writeToStream(std::ostream& os, std::vector<byte>& value);
//        static void writeToStream(std::ostream& os, std::vector<int16_t>& value);
//        static void writeToStream(std::ostream& os, string value);


    protected:
        std::vector<byte> mPortAddress;
        byte mRemotePort;
        std::vector<byte> mReturnPath;
        int mMessageType;
        PacketType mPacketType;
        PacketId mPacketId;
    };
}

#endif /* defined(__bladerunner_ios_sdk__Packet__) */
