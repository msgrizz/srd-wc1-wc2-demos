//
//  BRSetVolumeControlOrientationCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRSetVolumeControlOrientationCommand.h"
#import "BRMessage_Private.h"


@implementation BRSetVolumeControlOrientationCommand

#pragma mark - Public

+ (BRSetVolumeControlOrientationCommand *)commandWithOrientation:(uint8_t)orientation
{
	BRSetVolumeControlOrientationCommand *instance = [[BRSetVolumeControlOrientationCommand alloc] init];
	instance.orientation = orientation;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_SET_VOLUME_CONTROL_ORIENTATION;
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
    return [NSString stringWithFormat:@"<BRSetVolumeControlOrientationCommand %p> orientation=0x%02X",
            self, self.orientation];
}

@end
