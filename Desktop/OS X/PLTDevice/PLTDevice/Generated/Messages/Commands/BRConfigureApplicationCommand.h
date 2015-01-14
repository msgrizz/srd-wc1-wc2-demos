//
//  BRConfigureApplicationCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_APPLICATION 0xFF02

#define BRDefinedValue_ConfigureApplicationCommand_FeatureID_FeatureID_DisplayReadout 0x0000
#define BRDefinedValue_ConfigureApplicationCommand_FeatureID_FeatureID_Units 0x0001
#define BRDefinedValue_ConfigureApplicationCommand_FeatureID_FeatureID_LockOnPowerup 0x0002
#define BRDefinedValue_ConfigureApplicationCommand_FeatureID_FeatureID_LockOnDoff 0x0003
#define BRDefinedValue_ConfigureApplicationCommand_FeatureID_FeatureID_EnableButtonLock 0x0004
#define BRDefinedValue_ConfigureApplicationCommand_FeatureID_FeatureID_EnablePanicSequence 0x0005
#define BRDefinedValue_ConfigureApplicationCommand_FeatureID_FeatureID_DateAndTime 0x0006


@interface BRConfigureApplicationCommand : BRCommand

+ (BRConfigureApplicationCommand *)commandWithFeatureID:(uint16_t)featureID characteristic:(uint16_t)characteristic configurationData:(NSData *)configurationData;

@property(nonatomic,assign) uint16_t featureID;
@property(nonatomic,assign) uint16_t characteristic;
@property(nonatomic,strong) NSData * configurationData;


@end
