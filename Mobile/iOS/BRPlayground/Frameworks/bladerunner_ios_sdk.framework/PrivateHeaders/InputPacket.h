//
//  InputPacket.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/22/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__InputPacket__
#define __bladerunner_ios_sdk__InputPacket__

#include "Packet.h"

namespace bladerunner
{
    class InputPacket : public Packet
    {

    public:
        InputPacket();
        InputPacket(int messageType);
        static BRError unmarshall(std::vector<byte>& packet, int offset, std::vector<BRType>& types, std::vector<BRProtocolElement>& result);
        static bool compare(std::vector<BRProtocolElement>& elements, std::vector<BRType>& types);
        static BRError intToPacketType(int intType, PacketType& packetType);

        /**
         * Reads and returns all bytes of this packet, starting just after the packet delimiter.
         *
         * A packet looks like this:
         * <ul>
         * <li>DELIMITER
         * <li>packet length (unsigned short)
         * <li>packet type (unsigned byte)
         * <li>payload...
         * </ul>
         *
         */
        static BRError readPacket(std::vector<byte>& packet, InputPacket** result);
        
        virtual int hashCode() { return mMessageType; }


    private:
        // Read element from byte array
        static BRError readBool(const std::vector<byte>& packet, int index, bool& result);
        static BRError readByte(const std::vector<byte>& packet, int index, byte& result);
        static BRError readShort(const std::vector<byte>& packet, int index, int16_t& result);
        static BRError readInt(const std::vector<byte>& packet, int index, int32_t& result);
        static BRError readLong(const std::vector<byte>& packet, int index, int64_t& result);
        static BRError readByteArray(const std::vector<byte>& packet, int index, std::vector<byte>& result);
        static BRError readShortArray(const std::vector<byte>& packet, int index, std::vector<int16_t>& result);
        static BRError readString(const std::vector<byte>& packet, int index, string& result);

        /*
         * The packet length is defined as the payload and packet type bytes.  The
         * delimiter, length, or checksum are not counted.
        */
        static int getPacketLength(const std::vector<byte>& payload) { return payload.size() + PACKET_TYPE_LENGTH; }
    };

    typedef std::shared_ptr<InputPacket> InputPacketPtr;
}

#endif /* defined(__bladerunner_ios_sdk__InputPacket__) */
