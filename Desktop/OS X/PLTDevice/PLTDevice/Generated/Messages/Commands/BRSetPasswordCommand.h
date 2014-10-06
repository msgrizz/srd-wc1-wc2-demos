//
//  BRSetPasswordCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_PASSWORD 0x0F16



@interface BRSetPasswordCommand : BRCommand

+ (BRSetPasswordCommand *)commandWithPassword:(NSString *)password;

@property(nonatomic,strong) NSString * password;


@end
