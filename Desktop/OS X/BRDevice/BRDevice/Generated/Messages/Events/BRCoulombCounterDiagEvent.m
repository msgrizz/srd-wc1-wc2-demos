//
//  BRCoulombCounterDiagEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCoulombCounterDiagEvent.h"
#import "BRMessage_Private.h"


@interface BRCoulombCounterDiagEvent ()

@property(nonatomic,strong,readwrite) NSData * coulombCounterData;


@end


@implementation BRCoulombCounterDiagEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_COULOMB_COUNTER_DIAG_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"coulombCounterData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRCoulombCounterDiagEvent %p> coulombCounterData=%@",
            self, self.coulombCounterData];
}

@end
