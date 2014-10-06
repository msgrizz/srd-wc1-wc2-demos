//
//  PLTDialogInteractionResult_Internal.h
//  PLTDevice
//
//  Created by Morgan Davis on 6/4/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#ifdef BANGLE

@class PLTDialogInteractionResult;
@class BRApplicationActionResultEvent;


@interface PLTDialogInteractionResult ()

+ (PLTDialogInteractionResult *)resultWithBREvent:(BRApplicationActionResultEvent *)event;
- (void)parseEvent:(BRApplicationActionResultEvent *)event;

@end

#endif
