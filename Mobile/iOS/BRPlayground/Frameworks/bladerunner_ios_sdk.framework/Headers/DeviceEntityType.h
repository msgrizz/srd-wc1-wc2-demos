//
//  DeviceEntityType.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/20/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_DeviceEntityType_h
#define bladerunner_ios_sdk_DeviceEntityType_h

#define DEFAULT_TYPE -1

namespace bladerunner
{
    class DeviceEntityType
    {

    public:
        DeviceEntityType(int16_t id) { mID = id; }
        int16_t getID() const { return mID; }
        void setID(int16_t id) { mID = id; }
        bool operator==(const DeviceEntityType& type) const { return mID == type.mID; }
        bool operator<(const DeviceEntityType& type) const { return mID < type.mID; }

        virtual int hashCode() = 0;
            
    protected:
        int16_t mID;
    };
}

#endif
