//
//  BRUSBPIDSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRUSBPIDSettingResult.h"
#import "BRMessage_Private.h"




@interface BRUSBPIDSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t pid;


@end


@implementation BRUSBPIDSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_USB_PID_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"pid", @"type": @(BRPayloadItemTypeUnsignedShort)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRUSBPIDSettingResult %p> pid=0x%04X",
            self, self.pid];
}

@end
