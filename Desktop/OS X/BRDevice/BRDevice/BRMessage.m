//
//  BRMesage.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"
#import "BRMessage_Private.h"
#import "NSData+HexStrings.h"


//@interface BRMessage () 
//
////@property(nonatomic,strong,readwrite)   NSData  *data;
//
//@end


@implementation BRMessage

@dynamic length;

- (uint16_t)length
{
	// 7 nibbles address
	// 1 nibble type
	// X bytes payload
	
	return 4 + [self.payload length];
}

@dynamic type;

- (BRMessageType)type
{
	// return appropriate message type in subclasses
	//self.type = 0xF;
	return _type;
}

- (void)setType:(BRMessageType)aType
{
	_type = aType;
}

@dynamic payload;

//- (void)setPayload:(NSData *)payload
//{
//    _payload = payload;
//    [self parsePayload];
//}

- (NSData *)payload
{
	// compute payload from ivars
    return nil;
}

//@dynamic data;

#pragma mark - Public

+ (BRMessage *)message
{
	BRMessage *message = [[BRMessage alloc] init];
	return message;
}

- (id)init
{
	self = [super init];
	self.address = @"0000000";
	return self;
}

//#pragma mark - Private
//
//- (void)parsePayload
//{
//	
//}

@end
