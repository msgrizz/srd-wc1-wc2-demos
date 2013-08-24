//
//  InfoViewController.h
//  CSR Wireless Sensor
//
//  Created by Doug Rosener on 9/17/12.
//  Copyright (c) 2012 Cambridge Silicon Radio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController <UITextFieldDelegate>{

}
@property(nonatomic,strong) IBOutlet UITextView *consoleTextView;
@property(nonatomic,strong) IBOutlet UITextField *serverTextView;
@property(nonatomic,strong) IBOutlet UITextField *portTextView;
@property(nonatomic,strong) IBOutlet UITextField *userTextView;
@property(nonatomic,strong) IBOutlet UITextField *passTextView;
@property(nonatomic,strong) IBOutlet UISwitch *switchView;

- (IBAction)doneButton:(id)sender;
@end
