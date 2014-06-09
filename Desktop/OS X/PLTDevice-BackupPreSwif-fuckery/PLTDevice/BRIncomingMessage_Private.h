//
//  BRIncomingMessage_Private.h
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIncomingMessage.h"


@interface BRIncomingMessage () {
	NSData      *_data;
	NSData      *_payload;
}

+ (BRIncomingMessage *)messageWithData:(NSData *)data;
- (void)parseData;

@property(nonatomic,strong,readwrite)	NSData		*data;
@property(nonatomic,strong,readwrite)	NSData		*payload;

@end