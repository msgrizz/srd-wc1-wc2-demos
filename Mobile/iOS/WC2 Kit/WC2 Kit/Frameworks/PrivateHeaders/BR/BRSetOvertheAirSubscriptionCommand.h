//
//  BRSetOvertheAirSubscriptionCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_OVERTHEAIR_SUBSCRIPTION 0x0F26



@interface BRSetOvertheAirSubscriptionCommand : BRCommand

+ (BRSetOvertheAirSubscriptionCommand *)commandWithOtaEnabled:(BOOL)otaEnabled;

@property(nonatomic,assign) BOOL otaEnabled;


@end
