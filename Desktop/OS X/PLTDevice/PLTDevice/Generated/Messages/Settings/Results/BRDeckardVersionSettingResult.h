//
//  BRDeckardVersionSettingResult.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResult.h"


#define BR_DECKARD_VERSION_SETTING_RESULT 0x0AFE



@interface BRDeckardVersionSettingResult : BRSettingResult

@property(nonatomic,readonly) BOOL releaseOrDev;
@property(nonatomic,readonly) uint16_t majorVersion;
@property(nonatomic,readonly) uint16_t minorVersion;
@property(nonatomic,readonly) uint16_t maintenanceVersion;


@end
