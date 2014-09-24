//
//  LockViewController.m
//  BangleTD&S
//
//  Created by Morgan Davis on 6/11/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "LockViewController.h"
#import "NSData+Hash.h"
#import "NSData+HexStrings.h"
#import <Security/Security.h>
#import "BRPerformApplicationActionCommand.h"
#import "AppDelegate.h"
#import "PLTDevice_Internal.h"
#import "BRDevice.h"
#import "BRRawMessage.h"


@interface LockViewController ()

@property(nonatomic,assign)	BOOL					locked;
@property(nonatomic,strong)	IBOutlet	UIButton	*lockUnlockButton;

- (IBAction)lockUnlockButton:(id)sender;
- (IBAction)lockButton:(id)sender;
- (IBAction)addContactButton:(id)sender;
- (NSString *)passwordHashByAddingToKeychain;
- (NSString *)passwordHashFromKeychain;
- (void)setLockState:(BOOL)lockState;
- (void)updateLockUnlockButton;

@end


@implementation LockViewController

#pragma mark - Private

- (IBAction)lockUnlockButton:(id)sender
{
	NSLog(@"unlockButton");
	
	[self performSelectorInBackground:@selector(_lockUnlockButton) withObject:nil];
}

- (IBAction)lockButton:(id)sender
{
	NSLog(@"lockButton:");
	[self setLockState:YES];
}

- (IBAction)addContactButton:(id)sender
{
	NSLog(@"addContactButton:");
	
	const char *name = [@"CARY" cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *nameData = [NSData dataWithBytes:name length:strlen(name)];
	//uint16_t nameLen = (uint16_t)[nameData length];
	
	const char *number = [@"2066612398" cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *numberData = [NSData dataWithBytes:number length:strlen(number)];
	//uint16_t numberLen = (uint16_t)[numberData length];
	
	NSString *hexString = [NSString stringWithFormat:@"%@ 00 %@ 00",
						   [nameData hexStringWithSpaceEvery:0],
						   [numberData hexStringWithSpaceEvery:0]
						   ];
	
	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
	hexString = [NSString stringWithFormat:@"%04X %04X %@",
				 0xFF0B,
				 deckardArrayLen,
				 hexString
				 ];
	
	BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeCommand payload:[NSData dataWithHexString:hexString]];
	//[self.sensorsDevice sendMessage:message];
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BRDevice *sensorsDevice = appDelegate.device.brDevice.remoteDevices[@(5)];
	[sensorsDevice sendMessage:message];
}

- (void)_lockUnlockButton
{
	NSLog(@"_lockUnlockButton");
	
	if (self.locked) {
		NSString *password = [self passwordHashFromKeychain];
		NSLog(@"Password: %@", password);
		
		if (!password) {
			password = [self passwordHashFromKeychain];
			NSLog(@"Password: %@", password);
		}
		
		[self setLockState:NO];
		self.locked = NO;
	}
	else {
		[self setLockState:YES];
		self.locked = YES;
	}
	
	[self updateLockUnlockButton];
}

- (NSString *)passwordHashByAddingToKeychain
{
	NSLog(@"checkAddPasswordHash");
	
	// generate the password hash
	NSString *passwd = @"1234";
	NSData *passData = [NSData dataWithBytes:[passwd UTF8String] length:[passwd length]];
	NSData *shaData = [passData SHA1Data];
	
	SecAccessControlRef control = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
																  kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
																  kSecAccessControlUserPresence,
																  NULL);
	
	NSDictionary *query = @{(__bridge id)kSecClass:				(__bridge id)kSecClassGenericPassword,
							(__bridge id)kSecAttrService:		@"com.plantronics.BangleTD-SDemo.unlockPasscode.43",
							(__bridge id)kSecAttrAccessControl:	(__bridge id)control,
							(__bridge id)kSecValueData:			shaData
							};
	
	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, nil);
	
	if (status == noErr) {
		NSLog(@"Added password.");
	}
	else if (status == errSecDuplicateItem) {
		NSLog(@"Duplicate item.");
	}
	else {
		NSLog(@"Error adding password SecItem: %d", status);
	}

	return [shaData hexStringWithSpaceEvery:0];
}

- (NSString *)passwordHashFromKeychain
{
	NSLog(@"getPasswordHash");

	SecAccessControlRef control = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
																  kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
																  kSecAccessControlUserPresence,
																  NULL);
	
	NSDictionary *query = @{(__bridge id)kSecClass:					(__bridge id)kSecClassGenericPassword,
							(__bridge id)kSecAttrService:			@"com.plantronics.BangleTD-SDemo.unlockPasscode.43",
							(__bridge id)kSecAttrAccessControl:		(__bridge id)control,
							(__bridge id)kSecUseOperationPrompt:	@"Bangle",
							(__bridge id)kSecReturnData:			@YES
							};
	
	OSStatus status = noErr;
	CFTypeRef data = nil;
	
	status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), &data);
	
	NSString *shaString = [(__bridge NSData *)data hexStringWithSpaceEvery:0];
	
	NSLog(@"Get status: %d", status);
	
	if (status == errSecItemNotFound) {
		[self passwordHashByAddingToKeychain];
		return nil;
	}
	if (status == errSecSuccess) {
		NSLog(@"Lookup errSecSuccess.");
	}
	else if (status == noErr) {
		NSLog(@"Lookup noErr.");
	}
	
	return shaString;
}

- (void)setLockState:(BOOL)lockState
{
	[self performSelectorOnMainThread:@selector(_setLockState:) withObject:@(lockState) waitUntilDone:NO];
}

- (void)_setLockState:(NSNumber *)lockStateNum
{
	@autoreleasepool {
		BOOL lockState = [lockStateNum boolValue];
		
		NSMutableString *hexString = [NSMutableString stringWithFormat:@"%02X",
									  lockState];
		
		uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
		hexString = [NSMutableString stringWithFormat:@"%04X %@",
					 deckardArrayLen,
					 hexString
					 ];
		
		BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDLock
																																			   action:0
																																		operatingData:[NSData dataWithHexString:hexString]];
		AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		BRDevice *sensorsDevice = appDelegate.device.brDevice.remoteDevices[@(5)];
		[sensorsDevice sendMessage:command];
	}
}

- (void)updateLockUnlockButton
{
	if (self.locked) {
		UIImage *unlockImage = [UIImage imageNamed:@"UnlockButton"];
		[self.lockUnlockButton setImage:unlockImage forState:UIControlStateNormal];
	}
	else {
		UIImage *lockImage = [UIImage imageNamed:@"LockButton"];
		[self.lockUnlockButton setImage:lockImage forState:UIControlStateNormal];
	}
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.locked = YES;
	
	[self updateLockUnlockButton];
	
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BRDevice *sensorsDevice = appDelegate.device.brDevice.remoteDevices[@(5)];
	sensorsDevice.delegate = self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
