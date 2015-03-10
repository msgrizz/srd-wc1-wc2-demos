//
//  PLTHeadingInfo.h
//  PLTDevice
//
//  Created by Morgan Davis on 12/22/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTInfo.h"


typedef double PLTHeading;


@interface PLTHeadingInfo : PLTInfo

@property(nonatomic,readonly)	PLTHeading	heading;

@end
