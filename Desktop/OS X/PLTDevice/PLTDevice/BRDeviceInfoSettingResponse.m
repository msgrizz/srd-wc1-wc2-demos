//
//  BRDeviceInfoSettingResponse.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRDeviceInfoSettingResponse.h"
#import "BRIncomingMessage_Private.h"


@interface BRDeviceInfoSettingResponse ()

@property(nonatomic,strong,readwrite) NSMutableArray   *majorHardwareVersions;
@property(nonatomic,strong,readwrite) NSMutableArray   *minorHardwareVersions;
@property(nonatomic,strong,readwrite) NSMutableArray   *majorSoftwareVersions;
@property(nonatomic,strong,readwrite) NSMutableArray   *minorSoftwareVersions;
@property(nonatomic,strong,readwrite) NSMutableArray   *supportedServices;

@end


@implementation BRDeviceInfoSettingResponse

#pragma mark - Public

- (void)parseData
{
	[super parseData];
	
	self.majorHardwareVersions = [NSMutableArray array];
	self.minorHardwareVersions = [NSMutableArray array];
	self.majorSoftwareVersions = [NSMutableArray array];
	self.minorSoftwareVersions = [NSMutableArray array];
	self.supportedServices = [NSMutableArray array];
	
	enum DeviceInfo {
		DeviceInfoMajorHWVersion = 0,
		DeviceInfoMinorHWVersion,
		DeviceInfoMajorSWVersion,
		DeviceInfoMinorSWVersion,
		DeviceInfoSupportedServices
	};
	
    uint16_t offset = 2;
	uint16_t len = 0;
	uint8_t *vers;
	
	for (enum DeviceInfo i = DeviceInfoMajorHWVersion; i < DeviceInfoSupportedServices; i++) {
		
		[[self.payload subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
		len = ntohs(len);
		
		offset += sizeof(uint16_t);
		
		vers = malloc(len);
		[[self.payload subdataWithRange:NSMakeRange(offset, len)] getBytes:vers length:len];
		
		for (int v=0; v<len; v++) {
			uint8_t version = vers[v];
			switch (i) {
				case DeviceInfoMajorHWVersion:
					[(NSMutableArray *)self.majorHardwareVersions addObject:@(version)];
					break;
				case DeviceInfoMinorHWVersion:
					[(NSMutableArray *)self.minorHardwareVersions addObject:@(version)];
					break;
				case DeviceInfoMajorSWVersion:
					[(NSMutableArray *)self.majorSoftwareVersions addObject:@(version)];
					break;
				case DeviceInfoMinorSWVersion:
					[(NSMutableArray *)self.minorSoftwareVersions addObject:@(version)];
					break;
				case DeviceInfoSupportedServices: // suppress compiler warnings
					break;
			}
		}
		
		free(vers);
		
		offset += len;
	}
	
	[[self.payload subdataWithRange:NSMakeRange(offset, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
	len = ntohs(len);
	
	offset += sizeof(uint16_t);
	
	uint16_t services[len];
	[[self.payload subdataWithRange:NSMakeRange(offset, len)] getBytes:&services length:len];
	
	for (int s=1; s<(len/2); s++) {
		[(NSMutableArray *)self.supportedServices addObject:@(htons(services[s]))];
	}
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRDeviceInfoSettingResponse %p> majorHardwareVersions=%@, minorHardwareVersions=%@, majorSoftwareVersions=%@, minorSoftwareVersions=%@, supportedServices=%@",
            self, self.majorHardwareVersions, self.minorHardwareVersions, self.majorSoftwareVersions, self.minorSoftwareVersions, self.supportedServices];
}

@end
