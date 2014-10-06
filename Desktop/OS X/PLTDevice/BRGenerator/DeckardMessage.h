//
//  DeckardMessage.h
//  BRSDKGenerator
//
//  Created by Morgan Davis on 9/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	DeckardMessageTypeCommand,
	DeckardMessageTypeSetting,
	DeckardMessageTypeSettingRequest,
	DeckardMessageTypeSettingResult,
	DeckardMessageTypeEvent,
	DeckardMessageTypeException
} DeckardMessageType;


@interface DeckardMessage : NSObject

+ (DeckardMessage *)messageWithType:(DeckardMessageType)type name:(NSString *)name identifier:(NSUInteger)identifier section:(NSString *)section;

@property(nonatomic,strong)	NSString			*section;
@property(nonatomic,assign)	DeckardMessageType	type;
@property(nonatomic,strong)	NSString			*name;
@property(nonatomic,assign)	NSUInteger			identifier;
@property(nonatomic,strong)	NSMutableArray		*payloadIn;
@property(nonatomic,strong)	NSMutableArray		*payloadOut;

@end
