//
//  BRConfigureAutotransferCallCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_AUTOTRANSFER_CALL 0x020C



@interface BRConfigureAutotransferCallCommand : BRCommand

+ (BRConfigureAutotransferCallCommand *)commandWithAutoTransferCall:(BOOL)autoTransferCall;

@property(nonatomic,assign) BOOL autoTransferCall;


@end
