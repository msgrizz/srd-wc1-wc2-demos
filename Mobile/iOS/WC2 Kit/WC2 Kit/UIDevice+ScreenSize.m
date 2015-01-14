//
//  UIDevice+ScreenSize.m
//  PLTSensor
//
//  Created by Davis, Morgan on 3/22/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "UIDevice+ScreenSize.h"

@implementation UIDevice (ScreenSize)

+ (BOOL)hasFourInchDisplay
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}

@end
