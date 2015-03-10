//
//  BRUserIDCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_USER_ID 0x0A06



@interface BRUserIDCommand : BRCommand

+ (BRUserIDCommand *)commandWithUserID:(NSData *)userID;

@property(nonatomic,strong) NSData * userID;


@end
