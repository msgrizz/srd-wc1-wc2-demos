//
//  SecuritySceneView.h
//  WC2 Kit
//
//  Created by Morgan Davis on 3/5/15.
//  Copyright (c) 2015 Plantronics. All rights reserved.
//

#import <SceneKit/SceneKit.h>


@protocol SecuritySceneViewEventDelegate;


@interface SecuritySceneView : SCNView

@property(nonatomic, assign) id <SecuritySceneViewEventDelegate> eventDelegate;

@end


@protocol SecuritySceneViewEventDelegate <NSObject>

- (void)securitySceneView:(SecuritySceneView *)theView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
