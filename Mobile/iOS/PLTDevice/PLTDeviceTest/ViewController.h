//
//  ViewController.h
//  PLTDeviceTest
//
//  Created by Davis, Morgan on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController

- (IBAction)calButton:(id)sender;
- (IBAction)queryButton:(id)sender;
- (IBAction)subscribeButton:(id)sender;
- (IBAction)unsubscribeButton:(id)sender;
- (IBAction)resetButton:(id)sender;

//@property(nonatomic, strong)	IBOutlet UILabel	*headingLabel;
//@property(nonatomic, strong)	IBOutlet UILabel	*pitchLabel;
//@property(nonatomic, strong)	IBOutlet UILabel	*rollLabel;
@property(nonatomic, strong)	IBOutlet UILabel	*orientationLabel;

@end
