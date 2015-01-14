//
//  BRLastDateConnectedCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_LAST_DATE_CONNECTED 0x0A0B



@interface BRLastDateConnectedCommand : BRCommand

+ (BRLastDateConnectedCommand *)commandWithMonth:(uint16_t)month day:(uint16_t)day year:(uint32_t)year;

@property(nonatomic,assign) uint16_t month;
@property(nonatomic,assign) uint16_t day;
@property(nonatomic,assign) uint32_t year;


@end
