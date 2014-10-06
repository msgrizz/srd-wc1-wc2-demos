//
//  BRSetGenesGUIDCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_GENES_GUID 0x0A1E



@interface BRSetGenesGUIDCommand : BRCommand

+ (BRSetGenesGUIDCommand *)commandWithGuid:(NSData *)guid;

@property(nonatomic,strong) NSData * guid;


@end
