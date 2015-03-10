//
//  BRSetVocalystPhoneNumberCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_VOCALYST_PHONE_NUMBER 0x0A12



@interface BRSetVocalystPhoneNumberCommand : BRCommand

+ (BRSetVocalystPhoneNumberCommand *)commandWithVocalystPhoneNumber:(NSString *)vocalystPhoneNumber;

@property(nonatomic,strong) NSString * vocalystPhoneNumber;


@end
