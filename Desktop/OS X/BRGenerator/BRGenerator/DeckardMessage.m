//
//  DeckardMessage.m
//  BRSDKGenerator
//
//  Created by Morgan Davis on 9/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "DeckardMessage.h"


@implementation DeckardMessage

#pragma mark - Public

+ (DeckardMessage *)messageWithType:(DeckardMessageType)type name:(NSString *)name identifier:(NSUInteger)identifier section:(NSString *)section
{
	DeckardMessage *message = [[DeckardMessage alloc] init];
	message.type = type;
	message.name = name;
	message.identifier = identifier;
	message.section = section;
	return message;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	DeckardMessage *copy = [[DeckardMessage allocWithZone:zone] init];
	
	copy.section = [self.section copy];
	copy.type = self.type;
	copy.name = [self.name copy];
	copy.identifier = self.identifier;
	copy.payloadIn = [self.payloadIn copy];
	copy.payloadOut = [self.payloadOut copy];
	
	return copy;
}

#pragma mark - NSObject

- (id)init
{
	self = [super init];
	self.payloadIn = [NSMutableArray array];
	self.payloadOut = [NSMutableArray array];
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<DeckardMessage %p> section=%@, type=%d, name=%@, identifier=0x%04lX, payloadIn=%@, payloadOut=%@",
			self, self.section, self.type, self.name, (unsigned long)self.identifier, self.payloadIn, self.payloadOut];
}

@end
