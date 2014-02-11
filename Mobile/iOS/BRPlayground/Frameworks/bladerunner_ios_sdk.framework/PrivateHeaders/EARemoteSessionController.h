//
//  EARemoteSessionController.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 8/5/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__EARemoteSessionController__
#define __bladerunner_ios_sdk__EARemoteSessionController__

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@interface EARemoteSessionController : NSObject

@property (atomic, assign) EASession* session;

- (id)initWithDevice:(void*)device andRequestQueue:(void*)requestQueue andResponseQueue:(void*)responseQueue andSession:(void*)session;
- (BOOL)openSession:(uint8_t)port;
- (void)sendCloseMessage;
- (void)closeSession;

@end

#endif /* defined(__bladerunner_ios_sdk__EARemoteSessionController__) */
