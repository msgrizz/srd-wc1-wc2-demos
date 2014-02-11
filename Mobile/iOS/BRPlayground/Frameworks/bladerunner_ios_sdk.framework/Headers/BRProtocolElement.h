//
//  BRProtocolElement.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/22/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__BRProtocolElement__
#define __bladerunner_ios_sdk__BRProtocolElement__

#include <string>
#include <vector>
#include "BRType.h"
#include "BRError.h"
#include "CommonDefinitions.h"

namespace bladerunner
{
    // Protocol element - holds one variable of any of allowed types
    class BRProtocolElement
    {
    public:
        // Constructors for all allowed BR types
        explicit BRProtocolElement(const bool);
        explicit BRProtocolElement(const byte);
        explicit BRProtocolElement(const int16_t);
        explicit BRProtocolElement(const uint16_t);
        explicit BRProtocolElement(const int32_t);
        explicit BRProtocolElement(const uint32_t);
        explicit BRProtocolElement(const int64_t);
        explicit BRProtocolElement(const uint64_t);
        explicit BRProtocolElement(const string &);
        explicit BRProtocolElement(const std::vector<byte> &);
        explicit BRProtocolElement(const std::vector<int16_t> &);
        // Copy constructor needed because we need deep copy of short array, byte array, and strings
        BRProtocolElement(const BRProtocolElement &);
        ~BRProtocolElement();
        
        bool operator==(const BRProtocolElement& element);
        
        // Get type of data held
        BRType getType() const;
        
        // Gets value of data held.
        BRError getValue(bool &) const;
        BRError getValue(byte &) const;
        BRError getValue(uint16_t &) const;
        BRError getValue(int16_t &) const;
        BRError getValue(uint32_t &) const;
        BRError getValue(int32_t &) const;
        BRError getValue(uint64_t &) const;
        BRError getValue(int64_t &) const;
        BRError getValue(std::vector<byte> &) const;
        BRError getValue(std::vector<int16_t> &) const;
        BRError getValue(string &) const;
        
        std::vector<byte> getEncodedBytes() const;
        
    private:
        // Get length of the data held. This is needed for calculation of header length
        uint16_t getLength() const;
        
        BRType mType;
        union
        {
            bool boolValue;
            byte byteValue;
            int16_t int16Value;
            uint16_t uint16Value;
            int32_t int32Value;
            uint32_t uint32Value;
            int64_t int64Value;
            uint64_t uint64Value;
        } value;
        string stringValue;
        std::vector<byte> barray;
        std::vector<int16_t> sarray;
    };
}

#endif /* defined(__bladerunner_ios_sdk__BRProtocolElement__) */
