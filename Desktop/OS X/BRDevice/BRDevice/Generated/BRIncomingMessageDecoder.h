//
//  BRIncomingMessageDecoder.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BRIncomingMessage;


@interface BRIncomingMessageDecoder : NSObject

+ (BRIncomingMessage *)messageWithData:(NSData *)data;

@end
