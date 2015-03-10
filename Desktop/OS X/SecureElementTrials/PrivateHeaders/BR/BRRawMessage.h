//
//  BRRawMessage.h
//  PLTDevice
//
//  Created by Morgan Davis on 4/1/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BROutgoingMessage.h"


@interface BRRawMessage : BROutgoingMessage

+ (BRRawMessage *)messageWithType:(BRMessageType)type payload:(NSData *)payload;

@end
