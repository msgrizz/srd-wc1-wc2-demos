//
//  AppDelegate.h
//  BangleTD&S
//
//  Created by Morgan Davis on 6/11/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLTDevice;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(strong,nonatomic)		UIWindow		*window;
@property(nonatomic,readonly)	PLTDevice		*device;

@end

