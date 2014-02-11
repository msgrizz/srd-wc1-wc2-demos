//
//  SignatureDescription.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 7/9/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__SignatureDescription__
#define __bladerunner_ios_sdk__SignatureDescription__

#include <vector>
#include "BRType.h"

namespace bladerunner
{
    class SignatureDescription
    {

    public:
        SignatureDescription(int16_t id);
        SignatureDescription(int16_t id, const std::vector<BRType>& signature);
        SignatureDescription(int16_t id, const std::vector<BRType>& inputSignature, const std::vector<BRType>& outputSignature);
        bool operator<(const SignatureDescription& description) const;
        int16_t getID() { return mID; }
        std::vector<BRType>& getSignature() { return mOutputSignature; }
        std::vector<BRType>& getInputSignature() { return mInputSignature; }
        std::vector<BRType>& getOutputSignature() { return mOutputSignature; }


    private:
        int16_t mID;
        std::vector<BRType> mInputSignature;
        std::vector<BRType> mOutputSignature;
    };
}

#endif /* defined(__bladerunner_ios_sdk__SignatureDescription__) */
