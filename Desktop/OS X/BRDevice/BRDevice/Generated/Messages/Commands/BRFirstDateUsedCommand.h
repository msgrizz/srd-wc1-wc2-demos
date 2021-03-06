//
//  BRFirstDateUsedCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_FIRST_DATE_USED 0x0A07



@interface BRFirstDateUsedCommand : BRCommand

+ (BRFirstDateUsedCommand *)commandWithMonth:(uint16_t)month day:(uint16_t)day year:(uint32_t)year;

@property(nonatomic,assign) uint16_t month;
@property(nonatomic,assign) uint16_t day;
@property(nonatomic,assign) uint32_t year;


@end
