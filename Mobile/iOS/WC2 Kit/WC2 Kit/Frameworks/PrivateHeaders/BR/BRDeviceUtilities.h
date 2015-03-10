//
//  BRDeviceUtilities.h
//  BRDevice
//
//  Created by Morgan Davis on 1/13/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRMessage.h"


NSData *BRDeviceDataFromHexString(NSString *hexString);
NSString *BRDeviceHexStringFromData(NSData *data, unsigned int byteSpacing);
NSString *BRDeviceDescriptionFromArrayOfShortIntegers(NSArray *array);
BRMessageType BRDeviceMessageTypeFromMessageData(NSData *data);
uint16_t BRDeviceDeckardIDFromMessageData(NSData *data);
uint16_t BRDeviceDeckardIDFromMessagePayload(NSData *payload);
uint16_t BRDeviceExceptionIDFromMessageData(NSData *data);
