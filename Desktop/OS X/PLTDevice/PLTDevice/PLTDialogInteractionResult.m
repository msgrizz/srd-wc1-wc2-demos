//
//  PLTDialogInteractionResult.m
//  PLTDevice
//
//  Created by Morgan Davis on 6/4/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#ifdef BANGLE

#import "PLTDialogInteractionResult.h"
#import "PLTDialogInteractionResult_Internal.h"
#import "BRApplicationActionResultEvent.h"


@interface PLTDialogInteractionResult ()

@property(nonatomic,assign,readwrite) NSInteger result;

@end


@implementation PLTDialogInteractionResult

#pragma mark - API Internal

+ (PLTDialogInteractionResult *)resultWithBREvent:(BRApplicationActionResultEvent *)event
{
	PLTDialogInteractionResult *result = [PLTDialogInteractionResult new];
	[result parseEvent:event];
	return result;
}

- (void)parseEvent:(BRApplicationActionResultEvent *)event
{
	// each "dialog interaction" result blog's first byte is the result code
	NSData *resultData = event.resultData;
	
	uint8_t result;
	[[resultData subdataWithRange:NSMakeRange(0, sizeof(uint8_t))] getBytes:&result length:sizeof(uint8_t)];
	self.result = result;
}

@end

#endif
