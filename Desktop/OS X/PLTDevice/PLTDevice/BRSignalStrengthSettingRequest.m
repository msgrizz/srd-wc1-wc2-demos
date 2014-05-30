//
//  BRSignalStrengthSettingRequest.m
//  BRDevice
//
//  Created by Morgan Davis on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSignalStrengthSettingRequest.h"
#import "NSData+HexStrings.h"


@interface BRSignalStrengthSettingRequest ()

@property(nonatomic,assign,readwrite) int conncetionID;

@end


@implementation BRSignalStrengthSettingRequest

#pragma BRSettingRequest

+ (BRSignalStrengthSettingRequest *)requestWithConnectionID:(int)conncetionID
{
	BRSignalStrengthSettingRequest *request = [[[super class] alloc] init];
	request.conncetionID = conncetionID;
    return request;
}

#pragma BRMessage

- (NSData *)payload
{
    NSString *hexString = [NSString stringWithFormat:@"%04X %02X",
                           0x0800,						// deckard id
                           self.conncetionID];          // connection id
    
    return [NSData dataWithHexString:hexString];
}

@end
