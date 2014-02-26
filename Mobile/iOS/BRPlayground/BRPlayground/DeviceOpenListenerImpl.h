//
//  DeviceOpenListenerImpl.h
//  TestHarnessApp
//
//  Created by AndreyKozlov on 7/1/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __TestHarnessApp__DeviceOpenListenerImpl__
#define __TestHarnessApp__DeviceOpenListenerImpl__

#import <bladerunner_ios_sdk/DeviceOpenListener.h>

@protocol DeviceOpenListenerDelegate <NSObject>

//- (void)openlistenerCallBackWithSuccess:(BOOL)success;
- (void)openListenerCallBackWithError:(bladerunner::BRError)error;

@end

namespace bladerunner
{    
    class DeviceOpenListenerImpl : public DeviceOpenListener
    {
        
    public:
        id<DeviceOpenListenerDelegate> delegate;
        
        virtual void deviceOpen(BladeRunnerDevice& device);
        virtual void openFailed(BladeRunnerDevice& device, BRError error);
    };
}

#endif /* defined(__TestHarnessApp__DeviceOpenListenerImpl__) */