//
//  BRTapsEvent.h
//  BTSniffer
//
//  Created by Davis, Morgan on 2/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BREvent.h"


typedef enum {
    PLTTapDirectionXUp = 1,
    PLTTapDirectionXDown,
    PLTTapDirectionYUp,
    PLTTapDirectionYDown,
    PLTTapDirectionZUp,
    PLTTapDirectionZDown
} PLTTapDirection;


@interface BRTapsEvent : BREvent

@property(nonatomic,readonly) NSUInteger        taps;
@property(nonatomic,readonly) PLTTapDirection   direction;

@end
