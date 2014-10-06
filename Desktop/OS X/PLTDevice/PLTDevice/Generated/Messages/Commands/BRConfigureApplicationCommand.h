//
//  BRConfigureApplicationCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_APPLICATION 0xFF02

extern const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_DisplayReadout;
extern const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_Units;
extern const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_LockOnPowerup;
extern const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_LockOnDoff;
extern const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_EnableButtonLock;
extern const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_EnablePanicSequence;
extern const uint16_t ConfigureApplicationCommand_FeatureID_FeatureID_DateAndTime;


@interface BRConfigureApplicationCommand : BRCommand

+ (BRConfigureApplicationCommand *)commandWithFeatureID:(uint16_t)featureID characteristic:(uint16_t)characteristic configurationData:(NSData *)configurationData;

@property(nonatomic,assign) uint16_t featureID;
@property(nonatomic,assign) uint16_t characteristic;
@property(nonatomic,strong) NSData * configurationData;


@end
