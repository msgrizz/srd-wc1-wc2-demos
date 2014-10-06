//
//  BRMesage.m
//  BRDevice
//
//  Created by Morgan Davis on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"
#import "BRMessage_Private.h"


@implementation BRMessage

@dynamic length;

- (uint16_t)length
{
	// 7 nibbles address
	// 1 nibble type
	// X bytes payload
	
	// most messages can compute paylaod length with payloadDescriptors, others have hard-coded payloads so we must actually inspect the length of the blob
	uint16_t payloadLength = [self payloadLength];
	if (payloadLength <= 2) {
		payloadLength = [self.payload length];
	}
	return 4 + payloadLength;
}

@dynamic type;

- (BRMessageType)type
{
	// return appropriate message type in subclasses
	return _type;
}

- (void)setType:(BRMessageType)aType
{
	_type = aType;
}

@dynamic payload;

- (NSData *)payload
{
	// compute payload from descriptors
    return nil;
}

- (NSArray *)payloadDescriptors
{
	return nil;
}

- (uint16_t)payloadLength
{
	uint16_t len = 2; // deckard ID
	
	for (NSDictionary *item in [self payloadDescriptors]) {
		NSString *name = item[@"name"];
		BRPayloadItemType type = [item[@"type"] intValue];
		NSValue *value = [self valueForKey:name];
		
		switch (type) {
			case BRPayloadItemTypeBoolean:
			case BRPayloadItemTypeByte:
				len += sizeof(uint8_t);
				break;
				
			case BRPayloadItemTypeShort:
			case BRPayloadItemTypeUnsignedShort:
				len += sizeof(uint16_t);
				break;
				
			case BRPayloadItemTypeLong:
			case BRPayloadItemTypeInt:
			case BRPayloadItemTypeUnsignedLong:
			case BRPayloadItemTypeUnsignedInt:
				len += sizeof(uint32_t);
				break;
				
			case BRPayloadItemTypeByteArray: {
				NSData *data = [value pointerValue];
				len += sizeof(uint16_t);
				uint16_t dataLen = [data length];
				len += dataLen;
				break; }
				
			case BRPayloadItemTypeShortArray: {
				NSData *data = [value pointerValue];
				len += sizeof(uint16_t);
				uint16_t dataLen = [data length];
				len += dataLen * 2;
				break; }
				
			case BRPayloadItemTypeString: {
				NSString *string = [value pointerValue];
				len += sizeof(uint16_t);
				uint16_t stringLen = [string length];
				len += stringLen * 2;
				break; }
		}
	}
	
	return len;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	// auto-generated in subclasses for most messages (not top-level BR messages)
	return 0x0;
}

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

@end
