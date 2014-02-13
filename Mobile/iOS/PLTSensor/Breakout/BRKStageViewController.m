//
//  BRKStage.m
//  Breakout
//
//
// This file is part of Breakout.
// 
// Breakout is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Breakout is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with Breakout.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Tommaso Piazza on 11/4/11.
//

#import "BRKStageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BRKPaddle.h"
#import "BRKBall.h"
#import "BRKBlock.h"
#import "PLTContextServer.h"
#import "PLTHeadsetManager.h"
#import "NSData+Base64.h"


#define kBlocksMax 30 //The maximum number of blocks in the game
#define kBlockLine 300 //Y below witch allow block respawn

//#define PADDLE_LOCATION     CGPointMake(110, 400)
//#define BALL_LOCATION       CGPointMake(150, 380)
#define PADDLE_LOCATION     CGPointMake(110, 480)
#define BALL_LOCATION       CGPointMake(150, 460)


double d2r(double d)
{
	return d * (M_PI/180.0);
}

double r2d(double d)
{
	return d * (180.0/M_PI);
}


@interface BRKStageViewController () <PLTContextServerDelegate>
{
    NSMutableArray *blocks;
    BRKPaddle *paddle;
    BRKBall *ball;
    CADisplayLink *displayLink; //A timer called each time the display needs redrawing, 60 times a seconds
    //NSTimer *gameTimer;
    float paddleOffset;
    BOOL tapsDown;
    BOOL dead;
    UILabel *deadLabel;
}

- (void)gameLoop:(CADisplayLink *)sender; // The main loop
- (void)startOver;
- (void)spawnBlocks; //Used to spawn the blocks
//- (void)startGameTimer;
//- (void)stopGameTimer;

@end


@implementation BRKStageViewController

#pragma mark - Private

//- (void)startGameTimer
//{
//    gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(gameLoop:) userInfo:nil repeats:YES];
//}
//
//- (void)stopGameTimer
//{
//    if (gameTimer) [gameTimer invalidate];
//    gameTimer = nil;
//}

- (void)headsetInfoDidUpdateNotification:(NSNotification *)note
{
    [self headsetInfoDidUpdate:note.userInfo];
}

- (void)headsetInfoDidUpdate:(NSDictionary *)info
{
    BOOL taps = [info[PLTHeadsetInfoKeyTapCount] boolValue];
//	self.isDonned = [(NSNumber *)info[PLTHeadsetInfoKeyIsDonned] boolValue];
    
    BOOL newTaps = taps && tapsDown;
    tapsDown = !taps;
    if (newTaps) {
        [self startOver];
    }
    
    //if (!dead) {
        Vec3 eulerAngles;
        NSData *rotationData = [info objectForKey:PLTHeadsetInfoKeyRotationVectorData];
        [rotationData getBytes:&eulerAngles.x length:[rotationData length]];
        
        static const CGFloat DISTANCE = 250.0;
        
        // stop wrap-around, and extreme offset values
        if (eulerAngles.x > 85) {
            eulerAngles.x = 85;
        }
        else if (eulerAngles.x < -85) {
            eulerAngles.x = -85;
        }
        if (eulerAngles.y > 85) {
            eulerAngles.y = 85;
        }
        else if (eulerAngles.y < -85) {
            eulerAngles.y = -85;
        }
        
        float screenWidth = self.view.frame.size.width;
        
        CGFloat xOffset = DISTANCE * tan(d2r(eulerAngles.x));
        //NSLog(@"xOffset: %.2f", xOffset);
        
        float center = screenWidth/2.0;
        float newXOffset = center + xOffset;
        
        // pin paddle to screen edges
        if (newXOffset < paddle.frame.size.width/2.0) {
            newXOffset = paddle.frame.size.width/2.0;
        }
        else if (newXOffset > self.view.frame.size.width - paddle.frame.size.width/2.0) {
            newXOffset = self.view.frame.size.width - paddle.frame.size.width/2.0;
        }
        
        [UIView animateWithDuration:.1 animations:^{
            paddle.center = CGPointMake(newXOffset, paddle.center.y);
        }];
    //}
}

- (void)spawnBlocks
{
    /* 
     Startin at y 50 add each block to stage view.
     Starting at x 10, every 5 blocks start a new block line.
     */
    
    [blocks makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [blocks removeAllObjects];

    int y = 55;
    for (int i = 0; i < kBlocksMax; i++) {
        
        if (i%5 == 0) y+=kBlockHeight;
        
        BRKBlock *aBlock = [BRKBlock blockAtPosition:CGPointMake((10+i*kBlockWidth)%300,y)];
        
        aBlock.tag = i;
        [self.view addSubview:aBlock];
        [blocks addObject:aBlock];
    }
}

- (void)gameLoop:(CADisplayLink *)sender
{
//    static BOOL skip = NO;
//    if (skip) {
//        skip = NO;
//        return;
//    }
//    skip = YES;
    
    if ([ball isAboveLifeLine]) { //Check if the ball isn't below the paddles.
        dead = NO;
        deadLabel.alpha = 0.0;
        
        CGPoint nextPosition =  [ball nextPosition]; //Get the ball's next position.
        
        //If the are no blocks left and the ball is below the spawn line then spawn new blocks.
        if ([blocks count] == 0 && nextPosition.y > kBlockLine) {
            [self spawnBlocks];
        }
        
        if ([paddle isImpactWithBallAtPosition:nextPosition]) {
            [ball bounce];
        }
        
        for (BRKBlock *block in blocks) {
            
            //Check is the ball will hit a block
            if ([block isImpactWithBallAtPosition:nextPosition]) {
                
                //If the block has zero health remove it.
                //if([block update] == 0 ){
                    [blocks removeObject:block];
                    [block removeFromSuperview];
                    //[self updateScore];
                //}
                [ball bounce];
                break; //Jump out of the for loop on impact.
            }
        }
        
        [ball update]; //Move the ball.
    }
    else {
        //The ball is below the paddle.
//        if([self updateLives] == 0){ //if no lives left game over
//        
//            [self gameOver];
//            
//        } else {
//        
//            //Puse the game and reset the ball
//            [self playPause];
//            [ball resetAtPosition:CGPointMake(150, 380)];
//            [paddle resetAtPosition:CGPointMake(110, 400)];
//        
//        }
    
        dead = YES;
        deadLabel.alpha = 1.0;
        //[self stopGameTimer];
    }
}

- (void)startOver
{
    [ball resetAtPosition:BALL_LOCATION];
    [paddle resetAtPosition:PADDLE_LOCATION];
    [self spawnBlocks];
    displayLink.paused = NO;
    //[self startGameTimer];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    /*
//    Called for each touch on the stage's view
//    move the paddle a the touch's position
//    unless the game is paused.
//     */
//    
//    if(!displayLink.isPaused) {
//        UITouch *touch = [[event allTouches] anyObject];
//        CGPoint location = [touch locationInView:self.view];
//        paddle.center = CGPointMake(location.x, paddle.center.y);
//    }
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	[self touchesBegan:touches withEvent:event];
//}

#pragma mark - PLTContextServerDelegate

- (void)server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message
{
    if (!HEADSET_CONNECTED) {
        if ([message hasType:@"event"]) {
			if ([[message messageId] isEqualToString:EVENT_HEAD_TRACKING]) {
                NSDictionary *info = [[PLTHeadsetManager sharedManager] infoFromPacketData:[message.payload[@"quaternion"] base64DecodedData]];
				if (info) {
					[self headsetInfoDidUpdate:info];
				}
            }
        }
    }
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.title = @"Game";
    self.tabBarItem.title = @"Game";
    self.tabBarItem.image = [UIImage imageNamed:@"game_icon.png"];
    
    displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(gameLoop:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if (self) {
        deadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        deadLabel.text = @"Bahhh! Tap headset to try again!";
        deadLabel.textAlignment = NSTextAlignmentCenter;
        deadLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20.0];
        deadLabel.textColor = [UIColor whiteColor];
        deadLabel.shadowColor = [UIColor blackColor];
        deadLabel.shadowOffset = CGSizeMake(1, 2);
        [self.view addSubview:deadLabel];
        
        // Custom initialization
        blocks = [NSMutableArray arrayWithCapacity:kBlocksMax];
        
        //[self spawnBlocks];
        
        paddle = (BRKPaddle *)[BRKPaddle blockAtPosition:PADDLE_LOCATION withImageNamed:@"paddle.png"];
        [self.view addSubview:paddle];
        ball = [[BRKBall alloc ] initWithPosition:BALL_LOCATION];
        [self.view addSubview:ball];
        
        //[self startGameTimer];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationController.navigationBarHidden = NO;
	
	UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav_ios7.png"];
	if (!IOS7) pltImage = [UIImage imageNamed:@"pltlabs_nav.png"];
	CGRect navFrame = self.navigationController.navigationBar.frame;
	CGRect pltFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
								 (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
								 pltImage.size.width + 2,
								 pltImage.size.height + 2);
	
	UIImageView *view = [[UIImageView alloc] initWithFrame:pltFrame];
	view.contentMode = UIViewContentModeCenter;
	view.image = pltImage;
	self.navigationItem.titleView = view;
	
	UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cogBarButton.png"]
																   style:UIBarButtonItemStyleBordered
																  target:[UIApplication sharedApplication].delegate
																  action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = actionItem;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self startOver];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headsetInfoDidUpdateNotification:) name:PLTHeadsetInfoDidUpdateNotification object:nil];
    [[PLTContextServer sharedContextServer] addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    displayLink.paused = YES;
    //[self stopGameTimer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PLTHeadsetInfoDidUpdateNotification object:nil];
    [[PLTContextServer sharedContextServer] removeDelegate:self];
}

@end
