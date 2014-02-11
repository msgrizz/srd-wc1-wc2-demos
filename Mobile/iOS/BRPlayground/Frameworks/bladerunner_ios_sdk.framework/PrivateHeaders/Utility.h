//
//  Utility.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/27/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__Utility__
#define __bladerunner_ios_sdk__Utility__

#include <vector>
#include "CommonDefinitions.h"

namespace bladerunner
{
    class Utility
    {
    public:
        static int hashVector(const std::vector<bool>& vector);
        static int hashVector(const std::vector<byte>& vector);
        static int hashVector(const std::vector<int16_t>& vector);
        static int hashVector(const std::vector<int32_t>& vector);
        static int hashVector(const std::vector<int64_t>& vector);


    private:
        template<class T>
        static int hashVectorImpl(const std::vector<T>& vector);
    };
}

#endif /* defined(__bladerunner_ios_sdk__Utility__) */
