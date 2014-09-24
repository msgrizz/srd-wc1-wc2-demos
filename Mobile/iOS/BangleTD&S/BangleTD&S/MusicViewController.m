//
//  MusicViewController.m
//  BangleTD&S
//
//  Created by Morgan Davis on 6/11/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "MusicViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface MusicViewController ()

@property(nonatomic,strong)	AVAudioPlayer			*player;
@property(nonatomic,strong)	IBOutlet	UIButton	*playPauseButton;

- (IBAction)playPauseButton:(id)sender;
- (void)updatePlayPauseButton;

@end


@implementation MusicViewController


#pragma mark - Private

- (IBAction)playPauseButton:(id)sender
{
	NSLog(@"playPauseButton:");
	
	if (!self.player.isPlaying) {
		NSLog(@"(playing)");
		[self.player play];
	}
	else {
		NSLog(@"(pausing)");
		[self.player stop];
		//self.player.currentTime = 0;
	}
	
	[self updatePlayPauseButton];
}

- (void)updatePlayPauseButton
{
	if (self.player.isPlaying) {
		UIImage *pauseImage = [UIImage imageNamed:@"PauseMusicButton"];
		//NSLog(@"pauseImage: %@", pauseImage);
		[self.playPauseButton setImage:pauseImage forState:UIControlStateNormal];
	}
	else {
		UIImage *playImage = [UIImage imageNamed:@"PlayMusicButton"];
		[self.playPauseButton setImage:playImage forState:UIControlStateNormal];
	}
}

#pragma mark - UIViewController

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        
//    }
//    return self;
//}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// setup music player
	NSString *path = [[NSBundle mainBundle] pathForResource:@"gameofthrones" ofType:@"mp3"];
	NSURL *file = [NSURL fileURLWithPath:path];
	self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
	[self.player prepareToPlay];
	
	[self updatePlayPauseButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

