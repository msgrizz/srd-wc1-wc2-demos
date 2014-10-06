//
//  BRConfigureAutotransferCallCommand.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/03/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRCommand.h"


#define BR_CONFIGURE_AUTOTRANSFER_CALL 0x020C



@interface BRConfigureAutotransferCallCommand : BRCommand

+ (BRConfigureAutotransferCallCommand *)commandWithAutoTransferCall:(BOOL)autoTransferCall;

@property(nonatomic,assign) BOOL autoTransferCall;


@end
