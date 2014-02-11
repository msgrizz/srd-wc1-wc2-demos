//
//  ThreadUtil.h
//  PlantroncisDFU
//
//  Created by amandravin on 6/26/13.
//  Copyright (c) 2013 Plantroncis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>


class PltCustomThreadCallback;

@interface PltCustomThread : NSObject
{
    pthread_t                   m_thread;
    CFRunLoopRef                m_runLoop;
    bool                        m_shutdown;
    dispatch_semaphore_t        m_startupCondition;
    CFRunLoopSourceRef          m_stopSignalSource;
    PltCustomThreadCallback*    m_callback;
}

- (CFRunLoopRef) getRunLoop;

- (void) join;

+ (void) asyncRunBlock:(void (^)(void))block inRunLoop:(CFRunLoopRef)runLoop;
+ (void) syncRunBlock:(void (^)(void))block inRunLoop:(CFRunLoopRef)runLoop;

@end