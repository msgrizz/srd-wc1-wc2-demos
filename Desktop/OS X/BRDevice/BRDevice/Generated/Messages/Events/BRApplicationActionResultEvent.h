//
//  BRApplicationActionResultEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_APPLICATION_ACTION_RESULT_EVENT 0xFF03



@interface BRApplicationActionResultEvent : BREvent

@property(nonatomic,readonly) uint16_t featureID;
@property(nonatomic,readonly) uint16_t action;
@property(nonatomic,readonly) NSData * operatingData;
@property(nonatomic,readonly) NSData * resultData;


@end
