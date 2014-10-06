//
//  BRSetVolumeControlOrientationEvent.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSetVolumeControlOrientationEvent.h"
#import "BRMessage_Private.h"




@interface BRSetVolumeControlOrientationEvent ()

@property(nonatomic,assign,readwrite) uint8_t orientation;


@end


@implementation BRSetVolumeControlOrientationEvent

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_VOLUME_CONTROL_ORIENTATION_EVENT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"orientation", @"type": @(BRPayloadItemTypeByte)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRSetVolumeControlOrientationEvent %p> orientation=0x%02X",
            self, self.orientation];
}

@end
