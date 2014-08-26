//
//  BRConfigureApplicationCommad.m
//  PLTDevice
//
//  Created by Morgan Davis on 6/16/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureApplicationCommad.h"
#import "NSData+HexStrings.h"


@implementation BRConfigureApplicationCommad

#pragma mark - Public

+ (BRConfigureApplicationCommad *)commandWithFeatureID:(uint16_t)featureID characteristic:(uint16_t)characteristic configurationData:(NSData *)configurationData
{
	BRConfigureApplicationCommad *command = [[super alloc] init];
	command.featureID = featureID;
	command.characteristic = characteristic;
	command.configurationData = configurationData;
	return command;
}

#pragma mark BRMessage

- (NSData *)payload
{
	NSString *hexString = [NSString stringWithFormat:@"%04X %04X %04X %@",
						   0xFF02,                  // deckard id
						   self.featureID,
						   self.characteristic,             
						   [self.configurationData hexStringWithSpaceEvery:0]];
	
	return [NSData dataWithHexString:hexString];
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<BRConfigureApplicationCommad %p> featureID=%04X, characteristic=%04X, configurationData=%@",
			self, self.featureID, self.characteristic, [self.configurationData hexStringWithSpaceEvery:1]];
}

@end
