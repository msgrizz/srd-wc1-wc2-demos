//
//  ViewController.m
//  LockitronFinagler
//
//  Created by Morgan Davis on 12/10/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "ViewController.h"


NSString *const PLTAccessToken =	@"0ed01e72a1374dd306f92e4b042653e37c13bb2f65517963fcc42f6c27636881";
NSString *const PLTLock1ID =		@"33572b6a-0ca4-4361-804c-15801719a31c";
NSString *const PLTLock2ID =		@"0ca67ee8-1fc4-407e-8826-a47b3aaadc63";
NSString *const PLTLock3ID =		@"?";


typedef enum {
	PLTLockStateUnknown = -1,
	PLTLockStateUnlocked = 0,
	PLTLockStateLocked = 1
} PLTLockState;


@interface ViewController () <NSURLConnectionDelegate>

@property(nonatomic,retain)				NSMutableArray		*lockStates;
@property(nonatomic,retain) IBOutlet	UISegmentedControl	*segmentedControl;
@property(nonatomic,retain) IBOutlet	UILabel				*stateLabel;
@property(nonatomic,retain) IBOutlet	UIButton			*lockButton;
@property(nonatomic,retain) IBOutlet	UIButton			*unlockButton;

- (NSString *)selectedLockID;
- (void)queryAllLocks;
- (void)updateUIFromLockStates;
- (void)setState:(PLTLockState)state forLock:(NSString *)lockID;
- (void)toggleLockState:(NSString *)lockID;
- (IBAction)segmentedControlChanged:(id)sender;
- (IBAction)lockButton:(id)sender;
- (IBAction)unlockButton:(id)sender;
- (IBAction)toggleButton:(id)sender;

@end


@implementation ViewController

#pragma mark - Private

- (NSString *)selectedLockID
{
	switch (self.segmentedControl.selectedSegmentIndex) {
		case 0: return PLTLock1ID;
		case 1: return PLTLock2ID;
		case 2: return PLTLock3ID;
	}
	return nil;
}

- (void)queryAllLocks
{
	//https://api.lockitron.com/v2/locks?access_token=3b60a122bcc30af7ea82189e195dabf33b7b939e04dd00cab7aa411b72f5dd6d
	
	//NSString *accessToken = @"3b60a122bcc30af7ea82189e195dabf33b7b939e04dd00cab7aa411b72f5dd6d";
	NSString *accessToken = PLTAccessToken;
	
	NSString *urlString = [NSString stringWithFormat:@"https://api.lockitron.com/v2/locks?access_token=%@", accessToken];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)updateUIFromLockStates
{
	NSLog(@"updateUIFromLockStates");
	
	PLTLockState state = [self.lockStates[[self.segmentedControl selectedSegmentIndex]] intValue];
	if (state == PLTLockStateLocked) {
		self.stateLabel.text = @"Locked";
//		self.lockButton.enabled = NO;
//		self.unlockButton.enabled = YES;
	}
	else if (state == PLTLockStateUnlocked) {
		self.stateLabel.text = @"Unlocked";
//		self.lockButton.enabled = YES;
//		self.unlockButton.enabled = NO;
	}
	else {
		self.stateLabel.text = @"Unknown";
//		self.lockButton.enabled = NO;
//		self.unlockButton.enabled = NO;
	}
}

- (void)setState:(PLTLockState)state forLock:(NSString *)lockID
{
	//NSString *accessToken = @"3b60a122bcc30af7ea82189e195dabf33b7b939e04dd00cab7aa411b72f5dd6d";
	NSString *accessToken = PLTAccessToken;
	NSString *stateString;
	if (state == PLTLockStateLocked) {
		stateString = @"lock";
	}
	else if (state == PLTLockStateUnlocked) {
		stateString = @"unlock";
	}
	else {
		NSLog(@"Bad state. Aborting.");
		return;
	}
	
	NSString *urlString = [NSString stringWithFormat:@"https://api.lockitron.com/v2/locks/%@", lockID];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"PUT"];
	NSString *argString = [NSString stringWithFormat:@"access_token=%@&state=%@", accessToken, stateString];
	NSData *argData = [argString dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:argData];
	[request setValue:[NSString stringWithFormat:@"%lu", [argData length]] forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)toggleLockState:(NSString *)lockID
{
	//NSString *accessToken = @"3b60a122bcc30af7ea82189e195dabf33b7b939e04dd00cab7aa411b72f5dd6d";
	NSString *accessToken = PLTAccessToken;
	NSString *state = @"toggle";
	
	NSString *urlString = [NSString stringWithFormat:@"https://api.lockitron.com/v2/locks/%@", lockID];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"PUT"];
	NSString *argString = [NSString stringWithFormat:@"access_token=%@&state=%@", accessToken, state];
	NSData *argData = [argString dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:argData];
	[request setValue:[NSString stringWithFormat:@"%lu", [argData length]] forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender
{
	NSLog(@"segmentedControlChanged:");
	
	[self updateUIFromLockStates];
	
	[self queryAllLocks];
}

- (IBAction)lockButton:(id)sender
{
	NSLog(@"lockButton:");
	
	[self setState:PLTLockStateLocked forLock:[self selectedLockID]];
}

- (IBAction)unlockButton:(id)sender
{
	NSLog(@"unlockButton:");
	
	[self setState:PLTLockStateUnlocked forLock:[self selectedLockID]];
}

- (IBAction)toggleButton:(id)sender
{
	NSLog(@"toggleButton:");
	
	[self toggleLockState:[self selectedLockID]];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connection:didReceiveResponse: %@", response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"connection:didReceiveData: %@", data);
	
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"string: %@", string);
	
	NSError *error;
	id parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error) {
		NSLog(@"Error deserializing JSON data: %@", error);
	}
	else {
		NSLog(@"parsedData: %@", parsedData);
		
		if ([parsedData isKindOfClass:[NSArray class]]) {
			NSLog(@"array");
			NSArray *parsedArray = (NSArray *)parsedData;
			for (id arrayItem in parsedArray) {
				if ([arrayItem isKindOfClass:[NSDictionary class]]) {
					NSLog(@"dictionary");
					NSDictionary *lockDict = (NSDictionary *)arrayItem;
					NSString *idString = [lockDict objectForKey:@"id"];
					NSString *nameString = [lockDict objectForKey:@"name"];
					NSLog(@"nameString: %@", nameString);
					if (idString) {
						NSLog(@"idString: %@", idString);
						NSString *stateString = lockDict[@"state"];
						PLTLockState state = PLTLockStateUnknown;
						
						if (stateString && ![stateString isKindOfClass:[NSNull class]]) {
							if ([stateString isEqualToString:@"lock"]) {
								state = PLTLockStateLocked;
							}
							else if ([stateString isEqualToString:@"unlock"]) {
								state = PLTLockStateUnlocked;
							}
						}
						else {
							NSLog(@"No state");
						}
						
						if ([idString isEqualToString:PLTLock1ID]) {
							NSLog(@"PLTLock1ID");
							self.lockStates[0] = @(state);
						}
						else if ([idString isEqualToString:PLTLock2ID]) {
							NSLog(@"PLTLock2ID");
							self.lockStates[1] = @(state);
						}
						else if ([idString isEqualToString:PLTLock3ID]) {
							NSLog(@"PLTLock3ID");
							self.lockStates[2] = @(state);
						}
						
						NSLog(@"self.lockStates: %@", self.lockStates);
						
						[self updateUIFromLockStates];
					}
					else {
						NSLog(@"No ID string...");
					}
				}
			}
		}
		else {
			NSLog(@"Doesn't look like a list of devices... Freshing list...");
			[self queryAllLocks];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
{
	NSLog(@"connection:didSendBodyData: %lu", bytesWritten);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"connectionDidFinishLoading: %@", connection);
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.lockStates = [@[@(PLTLockStateUnknown), @(PLTLockStateUnknown), @(PLTLockStateUnknown)] mutableCopy];
	[self segmentedControlChanged:self.segmentedControl];
}

@end
