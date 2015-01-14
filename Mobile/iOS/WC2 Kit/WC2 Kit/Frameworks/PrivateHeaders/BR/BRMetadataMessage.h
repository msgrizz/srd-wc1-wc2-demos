//
//  BRMetadataMessage.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIncomingMessage.h"


@interface BRMetadataMessage : BRIncomingMessage

//+ (BRMetadataMessage *)messageWithData:(NSData *)data;

@property(nonatomic,readonly) NSArray   *commands;
@property(nonatomic,readonly) NSArray   *settings;
@property(nonatomic,readonly) NSArray   *events;

@end
