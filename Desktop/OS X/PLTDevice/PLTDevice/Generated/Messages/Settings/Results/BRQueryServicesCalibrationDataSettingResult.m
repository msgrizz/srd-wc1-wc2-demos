//
//  BRQueryServicesCalibrationDataSettingResult.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRQueryServicesCalibrationDataSettingResult.h"
#import "BRMessage_Private.h"




@interface BRQueryServicesCalibrationDataSettingResult ()

@property(nonatomic,assign,readwrite) uint16_t serviceID;
@property(nonatomic,assign,readwrite) uint16_t characteristic;
@property(nonatomic,strong,readwrite) NSData * calibrationData;


@end


@implementation BRQueryServicesCalibrationDataSettingResult

#pragma mark - Public

@dynamic deckardID;
- (uint16_t)deckardID
{
	return BR_QUERY_SERVICES_CALIBRATION_DATA_SETTING_RESULT;
}

#pragma mark BRMessage

- (NSArray *)payloadDescriptors
{
	// auto-generated to hold name, order and type information for payload items
	return @[
			@{@"name": @"serviceID", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"characteristic", @"type": @(BRPayloadItemTypeUnsignedShort)},
			@{@"name": @"calibrationData", @"type": @(BRPayloadItemTypeByteArray)}
			 ];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRQueryServicesCalibrationDataSettingResult %p> serviceID=0x%04X, characteristic=0x%04X, calibrationData=%@",
            self, self.serviceID, self.characteristic, self.calibrationData];
}

@end
