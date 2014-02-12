//
//  DeviceListenerImpl.h
//  TestHarnessApp
//
//  Created by AndreyKozlov on 6/21/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __TestHarnessApp__ListenerClass__
#define __TestHarnessApp__ListenerClass__

#include <iostream>
#import <bladerunner_ios_sdk/DeviceListener.h>
#endif /* defined(__TestHarnessApp__ListenerClass__) */

@protocol DevicelistenerDelegate <NSObject>

//- (void)listenerCallBackWithSuccess:(BOOL)success;
- (void)listenerFoundDevice:(bladerunner::BladeRunnerDevice &)device;
- (void)listenerDiscoveryStopped:(bool)success;


@end

namespace bladerunner
{
    
    class DeviceListenerImpl : public DeviceListener
    {
    
    public:
        id<DevicelistenerDelegate> delegate;
        int deviceCount;
        
        virtual void foundDevice(BladeRunnerDevice &device);
        virtual void discoveryStopped(bool success);
    };
    
}