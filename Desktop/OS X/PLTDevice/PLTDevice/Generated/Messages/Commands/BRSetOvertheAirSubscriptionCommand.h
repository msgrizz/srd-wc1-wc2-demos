//
//  BRSetOvertheAirSubscriptionCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_OVERTHEAIR_SUBSCRIPTION 0x0F26



@interface BRSetOvertheAirSubscriptionCommand : BRCommand

+ (BRSetOvertheAirSubscriptionCommand *)commandWithOtaEnabled:(BOOL)otaEnabled;

@property(nonatomic,assign) BOOL otaEnabled;


@end
