//
//  PLTContextServer.m
//
//  Created by Antony Bayley on 19/06/2012.
//  Copyright (c) 2012 Plantronics, Inc. All rights reserved.
//

#import "PLTContextServer.h"


NSString *const PLTContextServerDidChangeStateNotification =						@"PLTContextServerDidChangeStateNotification";
NSString *const PLTContextServerDidChangeStateNotificationInfoKeyState =			@"PLTContextServerDidChangeStateNotificationInfoKeyState";
NSString *const PLTContextServerDidChangeStateNotificationInfoKeyPreviousState =	@"PLTContextServerDidChangeStateNotificationInfoKeyPreviousState";
NSString *const PLTContextServerNewLogOutputNotification =							@"PLTContextServerNewLogOutputNotification";
NSString *const PLTContextServerNewLogOutputNotificationInfoKeyOutput =				@"PLTContextServerNewLogOutputNotificationInfoKeyOutput";
NSString *const PLTContextServerNewLogOutputNotificationInfoKeyLog =				@"PLTContextServerNewLogOutputNotificationInfoKeyLog";


@interface PLTContextServer () <SRWebSocketDelegate, UIAlertViewDelegate>
{
    // instance variables
    // (strong by default, unless declaration is prefixed by __weak)

    // DO NOT USE INSTANCE VARIABLES IN A SINGLE INSTANCE CLASS!!!
	
	// Added by Morgan:
	PLTContextServerState _state;
}

// class extension properties
@property(nonatomic,assign) PLTContextServerState state;            // context server connection state
@property(nonatomic,strong) SRWebSocket *webSocket;                 // websocket used to communicate with context server
@property(nonatomic,strong) NSTimer *connectionTimer;               // connection attempt times out if server does not respond
@property(nonatomic,strong) NSTimer *retryTimer;                    // delay before retrying if connection fails
@property(nonatomic,strong) NSMutableArray *delegates;              // PLTContextServer delegates
@property(nonatomic,strong) NSMutableArray *messageCache;           // cache for messages sent while server is offline
@property(nonatomic,assign) NSUInteger serverConnectionAttempts;    // number of failed connection attempts
@property(nonatomic,strong) UIAlertView *reconnectAlertView;
@property(nonatomic,strong) NSMutableString *_log;
@property(nonatomic,assign) BOOL cancelledReconnect;

// class extension methods
- (void) connectFromDisconnectedState;
- (void) authenticate;
- (void) connectionTimeout;
- (BOOL) sendMessage:(PLTContextServerMessage *)message;
- (void) showReconnectAlert;
- (void) log:(NSString *)format, ...;

@end


int _heading, _pitch;



@implementation PLTContextServer

@synthesize authenticationDate = _authenticationDate;
@dynamic state;
@dynamic log;

- (PLTContextServerState)state
{
	return _state;
}

- (void)setState:(PLTContextServerState)state
{
	PLTContextServerState previousState = _state;
	_state = state;
	if (state != previousState) {
		NSDictionary *userInfo = @{
		PLTContextServerDidChangeStateNotificationInfoKeyState : @(_state),
		PLTContextServerDidChangeStateNotificationInfoKeyPreviousState : @(previousState)};
		[[NSNotificationCenter defaultCenter] postNotificationName:PLTContextServerDidChangeStateNotification object:nil userInfo:userInfo];
	}
}

- (NSString *)log
{
	return self._log;
}

// ----------------------------------------------------------------------------
// PLTContextServer class methods
// ----------------------------------------------------------------------------

// a single instance of PLTContextServer is shared by all users
+(PLTContextServer *)sharedContextServerWithURL:(NSString *)url
                                       username:(NSString *)username
                                       password:(NSString *)password
                                      protocols:(NSArray *)protocols
{
    static PLTContextServer *sharedContextServer = nil;
    if (!sharedContextServer)
    {
        // initialization carried out the first time the class is instantiated
        sharedContextServer = [[super allocWithZone:nil] init];
        if (sharedContextServer)
        {
            // Initialize properties
			sharedContextServer.url = url;
            sharedContextServer.username = username;
            sharedContextServer.password = password;
            sharedContextServer.state = PLT_CONTEXT_SERVER_CLOSED;
            sharedContextServer.authenticationDate = nil;
            sharedContextServer.delegates = [[NSMutableArray alloc] init];
            sharedContextServer.webSocket = nil;
            sharedContextServer.protocols = protocols;
            sharedContextServer.connectionTimer = nil;
            sharedContextServer.messageCache = [[NSMutableArray alloc] init];
            //sharedContextServer.serverConnectionAttempts = 0;
			
			sharedContextServer._log = [NSMutableString string];
            
            debugLog_CS(@"[CS] starting context server with properties...");
            debugLog_CS(@"[CS]   URL = %@", sharedContextServer.url);
            debugLog_CS(@"[CS]   username = %@", sharedContextServer.username);
            debugLog_CS(@"[CS]   password = %@", sharedContextServer.password);
            debugLog_CS(@"[CS]   protocols = %@", sharedContextServer.protocols);
        }
    }
    
    if (url) sharedContextServer.url = url;
    if (username) sharedContextServer.username = username;
    if (password) sharedContextServer.password = password;
    if (protocols) sharedContextServer.protocols = protocols;
    
    return sharedContextServer;
}


// a single instance of PLTContextServer is shared by all users
+ (PLTContextServer *) sharedContextServer
{
    // call this class's designated initializer
    return [PLTContextServer sharedContextServerWithURL:nil username:nil password:nil protocols:nil];
}


// enforce singleton status of the PLTContextServer class
+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedContextServer];
}


// ----------------------------------------------------------------------------
// PLTContextServer instance methods and properties
// ----------------------------------------------------------------------------

// public properties
@synthesize url = _url;
@synthesize username = _username;
@synthesize password = _password;
@synthesize protocols = _protocols;
//@synthesize state = _state;
@synthesize delegates = _delegates;
@synthesize reconnectAlertView = _reconnectAlertView;


// *******  PLTContextServer public methods  *******

- (void) openConnection
{
    debugLog_CS(@"[CS] Openning connection to context server...\n");
	
	self.cancelledReconnect = NO;
    
    // Ignore the request if a connection is already in progress
    if (!self.connectionTimer)
    {
        // set a timeout to prevent application hang if the server is offline
        // or fails to respond
        debugLog_CS(@"Creating connection timer...\n");
        self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(connectionTimeout) userInfo:nil repeats:NO];
        
        if (self.state == PLT_CONTEXT_SERVER_CLOSED) {
            [self connectFromDisconnectedState];
            self.authenticationDate = nil;
        }
        else {
            // close any existing connection before opening the new connection
            [self closeConnection];
        }
    }
    else {
        debugLog_CS(@"[CS] Connection already pending.\n");
    }
}

- (void) closeConnection
{
    if (self.state != PLT_CONTEXT_SERVER_CLOSED)
    {
        debugLog_CS(@"[CS] Closing connection to context server...");
		[self log:@"Closing connection with server..."];
        self.state = PLT_CONTEXT_SERVER_CLOSING;
        self.authenticationDate = nil;
        [self.webSocket close];
    }
}


// send message, or cache if server is offline
- (BOOL) sendMessage:(PLTContextServerMessage *)message cacheIfServerIsOffline:(BOOL)cacheEnable
{
    BOOL messageWasSent = NO;

    if (self.state >= PLT_CONTEXT_SERVER_AUTHENTICATED) {
        messageWasSent = [self sendMessage:message];
    }
    else {
        if (cacheEnable) {
            debugLog_CS(@"[CS] Caching message: context server is not connected");
            [self.messageCache addObject:message];
        }
        else {
            debugLog_CS(@"[CS] Discarding message: context server is not connected");
        }
        // increment the connection attempts counter and connect to server
        //self.serverConnectionAttempts++;
        [self openConnection];
    }
    return messageWasSent;
}


// send message without caching - only used inside the PLTContextServer class to
// open and authenticate the websocket connection.
- (BOOL) sendMessage:(PLTContextServerMessage *)message
{
    BOOL messageWasSent = NO;
    
    // check that WebSocket is open
    if (self.state < PLT_CONTEXT_SERVER_OPEN) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Context Server Exception" 
                              message:@"WebSocket is not open." 
                              delegate:nil 
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    // check that Server authentication is complete
    else if (self.state < PLT_CONTEXT_SERVER_AUTHENTICATED && ![message.type isEqualToString:MESSAGE_TYPE_AUTHENTICATE]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Context Server Exception" 
                              message:@"Server requires authentication with username & password." 
                              delegate:nil 
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    else
    {
        // send message
        
        // SocketRocket requires JSON packaged as an NSString object, in order to set frame type to 'text'
        NSString *jsonDataAsString = [message copyAsJSONStringWithOption:kNilOptions];
        [self.webSocket send:jsonDataAsString];
        jsonDataAsString = [message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted];
        debugLog_CS(@"[CS] Send message...\n%@\n", jsonDataAsString);
        messageWasSent = YES;
        
        // update connection state, if authentication is in progress
        if ([message.type isEqualToString:MESSAGE_TYPE_AUTHENTICATE]) {
            self.state = PLT_CONTEXT_SERVER_AUTHENTICATING;
			[self log:@"Authenticating user \"%@\"...", self.username];
        }
        if ([message.type isEqualToString:MESSAGE_TYPE_REGISTER_DEVICE]) {
			if ([message.messageId isEqualToString:REGISTER_DEVICE]) {
				self.state = PLT_CONTEXT_SERVER_REGISTERING;
				[self log:@"Registering device \"%@\"...", ((NSDictionary *)message.payload[@"device"])[@"deviceId"]];
			}
            else {
				self.state = PLT_CONTEXT_SERVER_UNREGISTERING;
				[self log:@"Unregistering device \"%@\"...", ((NSDictionary *)message.payload[@"device"])[@"deviceId"]];
			}
        }
    }  
    return messageWasSent;
}


- (void) addDelegate:(id<PLTContextServerDelegate>)delegate
{
	if (![self.delegates containsObject:delegate]) {
		__weak id weakDelegate = delegate;
		[self.delegates addObject:weakDelegate];
	}
}


- (void) removeDelegate:(id<PLTContextServerDelegate>)delegate
{
	if ([self.delegates containsObject:delegate]) {
		[self.delegates removeObject:delegate];
	}
}

//- (BOOL) hasDelegate:(id)obj
//{
//    return [self.delegates containsObject:delegate];
//}


// *******  PLTContextServer class extension methods  *******

- (void) connectFromDisconnectedState
{
    debugLog_CS(@"[CS] Opening connection to context server (from disconnect)...");
	[self log:@"Connecting to server at %@...", self.url];
    NSURL *serverUrl = [NSURL URLWithString:self.url];
    self.webSocket = [[SRWebSocket alloc] initWithURL:serverUrl protocols:self.protocols];
    self.webSocket.delegate = self;
    self.state = PLT_CONTEXT_SERVER_OPENING;
    [self.webSocket open];
}


- (void) authenticate
{
    debugLog_CS(@"[CS] Authenticating...");
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.username, @"username",
                             self.password, @"password",
                             nil];
    PLTContextServerMessage *message = [[PLTContextServerMessage alloc] initWithType:MESSAGE_TYPE_AUTHENTICATE messageId:AUTHENTICATE_USERNAME_PASSWORD payload:payload];    
    [self sendMessage:message]; 
}


//- (void) connectionTimeout
//{
//    if (self.state >= PLT_CONTEXT_SERVER_OPEN) {
//        debugLog_CS(@"[CS] Authentication failure: server did not respond\n");
//        self.state = PLT_CONTEXT_SERVER_OPEN;
//    }
//    else {
//        debugLog_CS(@"[CS] Connection failure: server did not respond\n");
//        self.state = PLT_CONTEXT_SERVER_CLOSED;
//    }
//    
//    // notify the PLTContextServer delegates that authentication failed
//    for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
//        if ([delegate respondsToSelector:@selector(server:didAuthenticate:)]) {
//            [delegate server:self didAuthenticate:NO];
//        }
//    }
//    
//    // kill the connection timer
//    if (self.connectionTimer) {
//        [self.connectionTimer invalidate];
//        self.connectionTimer = nil;
//    }
//    
//    if (self.serverConnectionAttempts == 3) {
//        // alert the user after 3 consecutive connection failures
//        NSString *alertMessage = [NSString stringWithFormat:@"Context Server connection failed: message timeout"];
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"Context Server Exception"
//                              message:alertMessage
//                              delegate:nil
//                              cancelButtonTitle:@"Reconnect"
//                              otherButtonTitles:nil];
//        [alert show];
//    }
//    
//    // continue attempting reconnection every 10 seconds while app is in the foreground
//    self.serverConnectionAttempts++;
//    [self openConnection];    
//}


- (void) connectionTimeout
{
    debugLog_CS(@"[CS] Connection timed out.\n");
	[self log:@"Connection timed out."];
    
    if (self.state >= PLT_CONTEXT_SERVER_OPEN) {
        debugLog_CS(@"[CS] Authentication failure: server did not respond\n");
		[self log:@"Authentication failure: server did not respond."];
        self.state = PLT_CONTEXT_SERVER_OPEN;
    }
    else {
        debugLog_CS(@"[CS] Connection failure: server did not respond\n");
		[self log:@"Connection failure: server did not respond."];
        self.state = PLT_CONTEXT_SERVER_CLOSED;
        self.authenticationDate = nil;
    }
    
    // notify the PLTContextServer delegates that authentication failed
    for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
        if ([delegate respondsToSelector:@selector(server:didAuthenticate:)]) {
            [delegate server:self didAuthenticate:NO];
        }
    }
    
    // kill the connection timer
    if (self.connectionTimer) {
        debugLog_CS(@"[CS] Killing connection timer (1).\n");
        [self.connectionTimer invalidate];
        self.connectionTimer = nil;
    }
    
    [self showReconnectAlert];
    
//    if (self.serverConnectionAttempts == 3) {
//        // alert the user after 3 consecutive connection failures
//        NSString *alertMessage = [NSString stringWithFormat:@"Context Server connection failed: message timeout"];
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"Context Server Exception"
//                              message:alertMessage
//                              delegate:nil
//                              cancelButtonTitle:@"Reconnect"
//                              otherButtonTitles:nil];
//        [alert show];
//    }
    
    // continue attempting reconnection every 10 seconds while app is in the foreground
    //self.serverConnectionAttempts++;
    [self openConnection];
}

- (void)showReconnectAlert
{
    NSLog(@"showReconnectAlert");
    
    // block the user with a "Reconnecting" alert until a new connection is established
    if(!self.reconnectAlertView) {
        self.reconnectAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Lost"
                                                             message:@"Please wait while the context server connection is re-established...\n\n\n"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [self.reconnectAlertView show];
		
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(self.reconnectAlertView.bounds.origin.x + self.reconnectAlertView.bounds.size.width / 2.0,
                                       self.reconnectAlertView.bounds.origin.y + self.reconnectAlertView.bounds.size.height - 90);
		
		[indicator startAnimating];
        [self.reconnectAlertView addSubview:indicator];
    }
}

// *******  UIAlertVIewDelegate methods *******

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"alertView:didDismissWithButtonIndex: %d",buttonIndex);
	
	if ([self.connectionTimer isValid]) {
		[self.connectionTimer invalidate];
		self.connectionTimer = nil;
	}
	if ([self.retryTimer isValid]) {
		[self.retryTimer invalidate];
		self.retryTimer = nil;
	}
	self.cancelledReconnect = YES;
	self.reconnectAlertView = nil;
	[self closeConnection];
}


// *******  SRWebSocketDelegate methods  *******


- (void)webSocket:(SRWebSocket *)sender didReceiveMessage:(id)json
{
	debugLog_CS(@"[CS] Received message from context server...");
    
    PLTContextServerMessage *message = [[PLTContextServerMessage alloc] initWithJsonData:json];
	self.latestMessage = message;
    
    if (!message) {
        // invalid PLTMessage
        debugLog_CS(@"[CS] Message contains invalid JSON");
    }
    else {
        // valid PLTMessage
#if (DEBUG_PRINT_ENABLED == 1 && defined(DEBUG_PRINT_ENABLED_CS))
        NSString *jsonDataAsString = [message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted];
        debugLog_CS(@"[CS] %@\n", jsonDataAsString);
#endif
        
        //NSLog(@"MESSAGE: %@",[message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]);
        
        // parse message
        
        // handle authentication messages in this class
        if([message hasType:MESSAGE_TYPE_AUTHENTICATE])
        {
            BOOL authenticationWasSuccessful = NO;
            
            if ([message hasMessageId:AUTHENTICATE_SUCCESS]) {
                // authentication is complete
                authenticationWasSuccessful = YES;
                debugLog_CS(@"[CS] Authentication response: success\n");
				[self log:@"Successfully authenticated."];
                self.state = PLT_CONTEXT_SERVER_AUTHENTICATED;
                self.authenticationDate = [NSDate date];

                // reset the connection attempts count
                //self.serverConnectionAttempts = 0;
                
                // send cached messages
                NSMutableArray *sentMessages = [[NSMutableArray alloc] init];
                if (self.messageCache.count > 0) {
                    debugLog_CS(@"[CS] Sending %d cached messages to server", self.messageCache.count);
                    for (PLTContextServerMessage *message in self.messageCache) {
                        if ([self sendMessage:message cacheIfServerIsOffline:NO]) {
                            // message was sent successfully
                            [sentMessages addObject:message];
                        }
                        else
                            // sendMessage:cacheIfServerIsOffline: method has already incremented
                            // self.serverConnectionAttempts and initiated a new connection attempt.
                            break;
                    }
                    // remove the messages that were sent successfully from the cache
                    for (PLTContextServerMessage *message in sentMessages) {
                        [self.messageCache removeObject:message];
                    }
                }
                
                [self.reconnectAlertView dismissWithClickedButtonIndex:0 animated:YES];
                self.reconnectAlertView = nil;
            }
            else {
                debugLog_CS(@"[CS] Authentication response: failed\n");
				[self log:@"Authentication failed."];
                //self.state = PLT_CONTEXT_SERVER_OPEN;
                [self closeConnection];
            }
            // notify the PLTContextServer delegates about the authentication result
            for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
                if ([delegate respondsToSelector:@selector(server:didAuthenticate:)]) {
                    [delegate server:self didAuthenticate:authenticationWasSuccessful];
                }
            }
            // kill the connection timer
            if (self.connectionTimer) {
                debugLog_CS(@"[CS] Killing connection timer (2).\n");
                [self.connectionTimer invalidate];
                self.connectionTimer = nil;
            }
        }
        
		else if([message hasType:MESSAGE_TYPE_REGISTER_DEVICE])
        {            
			if ([message hasMessageId:REGISTER_SUCCESS] ) {
				// registration complete
                debugLog_CS(@"[CS] Registration response: success\n");
				[self log:@"Successfully registered device."];
                self.state = PLT_CONTEXT_SERVER_REGISTERED;
				
				for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
					if ([delegate respondsToSelector:@selector(server:didRegister:)]) {
						[delegate server:self didRegister:YES];
					}
				}
            }
			else if ([message hasMessageId:REGISTER_FAILED]) {
				// registration failed
				debugLog_CS(@"[CS] Registration response: failed\n");
				[self log:@"Registration failed."];
                self.state = PLT_CONTEXT_SERVER_AUTHENTICATED;
				
				for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
					if ([delegate respondsToSelector:@selector(server:didRegister:)]) {
						[delegate server:self didRegister:NO];
					}
				}
			}
			else if ([message hasMessageId:UNREGISTER_SUCCESS]) {
				// unregister complete
				debugLog_CS(@"[CS] Unregistration responce: success\n");
				[self log:@"Successfully unregistered device."];
                self.state = PLT_CONTEXT_SERVER_AUTHENTICATED;
				
				for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
					if ([delegate respondsToSelector:@selector(server:didUnregister:)]) {
						[delegate server:self didUnregister:YES];
					}
				}
			}
			else if ([message.messageId isEqualToString:UNREGISTER_FAILED]) {
				// unregister failed
				debugLog_CS(@"[CS] Unregistration responce: failed\n");
				[self log:@"Unregistration failed."];
                self.state = PLT_CONTEXT_SERVER_REGISTERED;
				
				for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
					if ([delegate respondsToSelector:@selector(server:didUnregister:)]) {
						[delegate server:self didUnregister:NO];
					}
				}
			}
        }
        
		// send all other message types to the PLTContextServer delegate
        else
        {
            for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
                if([delegate respondsToSelector:@selector(server:didReceiveMessage:)]) {
                    [delegate server:self didReceiveMessage:message];
                }
            }
        }
    }
}


- (void)webSocketDidOpen:(SRWebSocket *)sender
{
    debugLog_CS(@"[CS] Context server did open");
	[self log:@"Successfully connected to server."];
    self.state = PLT_CONTEXT_SERVER_OPEN;
    
    // notify the PLTContextServer delegate that the WebSocket is open
    for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
        if ([delegate respondsToSelector:@selector(serverDidOpen:)]) {
            [delegate serverDidOpen:self];
        }
    }
    // authenticate
    [self authenticate];
}


- (void)webSocket:(SRWebSocket *)sender didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
	NSLog(@"didCloseWithCode: %d, reason: %@, wasClean: %@", code, reason, (wasClean?@"YES":@"NO") );
	
    self.state = PLT_CONTEXT_SERVER_CLOSED;
    self.authenticationDate = nil;
	self.latestMessage = nil;
    debugLog_CS(@"[CS] Context Server did close with code: %d, reason: %@, wasClean: %d", code, reason, wasClean);
	[self log:@"Server connection closed with code: %@, reason: %@, clean? %@",
	 [NSString stringWithFormat:@"%d",code], reason, (wasClean?@"YES":@"NO")];
    
    // notify the PLTContextServer delegate that the WebSocket connection has closed
    for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
        if ([delegate respondsToSelector:@selector(server:didCloseWithCode:reason:wasClean:)]) {
            [delegate server:self didCloseWithCode:code reason:reason wasClean:wasClean];
        }
    }
    self.webSocket.delegate = nil;

    // if the previous connection was closed as part of the reconnection sequence,
    // open the new connection
    // Added code==SRStatusCodeDisconnectFailure 11-26-12 by Morgan
    //if (self.connectionTimer || (code==SRStatusCodeDisconnectFailure)) {
    if (self.connectionTimer) {
        [self connectFromDisconnectedState];
    }
}


- (void)webSocket:(SRWebSocket *)sender didFailWithError:(NSError *)error
{
    debugLog_CS(@"[CS] Context server did fail with error: %@", error);
	[self log:@"Connection failed with error: %@", error];
    self.state = PLT_CONTEXT_SERVER_CLOSED;
    self.authenticationDate = nil;
    
    // notify the PLTContextServer delegate that the context server has failed
    for (id<PLTContextServerDelegate> delegate in [self.delegates copy]) {
        if ([delegate respondsToSelector:@selector(server:didFailWithError:)]) {
            [delegate server:self didFailWithError:error];
        }
    }
	
	if (!self.cancelledReconnect) {
		[self showReconnectAlert];
		
		//    if (self.serverConnectionAttempts == 3) {
		//        // alert the user after 3 consecutive connection failures
		//        NSString *alertMessage = [NSString stringWithFormat:@"Context Server connection failed with error:\n%@", error];
		//        UIAlertView *alert = [[UIAlertView alloc]
		//                              initWithTitle:@"Context Server Exception"
		//                              message:alertMessage
		//                              delegate:nil
		//                              cancelButtonTitle:@"Reconnect"
		//                              otherButtonTitles:nil];
		//        [alert show];
		//    }
		
		// kill the connection timer
		if (self.connectionTimer) {
			debugLog_CS(@"[CS] Killing connection timer (3).\n");
			[self.connectionTimer invalidate];
			self.connectionTimer = nil;
		}
		
		// continue attempting reconnection every 5 seconds while app is in the foreground
		//self.serverConnectionAttempts++;
		self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(openConnection) userInfo:nil repeats:NO];
	}
}

//void HSLog(NSString *format, va_list list)
- (void)log:(NSString *)format, ...
{
		va_list args;
	va_start(args, format);
    NSString *formatted = [[NSString alloc] initWithFormat:format arguments:args];
	NSLog(@"%@", formatted);
	formatted = [formatted stringByAppendingString:@"\n"];
	va_end(args);
	[self._log appendString:formatted];
	NSDictionary *userInfo = @{PLTContextServerNewLogOutputNotificationInfoKeyOutput : formatted,
							PLTContextServerNewLogOutputNotification : self._log};
	[[NSNotificationCenter defaultCenter] postNotificationName:PLTContextServerNewLogOutputNotification object:nil userInfo:userInfo];
}


@end
