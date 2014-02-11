//
//  OutputPacketInterface.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/23/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_OutputPacketInterface_h
#define bladerunner_ios_sdk_OutputPacketInterface_h

#include <vector>
#include "ProtocolState.h"
#include "CommonDefinitions.h"

namespace bladerunner
{
    class OutputPacketInterface
    {
        
    public:
        /**
         * Writes this packet to abyte array.
        */
        virtual void write(std::vector<byte>& packet) = 0;

        /**
         * Most output packets always put the output FSM into a specific state.
        */
        virtual ProtocolState nextState() = 0;
    };
}

#endif
