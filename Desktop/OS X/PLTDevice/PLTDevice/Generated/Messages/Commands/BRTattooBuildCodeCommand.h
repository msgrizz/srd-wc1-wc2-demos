//
//  BRTattooBuildCodeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_TATTOO_BUILD_CODE 0x0A03



@interface BRTattooBuildCodeCommand : BRCommand

+ (BRTattooBuildCodeCommand *)commandWithBuildCode:(NSData *)buildCode;

@property(nonatomic,strong) NSData * buildCode;


@end
