//
//  BRTattooBuildCodeCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRTattooBuildCodeCommand.h"
#import "BRMessage_Private.h"


@implementation BRTattooBuildCodeCommand

#pragma mark - Public

+ (BRTattooBuildCodeCommand *)commandWithBuildCode:(NSData *)buildCode
{
	BRTattooBuildCodeCommand *instance = [[BRTattooBuildCodeCommand alloc] init];
	instance.buildCode = buildCode;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_TATTOO_BUILD_CODE;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"buildCode", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRTattooBuildCodeCommand %p> buildCode=%@",
            self, self.buildCode];
}

@end
