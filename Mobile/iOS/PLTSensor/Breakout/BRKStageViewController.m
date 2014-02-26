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
//#import "TestFlight.h"


typedef enum {
    PLTGameStateNotStarted,
    PLTGameStateStarted,
    PLTGameStateEnded
} PLTGameState;


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
    CADisplayLink *displayLink;
    float paddleOffset;
    BOOL tapsDown;
    UILabel *label;
    PLTGameState gameState;
    BOOL paused;
}

- (void)gameLoop:(CADisplayLink *)sender;
- (void)startOver;
- (void)spawnBlocks;

@end


@implementation BRKStageViewController

#pragma mark - Private

- (void)headsetInfoDidUpdateNotification:(NSNotification *)note
{
    [self headsetInfoDidUpdate:note.userInfo];
}

- (void)headsetInfoDidUpdate:(NSDictionary *)info
{
    BOOL donned = [(NSNumber *)info[PLTHeadsetInfoKeyIsDonned] boolValue];
    paused = !donned;
    BOOL taps = [info[PLTHeadsetInfoKeyTapCount] boolValue];
    BOOL newTaps = taps && tapsDown;
    tapsDown = !taps;
    
    
    static int prevState = -1;
    
    if (gameState == PLTGameStateNotStarted && paused) {
        label.text = @"Put headset on and tap to begin!";
        label.alpha = 1.0;
    }
    else if (gameState == PLTGameStateNotStarted && !paused && !newTaps) {
        label.text = @"Tap headset to begin!";
        label.alpha = 1.0;
    }
    else if (gameState == PLTGameStateNotStarted && !paused && newTaps) {
        [self startOver];
    }
    else if (gameState == PLTGameStateEnded && !paused && newTaps) {
        [self startOver];
        gameState = PLTGameStateStarted;
    }
    else if (gameState == PLTGameStateEnded && paused) {
        label.text = @"Put headset on and tap to try again!";
        label.alpha = 1.0;
    }
    else if (gameState == PLTGameStateEnded && !paused) {
        label.text = @"Bahhh! Tap headset to try again!";
        label.alpha = 1.0;
    }
    else if (gameState == PLTGameStateStarted && paused) {
        label.text = @"Game paused. Put headset on to resume!";
        label.alpha = 1.0;
    }
    else if (gameState == PLTGameStateStarted && !paused) {
        label.alpha = 0.0;
    }
    
    if (gameState == PLTGameStateStarted && !paused) {
        Vec3 eulerAngles;
        NSData *rotationData = [info objectForKey:PLTHeadsetInfoKeyRotationVectorData];
        [rotationData getBytes:&eulerAngles.x length:[rotationData length]];
        
        CGFloat DISTANCE;
        if (IPAD) DISTANCE = 425.0;
        else DISTANCE = 420.0;
        
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
    }
}

- (void)spawnBlocks
{
    /* 
     Startin at y 50 add each block to stage view.
     Starting at x 10, every 5 blocks start a new block line.
     */
    
    [blocks makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [blocks removeAllObjects];
    
    int maxBlocks;
    if (IPAD) maxBlocks = 24; // 6 blocks * 4 lines
    else maxBlocks = 30; // 5 blocks * 6 lines

    int y;
    if (IPAD) y = 10;
    else y = 40;
    int x = 0;
    for (int i = 0; i < maxBlocks; i++) {
        
        if (IPAD) {
            if (i%6 == 0) {
                y += BLOCK_SIZE_IPAD.height;
                x = 0;
            }
        }
        else {
            if (i%5 == 0) {
                y += BLOCK_SIZE_IPHONE.height;
                x = 0;
            }
        }
        
        BRKBlock *aBlock = [BRKBlock blockAtPosition:CGPointMake(x, y)];
        
        int blockSpacee;
        if (IPAD) {
            blockSpacee = BLOCK_SIZE_IPAD.width + 3;
        }
        else {
            blockSpacee = BLOCK_SIZE_IPHONE.width + 5;
        }
        x += blockSpacee;
        
        aBlock.tag = i;
        [self.view addSubview:aBlock];
        [blocks addObject:aBlock];
    }
}

- (void)gameLoop:(CADisplayLink *)sender
{
    if (gameState == PLTGameStateStarted && !paused) {
        if ([ball isAboveLifeLine]) {
            [ball startAnimating];
            label.alpha = 0.0;
            ball.alpha = 1.0;
            
            CGPoint nextPosition =  [ball nextPosition];
            
            //If the are no blocks left and the ball is below the spawn line then spawn new blocks.
            static const float BLOCK_LINE = 300.0;
            if ([blocks count] == 0 && nextPosition.y > BLOCK_LINE) {
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
            
            gameState = PLTGameStateEnded;
            label.text = @"Bahhh! Tap headset to try again!";
            label.alpha = 1.0;
            ball.alpha = 0.0;
            [ball stopAnimating];
        }
    }
    else {
        [ball stopAnimating];
    }
}

- (void)startOver
{
    gameState = PLTGameStateStarted;
    
    float yOffset = 80.0;
    CGPoint midBottom = CGPointMake(self.view.frame.size.width/2.0,
                                    self.view.frame.size.height - yOffset);
    CGFloat ballYOffset;
    if (IPAD) ballYOffset = 8.0;
    else ballYOffset = 12.0;
    CGPoint ballPoint = CGPointMake(midBottom.x - ball.frame.size.width/2.0,
                                    midBottom.y - ball.frame.size.height/2.0 - paddle.frame.size.height + ballYOffset);
    CGFloat paddleYOffset;
    if (IPAD) paddleYOffset = 0;
    else paddleYOffset = 12.0;
    CGPoint paddlePoint = CGPointMake(midBottom.x - paddle.frame.size.width/2.0,
                                      midBottom.y - paddle.frame.size.height/2.0 + paddleYOffset);
    [ball resetAtPosition:ballPoint];
    [paddle resetAtPosition:paddlePoint];

    [self spawnBlocks];
    displayLink.paused = NO;
}

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
    displayLink.paused = YES;
    
    if (self) {
        float yOffset;
        if (IPAD) yOffset = 0;
        else yOffset = 20.0;
        float padding;
        if (IPAD) padding = 20.0;
        else padding = 10.0;
        label = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, self.view.frame.size.width - padding*2.0, self.view.frame.size.height + yOffset)];
        label.textAlignment = NSTextAlignmentCenter;
        float fontSize;
        if (IPAD) fontSize = 24.0;
        else fontSize = 20.0;
        label.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:fontSize];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = .5;
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(1, 2);
        [self.view addSubview:label];
        
        blocks = [NSMutableArray array];

        if (IPAD) paddle = (BRKPaddle *)[BRKPaddle blockAtPosition:CGPointZero withImageNamed:@"paddle_ipad.png"];
        else paddle = (BRKPaddle *)[BRKPaddle blockAtPosition:CGPointZero withImageNamed:@"paddle_iphone.png"];
        [self.view addSubview:paddle];
        ball = [[BRKBall alloc] initWithPosition:CGPointZero];
        [self.view addSubview:ball];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headsetInfoDidUpdateNotification:) name:PLTHeadsetInfoDidUpdateNotification object:nil];
    [[PLTContextServer sharedContextServer] addDelegate:self];
    
    [super viewWillAppear:animated];
    
    [self startOver];
    gameState = PLTGameStateNotStarted;
    paused = ![(NSNumber *)[PLTHeadsetManager sharedManager].latestInfo[PLTHeadsetInfoKeyIsDonned] boolValue];
    if (!paused) {
        label.text = @"Tap headset to begin!";
    }
    else {
        label.text = @"Put headset on and tap to begin!";
    }
    label.alpha = 1.0;
    
    displayLink.paused = NO;
    
    //[TestFlight passCheckpoint:@"GAME_TAB"];
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
