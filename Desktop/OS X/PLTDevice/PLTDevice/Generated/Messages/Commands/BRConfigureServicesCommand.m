//
//  BRConfigureServicesCommand.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRConfigureServicesCommand.h"
#import "BRMessage_Private.h"


const uint16_t ConfigureServicesCommand_Characteristic_UI_ScrollMessage = 0x0000;
const uint16_t ConfigureServicesCommand_Characteristic_UI_Marquee = 0x0001;
const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayFlip = 0x0002;
const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayRotate = 0x0003;
const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayMessage = 0x0004;
const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayToggle = 0x0005;
const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayInvert = 0x0006;
const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayClear = 0x0007;
const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayPunctuation = 0x0008;
const uint16_t ConfigureServicesCommand_Characteristic_UI_DisplayIcon = 0x0009;
const uint16_t ConfigureServicesCommand_Characteristic_RTC_Configure = 0x0000;
const uint16_t ConfigureServicesCommand_Characteristic_NFC_SetNDEF = 0x0000;
const uint16_t ConfigureServicesCommand_Characteristic_NFC_Write = 0x0001;


@implementation BRConfigureServicesCommand

#pragma mark - Public

+ (BRConfigureServicesCommand *)commandWithServiceID:(uint16_t)serviceID characteristic:(uint16_t)characteristic configurationData:(NSData *)configurationData
{
	BRConfigureServicesCommand *instance = [[BRConfigureServicesCommand alloc] init];
	instance.serviceID = serviceID;
	instance.characteristic = characteristic;
	instance.configurationData = configurationData;
	return instance;
}

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_CONFIGURE_SERVICES;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serviceID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"configurationData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRConfigureServicesCommand %p> serviceID=0x%04X, characteristic=0x%04X, configurationData=%@",
            self, self.serviceID, self.characteristic, self.configurationData];
}

@end
