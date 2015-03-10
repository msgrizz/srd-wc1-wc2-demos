//
//  BRPlatformSpecificInstrumentationMessageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_PLATFORM_SPECIFIC_INSTRUMENTATION_MESSAGE 0x0803



@interface BRPlatformSpecificInstrumentationMessageCommand : BRCommand

+ (BRPlatformSpecificInstrumentationMessageCommand *)commandWithData:(NSData *)data;

@property(nonatomic,strong) NSData * data;


@end
