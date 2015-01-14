//
//  BRIncomingMessageMux.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BRIncomingMessage;


@interface BRIncomingMessageMux : NSObject

+ (BRIncomingMessage *)messageWithData:(NSData *)data;

@end
