//
//  PLTContextServer.h
//  WebSocketTest1
//
//  Created by Antony Bayley on 04/05/2012.
//  Copyright (c) 2012 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "PLTContextServerMessage.h"


// for convenience
#define CLIENT_AUTHENTICATED	([PLTContextServer sharedContextServer].state >= PLT_CONTEXT_SERVER_AUTHENTICATED)
#define DEVICE_REGISTERED		([PLTContextServer sharedContextServer].state == PLT_CONTEXT_SERVER_REGISTERED)

// enable or disable debug log messages for this module only
//#define DEBUG_PRINT_ENABLED_CS

#ifdef DEBUG_PRINT_ENABLED_CS
#define debugLog_CS(...) debugLog(__VA_ARGS__)
#define debugPrintf_CS(...) printf(__VA_ARGS__)
#else
#define debugLog_CS(...) do {} while (0)     // optimized out by the compiler
#define debugPrintf_CS(...) do {} while (0)  // optimized out by the compiler
#endif


extern NSString *const PLTContextServerDidChangeStateNotification;
extern NSString *const PLTContextServerDidChangeStateNotificationInfoKeyState;
extern NSString *const PLTContextServerDidChangeStateNotificationInfoKeyPreviousState;
extern NSString *const PLTContextServerNewLogOutputNotification;
extern NSString *const PLTContextServerNewLogOutputNotificationInfoKeyOutput;
extern NSString *const PLTContextServerNewLogOutputNotificationInfoKeyLog;


@protocol PLTContextServerDelegate;

// state of connection between iPhone client and context server
typedef enum {
    PLT_CONTEXT_SERVER_CLOSED = 0,
    PLT_CONTEXT_SERVER_CLOSING = 1,
    PLT_CONTEXT_SERVER_OPENING = 2,
    PLT_CONTEXT_SERVER_OPEN = 3,
    PLT_CONTEXT_SERVER_AUTHENTICATING = 4,
    PLT_CONTEXT_SERVER_AUTHENTICATED = 5,
    PLT_CONTEXT_SERVER_REGISTERING = 6,
    PLT_CONTEXT_SERVER_REGISTERED = 7,
	PLT_CONTEXT_SERVER_UNREGISTERING = 8
} PLTContextServerState;


@interface PLTContextServer : NSObject

// ----------------------------------------------------------------------------
// class methods
// ----------------------------------------------------------------------------

// a single instance of PLTContexServer is shared by all users
+(PLTContextServer *)sharedContextServer;
+(PLTContextServer *)sharedContextServerWithURL:(NSString *)url
                                       username:(NSString *)username
                                       password:(NSString *)password
                                      protocols:(NSArray *)protocols;

// enforce singleton status of the PLTContextServer class
+(id)allocWithZone:(NSZone *)zone;


// ----------------------------------------------------------------------------
// instance properties
// ----------------------------------------------------------------------------
@property(nonatomic,copy)       NSString                *url;
@property(nonatomic,copy)       NSString                *username;
@property(nonatomic,copy)       NSString                *password;
@property(nonatomic,strong)     NSArray                 *protocols;
@property(nonatomic,readonly)   PLTContextServerState   state;
@property(nonatomic,strong)     NSDate                  *authenticationDate; // should be read-only
@property(nonatomic,readonly)	NSString				*log;
@property(nonatomic,strong)		PLTContextServerMessage *latestMessage;


// ----------------------------------------------------------------------------
// instance methods
// ----------------------------------------------------------------------------
- (void) openConnection;
- (void) closeConnection;
- (BOOL) sendMessage:(PLTContextServerMessage *)message cacheIfServerIsOffline:(BOOL)cacheEnable;
- (void) addDelegate:(id<PLTContextServerDelegate>)delegate;
- (void) removeDelegate:(id<PLTContextServerDelegate>)delegate;
//- (BOOL) hasDelegate:(id)obj;

@end


// ----------------------------------------------------------------------------
// PLTContextServerDelegate methods
// ----------------------------------------------------------------------------
@protocol PLTContextServerDelegate <NSObject>

@optional

- (void) server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message;
- (void) serverDidOpen:(PLTContextServer *)sender;
- (void) server:(PLTContextServer *)sender didAuthenticate:(BOOL)authenticationWasSuccessful;
- (void) server:(PLTContextServer *)sender didRegister:(BOOL)registrationWasSuccessful;
- (void) server:(PLTContextServer *)sender didUnregister:(BOOL)unregistrationWasSuccessful;
- (void) server:(PLTContextServer *)sender didFailWithError:(NSError *)error;
- (void) server:(PLTContextServer *)sender didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (BOOL) serverShouldTryToReconnect:(PLTContextServer *)sender;
                  
@end
                  
