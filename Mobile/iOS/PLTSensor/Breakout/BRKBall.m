//
//  BRKBall.m
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
//
//  Created by Tommaso Piazza on 11/4/11.
//

#import "BRKBall.h"
#import "UIImage+Rotate.h"


@implementation BRKBall

- (BRKBall *) initWithPosition:(CGPoint) position {

    if((self = [super init])){
        
        bouncyness = 1.0;
        speed = CGPointMake(3.0, 3.0);
        accelleration = 0.0;
        direction = CGPointMake(1.0, 1.0);
        
        ballView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ball_f1.png"]];
        self.frame = CGRectMake(position.x, position.y, ballView.frame.size.width, ballView.frame.size.height);
        [self addSubview:ballView];
        
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:6];
        for (int f=1; f<=6; f++) {
            [frames addObject:[UIImage imageNamed:[NSString stringWithFormat:@"ball_f%d.png", f]]];
            ballView.animationImages = frames;
            ballView.animationDuration = .15; // default is 1/30 * numFrames
            [ballView startAnimating];
        }
        
//        [self createBallImages];
//        timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void) createBallImages
{
    ballImages = [NSMutableArray array];
    for (int n = 0; n<360; n++) [ballImages addObject:[NSNull null]];
    for (int d=0; d<360; d+=10) {
        UIImage *ball = [[UIImage imageNamed:@"ball.png"] imageRotatedByDegrees:(double)d clip:NO]; // clipping doesn't work correctly
        //[ballImages addObject:ball];
        ballImages[d] = ball;
    }
}

- (void) update{
    
    //Keep adjusting the ball's position untill a valid one if found.
    while(![self isPositionValid]);
    self.center = [self nextPosition];

}

- (BOOL) isPositionValid {

    if([self isWithinStageBounds]){
        return YES;
    }
    
    return NO;

}

- (BOOL) isWithinStageBounds {
    
    //Check of if the ball is within the bounds of the stage
    
    CGPoint nextPosition = [self nextPosition];

    if(nextPosition.x >= self.superview.frame.origin.x + self.frame.size.width/2 && 
       nextPosition.x + self.frame.size.width/2 <=  self.superview.frame.origin.x+self.superview.frame.size.width){
        if (nextPosition.y >= self.superview.frame.origin.y && 
            nextPosition.y + self.frame.size.height/2 <= self.superview.frame.origin.y + self.superview.frame.size.height) {
            return YES;
        } else { 
            direction.y *= -1;
        }
    
    } else { 
        direction.x *= -1;
    }
    
    return NO;
    
}

- (BOOL) isAboveLifeLine {

    if(self.center.y > kLifeLineY)
        return NO;

    return YES;
}

- (CGPoint) nextPosition {

    return CGPointMake(self.center.x+(speed.x*direction.x), self.center.y+(speed.y*direction.y));
    
}

- (void) bounce {

    direction.x *=1;
    direction.y *=-1;
}

- (void) resetAtPosition:(CGPoint) position {

    self.frame = CGRectMake(position.x, position.y, ballView.frame.size.width, ballView.frame.size.height);
    direction.x=1;
    direction.y = -1;
    //srand([NSDate timeIntervalSinceReferenceDate]);
    //direction.x = (rand() % 2) + 1;
    bouncyness = 1.0;
    accelleration = 0.0;
}

- (void) timer:(NSTimer *)theTimer
{
    static int b = 0;
    ballView.image = ballImages[b];
    b += 10;
    if (b>=360) b = 0;
//    static int degrees = 0;
//    UIImage *ball = balls[[NSNumber numberWithInt:degrees]];
//    if (!ball) {
//        NSLog(@"create ball");
//        //ballView.image = rotate([UIImage imageNamed:@"ball.png"], degrees);
//        ball = [[UIImage imageNamed:@"ball.png"] imageRotatedByDegrees:(double)degrees clip:YES];
//        balls[[NSNumber numberWithInt:degrees]] = ball;
//    }
//    ballView.image = ball;
//    degrees += 10;
//    if (degrees>360) degrees = 0;
}

@end
