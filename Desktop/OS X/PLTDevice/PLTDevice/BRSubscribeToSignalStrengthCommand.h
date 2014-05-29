//
//  BRSubscribeToSignalStrengthCommand.h
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


@interface BRSubscribeToSignalStrengthCommand : BRCommand

+ (BRSubscribeToSignalStrengthCommand *)commandWithSubscription:(BOOL)subscribe connectionID:(int)conncetionID;

@property(nonatomic,readonly) BOOL subscribe;
@property(nonatomic,readonly) int conncetionID;

@end
