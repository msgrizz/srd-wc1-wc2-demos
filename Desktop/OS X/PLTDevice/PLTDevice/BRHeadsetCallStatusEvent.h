//
//  BRHeadsetCallStatusEvent
//  PLTDevice
//
//  Created by Morgan Davis on 8/27/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


//<tr><td>0</td><td>Idle</td></tr>
//<tr><td>1</td><td>Active</td></tr>
//<tr><td>2</td><td>Ringing</td></tr>
//<tr><td>3</td><td>Dialing</td></tr>
//<tr><td>4</td><td>ActiveAndRinging</td></tr>


@interface BRHeadsetCallStatusEvent : BREvent

@property(nonatomic,readonly)	uint16_t	numberOfDevices;
@property(nonatomic,readonly)	uint8_t		connectionID;
@property(nonatomic,readonly)	uint8_t		state;
@property(nonatomic,readonly)	NSString	*number;

@end
