//
//  BRPlatformSpecificInstrumentationMessageCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_PLATFORM_SPECIFIC_INSTRUMENTATION_MESSAGE 0x0803



@interface BRPlatformSpecificInstrumentationMessageCommand : BRCommand

+ (BRPlatformSpecificInstrumentationMessageCommand *)commandWithData:(NSData *)data;

@property(nonatomic,strong) NSData * data;


@end
