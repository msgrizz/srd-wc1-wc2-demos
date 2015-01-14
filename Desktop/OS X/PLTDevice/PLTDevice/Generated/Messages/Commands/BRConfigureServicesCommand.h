//
//  BRConfigureServicesCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_SERVICES 0xFF00

#define BRDefinedValue_ConfigureServicesCommand_Characteristic_UI_ScrollMessage 0x0000
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_UI_Marquee 0x0001
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_UI_DisplayFlip 0x0002
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_UI_DisplayRotate 0x0003
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_UI_DisplayMessage 0x0004
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_UI_DisplayToggle 0x0005
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_UI_DisplayInvert 0x0006
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_UI_DisplayClear 0x0007
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_UI_DisplayPunctuation 0x0008
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_UI_DisplayIcon 0x0009
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_RTC_Configure 0x0000
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_NFC_SetNDEF 0x0000
#define BRDefinedValue_ConfigureServicesCommand_Characteristic_NFC_Write 0x0001


@interface BRConfigureServicesCommand : BRCommand

+ (BRConfigureServicesCommand *)commandWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic configurationData:(NSData *)configurationData;

@property(nonatomic,assign) uint16_t serviceID;
@property(nonatomic,assign) uint16_t characteristic;
@property(nonatomic,strong) NSData * configurationData;


@end
