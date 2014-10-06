//
//  BRApplicationActionResultEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_APPLICATION_ACTION_RESULT_EVENT 0xFF03



@interface BRApplicationActionResultEvent : BREvent

@property(nonatomic,readonly) uint16_t featureID;
@property(nonatomic,readonly) uint16_t action;
@property(nonatomic,readonly) NSData * operatingData;
@property(nonatomic,readonly) NSData * resultData;


@end
