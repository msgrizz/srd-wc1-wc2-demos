//
//  EASessionController.h
//  MfiHelper
//
//  Created by Evgeniy Kapralov on 3/25/13.
//  Copyright (c) 2013 Evgeniy Kapralov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@protocol EASessionControllerDelegate

- (void)dataReceived:(NSData*)data;

@end

// NOTE: EASessionController is not thread-safe

@interface EASessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate>
{
    EAAccessory* m_accessory;
    NSString* m_protocolString;
}

@property (atomic, readonly) EAAccessory* accessory;
@property (atomic, readonly) NSString* protocolString;
@property (atomic, strong) EASession* session;
@property (atomic, assign) id<EASessionControllerDelegate> delegate;

- (id)initWithDevice:(void*)device andRequestQueue:(void*)requestQueue andResponseQueue:(void*)responseQueue;
- (BOOL)openSessionForAddress:(const char*)address;
- (void)sendCloseMessage;
- (void)closeSession;
- (void)setResponseQueueMap:(void*)map;

- (void)writeData:(NSData *)data;
- (NSArray*)getBladeRunnerDevices;
- (NSArray*)discoverBladeRunnerDevices;

@end
