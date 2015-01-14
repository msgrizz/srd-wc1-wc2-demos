//
//  BRBluetoothDSPLoadCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRBluetoothDSPLoadCommand.h"
#import "BRMessage_Private.h"


@implementation BRBluetoothDSPLoadCommand

#pragma mark - Public

+ (BRBluetoothDSPLoadCommand *)commandWithLoad:(BOOL)load
{
	BRBluetoothDSPLoadCommand *instance = [[BRBluetoothDSPLoadCommand alloc] init];
	instance.load = load;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_BLUETOOTH_DSP_LOAD;
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
    return [NSString stringWithFormat:@"<BRBluetoothDSPLoadCommand %p> load=%@",
            self, (self.load ? @"YES" : @"NO")];
}

@end
