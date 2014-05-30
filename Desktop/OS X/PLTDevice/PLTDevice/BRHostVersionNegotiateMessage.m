//
//  BRHostVersionNegotiateMessage.h
//  PLTDevice
//
//  Created by Morgan Davis on 3/10/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRHostVersionNegotiateMessage.h"
#import "BRMessage_Private.h"
#import "NSData+HexStrings.h"


@interface BRHostVersionNegotiateMessage ()

@property(nonatomic,readwrite)			uint8_t		minimumVersion;
@property(nonatomic,readwrite)			uint8_t		maximumVersion;

@end


@implementation BRHostVersionNegotiateMessage

#pragma mark - Public

+ (BRHostVersionNegotiateMessage *)messageWithMinimumVersion:(uint8_t)minimumVersion maximumVersion:(uint8_t)maximumVersion
{
    BRHostVersionNegotiateMessage *message = [[BRHostVersionNegotiateMessage alloc] init];
	message.minimumVersion = minimumVersion;
	message.maximumVersion = maximumVersion;
    return message;
}

- (BRMessageType)type
{
	return BRMessageTypeHostProtocolVersion;
}

#pragma BRMessage

- (NSData *)payload
{
	NSString *hexString = [NSString stringWithFormat:@"%02X %02X %02X",
						   self.minimumVersion,					// min protocol version
						   self.maximumVersion,					// max protocol version
						   0x01                                 // device capibility
						   ];
	
	return [NSData dataWithHexString:hexString];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRHostVersionNegotiateCommand %p>",
            self];
}

@end
