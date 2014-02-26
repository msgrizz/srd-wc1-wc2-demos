//
//  DeciceEventListenerImpl.h
//  TestHarnessApp
//
//  Created by AndreyKozlov on 8/9/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __TestHarnessApp__DeciceEventListenerImpl__
#define __TestHarnessApp__DeciceEventListenerImpl__


#import <bladerunner_ios_sdk/DeviceEventListener.h>
#import <bladerunner_ios_sdk/DeviceEvent.h>

@protocol DeviceEventListenerDelegate <NSObject>

- (void)eventListenerCallBackWithEvent:(bladerunner::DeviceEvent)deviceEvent;

@end

namespace bladerunner
{
    class DeviceEventListenerImpl : public DeviceEventListener
    {
        
    public:
        id<DeviceEventListenerDelegate> delegate;
        
        virtual void receiveEvent(DeviceEvent& deviceEvent);
    };
}


#endif /* defined(__TestHarnessApp__DeciceEventListenerImpl__) */
