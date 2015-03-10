//
//  BRRemoteDevice_Private.h
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRRemoteDevice.h"


@interface BRRemoteDevice () <BRDeviceDelegate>

+ (BRRemoteDevice *)deviceWithParent:(BRDevice *)parent port:(uint8_t)port;
- (void)BRDevice:(BRDevice *)device didReceiveMetadata:(BRMetadataMessage *)metadata;

@end
