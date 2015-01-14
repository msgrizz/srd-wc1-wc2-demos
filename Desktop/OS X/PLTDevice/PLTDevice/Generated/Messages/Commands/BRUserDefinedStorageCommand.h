//
//  BRUserDefinedStorageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_USER_DEFINED_STORAGE 0x0A0F



@interface BRUserDefinedStorageCommand : BRCommand

+ (BRUserDefinedStorageCommand *)commandWithData:(NSData *)data;

@property(nonatomic,strong) NSData * data;


@end
