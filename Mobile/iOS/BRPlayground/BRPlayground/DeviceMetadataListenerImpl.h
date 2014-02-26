//
//  MetadataListenerImpl.h
//  TestHarnessApp
//
//  Created by AndreyKozlov on 7/23/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __TestHarnessApp__MetadataListener__
#define __TestHarnessApp__MetadataListener__

#import <bladerunner_ios_sdk/DeviceMetadataListener.h>

@protocol DeviceMetadataListenerDelegate <NSObject>

- (void)metadataListenerCallBackWithCommands:(std::set<bladerunner::DeviceCommandType>)commands Settings:(std::set<bladerunner::DeviceSettingType>)settings Events:(std::set<bladerunner::DeviceEventType>)events;

@end

namespace bladerunner
{
    class DeviceMetadataListenerImpl : public DeviceMetadataListener
    {
        
    public:
        id<DeviceMetadataListenerDelegate> delegate;
        
        virtual void metadataReceived(BladeRunnerDevice& device, const std::set<DeviceCommandType>& commands, const std::set<DeviceSettingType>& settings, const std::set<DeviceEventType>& events);
    };
}


#endif /* defined(__TestHarnessApp__MetadataListener__) */
