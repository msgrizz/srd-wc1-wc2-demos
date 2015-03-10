//
//  BRCurrentSelectedLanguageChangedEvent.h
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 01/28/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "BREvent.h"


#define BR_CURRENT_SELECTED_LANGUAGE_CHANGED_EVENT 0x0E1A



@interface BRCurrentSelectedLanguageChangedEvent : BREvent

@property(nonatomic,readonly) int16_t languageId;


@end
