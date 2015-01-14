//
//  BRSetVocalystPhoneNumberCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_SET_VOCALYST_PHONE_NUMBER 0x0A12



@interface BRSetVocalystPhoneNumberCommand : BRCommand

+ (BRSetVocalystPhoneNumberCommand *)commandWithVocalystPhoneNumber:(NSString *)vocalystPhoneNumber;

@property(nonatomic,strong) NSString * vocalystPhoneNumber;


@end
