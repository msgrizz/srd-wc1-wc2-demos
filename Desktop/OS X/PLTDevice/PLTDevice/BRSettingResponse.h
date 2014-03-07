//
//  BRCommandResponse.h
//  BTSniffer
//
//  Created by Davis, Morgan on 2/24/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"


@interface BRSettingResponse : BRMessage

+ (BRSettingResponse *)settingResponseWithData:(NSData *)data;
- (id)initWithData:(NSData *)data;
- (void)parseData;

@end
