//
//  ViewController.m
//  BRDeviceTest_IOS
//
//  Created by Morgan Davis on 5/29/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "ViewController.h"

#import "BRDevice.h"
#import "PLTDevice_Internal.h"
#import "BRRemoteDevice.h"
#import "NSData+HexStrings.h"
#import "BRMessage.h"
#import "BRSubscribeToServiceCommand.h"
#import "BRWearingStateSettingRequest.h"
#import "BRSignalStrengthSettingRequest.h"
#import "BRSubscribeToSignalStrengthCommand.h"
#import "BRServiceDataSettingRequest.h"
#import "BRDeviceInfoSettingRequest.h"
#import "BRWearingStateEvent.h"
#import "BROrientationTrackingEvent.h"
#import "BRSignalStrengthEvent.h"
#import "BRTapsEvent.h"
#import "BRFreeFallEvent.h"
#import "BRPedometerEvent.h"
#import "BRGyroscopeCalStatusEvent.h"
#import "BRWearingStateSettingResponse.h"
#import "BRSignalStrengthSettingResponse.h"
#import "BROrientationTrackingSettingResponse.h"
#import "BRTapsSettingResponse.h"
#import "BRFreeFallSettingResponse.h"
#import "BRPedometerSettingResponse.h"
#import "BRGyroscopeCalStatusSettingResponse.h"
#import "BRCalibratePedometerServiceCommand.h"
#import "BRServiceCalibrationSettingRequest.h"

#import "BRDeviceConnectedEvent.h"

#import "PLTDevice.h"
#import "PLTDevice_Internal.h"
//#import <IOBluetooth/IOBluetooth.h>

#import "BRRawMessage.h"

#warning BANGLE

#import "BRPerformApplicationActionCommand.h"
#import "BRApplicationActionResultEvent.h"
#import "BRConfigureApplicationCommad.h"

#warning genesis
#import "BRIncomingMessage.h"
#import <CoreMotion/CoreMotion.h>


typedef struct {
	double x;
	double y;
	double z;
} BREulerAngles;

double BRR2D(double d)
{
	return d * (180.0/M_PI);
}

BREulerAngles BREulerAnglesFromQuaternion(BRQuaternion q)
{
	double q0 = q.w;
	double q1 = q.x;
	double q2 = q.y;
	double q3 = q.z;
	
	double m22 = 2*pow(q0,2) + 2*pow(q2,2) - 1;
	double m21 = 2*q1*q2 - 2*q0*q3;
	double m13 = 2*q1*q3 - 2*q0*q2;
	double m23 = 2*q2*q3 + 2*q0*q1;
	double m33 = 2*pow(q0,2) + 2*pow(q3,2) - 1;
	
	double psi = -BRR2D(atan2(m21,m22));
	double theta = BRR2D(asin(m23));
	double phi = -BRR2D(atan2(m13, m33));
	
	return (BREulerAngles){ psi, theta, phi };
}


@interface ViewController () <BRDeviceDelegate>

- (IBAction)openConnectionButton:(id)sender;
- (IBAction)closeConnectionButton:(id)sender;
- (IBAction)subscribeToServicesButton:(id)sender;
- (IBAction)unsubscribeFromServicesButton:(id)sender;
- (IBAction)queryDeviceInfoButton:(id)sender;
- (IBAction)queryWearingStateButton:(id)sender;
- (IBAction)querySignalStrengthButton:(id)sender;
- (IBAction)queryServicesButton:(id)sender;
- (IBAction)subscribeToSignalStrengthButton:(id)sender;
- (void)enableUI;
- (void)disableUI;

@property(nonatomic,retain) BRDevice						*device;
@property(nonatomic,retain) BRRemoteDevice					*sensorsDevice;

@property(nonatomic,assign) IBOutlet UIButton               *closeConnectionButton;
@property(nonatomic,assign) IBOutlet UIButton               *queryWearingStateButton;
@property(nonatomic,assign) IBOutlet UIButton               *querySignalStrengthButton;
@property(nonatomic,assign) IBOutlet UIButton               *queryDeviceInfoButton;
@property(nonatomic,assign) IBOutlet UIButton               *querySubscribeToServicesButton;
@property(nonatomic,assign) IBOutlet UIButton               *queryUnsubscriberFromServicesButton;
@property(nonatomic,assign) IBOutlet UIButton               *queryQueryServicesButton;
@property(nonatomic,assign) IBOutlet UIButton               *subscribeToSignalStrengthButton;
@property(nonatomic,assign) IBOutlet UILabel				*connectedLabel;
@property(nonatomic,assign) IBOutlet UILabel				*wearingStateLabel;
@property(nonatomic,assign) IBOutlet UILabel				*signalStrengthLabel;
@property(nonatomic,assign) IBOutlet UIProgressView			*headingIndicator;
@property(nonatomic,assign) IBOutlet UIProgressView			*pitchIndicator;
@property(nonatomic,assign) IBOutlet UIProgressView			*rollIndicator;
@property(nonatomic,assign) IBOutlet UILabel				*freeFallLabel;
@property(nonatomic,assign) IBOutlet UILabel				*tapsLabel;
@property(nonatomic,assign) IBOutlet UILabel				*pedometerLabel;
@property(nonatomic,assign) IBOutlet UILabel				*gyroCalLabel;
@property(nonatomic,assign) IBOutlet UILabel				*dataLabel;


#warning BANGLE
- (IBAction)dialogInteractionButton:(id)sender;
- (IBAction)configureApplicationButton:(id)sender;
- (IBAction)unlockButton:(id)sender;
- (IBAction)lockButton:(id)sender;

- (void)showTextDialogWithTopText:(NSString *)topText bottomText:(NSString *)bottomText;
- (void)showYesNoDialogWithTopText:(NSString *)topText;
- (void)showChooseNumberDialogWithTopText:(NSString *)topText;
- (void)showChooseOneDialogWithTopText:(NSString *)topText choices:(NSArray *)choices;
- (void)showChooseMultipleDialogWithTopText:(NSString *)topText choices:(NSArray *)choices;

- (void)setDisplayReadoutForCharacteristic:(BRDisplayReadoutCharacteristic)characteristic enabled:(BOOL)enabled;

- (void)setLockState:(BOOL)lockState;

@property(nonatomic,strong) NSArray							*dialogChoices;

@property(nonatomic,assign) IBOutlet UIButton               *dialogInteractionButton;
@property(nonatomic,assign) IBOutlet UIButton               *configureApplicationButton;
@property(nonatomic,assign) IBOutlet UILabel				*dialogInteractionResultLabel;
@property(nonatomic,assign) IBOutlet UIButton               *unlockButton;
@property(nonatomic,assign) IBOutlet UIButton               *lockButton;


#warning genesis
- (IBAction)genesisTurnOn:(id)sender;
- (void)parseAccelX:(float)x Y:(float)y Z:(float)z;

#warning evernote
- (IBAction)getCallStatus:(id)sender;


@end


@implementation ViewController

#pragma mark - Private

- (IBAction)openConnectionButton:(id)sender
{
	if (!self.device) {
		NSArray *devices = [PLTDevice availableDevices];
		if ([devices count]) {
			EAAccessory *accessory = ((PLTDevice *)devices[0]).accessory;
			BRDevice *device = [BRDevice deviceWithAccessory:accessory];
			self.device = device;
			self.device.delegate = self;
			[self.device openConnection];
		}
	}
}

- (IBAction)closeConnectionButton:(id)sender
{
	[self.device closeConnection];
}

- (IBAction)queryWearingStateButton:(id)sender
{
	BRWearingStateSettingRequest *request = (BRWearingStateSettingRequest *)[BRWearingStateSettingRequest request];
	[self.device sendMessage:request];
}

- (IBAction)subscribeToSignalStrengthButton:(id)sender
{
	BRSubscribeToSignalStrengthCommand *command = [BRSubscribeToSignalStrengthCommand commandWithSubscription:YES connectionID:0];
	[self.device sendMessage:command];
}

- (IBAction)querySignalStrengthButton:(id)sender
{
	BRSignalStrengthSettingRequest *request = (BRSignalStrengthSettingRequest *)[BRSignalStrengthSettingRequest request];
	[self.device sendMessage:request];
}

- (IBAction)queryDeviceInfoButton:(id)sender
{
	//	NSString *msg = @"FF0300030000000100";
	//	BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeCommand payload:[NSData dataWithHexString:msg]];
	//	[self.sensorsDevice sendMessage:message];
	
	BRDeviceInfoSettingRequest *request = (BRDeviceInfoSettingRequest *)[BRDeviceInfoSettingRequest request];
	[self.sensorsDevice sendMessage:request];
}

- (IBAction)queryServicesButton:(id)sender
{
	//	[self performSelectorInBackground:@selector(ya) withObject:nil];
	
	//	BRServiceDataSettingRequest *request = [BRServiceDataSettingRequest requestWithServiceID:BRServiceIDPedometer];
	//	[self.sensorsDevice sendMessage:request];
	
	BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDFreeFall
																						mode:BRServiceSubscriptionModePeriodic
																					  period:1000];
	[self.sensorsDevice sendMessage:message];
	
	
	//    for (int i = 0; i <= BRServiceIDGyroCal; i++) {
	//        if (i==1) continue;
	//        
	//		BRServiceDataSettingRequest *request = [BRServiceDataSettingRequest requestWithServiceID:i];
	//		[self.sensorsDevice sendMessage:request];
	//    }
} 

- (IBAction)subscribeToServicesButton:(id)sender
{
//	    BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDAmbientPressure
//	                                                                                        mode:BRServiceSubscriptionModePeriodic
//	                                                                                      period:500];
//	    [self.sensorsDevice sendMessage:message];
	
	for (int i = 0; i <= BRServiceIDGyroCal; i++) {
		if (i==1) continue;
		//if (i==BRServiceIDOrientationTracking) continue;
		
		BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:i
																							mode:BRServiceSubscriptionModeOnChange
																						  period:0];
		[self.sensorsDevice sendMessage:message];
	}
	
	//[self performSelector:@selector(s_two) withObject:nil afterDelay:.25];
}

// pressure not working

- (void)s_two
{
	BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDAmbientHumidity
																						mode:BRServiceSubscriptionModePeriodic
																					  period:1000];
	[self.sensorsDevice sendMessage:message];
	
	//[self performSelector:@selector(s_three) withObject:nil afterDelay:.25];
}

- (void)s_three
{
	BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDAmbientHumidity
																						mode:BRServiceSubscriptionModePeriodic
																					  period:1000];
	[self.sensorsDevice sendMessage:message];
}

- (IBAction)unsubscribeFromServicesButton:(id)sender
{
	BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDOrientationTracking
																						mode:BRServiceSubscriptionModeOff
																					  period:0];
	[self.sensorsDevice sendMessage:message];
	
	message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDSkinTemperature
														   mode:BRServiceSubscriptionModeOff
														 period:0];
	[self.sensorsDevice sendMessage:message];
	
	message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDAmbientPressure
														   mode:BRServiceSubscriptionModeOff
														 period:0];
	[self.sensorsDevice sendMessage:message];
	
	message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDAmbientHumidity
														   mode:BRServiceSubscriptionModeOff
														 period:0];
	[self.sensorsDevice sendMessage:message];
	
	//[self performSelector:@selector(u_two) withObject:nil afterDelay:.25];
}

- (void)u_two
{
	BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:0x000F // ambient pressure
																						mode:BRServiceSubscriptionModeOff
																					  period:0];
	[self.sensorsDevice sendMessage:message];
	
	[self performSelector:@selector(u_three) withObject:nil afterDelay:.25];
}

- (void)u_three
{
	BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:0x0008 // amiennt humidity
																						mode:BRServiceSubscriptionModeOff
																					  period:0];
	[self.sensorsDevice sendMessage:message];
}

- (void)enableUI
{
	[self.closeConnectionButton setEnabled:YES];
	[self.queryWearingStateButton setEnabled:YES];
	[self.querySignalStrengthButton setEnabled:YES];
	[self.queryDeviceInfoButton setEnabled:YES];
	[self.querySubscribeToServicesButton setEnabled:YES];
	[self.queryUnsubscriberFromServicesButton setEnabled:YES];
	[self.queryQueryServicesButton setEnabled:YES];
	[self.subscribeToSignalStrengthButton setEnabled:YES];
	
#warning BANGLE
	[self.dialogInteractionButton setEnabled:YES];
	[self.configureApplicationButton setEnabled:YES];
	[self.unlockButton setEnabled:YES];
	[self.lockButton setEnabled:YES];
}

- (void)disableUI
{
	[self.closeConnectionButton setEnabled:NO];
	[self.queryWearingStateButton setEnabled:NO];
	[self.querySignalStrengthButton setEnabled:NO];
	[self.queryDeviceInfoButton setEnabled:NO];
	[self.querySubscribeToServicesButton setEnabled:NO];
	[self.queryUnsubscriberFromServicesButton setEnabled:NO];
	[self.queryQueryServicesButton setEnabled:NO];
	[self.subscribeToSignalStrengthButton setEnabled:NO];
//	self.connectedLabel.stringValue = @"No";
//	self.wearingStateLabel.stringValue = @"-";
//	self.signalStrengthLabel.stringValue = @"-";
//	[self.headingIndicator setDoubleValue:-180];
//	[self.pitchIndicator setDoubleValue:-90];
//	[self.rollIndicator setDoubleValue:-90];
//	self.freeFallLabel.stringValue = @"-"; 
//	self.tapsLabel.stringValue = @"-";
//	self.pedometerLabel.stringValue = @"-";
//	self.gyroCalLabel.stringValue = @"-";
	
#warning BANGLE
	[self.dialogInteractionButton setEnabled:NO];
	[self.configureApplicationButton setEnabled:NO];
	[self.unlockButton setEnabled:NO];
	[self.lockButton setEnabled:NO];
}

#pragma mark - BANGLE

- (IBAction)dialogInteractionButton:(id)sender
{
	NSLog(@"dialogInteractionButton:");
	
	//[self showTextDialogWithTopText:@"I LOVE" bottomText:@"TURTLES"];
	//[self showYesNoDialogWithTopText:@"COOKIES"];
	//[self showChooseNumberDialogWithTopText:@"COOKIES"];
	//[self showChooseOneDialogWithTopText:@"FAVORITE" choices:@[@"CUPCAKES", @"MARMOLADE", @"CHEESE"]];
	[self showChooseMultipleDialogWithTopText:@"FAVORITES" choices:@[@"CUPCAKES", @"MARMOLADE", @"CHEESE"]];
}

- (IBAction)configureApplicationButton:(id)sender
{
	NSLog(@"configureApplicationButton:");
	
	[self setDisplayReadoutForCharacteristic:BRDisplayReadoutCharacteristicAmbientHumidity enabled:NO];
}

- (IBAction)unlockButton:(id)sender
{
	NSLog(@"unlockButton:");
	
	[self closeConnectionButton:self];
	
	//[self setLockState:NO];
}

- (IBAction)lockButton:(id)sender
{
	NSLog(@"lockButton:");
	
	NSLog(@"self.device.isConnected = %@", (self.device.isConnected ? @"YES" : @"NO"));
	NSLog(@"self.sensorsDevice.isConnected = %@", (self.sensorsDevice.isConnected ? @"YES" : @"NO"));
	
	//[self setLockState:YES];
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
	[self.sensorsDevice sendMessage:command];
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
	[self.sensorsDevice sendMessage:command];
	
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
	[self.sensorsDevice sendMessage:command];
	
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
	[self.sensorsDevice sendMessage:command];
	
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
	[self.sensorsDevice sendMessage:command];
}

- (void)setDisplayReadoutForCharacteristic:(BRDisplayReadoutCharacteristic)characteristic enabled:(BOOL)enabled
{
	NSLog(@"setDisplayReadoutForCharacteristic: %d, enabled: %@", characteristic, (enabled ? @"YES" : @"NO"));
	
	NSData *enabledData = [NSData dataWithBytes:&enabled length:sizeof(BOOL)];
	
	BRConfigureApplicationCommad *command = [BRConfigureApplicationCommad commandWithFeatureID:BRFeatureIDDisplayReadout characteristic:characteristic configurationData:enabledData];
	[self.sensorsDevice sendMessage:command];
}

- (void)setLockState:(BOOL)lockState
{
	NSMutableString *hexString = [NSMutableString stringWithFormat:@"%02X",
								  lockState];
	
	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
	hexString = [NSMutableString stringWithFormat:@"%04X %@",
				 deckardArrayLen,
				 hexString
				 ];
	
	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDLock
																																		   action:0
																																	operatingData:[NSData dataWithHexString:hexString]];
	[self.sensorsDevice sendMessage:command];
}

#pragma mark - Genesis

- (IBAction)genesisTurnOn:(id)sender
{
	NSLog(@"genesisTurnOn");
	
	BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeCommand payload:[NSData dataWithHexString:@"0F00"]];
	[self.device sendMessage:message];
}

- (void)parseAccelX:(float)x Y:(float)y Z:(float)z
{
	// actually apply the pedometer algo

	float mag = sqrtf(x*x + y*y);
	NSLog(@"mag: %.2f", mag);
	
//	static float maxMag = -MAXFLOAT;
//	static float minMag = MAXFLOAT;
//	
//	static int total = 0;
//	total++;
//	
//	static float accum = 0;
//	accum += mag;
//	
//	static float avg = 0;
//	avg = accum / (float)total;
//	
//	if (mag > maxMag) maxMag = mag;
//	if (mag < minMag) minMag = mag;
//	
//	NSLog(@"min: %.2f, max: %.2f, avg: %.2f", minMag, maxMag, avg);

//	static float min = .3;
//	static float max = .8;
	
	// MIDDLE (still) is ~.48
	static float min = .48 - .06;
	static float max = .48 + .06;
	
	static BOOL gotMax = NO;
	static BOOL gotMin = NO;
	
	static BOOL awaitingHighReset = NO;
	static BOOL awaitingLowReset = NO;
	
	static int lastThresh = -1;
	
	if (mag >= max) {
		if (!awaitingHighReset && !awaitingLowReset) {
			gotMax = YES;
			lastThresh = 1;
		}
	}
	else if (awaitingHighReset) {
		awaitingHighReset = NO;
		//gotMax = NO;
	}
	
	if (mag <= min) {
		if (!awaitingHighReset && !awaitingLowReset) {
			gotMin = YES;
			lastThresh = 0;
		}
	}
	else if (awaitingLowReset) {
		awaitingLowReset = NO;
		//gotMin = NO;
	}
	
	static int steps = 0;
	
	if (gotMin && gotMax) {
		if (!awaitingHighReset && !awaitingLowReset) {
		NSLog(@"**********************************************************************************************************************************\
			  **********************************************************************************************************************************\
			  ************************************************************** STEP **************************************************************\
			  **********************************************************************************************************************************\
			  **********************************************************************************************************************************");
			steps++;
			
			if (lastThresh == 0) { // low triggered
				awaitingLowReset = YES;
			}
			else if (lastThresh == 1) { // high triggered
				awaitingHighReset = YES;
			}
				
			gotMin = NO;
			gotMax = NO;
		}
	}
	
	NSLog(@"steps: %d", steps);
}

//- (void)parseAccelX:(float)x Y:(float)y Z:(float)z
//{
//	// actually apply the pedometer algo
//	
//	//float values[3] = {x*9.80665f*2, y*9.80665f*2, z*9.80665f*2};
//	float values[3] = {x*10, y*10, z*10};
//	
//	//NSLog(@"values: { %.2f, %.2f, %.2f }", values[0], values[1], values[2]);
//	
//	float vSum = 0;
//	for (int i=0 ; i<3 ; i++) {
//		//final float v = mYOffset + event.values[i] * mScale[j];
//		float v = self.mYOffset + values[i] * [(NSNumber *)self.mScale[1] floatValue];
//		vSum += v;
//	}
//	int k = 0;
//	float v = vSum / 3;
//	
//	NSLog(@"v = %.2f", v);
//	return;
//	
//	float direction = (v > [(NSNumber *)self.mLastValues[k] intValue] ? 1 : (v < [(NSNumber *)self.mLastValues[k] intValue] ? -1 : 0));
//	if (direction == - [(NSNumber *)self.mLastDirections[k] intValue]) {
//		// Direction changed
//		int extType = (direction > 0 ? 0 : 1); // minumum or maximum?
//		((NSMutableArray *)self.mLastExtremes[extType])[k] = self.mLastValues[k];
//		float diff = fabs([((NSMutableArray *)self.mLastExtremes[extType])[k] intValue] - [((NSMutableArray *)self.mLastExtremes[1 - extType])[k] intValue]);
//		
//		if (diff > self.mLimit) {
//			
//			BOOL isAlmostAsLargeAsPrevious = diff > ([self.mLastDiff[k] floatValue] * 2/3);
//			BOOL isPreviousLargeEnough = [self.mLastDiff[k] floatValue] > (diff/3);
//			BOOL isNotContra = (self.mLastMatch != 1 - extType);
//			
//			if (isAlmostAsLargeAsPrevious && isPreviousLargeEnough && isNotContra) {
//				NSLog(@"**********************************************************************************************************************************\
//					  **********************************************************************************************************************************\
//					  ************************************************************** STEP **************************************************************\
//					  **********************************************************************************************************************************\
//					  **********************************************************************************************************************************");
//				//				for (StepListener stepListener : mStepListeners) {
//				//					stepListener.onStep();
//				//				}
//				self.mLastMatch = extType;
//			}
//			else {
//				self.mLastMatch = -1;
//			}
//		}
//		self.mLastDiff[k] = @(diff);
//	}
//	self.mLastDirections[k] = @(direction);
//	self.mLastValues[k] = @(v);
//}

//- (void)parseAccelX:(float)x Y:(float)y Z:(float)z
//{
//	// actually apply the pedometer algo
//	
//	float values[3] = {x*9.80665f, y*9.80665f, z*9.80665f};
//	
//	float vSum = 0;
//	for (int i=0 ; i<3 ; i++) {
//		//final float v = mYOffset + event.values[i] * mScale[j];
//		float v = mYOffset + values[i] * mScale[1];
//		vSum += v;
//	}
//	int k = 0;
//	float v = vSum / 3;
//	
//	float direction = (v > mLastValues[k] ? 1 : (v < mLastValues[k] ? -1 : 0));
//	if (direction == - mLastDirections[k]) {
//		// Direction changed
//		int extType = (direction > 0 ? 0 : 1); // minumum or maximum?
//		mLastExtremes[extType][k] = mLastValues[k];
//		float diff = fabs(mLastExtremes[extType][k] - mLastExtremes[1 - extType][k]);
//		
//		if (diff > mLimit) {
//			
//			BOOL isAlmostAsLargeAsPrevious = diff > (mLastDiff[k]*2/3);
//			BOOL isPreviousLargeEnough = mLastDiff[k] > (diff/3);
//			BOOL isNotContra = (mLastMatch != 1 - extType);
//			
//			if (isAlmostAsLargeAsPrevious && isPreviousLargeEnough && isNotContra) {
//				NSLog(@"step");
////				for (StepListener stepListener : mStepListeners) {
////					stepListener.onStep();
////				}
//				mLastMatch = extType;
//			}
//			else {
//				mLastMatch = -1;
//			}
//		}
//		mLastDiff[k] = diff;
//	}
//	mLastDirections[k] = direction;
//	mLastValues[k] = v;
//}

#pragma mark - BRDeviceDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
	NSLog(@"BRDeviceDidConnect: %@", device);
	
	if (device == self.sensorsDevice) {
		//self.connectedLabel.stringValue = @"Connected";
		[self enableUI];
	}
	
#ifdef BR_GENESIS
	BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeSettingRequest payload:[NSData dataWithHexString:@"0100"]];
	[self.device sendMessage:message];
#endif
}

- (void)BRDeviceDidDisconnect:(BRDevice *)device
{
	NSLog(@"BRDeviceDidDisconnect: %@", device);
	
	[self disableUI];
	
	if (device == self.device) {
		self.device = nil;
		self.sensorsDevice = nil;
	}
	else if (device == self.sensorsDevice) {
		self.sensorsDevice = nil;
	}
}

- (void)BRDevice:(BRDevice *)device didFailConnectWithError:(int)ioBTError
{
	NSLog(@"BRDevice: %@ didFailConnectWithError: %d", device, ioBTError);
	
	if (device == self.device) {
		self.device = nil;
	}
	else if (device == self.sensorsDevice) {
		self.sensorsDevice = nil;
	}
}

- (void)BRDevice:(BRDevice *)device didReceiveEvent:(BREvent *)event
{
	NSLog(@"BRDevice: %@ didReceiveEvent: %@", device, event);
	
	if ([event isKindOfClass:[BRWearingStateEvent class]]) {
		BRWearingStateEvent *e = (BRWearingStateEvent *)event;
		self.wearingStateLabel.text = (e.isBeingWorn ? @"Yes" : @"No");
	}
	else if ([event isKindOfClass:[BRSignalStrengthEvent class]]) {
		BRSignalStrengthEvent *e = (BRSignalStrengthEvent *)event;
		self.signalStrengthLabel.text = [NSString stringWithFormat:@"%d", e.strength];
	}
	else if ([event isKindOfClass:[BROrientationTrackingEvent class]]) {
		BROrientationTrackingEvent *e = (BROrientationTrackingEvent *)event;
		BREulerAngles eulerAngles = BREulerAnglesFromQuaternion(e.quaternion);		
//		[self.headingIndicator setDoubleValue:-eulerAngles.x];
//		[self.pitchIndicator setDoubleValue:eulerAngles.y];
//		[self.rollIndicator setDoubleValue:eulerAngles.z];
	}
	else if ([event isKindOfClass:[BRTapsEvent class]]) {
		BRTapsEvent *e = (BRTapsEvent *)event;
		if (e.count) self.tapsLabel.text = [NSString stringWithFormat:@"%d in %@", e.count, NSStringFromTapDirection(e.direction)];
		else self.tapsLabel.text = @"-";
	}
	else if ([event isKindOfClass:[BRFreeFallEvent class]]) {
		BRFreeFallEvent *e = (BRFreeFallEvent *)event;
		self.freeFallLabel.text = (e.isInFreeFall ? @"Yes" : @"No");
	}
	else if ([event isKindOfClass:[BRPedometerEvent class]]) {
		BRPedometerEvent *e = (BRPedometerEvent *)event;
		self.pedometerLabel.text = [NSString stringWithFormat:@"%d", e.steps];
	}
	else if ([event isKindOfClass:[BRGyroscopeCalStatusEvent class]]) {
		BRGyroscopeCalStatusEvent *e = (BRGyroscopeCalStatusEvent *)event;
		self.gyroCalLabel.text = (e.isCalibrated ? @"Yes" : @"No");
	}
	
	
#warning BANGLE
	else if ([event isKindOfClass:[BRApplicationActionResultEvent class]]) {
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
	
	if ([response isKindOfClass:[BRWearingStateSettingResponse class]]) {
		BRWearingStateSettingResponse *r = (BRWearingStateSettingResponse *)response;
		self.wearingStateLabel.text = (r.isBeingWorn ? @"Yes" : @"No");
	}
	else if ([response isKindOfClass:[BRSignalStrengthSettingResponse class]]) {
		BRSignalStrengthSettingResponse *r = (BRSignalStrengthSettingResponse *)response;
		self.signalStrengthLabel.text = [NSString stringWithFormat:@"%d", r.strength];
	}
	else if ([response isKindOfClass:[BROrientationTrackingSettingResponse class]]) {
		BROrientationTrackingSettingResponse *r = (BROrientationTrackingSettingResponse *)response;
		BREulerAngles eulerAngles = BREulerAnglesFromQuaternion(r.quaternion);		
//		[self.headingIndicator setDoubleValue:-eulerAngles.x];
//		[self.pitchIndicator setDoubleValue:eulerAngles.y];
//		[self.rollIndicator setDoubleValue:eulerAngles.z];
	}
	else if ([response isKindOfClass:[BRTapsSettingResponse class]]) {
		BRTapsSettingResponse *r = (BRTapsSettingResponse *)response;
		if (r.count) self.tapsLabel.text = [NSString stringWithFormat:@"%d in %@", r.count, NSStringFromTapDirection(r.direction)];
		else self.tapsLabel.text = @"-";
	}
	else if ([response isKindOfClass:[BRFreeFallSettingResponse class]]) {
		BRFreeFallSettingResponse *r = (BRFreeFallSettingResponse *)response;
		self.freeFallLabel.text = (r.isInFreeFall ? @"Yes" : @"No");
	}
	else if ([response isKindOfClass:[BRPedometerSettingResponse class]]) {
		BRPedometerSettingResponse *r = (BRPedometerSettingResponse *)response;
		self.pedometerLabel.text = [NSString stringWithFormat:@"%d", r.steps];
	}
	else if ([response isKindOfClass:[BRGyroscopeCalStatusSettingResponse class]]) {
		BRGyroscopeCalStatusSettingResponse *r = (BRGyroscopeCalStatusSettingResponse *)response;
		self.gyroCalLabel.text = (r.isCalibrated ? @"Yes" : @"No");
	}
}

- (void)BRDevice:(BRDevice *)device didRaiseException:(BRException *)exception
{
	NSLog(@"BRDevice: %@ didRaiseException: %@", device, exception);
}

- (void)BRDevice:(BRDevice *)device didFindRemoteDevice:(BRRemoteDevice *)remoteDevice
{
	NSLog(@"BRDevice: %@ didFindRemoteDevice: %@", device, remoteDevice);
	
	if (remoteDevice.port == 0x5) {
		self.sensorsDevice = remoteDevice;
		self.sensorsDevice.delegate = self;
		[self.sensorsDevice openConnection];
	}
}

- (void)BRDevice:(BRDevice *)device didReceiveUnknownMessage:(BRIncomingMessage *)unknownMessage
{
#ifdef BR_GENESIS
	if ([[unknownMessage payload] isEqualToData:[NSData dataWithHexString:@"0200 0010 4649 545F 4143 435F 5031 425F 4400 0000 00"]]) {
		BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeSettingRequest payload:[NSData dataWithHexString:@"0101"]];
		[self.device sendMessage:message];
	}
	else if ([[unknownMessage payload] isEqualToData:[NSData dataWithHexString:@"0201 000C 504C 4430 3035 5F30 3032 0000"]]) {
		BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeSettingRequest payload:[NSData dataWithHexString:@"0102"]];
		[self.device sendMessage:message];
	}
	else if ([[unknownMessage payload] isEqualToData:[NSData dataWithHexString:@"0202 0010 3330 3132 5F30 3031 3030 315F 5231 4100"]]) {
		BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeSettingRequest payload:[NSData dataWithHexString:@"0103"]];
		[self.device sendMessage:message];
	}
	else if ([[unknownMessage payload] isEqualToData:[NSData dataWithHexString:@"0203 0012 0000 0000 0000 0000 0000 0000 0000 0000 0000"]]) {
		BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeSettingRequest payload:[NSData dataWithHexString:@"0104"]];
		[self.device sendMessage:message];
	}
	//else if ([[unknownMessage payload] isEqualToData:[NSData dataWithHexString:@"0204 64"]]) {
	else if ([[[unknownMessage payload] subdataWithRange:NSMakeRange(0, 2)] isEqualToData:[NSData dataWithHexString:@"0204"]]) {
		BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeSettingRequest payload:[NSData dataWithHexString:@"0105 0578"]];
		[self.device sendMessage:message];
	}
	else if ([[unknownMessage payload] isEqualToData:[NSData dataWithHexString:@"0205 0514"]]) {
		// wait for go button
	}
	else if ([[[unknownMessage payload] subdataWithRange:NSMakeRange(0, 2)] isEqualToData:[NSData dataWithHexString:@"1100"]]) { // accel or mag
		if ([[unknownMessage payload] length] > 22 ) { // accelerometer
			NSData *accelData = [[unknownMessage payload] subdataWithRange:NSMakeRange(4, [[unknownMessage payload] length] - 4)];
			NSString *accelerometerData = [[NSString alloc] initWithBytes:[accelData bytes] length:24 + 3 encoding:NSASCIIStringEncoding];
			
			NSRange valueRange;
			valueRange.location = 0;
			valueRange.length = 6;
			// Just skip sequence counter
			valueRange.location += 6 + 1;
			int xValue = [[accelerometerData substringWithRange:valueRange] intValue];
			valueRange.location += 6 + 1;
			int yValue = [[accelerometerData substringWithRange:valueRange] intValue];
			valueRange.location += 6 + 1;
			int zValue = [[accelerometerData substringWithRange:valueRange] intValue];
			
			//NSLog(@"%i, %i, %i", xValue, yValue, zValue);
			
//			static int xMax = 0, yMax = 0, zMax = 0;
//			if (xValue > xMax) xMax = xValue;
//			if (yValue > yMax) yMax = yValue;
//			if (zValue > zMax) zMax = zValue;
			
			float xMag = (float)xValue / ((float)UINT16_MAX/2.0);
			float yMag = (float)yValue / ((float)UINT16_MAX/2.0);
			float zMag = (float)zValue / ((float)UINT16_MAX/2.0);
			
			// +/- 1.0 is pretty easy to get by hand... I'm going to GUESS it's actually 1G...
			
			//NSLog(@"%.2f, %.2f, %.2f", xMag, yMag, zMag);
			
			[self parseAccelX:xMag Y:yMag Z:zMag];
		}
	}
#endif
}

- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data
{
	NSString *hexString = [data hexStringWithSpaceEvery:2];
	NSLog(@"--> %@", hexString);
	self.dataLabel.text = [NSString stringWithFormat:@"--> %@", hexString];
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
	NSString *hexString = [data hexStringWithSpaceEvery:2];
	NSLog(@"<-- %@", hexString);
	self.dataLabel.text = [NSString stringWithFormat:@"<-- %@", hexString];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
#warning genesis
//	self.mLastValues = [NSMutableArray array];
//	self.mLastValues = [NSMutableArray array]; // new float[3*2];
//	self.mScale = [NSMutableArray array]; // new float[2];
//	self.mLastDirections = [NSMutableArray array]; // new float[3*2];
//	self.mLastExtremes = [NSMutableArray array]; // { new float[3*2], new float[3*2] };
//	for (int i=0; i<10; i++) self.mLastExtremes[i] = [NSMutableArray array];
//	self.mLastDiff = [NSMutableArray array]; // new float[3*2];
//	
//	self.mLimit = 10;
//	self.mLastMatch = -1;
//	
//	int h = 480; // TODO: remove this constant
//	self.mYOffset = h * 0.5f;
//	self.mScale[0] = @(- (h * 0.5f * (1.0f / (9.80665f * 2)))); // SensorManager.STANDARD_GRAVITY
//	self.mScale[1] = @(- (h * 0.5f * (1.0f / (60.0f)))); // SensorManager.MAGNETIC_FIELD_EARTH_MAX
	
	
//	self.motionManager = [[CMMotionManager alloc] init];
//	self.motionManager.accelerometerUpdateInterval = .05;
//	
//	[self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:
//	 ^(CMAccelerometerData  *accelerometerData, NSError *error) {
//		 [self parseAccelX:accelerometerData.acceleration.x Y:accelerometerData.acceleration.y Z:accelerometerData.acceleration.z];
//		 if(error){
//			 NSLog(@"%@", error);
//		 }
//	 }];
}

@end
