//
//  BRVocalystInfoNumberCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_VOCALYST_INFO_NUMBER 0x0A16



@interface BRVocalystInfoNumberCommand : BRCommand

+ (BRVocalystInfoNumberCommand *)commandWithInfoPhoneNumber:(NSString *)infoPhoneNumber;

@property(nonatomic,strong) NSString * infoPhoneNumber;


@end
