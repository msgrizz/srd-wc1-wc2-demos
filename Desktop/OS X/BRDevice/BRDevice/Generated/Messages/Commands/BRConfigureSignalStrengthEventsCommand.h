//
//  BRConfigureSignalStrengthEventsCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_SIGNAL_STRENGTH_EVENTS 0x0800



@interface BRConfigureSignalStrengthEventsCommand : BRCommand

+ (BRConfigureSignalStrengthEventsCommand *)commandWithConnectionId:(uint8_t)connectionId enable:(BOOL)enable dononly:(BOOL)dononly trend:(BOOL)trend reportRssiAudio:(BOOL)reportRssiAudio reportNearFarAudio:(BOOL)reportNearFarAudio reportNearFarToBase:(BOOL)reportNearFarToBase sensitivity:(uint8_t)sensitivity nearThreshold:(uint8_t)nearThreshold maxTimeout:(int16_t)maxTimeout;

@property(nonatomic,assign) uint8_t connectionId;
@property(nonatomic,assign) BOOL enable;
@property(nonatomic,assign) BOOL dononly;
@property(nonatomic,assign) BOOL trend;
@property(nonatomic,assign) BOOL reportRssiAudio;
@property(nonatomic,assign) BOOL reportNearFarAudio;
@property(nonatomic,assign) BOOL reportNearFarToBase;
@property(nonatomic,assign) uint8_t sensitivity;
@property(nonatomic,assign) uint8_t nearThreshold;
@property(nonatomic,assign) int16_t maxTimeout;


@end
