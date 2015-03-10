//
//  BRMessage_Private.h
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"


typedef enum {
	BRPayloadItemTypeBoolean,
	BRPayloadItemTypeByte,
	BRPayloadItemTypeShort,
	BRPayloadItemTypeUnsignedShort,
	BRPayloadItemTypeLong,
	BRPayloadItemTypeUnsignedLong,
	BRPayloadItemTypeInt,
	BRPayloadItemTypeUnsignedInt,
	BRPayloadItemTypeByteArray,
	BRPayloadItemTypeShortArray,
	BRPayloadItemTypeString
} BRPayloadItemType;


@interface BRMessage () {
	BRMessageType _type;
}

- (NSArray *)payloadDescriptors;
- (uint16_t)payloadLength;

@property(nonatomic,strong,readwrite)	NSString		*address;
@property(nonatomic,assign,readwrite)	BRMessageType	type;
@property(nonatomic,assign,readwrite)	uint16_t		deckardID;

@end

