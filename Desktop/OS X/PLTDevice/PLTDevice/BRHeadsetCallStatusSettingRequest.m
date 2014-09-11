//
//  BRHeadsetCallStatusSettingRequest.m
//  PLTDevice
//
//  Created by Morgan Davis on 8/27/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHeadsetCallStatusSettingRequest.h"
#import "NSData+HexStrings.h"


@implementation BRHeadsetCallStatusSettingRequest

#pragma BRMessage

- (NSData *)payload
{
	NSString *hexString = [NSString stringWithFormat:@"%04X",
						   0x0E22];
	
	return [NSData dataWithHexString:hexString];
}

@end
