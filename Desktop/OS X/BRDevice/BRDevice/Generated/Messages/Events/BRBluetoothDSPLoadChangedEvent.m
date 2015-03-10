//
//  BRBluetoothDSPLoadChangedEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRBluetoothDSPLoadChangedEvent.h"
#import "BRMessage_Private.h"


@interface BRBluetoothDSPLoadChangedEvent ()

@property(nonatomic,assign,readwrite) BOOL load;


@end


@implementation BRBluetoothDSPLoadChangedEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_DSP_LOAD_CHANGED_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"load", @"type": @(BRPayloadItemTypeBoolean)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRBluetoothDSPLoadChangedEvent %p> load=%@",
            self, (self.load ? @"YES" : @"NO")];
}

@end
