//
//  BRTrainingHeadsetConnectionSettingRequest.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRTrainingHeadsetConnectionSettingRequest.h"
#import "BRMessage_Private.h"


@implementation BRTrainingHeadsetConnectionSettingRequest

#pragma BRSettingRequest

+ (BRTrainingHeadsetConnectionSettingRequest *)request
{
	BRTrainingHeadsetConnectionSettingRequest *instance = [[BRTrainingHeadsetConnectionSettingRequest alloc] init];

	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TRAINING_HEADSET_CONNECTION_SETTING_REQUEST;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[

			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTrainingHeadsetConnectionSettingRequest %p>",
            self];
}

@end
