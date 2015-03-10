//
//  BRTattooBuildCodeCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_TATTOO_BUILD_CODE 0x0A03



@interface BRTattooBuildCodeCommand : BRCommand

+ (BRTattooBuildCodeCommand *)commandWithBuildCode:(NSData *)buildCode;

@property(nonatomic,strong) NSData * buildCode;


@end
