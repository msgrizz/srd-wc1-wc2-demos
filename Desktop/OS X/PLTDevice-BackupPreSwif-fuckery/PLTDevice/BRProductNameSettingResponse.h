//
//  BRProductNameSettingResponse.h
//  PLTDevice
//
//  Created by Morgan Davis on 5/28/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRSettingResponse.h"


@interface BRProductNameSettingResponse : BRSettingResponse

@property(nonatomic,readonly) NSString   *name;

@end
