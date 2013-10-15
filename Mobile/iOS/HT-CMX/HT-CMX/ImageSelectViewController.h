//
//  ImageSelectViewController.h
//  HT-CMX
//
//  Created by Davis, Morgan on 10/14/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ImageSelectViewControllerDelegate;

@interface ImageSelectViewController : UITableViewController

@property(nonatomic, assign) id <ImageSelectViewControllerDelegate> delegate;

@end


@protocol ImageSelectViewControllerDelegate <NSObject>

- (void)imageSelectViewController:(ImageSelectViewController *)controller didSelectImage:(NSString *)image;

@end
