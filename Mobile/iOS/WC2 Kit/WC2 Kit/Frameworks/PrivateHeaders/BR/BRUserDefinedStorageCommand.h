//
//  BRUserDefinedStorageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_USER_DEFINED_STORAGE 0x0A0F



@interface BRUserDefinedStorageCommand : BRCommand

+ (BRUserDefinedStorageCommand *)commandWithData:(NSData *)data;

@property(nonatomic,strong) NSData * data;


@end
