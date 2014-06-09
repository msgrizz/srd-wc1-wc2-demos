//
//  BRMessage_Private.h
//  PLTDevice
//
//  Created by Morgan Davis on 5/15/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMessage.h"


@interface BRMessage () {
	BRMessageType _type;
}

@property(nonatomic,strong,readwrite)	NSString		*address;
@property(nonatomic,assign,readwrite)	BRMessageType	type;

@end

