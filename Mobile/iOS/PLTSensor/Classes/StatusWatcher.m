//
//  StatusWatcher.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 4/3/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "StatusWatcher.h"
#import "PLTHeadsetManager.h"
#import "PLTContextServer.h"
#import "AppDelegate.h"


typedef NS_ENUM(NSInteger, StatusWatcherState) {
	StatusWatcherStateNone,
	StatusWatcherStateHSOnly,
	StatusWatcherStateHSAuthAndReg,
	StatusWatcherStateHSAndAuth,
	StatusWatcherStateAuthOnly
};


@interface StatusWatcher ()

- (void)somethingChangedNotification:(NSNotification *)note;
- (void)updateView:(BOOL)animated;

@property(nonatomic,strong) NSDictionary			*iconsImageViews;
@property(nonatomic,strong) NSDictionary			*sizes;
@property(nonatomic,strong) NSDictionary			*gaps;
@property(nonatomic,strong) NSMutableArray			*bars;
@property(nonatomic,strong) UIView					*view;
@property(nonatomic,assign) BOOL					animating;
@property(nonatomic,assign) BOOL					updateAfterAnimating;
@property(nonatomic,assign) BOOL					animateAfterAnimating;
@property(nonatomic,assign) StatusWatcherState		state;
@property(nonatomic,strong) UINavigationBar			*activeBar;
@property(nonatomic,strong) UIView					*previousView;
@property(nonatomic,strong) NSMutableDictionary		*imageViewFrames;
@end


@implementation StatusWatcher

#pragma mark - Public

+ (StatusWatcher *)sharedWatcher
{
	static StatusWatcher *watcher = nil;
	if (!watcher) watcher = [[StatusWatcher alloc] init];
	return watcher;
}

- (void)setActiveNavigationBar:(UINavigationBar *)aBar animated:(BOOL)animated
{
	[self setActiveNavigationBar:aBar animated:YES delayed:YES];
}

- (void)setActiveNavigationBar:(UINavigationBar *)aBar animated:(BOOL)animated delayed:(BOOL)delayed;
{
	if ([DEFAULTS boolForKey:PLTDefaultsKeyShowStatusIcons]) {
		if (aBar) {
			if (animated) {
				[UIView animateWithDuration:.25 delay:(delayed ? .15 : 0) options:0
								 animations:^{
									 self.view.alpha = 1.0;
								 }
								 completion:nil];
			}
			else {
				self.view.alpha = 1.0;
			}
			
			// since UIView doesn't conform to NSCopying, we have to compose a new one manually...
			
			UIImageView *o_hs_v = self.iconsImageViews[@"hs"];
			UIImageView *o_auth_v = self.iconsImageViews[@"auth"];
			UIImageView *o_reg_v = self.iconsImageViews[@"reg"];
			
			UIView *viewCopy = [[UIView alloc] initWithFrame:self.view.frame];
			UIImageView *hs_v = [[UIImageView alloc] initWithImage:[o_hs_v image]];
			UIImageView *auth_v = [[UIImageView alloc] initWithImage:[o_auth_v image]];
			UIImageView *reg_v = [[UIImageView alloc] initWithImage:[o_reg_v image]];
			
			[hs_v setFrame:CGRectFromString(self.imageViewFrames[@(0)])];
			[auth_v setFrame:CGRectFromString(self.imageViewFrames[@(1)])];
			[reg_v setFrame:CGRectFromString(self.imageViewFrames[@(2)])];
			
			hs_v.alpha = o_hs_v.alpha;
			auth_v.alpha = o_auth_v.alpha;
			reg_v.alpha = o_reg_v.alpha;
			
			[viewCopy addSubview:hs_v];
			[viewCopy addSubview:auth_v];
			[viewCopy addSubview:reg_v];
			
			[self.previousView removeFromSuperview];
			[self.activeBar addSubview:viewCopy]; // soon to be the old bar
			self.previousView = viewCopy;
			[self.view removeFromSuperview];
			self.activeBar = aBar;
			[self.activeBar addSubview:self.view];
			[self updateView:animated];
		}
		else {
			self.activeBar = nil;
			if (animated) {
				[UIView animateWithDuration:.2 animations:^{
					self.view.alpha = 0;
				} completion:nil];
			}
			else {
				self.view.alpha = 0;
			}
		}
	}
	else {
		[self.view removeFromSuperview];
		[self.previousView removeFromSuperview];
		self.bars = [NSMutableArray array];
	}
}

#pragma mark - Private

- (void)somethingChangedNotification:(NSNotification *)note
{
	[self updateView:YES];
}

- (void)updateView:(BOOL)animated
{
	//NSLog(@"updateView: %@",(animated?@"YES":@"NO"));
	
	if (self.animating) {
		//NSLog(@"Waiting.");
		self.updateAfterAnimating = YES;
		self.animateAfterAnimating = animated;
	}
	else {
		StatusWatcherState previousState = self.state;
		//NSLog(@"Previous state: %d",previousState);
	
		BOOL hs = HEADSET_CONNECTED;
		BOOL auth = CLIENT_AUTHENTICATED;
		BOOL reg = DEVICE_REGISTERED;
		
		UIImageView *hs_v = self.iconsImageViews[@"hs"];
		UIImageView *auth_v = self.iconsImageViews[@"auth"];
		UIImageView *reg_v = self.iconsImageViews[@"reg"];
		
		CGFloat hs_w = [self.sizes[@"hs"] floatValue];
		CGFloat auth_w = [self.sizes[@"auth"] floatValue];
		CGFloat reg_w = [self.sizes[@"reg"] floatValue];
		
		CGFloat hs_auth_gap = [self.gaps[@"hs_auth"] floatValue];
		CGFloat auth_reg_gap = [self.gaps[@"auth_reg"] floatValue];
	
		NSMutableArray *actions = [NSMutableArray array];
		
		if (!hs && !auth) { // . | . | .
			
			//NSLog(@". | . | .");
			
			[actions addObjectsFromArray:@[ @[@"hide", hs_v], @[@"hide", auth_v], @[@"hide", reg_v] ]];
			self.state = StatusWatcherStateNone;
		}
		
		else if (hs && !auth) { // hs | . | .
			
			//NSLog(@"hs | . | .");
			
			NSString *hs_f = NSStringFromCGRect(CGRectMake(0, 0, hs_w, 44.0));
			
			switch (previousState) {
				case StatusWatcherStateNone:
					[actions addObjectsFromArray:@[ @[@"add", hs_v, hs_f] ]];
					break;
				case StatusWatcherStateHSOnly:
					// nothing
					break;
				case StatusWatcherStateHSAuthAndReg:
					[actions addObjectsFromArray:@[ @[@"hide", auth_v], @[@"hide", reg_v] ]];
					break;
				case StatusWatcherStateHSAndAuth:
					[actions addObjectsFromArray:@[ @[@"hide", auth_v] ]];
					break;
				case StatusWatcherStateAuthOnly:
					[actions addObjectsFromArray:@[ @[@"hide", auth_v], @[@"add", hs_v, hs_f] ]];
					break;
				default:
					break;
			}
			self.state = StatusWatcherStateHSOnly;
		}
	
		else if (hs && auth && reg) { // hs | auth | reg
			
			//NSLog(@"hs | auth | reg");
			
			// hs, auth, reg
			NSString *hs_f = NSStringFromCGRect(CGRectMake(0, 0, hs_w, 44.0));
			NSString *auth_f = NSStringFromCGRect(CGRectMake(hs_w + hs_auth_gap, 0, auth_w, 44.0));
			NSString *reg_f = NSStringFromCGRect(CGRectMake(hs_w + hs_auth_gap + auth_w + auth_reg_gap, 0, reg_w, 44.0));
			
			switch (previousState) {
				case StatusWatcherStateNone:
					[actions addObjectsFromArray:@[ @[@"add", hs_v, hs_f], @[@"add", auth_v, auth_f], @[@"add", reg_v, reg_f] ]];
					break;
				case StatusWatcherStateHSOnly:
					[actions addObjectsFromArray:@[ @[@"add", auth_v, auth_f], @[@"add", reg_v, reg_f] ]];
					break;
				case StatusWatcherStateHSAuthAndReg:
					// nothing
					break;
				case StatusWatcherStateHSAndAuth:
					[actions addObjectsFromArray:@[ @[@"add", reg_v, reg_f] ]];
					break;
				case StatusWatcherStateAuthOnly:
					[actions addObjectsFromArray:@[ @[@"add", hs_v, hs_f], @[@"move", auth_v, auth_f], @[@"add", reg_v, reg_f] ]];
					break;
				default:
					break;
			}
			
			self.state = StatusWatcherStateHSAuthAndReg;
		}
	
		else if (hs && auth) { // hs | auth | .
			
			//NSLog(@"hs | auth | .");
			
			NSString *hs_f = NSStringFromCGRect(CGRectMake(0, 0, hs_w, 44.0));
			NSString *auth_f = NSStringFromCGRect(CGRectMake(hs_w + hs_auth_gap, 0, auth_w, 44.0));
			
			switch (previousState) {
				case StatusWatcherStateNone:
					[actions addObjectsFromArray:@[ @[@"add", hs_v, hs_f], @[@"add", auth_v, auth_f] ]];
					break;
				case StatusWatcherStateHSOnly:
					[actions addObjectsFromArray:@[ @[@"add", auth_v, auth_f] ]];
					break;
				case StatusWatcherStateHSAuthAndReg:
					[actions addObjectsFromArray:@[ @[@"hide", reg_v] ]];
					break;
				case StatusWatcherStateHSAndAuth:
					// nothing
					break;
				case StatusWatcherStateAuthOnly:
					[actions addObjectsFromArray:@[ @[@"move", auth_v, auth_f], @[@"add", hs_v, hs_f] ]];
					break;
				default:
					break;
			}
			
			self.state = StatusWatcherStateHSAndAuth;
		}
	
		else if (!hs && auth) { // auth | . | .
			
			//NSLog(@"auth | . | .");
			
			NSString *auth_f = NSStringFromCGRect(CGRectMake(0, 0, auth_w, 44.0));
			
			switch (previousState) {
				case StatusWatcherStateNone:
					[actions addObjectsFromArray:@[ @[@"add", auth_v, auth_f] ]];
					break;
				case StatusWatcherStateHSOnly:
					[actions addObjectsFromArray:@[ @[@"hide", hs_v], @[@"add", auth_v, auth_f] ]];
					break;
				case StatusWatcherStateHSAuthAndReg:
					[actions addObjectsFromArray:@[ @[@"move", auth_v, auth_f], @[@"hide", hs_v], @[@"hide", reg_v] ]];
					break;
				case StatusWatcherStateHSAndAuth:
					[actions addObjectsFromArray:@[ @[@"move", auth_v, auth_f], @[@"hide", hs_v] ]];
					break;
				case StatusWatcherStateAuthOnly:
					// nothing
					break;
				default:
					break;
			}
			
			self.state = StatusWatcherStateAuthOnly;
		}
	
	//NSLog(@"actions: %@",actions);
	
	for (NSArray *action in actions) {
		if ([action[0] isEqualToString:@"add"]) {
			[action[1] setAlpha:0];
			[action[1] setFrame:CGRectFromString(action[2])];
			self.imageViewFrames[@(((UIImageView *)action[1]).tag)] = action[2];
		}
		else if ([action[0] isEqualToString:@"move"]) {
			self.imageViewFrames[@(((UIImageView *)action[1]).tag)] = action[2];
		}
	}
	
	[UIView animateWithDuration:.25
					 animations:^(void) {
						 for (NSArray *action in actions) {
							 if ([action[0] isEqualToString:@"add"]) {
								 [action[1] setAlpha:1];
							 }
							 else if ([action[0] isEqualToString:@"hide"]) {
								 [action[1] setAlpha:0];
							 }
							 else if([action[0] isEqualToString:@"move"]) {
								 [action[1] setFrame:CGRectFromString(action[2])];
							 }
						 }
					 }
					 completion:^(BOOL finished) {
						 self.animating = NO;
						 if (self.updateAfterAnimating) {
							 //NSLog(@"Animation waiting!");
							 self.updateAfterAnimating = NO;
							 [self updateView:self.animateAfterAnimating];
						 }
					 }];
	}
}

#pragma mark - NSObject

- (id)init
{
	if (self = [super init]) {
		
		UIImage *hsIcon = [UIImage imageNamed:@"hs_status_icon.png"];
		UIImage *authIcon = [UIImage imageNamed:@"auth_status_icon.png"];
		UIImage *regIcon = [UIImage imageNamed:@"reg_status_icon.png"];
		if (IOS7) {
			hsIcon = [UIImage imageNamed:@"hs_status_icon_ios7.png"];
			authIcon = [UIImage imageNamed:@"auth_status_icon_ios7.png"];
			regIcon = [UIImage imageNamed:@"reg_status_icon_ios7.png"];
		}
		
		self.iconsImageViews = @{
								 @"hs" : [[UIImageView alloc] initWithImage:hsIcon],
								 @"auth" : [[UIImageView alloc] initWithImage:authIcon],
								 @"reg" : [[UIImageView alloc] initWithImage:regIcon]};
		((UIImageView *)self.iconsImageViews[@"hs"]).tag = 0;
		((UIImageView *)self.iconsImageViews[@"auth"]).tag = 1;
		((UIImageView *)self.iconsImageViews[@"reg"]).tag = 2;
		
		self.sizes = @{
		@"hs" : @(20.0/2.0),
		@"auth" : @(35.0/2.0),
		@"reg" : @(30.0/2.0)};
		
		self.gaps = @{
		@"side_hs" : @(20.0/2.0),
		@"hs_auth" : @(12.0/2.0),
		@"auth_reg" : @(10.0/2.0)};
		
		CGFloat hs_w = [self.sizes[@"hs"] floatValue];
		CGFloat auth_w = [self.sizes[@"auth"] floatValue];
		CGFloat reg_w = [self.sizes[@"reg"] floatValue];
		CGFloat side_hs_gap = [self.gaps[@"side_hs"] floatValue];
		
		self.view = [[UIView alloc] initWithFrame:CGRectMake(side_hs_gap, 0, hs_w + auth_w + reg_w, 44.0)];
		[self.iconsImageViews[@"hs"] setAlpha:0];
		[self.iconsImageViews[@"auth"] setAlpha:0];
		[self.iconsImageViews[@"reg"] setAlpha:0];
		[self.view addSubview:self.iconsImageViews[@"hs"]];
		[self.view addSubview:self.iconsImageViews[@"auth"]];
		[self.view addSubview:self.iconsImageViews[@"reg"]];
		
		self.bars = [NSMutableArray array];
		self.imageViewFrames = [NSMutableDictionary dictionary];
		
		self.state = StatusWatcherStateNone;
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(somethingChangedNotification:) name:PLTHeadsetDidConnectNotification object:nil];
		[nc addObserver:self selector:@selector(somethingChangedNotification:) name:PLTHeadsetDidDisconnectNotification object:nil];
		[nc addObserver:self selector:@selector(somethingChangedNotification:) name:PLTContextServerDidChangeStateNotification object:nil];
	}
	return self;
}

@end
