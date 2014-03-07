//
//  BRSubscribeToSignalStrengthCommand.h
//  BTSniffer
//
//  Created by Davis, Morgan on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"


@interface BRSubscribeToSignalStrengthCommand : BRMessage

+ (BRSubscribeToSignalStrengthCommand *)commandWithSubscription:(BOOL)subscribe;

@property(nonatomic,readonly) BOOL subscribe;

@end
