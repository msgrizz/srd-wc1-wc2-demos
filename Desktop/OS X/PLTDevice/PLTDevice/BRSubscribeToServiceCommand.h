//
//  BRSubscribeToServicesCommandRequest.h
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingRequest.h"


@interface BRSubscribeToServiceCommand : BRMessage

+ (BRSubscribeToServiceCommand *)commandWithServiceID:(uint16_t)serviceID mode:(uint16_t)mode period:(uint16_t)period;

@property(nonatomic,assign) uint16_t   serviceID;
@property(nonatomic,assign) uint16_t   mode;
@property(nonatomic,assign) uint16_t   period;

@end
