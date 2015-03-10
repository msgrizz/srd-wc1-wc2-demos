//
//  SecuritySceneView.m
//  WC2 Kit
//
//  Created by Morgan Davis on 3/5/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import "SecuritySceneView.h"


@implementation SecuritySceneView

#pragma mark - UIResponder

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.eventDelegate securitySceneView:self touchesEnded:touches withEvent:event];
}

@end
