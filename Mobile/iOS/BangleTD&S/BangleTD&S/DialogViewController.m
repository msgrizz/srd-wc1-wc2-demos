//
//  DialogViewController.m
//  BangleTD&S
//
//  Created by Morgan Davis on 6/23/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "DialogViewController.h"
#import "BRDevice.h"
#import "NSData+HexStrings.h"
#import "BRPerformApplicationActionCommand.h"
#import "BRApplicationActionResultEvent.h"
#import "AppDelegate.h"
#import "PLTDevice_Internal.h"
#import "BRSubscribeToServiceCommand.h"


@interface DialogViewController () <BRDeviceDelegate>

- (IBAction)dialogInteractionButton:(id)sender;
- (void)unsuvscribeSensors;
- (void)showTextDialogWithTopText:(NSString *)topText bottomText:(NSString *)bottomText;
- (void)showYesNoDialogWithTopText:(NSString *)topText;
- (void)showChooseNumberDialogWithTopText:(NSString *)topText;
- (void)showChooseOneDialogWithTopText:(NSString *)topText choices:(NSArray *)choices;
- (void)showChooseMultipleDialogWithTopText:(NSString *)topText choices:(NSArray *)choices;

@property(nonatomic,strong) NSArray							*dialogChoices;
@property(nonatomic,assign) IBOutlet UILabel				*dialogInteractionResultLabel;

@end


@implementation DialogViewController

#pragma mark - Private

- (IBAction)dialogInteractionButton:(id)sender
{
	NSLog(@"dialogInteractionButton:");
	
	//[self showTextDialogWithTopText:@"I LOVE" bottomText:@"TURTLES"];
	//[self showYesNoDialogWithTopText:@"COOKIES"];
	//[self showChooseNumberDialogWithTopText:@"COOKIES"];
	//[self showChooseOneDialogWithTopText:@"FAVORITE" choices:@[@"CUPCAKES", @"MARMOLADE", @"CHEESE"]];
	[self showChooseMultipleDialogWithTopText:@"FAVORITES" choices:@[@"CUPCAKES", @"MARMOLADE", @"CHEESE"]];
}

- (void)unsuvscribeSensors
{
	NSLog(@"unsuvscribeSensors");
	
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BRDevice *sensorsDevice = appDelegate.device.brDevice.remoteDevices[@(5)];
	
	BRSubscribeToServiceCommand *command = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDOrientationTracking
																						mode:BRServiceSubscriptionModeOff
																					  period:0];
	[sensorsDevice sendMessage:command];
	
	command = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDAmbientHumidity
														   mode:BRServiceSubscriptionModeOff
														 period:0];
	[sensorsDevice sendMessage:command];
	
	command = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDSkinTemperature
														   mode:BRServiceSubscriptionModeOff
														 period:0];
	[sensorsDevice sendMessage:command];
	
	command = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDAmbientPressure
														   mode:BRServiceSubscriptionModeOff
														 period:0];
	[sensorsDevice sendMessage:command];
}

- (void)showTextDialogWithTopText:(NSString *)topText bottomText:(NSString *)bottomText
{
	const char *topPrompt = [topText cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *topPromptData = [NSData dataWithBytes:topPrompt length:strlen(topPrompt)];
	uint16_t topPromptLen = (uint16_t)[topPromptData length];
	
	const char *bottomPrompt = [bottomText cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *bottomPromptData = [NSData dataWithBytes:bottomPrompt length:strlen(bottomPrompt)];
	uint16_t bottomPromptLen = (uint16_t)[bottomPromptData length];
	
	NSString *hexString = [NSString stringWithFormat:@"%04X %@ %04X %@ %04X %04X",
						   topPromptLen,
						   [topPromptData hexStringWithSpaceEvery:0],
						   bottomPromptLen,
						   [bottomPromptData hexStringWithSpaceEvery:0],
						   2, // attention type
						   0x4748 // attention specifier
						   ];
	
	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
	hexString = [NSString stringWithFormat:@"%04X %@",
				 deckardArrayLen,
				 hexString
				 ];
	
	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDDialog
																																		   action:BRDialogApplicationActionTextAlert
																																	operatingData:[NSData dataWithHexString:hexString]];
	//[self.sensorsDevice sendMessage:command];
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BRDevice *sensorsDevice = appDelegate.device.brDevice.remoteDevices[@(5)];
	[sensorsDevice sendMessage:command];
}

- (void)showYesNoDialogWithTopText:(NSString *)topText
{
	const char *prompt = [topText cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *promptData = [NSData dataWithBytes:prompt length:strlen(prompt)];
	uint16_t promptLen = (uint16_t)[promptData length];
	
	NSString *hexString = [NSString stringWithFormat:@"%04X %@",
						   promptLen,
						   [promptData hexStringWithSpaceEvery:0]
						   ];
	
	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
	hexString = [NSString stringWithFormat:@"%04X %@",
				 deckardArrayLen,
				 hexString
				 ];
	
	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDDialog
																																		   action:BRDialogApplicationActionYesNo
																																	operatingData:[NSData dataWithHexString:hexString]];
	//[self.sensorsDevice sendMessage:command];
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BRDevice *sensorsDevice = appDelegate.device.brDevice.remoteDevices[@(5)];
	[sensorsDevice sendMessage:command];
}

- (void)showChooseNumberDialogWithTopText:(NSString *)topText
{
	const char *prompt = [topText cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *promptData = [NSData dataWithBytes:prompt length:strlen(prompt)];
	uint16_t promptLen = (uint16_t)[promptData length];
	
	NSString *hexString = [NSString stringWithFormat:@"%04X %@",
						   promptLen,
						   [promptData hexStringWithSpaceEvery:0]
						   ];
	
	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
	hexString = [NSString stringWithFormat:@"%04X %@",
				 deckardArrayLen,
				 hexString
				 ];
	
	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDDialog
																																		   action:BRDialogApplicationActionEnterNumber
																																	operatingData:[NSData dataWithHexString:hexString]];
	//[self.sensorsDevice sendMessage:command];
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BRDevice *sensorsDevice = appDelegate.device.brDevice.remoteDevices[@(5)];
	[sensorsDevice sendMessage:command];
}

- (void)showChooseOneDialogWithTopText:(NSString *)topText choices:(NSArray *)choices
{
	self.dialogChoices = choices;
	
	
	
	const char *prompt = [topText cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *promptData = [NSData dataWithBytes:prompt length:strlen(prompt)];
	uint16_t promptLen = (uint16_t)[promptData length];
	
	uint16_t choicesIndexes[[choices count]];
	NSMutableString *choicesString = [NSMutableString string];
	
	for (int c=0; c<[choices count]; c++) {
		NSString *choice = (NSString *)choices[c];
		[choicesString appendString:[choice uppercaseString]];
		choicesIndexes[c] = [choicesString length] - 1;
	}
	
	const char *choicesCStr = [choicesString cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *choicesData = [NSData dataWithBytes:choicesCStr length:strlen(choicesCStr)];
	
	uint16_t indexesArrayLen = (uint16_t)ceilf((float)sizeof(choicesIndexes)/2.0); // length in 2-byte incraments
	NSMutableString *hexString = [NSMutableString stringWithFormat:@"%04X %@ %04X",
								  promptLen,
								  [promptData hexStringWithSpaceEvery:0],
								  indexesArrayLen];
	
	for (int c=0; c<[choices count]; c++) {
		[hexString appendString:[NSString stringWithFormat:@"%04X", choicesIndexes[c]]];
	}
	
	[hexString appendString:[choicesData hexStringWithSpaceEvery:0]];
	
	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
	hexString = [NSMutableString stringWithFormat:@"%04X %@",
				 deckardArrayLen,
				 hexString
				 ];
	
	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDDialog
																																		   action:BRDialogApplicationActionChooseOne
																																	operatingData:[NSData dataWithHexString:hexString]];
	//[self.sensorsDevice sendMessage:command];
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BRDevice *sensorsDevice = appDelegate.device.brDevice.remoteDevices[@(5)];
	[sensorsDevice sendMessage:command];
}

- (void)showChooseMultipleDialogWithTopText:(NSString *)topText choices:(NSArray *)choices
{
	self.dialogChoices = choices;
	
	
	
	const char *prompt = [topText cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *promptData = [NSData dataWithBytes:prompt length:strlen(prompt)];
	uint16_t promptLen = (uint16_t)[promptData length];
	
	uint16_t choicesIndexes[[choices count]];
	NSMutableString *choicesString = [NSMutableString string];
	
	for (int c=0; c<[choices count]; c++) {
		NSString *choice = (NSString *)choices[c];
		[choicesString appendString:[choice uppercaseString]];
		choicesIndexes[c] = [choicesString length] - 1;
	}
	
	const char *choicesCStr = [choicesString cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *choicesData = [NSData dataWithBytes:choicesCStr length:strlen(choicesCStr)];
	
	uint16_t indexesArrayLen = (uint16_t)ceilf((float)sizeof(choicesIndexes)/2.0); // length in 2-byte incraments
	NSMutableString *hexString = [NSMutableString stringWithFormat:@"%04X %@ %04X",
								  promptLen,
								  [promptData hexStringWithSpaceEvery:0],
								  indexesArrayLen];
	
	for (int c=0; c<[choices count]; c++) {
		[hexString appendString:[NSString stringWithFormat:@"%04X", choicesIndexes[c]]];
	}
	
	[hexString appendString:[choicesData hexStringWithSpaceEvery:0]];
	
	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
	hexString = [NSMutableString stringWithFormat:@"%04X %@",
				 deckardArrayLen,
				 hexString
				 ];
	
	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDDialog
																																		   action:BRDialogApplicationActionChooseMultiple
																																	operatingData:[NSData dataWithHexString:hexString]];
	//[self.sensorsDevice sendMessage:command];
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BRDevice *sensorsDevice = appDelegate.device.brDevice.remoteDevices[@(5)];
	[sensorsDevice sendMessage:command];
}

#pragma mark - BRDeviceDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
	NSLog(@"BRDeviceDidConnect: %@", device);
}

- (void)BRDeviceDidDisconnect:(BRDevice *)device
{
	NSLog(@"BRDeviceDidDisconnect: %@", device);
}

- (void)BRDevice:(BRDevice *)device didFailConnectWithError:(int)ioBTError
{
	NSLog(@"BRDevice: %@ didFailConnectWithError: %d", device, ioBTError);
}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
	NSLog(@"BRDevice: %@ didReceiveEvent: %@", device, event);
	
#warning BANGLE
	if ([event isKindOfClass:[BRApplicationActionResultEvent class]]) {
		BRApplicationActionResultEvent *e = (BRApplicationActionResultEvent *)event;
		if (e.applicationID == BRApplicationIDDialog) {
			switch (e.action) {
				case BRDialogApplicationActionTextAlert: {
					// chaa
					break; }
				case BRDialogApplicationActionYesNo: {
					// chaa
					break; }
				case BRDialogApplicationActionEnterNumber: {
					uint8_t count;
					[[e.resultData subdataWithRange:NSMakeRange(1, sizeof(uint8_t))] getBytes:&count length:sizeof(uint8_t)];
					self.dialogInteractionResultLabel.text = [NSString stringWithFormat:@"%d cookies.", count];
					break; }
				case BRDialogApplicationActionChooseOne: {
					uint8_t index;
					[[e.resultData subdataWithRange:NSMakeRange(1, sizeof(uint8_t))] getBytes:&index length:sizeof(uint8_t)];
					self.dialogInteractionResultLabel.text = self.dialogChoices[index];
					break; }
				case BRDialogApplicationActionChooseMultiple: {
					//uint16_t len;
					//[[e.resultData subdataWithRange:NSMakeRange(1, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
					uint16_t len = [e.resultData length];
					uint8_t indexes[len];
					[[e.resultData subdataWithRange:NSMakeRange(0, len)] getBytes:&indexes length:len];
					NSMutableString *choices = [NSMutableString string];
					for (int i = 0; i<len; i++) {
						uint8_t index = indexes[i];
						if (i == len-1) {
							[choices appendString:self.dialogChoices[index]];
						}
						else {
							[choices appendString:[NSString stringWithFormat:@"%@, ", self.dialogChoices[index]]];
						}
					}
					self.dialogInteractionResultLabel.text = choices;
					break; }
				default:
					break;
			}
		}
	}
}

- (void)BRDevice:(BRDevice *)device didReceiveSettingResponse:(BRSettingResponse *)response
{
	NSLog(@"BRDevice: %@ didReceiveSettingResponse: %@", device, response);
}

- (void)BRDevice:(BRDevice *)device didRaiseException:(BRException *)exception
{
	NSLog(@"BRDevice: %@ didRaiseException: %@", device, exception);
}

- (void)BRDevice:(BRDevice *)device didFindRemoteDevice:(BRRemoteDevice *)remoteDevice
{
	NSLog(@"BRDevice: %@ didFindRemoteDevice: %@", device, remoteDevice);
}

- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data
{
	NSString *hexString = [data hexStringWithSpaceEvery:2];
	NSLog(@"--> %@", hexString);
	//self.dataLabel.text = [NSString stringWithFormat:@"--> %@", hexString];
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
	NSString *hexString = [data hexStringWithSpaceEvery:2];
	NSLog(@"<-- %@", hexString);
	//self.dataLabel.text = [NSString stringWithFormat:@"<-- %@", hexString];
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BRDevice *sensorsDevice = appDelegate.device.brDevice.remoteDevices[@(5)];
	sensorsDevice.delegate = self;
	
	[self unsuvscribeSensors];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
