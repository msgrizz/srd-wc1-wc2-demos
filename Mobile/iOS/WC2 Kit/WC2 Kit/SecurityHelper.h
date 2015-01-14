//
//  SecurityHelper.h
//  WC2 Kit
//
//  Created by Morgan Davis on 1/1/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SecurityHelperEnrollDelegate;
@protocol SecurityHelperSignDelegate;


typedef enum {
	SigningStateRetrievingEnrollments,
	SigningStateSigningOnDevice,
	SigningStateVerifyingSignatureWithServer
} SigningState;


@interface SecurityHelper : NSObject

+ (SecurityHelper *)sharedHelper;
- (void)ping;
- (void)enroll:(id <SecurityHelperEnrollDelegate>)delegate;
- (void)sign:(id <SecurityHelperSignDelegate>)delegate;

@property (nonatomic,retain)	NSString	*serverAddress;
@property (nonatomic,retain)	NSString	*serverUsername;
@property (nonatomic,retain)	NSString	*serverPassword;

@end


@protocol SecurityHelperEnrollDelegate <NSObject>

- (void)securityHelperDidEnroll:(SecurityHelper *)theHelper;
- (void)securityHelper:(SecurityHelper *)theHelper didEncounterErrorEnrolling:(NSError *)error;

@end


@protocol SecurityHelperSignDelegate <NSObject>

- (void)securityHelper:(SecurityHelper *)theHelper didUpdateSigningState:(SigningState)state;
- (void)securityHelperDidAuthenticate:(SecurityHelper *)theHelper;
- (void)securityHelperDidFailAuthenticate:(SecurityHelper *)theHelper;
- (void)securityHelper:(SecurityHelper *)theHelper didEncounterErrorAuthenticating:(NSError *)error;

@end
