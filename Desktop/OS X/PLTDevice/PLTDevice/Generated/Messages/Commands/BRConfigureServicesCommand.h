//
//  BRConfigureServicesCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_SERVICES 0xFF00

extern const uint16_t ConfigureServicesCommand_Characteristic_UI_ScrollMessage;
extern const uint16_t ConfigureServicesCommand_Characteristic_UI_Marquee;
extern const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayFlip;
extern const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayRotate;
extern const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayMessage;
extern const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayToggle;
extern const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayInvert;
extern const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayClear;
extern const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayPunctuation;
extern const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayIcon;
extern const uint16_t ConfigureServicesCommand_Characteristic_RTC_Configure;
extern const uint16_t ConfigureServicesCommand_Characteristic_NFC_SetNDEF;
extern const uint16_t ConfigureServicesCommand_Characteristic_NFC_Write;


@interface BRConfigureServicesCommand : BRCommand

+ (BRConfigureServicesCommand *)commandWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic configurationData:(NSData *)configurationData;

@property(nonatomic,assign) uint16_t serviceID;
@property(nonatomic,assign) uint16_t characteristic;
@property(nonatomic,strong) NSData * configurationData;


@end
