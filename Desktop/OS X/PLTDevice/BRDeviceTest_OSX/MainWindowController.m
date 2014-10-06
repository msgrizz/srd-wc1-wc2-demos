//
//  MainWindowController.m
//  PLTDevice
//
//  Created by Morgan Davis on 2/26/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "MainWindowController.h"
#import "BRDevice.h"
#import "BRRemoteDevice.h"
#import "NSData+HexStrings.h"
#import "BRMessage.h"

#import "BRSubscribeToServicesCommand.h"
#import "BRConfigureSignalStrengthEventsCommand.h"

#import "BRGetDeviceInfoSettingRequest.h"
#import "BRWearingStateSettingRequest.h"
#import "BRConnectionStatusSettingRequest.h"
#import "BRQueryServicesDataSettingRequest.h"
#import "BRCurrentSignalStrengthSettingRequest.h"

#import "BRWearingStateSettingResult.h"
#import "BRCurrentSignalStrengthSettingResult.h"
#import "BRQueryServicesDataSettingResult.h"

#import "BRWearingStateChangedEvent.h"
#import "BRSignalStrengthEvent.h"
#import "BRSubscribedServiceDataEvent.h"

#import "PLTDevice.h"
#import "PLTDevice_Internal.h"
//#import <IOBluetooth/IOBluetooth.h>

#import "BRRawMessage.h"

#warning BANGLE

//#import "BRPerformApplicationActionCommand.h"
//#import "BRApplicationActionResultEvent.h"
//#import "BRConfigureApplicationCommad.h"



#warning TEMPORARY
#import "Configuration.h"


typedef struct {
	double x;
	double y;
	double z;
} BREulerAngles;

double BRR2D(double d)
{
	return d * (180.0/M_PI);
}

PLTEulerAngles BREulerAnglesFromQuaternion(PLTQuaternion q)
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
	
    return (PLTEulerAngles){ psi, theta, phi };
}


@interface MainWindowController () <BRDeviceDelegate>

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

// WC1 Parsing Helpers

- (PLTQuaternion)quaternionFromServiceData:(NSData *)serviceData;
- (uint32_t)pedometerCountFromServiceData:(NSData *)serviceData;
- (BOOL)freeFallFromServiceData:(NSData *)serviceData;
- (void)getTapsFromServiceData:(NSData *)serviceData count:(uint8_t *)count direction:(uint8_t *)direction;
- (BOOL)calibrationFromServiceData:(NSData *)serviceData;


@property(nonatomic,retain) BRDevice						*device;
@property(nonatomic,retain) BRRemoteDevice					*sensorsDevice;

@property(nonatomic,assign) IBOutlet NSButton               *closeConnectionButton;
@property(nonatomic,assign) IBOutlet NSButton               *queryWearingStateButton;
@property(nonatomic,assign) IBOutlet NSButton               *querySignalStrengthButton;
@property(nonatomic,assign) IBOutlet NSButton               *queryDeviceInfoButton;
@property(nonatomic,assign) IBOutlet NSButton               *querySubscribeToServicesButton;
@property(nonatomic,assign) IBOutlet NSButton               *queryUnsubscriberFromServicesButton;
@property(nonatomic,assign) IBOutlet NSButton               *queryQueryServicesButton;
@property(nonatomic,assign) IBOutlet NSButton               *subscribeToSignalStrengthButton;
@property(nonatomic,assign) IBOutlet NSTextField            *connectedTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *wearingStateTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *signalStrengthTextField;
@property(nonatomic,assign) IBOutlet NSProgressIndicator    *headingIndicator;
@property(nonatomic,assign) IBOutlet NSProgressIndicator    *pitchIndicator;
@property(nonatomic,assign) IBOutlet NSProgressIndicator    *rollIndicator;
@property(nonatomic,assign) IBOutlet NSTextField            *freeFallTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *tapsTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *pedometerTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *gyroCalTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *dataTextField;


#warning BANGLE
//- (IBAction)dialogInteractionButton:(id)sender;
//- (IBAction)configureApplicationButton:(id)sender;
//- (IBAction)unlockButton:(id)sender;
//- (IBAction)lockButton:(id)sender;
//
//- (void)showTextDialogWithTopText:(NSString *)topText bottomText:(NSString *)bottomText;
//- (void)showYesNoDialogWithTopText:(NSString *)topText;
//- (void)showChooseNumberDialogWithTopText:(NSString *)topText;
//- (void)showChooseOneDialogWithTopText:(NSString *)topText choices:(NSArray *)choices;
//- (void)showChooseMultipleDialogWithTopText:(NSString *)topText choices:(NSArray *)choices;
//
//- (void)setDisplayReadoutForCharacteristic:(BRDisplayReadoutCharacteristic)characteristic enabled:(BOOL)enabled;
//
//- (void)setLockState:(BOOL)lockState;
//
//@property(nonatomic,strong) NSArray							*dialogChoices;
//
//@property(nonatomic,assign) IBOutlet NSButton               *dialogInteractionButton;
//@property(nonatomic,assign) IBOutlet NSButton               *configureApplicationButton;
//@property(nonatomic,assign) IBOutlet NSTextField            *dialogInteractionResultField;
//@property(nonatomic,assign) IBOutlet NSButton               *unlockButton;
//@property(nonatomic,assign) IBOutlet NSButton               *lockButton;


@end


@implementation MainWindowController

#pragma mark - Private

- (IBAction)openConnectionButton:(id)sender
{
	if (!self.device) {
		NSArray *devices = [PLTDevice availableDevices];
		if ([devices count]) {
			NSString *macString = ((PLTDevice *)devices[0]).address;
			self.device = [BRDevice deviceWithAddress:macString]; 
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
	BRConfigureSignalStrengthEventsCommand *command = [BRConfigureSignalStrengthEventsCommand commandWithConnectionId:0
																											   enable:YES
																											  dononly:NO
																												trend:NO
																									  reportRssiAudio:NO 
																								   reportNearFarAudio:NO
																								  reportNearFarToBase:NO 
																										  sensitivity:0
																										nearThreshold:71
																										   maxTimeout:UINT16_MAX];
    [self.device sendMessage:command];
}

- (IBAction)querySignalStrengthButton:(id)sender
{
    BRCurrentSignalStrengthSettingRequest *request = (BRCurrentSignalStrengthSettingRequest *)[BRCurrentSignalStrengthSettingRequest request];
    [self.device sendMessage:request];
}

- (IBAction)queryDeviceInfoButton:(id)sender
{
//	NSString *msg = @"FF0300030000000100";
//	BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeCommand payload:[NSData dataWithHexString:msg]];
//	[self.sensorsDevice sendMessage:message];
	
    BRGetDeviceInfoSettingRequest *request = (BRGetDeviceInfoSettingRequest *)[BRGetDeviceInfoSettingRequest request];
    [self.sensorsDevice sendMessage:request];
}

- (IBAction)queryServicesButton:(id)sender
{
//	[self performSelectorInBackground:@selector(ya) withObject:nil];
	
//	BRServiceDataSettingRequest *request = [BRServiceDataSettingRequest requestWithServiceID:BRServiceIDPedometer];
//	[self.sensorsDevice sendMessage:request];
	
//	BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:BRServiceIDFreeFall
//                                                                                        mode:BRServiceSubscriptionModePeriodic
//                                                                                      period:1000];
//	[self.sensorsDevice sendMessage:message];

	
    for (int i = 0; i <= BRServiceIDGyroCal; i++) {
        if (i==1) continue;
        
		BRQueryServicesDataSettingRequest *request = [BRQueryServicesDataSettingRequest requestWithServiceID:i characteristic:0];
		[self.sensorsDevice sendMessage:request];
    }
} 

- (IBAction)subscribeToServicesButton:(id)sender
{
//	BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:BRServiceIDOrientationTracking
//																				characteristic:0
//																						  mode:BRServiceSubscriptionModeOnChange
//																						period:0];
//    [self.sensorsDevice sendMessage:message];
    
    for (int i = 0; i <= BRServiceIDGyroCal; i++) {
        if (i==1) continue;
		if (i==BRServiceIDOrientationTracking) continue;
        
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:i
																					characteristic:0
																							  mode:BRServiceSubscriptionModeOnChange
																							period:0];
        [self.sensorsDevice sendMessage:message];
    }
}

- (IBAction)unsubscribeFromServicesButton:(id)sender
{
//	BRConnectionStatusSettingRequest *message = [BRConnectionStatusSettingRequest request];
//	[self.device sendMessage:message];
	
	
//	BRSubscribeToServiceCommand *message = [BRSubscribeToServiceCommand commandWithServiceID:0x00
//																						mode:BRServiceSubscriptionModeOff
//																					  period:0];
//	[self.sensorsDevice sendMessage:message];

	
    for (int i = 0; i <= BRServiceIDGyroCal; i++) {
        if (i==1) continue;
        
		BRSubscribeToServicesCommand *message = [BRSubscribeToServicesCommand commandWithServiceID:i
																					characteristic:0
																							  mode:BRServiceSubscriptionModeOff
																							period:0];
        [self.sensorsDevice sendMessage:message];
    }
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
//	[self.dialogInteractionButton setEnabled:YES];
//	[self.configureApplicationButton setEnabled:YES];
//	[self.unlockButton setEnabled:YES];
//	//[self.lockButton setEnabled:YES];
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
    self.connectedTextField.stringValue = @"No";
    self.wearingStateTextField.stringValue = @"-";
    self.signalStrengthTextField.stringValue = @"-";
    [self.headingIndicator setDoubleValue:-180];
    [self.pitchIndicator setDoubleValue:-90];
    [self.rollIndicator setDoubleValue:-90];
    self.freeFallTextField.stringValue = @"-"; 
    self.tapsTextField.stringValue = @"-";
    self.pedometerTextField.stringValue = @"-";
    self.gyroCalTextField.stringValue = @"-";
	
#warning BANGLE
//	[self.dialogInteractionButton setEnabled:NO];
//	[self.configureApplicationButton setEnabled:NO];
//	[self.unlockButton setEnabled:NO];
//	//[self.lockButton setEnabled:NO];
}

#pragma mark - WC1 Parsing Helpers

- (PLTQuaternion)quaternionFromServiceData:(NSData *)serviceData
{
	int32_t w, x, y, z;
	
	[[serviceData subdataWithRange:NSMakeRange(0, sizeof(int32_t))] getBytes:&w length:sizeof(int32_t)];
	[[serviceData subdataWithRange:NSMakeRange(4, sizeof(int32_t))] getBytes:&x length:sizeof(int32_t)];
	[[serviceData subdataWithRange:NSMakeRange(8, sizeof(int32_t))] getBytes:&y length:sizeof(int32_t)];
	[[serviceData subdataWithRange:NSMakeRange(12, sizeof(int32_t))] getBytes:&z length:sizeof(int32_t)];
	
	w = ntohl(w);
	x = ntohl(x);
	y = ntohl(y);
	z = ntohl(z);
	
	if (w > 32767) w -= 65536;
	if (x > 32767) x -= 65536;
	if (y > 32767) y -= 65536;
	if (z > 32767) z -= 65536;
	
	double fw = ((double)w) / 16384.0f;
	double fx = ((double)x) / 16384.0f;
	double fy = ((double)y) / 16384.0f;
	double fz = ((double)z) / 16384.0f;
	
	PLTQuaternion q = (PLTQuaternion){fw, fx, fy, fz};
	if (q.w>1.0001f || q.x>1.0001f || q.y>1.0001f || q.z>1.0001f) {
		NSLog(@"Bad quaternion! { %f, %f, %f, %f }", q.w, q.x, q.y, q.z);
	}
	else {
		return q;
	}
	
	return (PLTQuaternion){1, 0, 0, 0};
}

- (uint32_t)pedometerCountFromServiceData:(NSData *)serviceData
{
	uint32_t steps;
	[serviceData getBytes:&steps length:sizeof(uint32_t)];
	steps = ntohl(steps);
	return steps;
}

- (BOOL)freeFallFromServiceData:(NSData *)serviceData
{
	uint8_t ff;
	[serviceData getBytes:&ff length:sizeof(uint8_t)];
	return ff;
}

- (void)getTapsFromServiceData:(NSData *)serviceData count:(uint8_t *)count direction:(uint8_t *)direction
{
	uint8_t c;
	uint8_t d;
	
	[[serviceData subdataWithRange:NSMakeRange(0, sizeof(uint8_t))] getBytes:&d length:sizeof(uint8_t)];
	[[serviceData subdataWithRange:NSMakeRange(1, sizeof(uint8_t))] getBytes:&c length:sizeof(uint8_t)];
	
	*count = c;
	*direction = d;
}

- (BOOL)calibrationFromServiceData:(NSData *)serviceData
{
	uint8_t cal;
	[serviceData getBytes:&cal length:sizeof(uint8_t)];
	return (cal == 3);
}

#pragma mark - BANGLE

//- (IBAction)dialogInteractionButton:(id)sender
//{
//	NSLog(@"dialogInteractionButton:");
//	
//	//[self showTextDialogWithTopText:@"I LOVE" bottomText:@"TURTLES"];
//	//[self showYesNoDialogWithTopText:@"COOKIES"];
//	//[self showChooseNumberDialogWithTopText:@"COOKIES"];
//	//[self showChooseOneDialogWithTopText:@"FAVORITE" choices:@[@"CUPCAKES", @"MARMOLADE", @"CHEESE"]];
//	[self showChooseMultipleDialogWithTopText:@"FAVORITES" choices:@[@"CUPCAKES", @"MARMOLADE", @"CHEESE"]];
//}
//
//- (IBAction)configureApplicationButton:(id)sender
//{
//	NSLog(@"configureApplicationButton:");
//	
//	[self setDisplayReadoutForCharacteristic:BRDisplayReadoutCharacteristicAmbientHumidity enabled:NO];
//}
//
//- (IBAction)unlockButton:(id)sender
//{
//	NSLog(@"unlockButton:");
//	[self setLockState:NO];
//}
//
//- (IBAction)lockButton:(id)sender
//{
//	NSLog(@"lockButton:");
//	//[self setLockState:YES];
//	
//	
////	NSLog(@"ADD CONTACTS");
////	
////	const char *name = [@"MORGAN" cStringUsingEncoding:NSASCIIStringEncoding];
////	NSData *nameData = [NSData dataWithBytes:name length:strlen(name)];
////	//uint16_t nameLen = (uint16_t)[nameData length];
////	
////	const char *number = [@"8314198651" cStringUsingEncoding:NSASCIIStringEncoding];
////	NSData *numberData = [NSData dataWithBytes:number length:strlen(number)];
////	//uint16_t numberLen = (uint16_t)[numberData length];
////	
////	NSString *hexString = [NSString stringWithFormat:@"%@ 00 %@ 00",
////						   [nameData hexStringWithSpaceEvery:0],
////						   [numberData hexStringWithSpaceEvery:0]
////						   ];
////	
////	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
////	hexString = [NSString stringWithFormat:@"%04X %04X %@",
////				 0xFF0B,
////				 deckardArrayLen,
////				 hexString
////				 ];
////	
////	BRRawMessage *message = [BRRawMessage messageWithType:BRMessageTypeCommand payload:[NSData dataWithHexString:hexString]];
////	[self.sensorsDevice sendMessage:message];
//}
//
//
//- (void)showTextDialogWithTopText:(NSString *)topText bottomText:(NSString *)bottomText
//{
//	const char *topPrompt = [topText cStringUsingEncoding:NSASCIIStringEncoding];
//	NSData *topPromptData = [NSData dataWithBytes:topPrompt length:strlen(topPrompt)];
//	uint16_t topPromptLen = (uint16_t)[topPromptData length];
//	
//	const char *bottomPrompt = [bottomText cStringUsingEncoding:NSASCIIStringEncoding];
//	NSData *bottomPromptData = [NSData dataWithBytes:bottomPrompt length:strlen(bottomPrompt)];
//	uint16_t bottomPromptLen = (uint16_t)[bottomPromptData length];
//	
//	NSString *hexString = [NSString stringWithFormat:@"%04X %@ %04X %@ %04X %04X",
//						   topPromptLen,
//						   [topPromptData hexStringWithSpaceEvery:0],
//						   bottomPromptLen,
//						   [bottomPromptData hexStringWithSpaceEvery:0],
//						   2, // attention type
//						   0x4748 // attention specifier
//						   ];
//	
//	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
//	hexString = [NSString stringWithFormat:@"%04X %@",
//				 deckardArrayLen,
//				 hexString
//				 ];
//	
//	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDDialog
//																																		   action:BRDialogApplicationActionTextAlert
//																																	operatingData:[NSData dataWithHexString:hexString]];
//	[self.sensorsDevice sendMessage:command];
//}
//
//- (void)showYesNoDialogWithTopText:(NSString *)topText
//{
//	const char *prompt = [topText cStringUsingEncoding:NSASCIIStringEncoding];
//	NSData *promptData = [NSData dataWithBytes:prompt length:strlen(prompt)];
//	uint16_t promptLen = (uint16_t)[promptData length];
//	
//	NSString *hexString = [NSString stringWithFormat:@"%04X %@",
//						   promptLen,
//						   [promptData hexStringWithSpaceEvery:0]
//						   ];
//	
//	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
//	hexString = [NSString stringWithFormat:@"%04X %@",
//				 deckardArrayLen,
//				 hexString
//				 ];
//	
//	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDDialog
//																																		   action:BRDialogApplicationActionYesNo
//																																	operatingData:[NSData dataWithHexString:hexString]];
//	[self.sensorsDevice sendMessage:command];
//	
//}
//
//- (void)showChooseNumberDialogWithTopText:(NSString *)topText
//{
//	const char *prompt = [topText cStringUsingEncoding:NSASCIIStringEncoding];
//	NSData *promptData = [NSData dataWithBytes:prompt length:strlen(prompt)];
//	uint16_t promptLen = (uint16_t)[promptData length];
//	
//	NSString *hexString = [NSString stringWithFormat:@"%04X %@",
//						   promptLen,
//						   [promptData hexStringWithSpaceEvery:0]
//						   ];
//	
//	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
//	hexString = [NSString stringWithFormat:@"%04X %@",
//				 deckardArrayLen,
//				 hexString
//				 ];
//	
//	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDDialog
//																																		   action:BRDialogApplicationActionEnterNumber
//																																	operatingData:[NSData dataWithHexString:hexString]];
//	[self.sensorsDevice sendMessage:command];
//	
//}
//
//- (void)showChooseOneDialogWithTopText:(NSString *)topText choices:(NSArray *)choices
//{
//	self.dialogChoices = choices;
//	
//	
//	
//	const char *prompt = [topText cStringUsingEncoding:NSASCIIStringEncoding];
//	NSData *promptData = [NSData dataWithBytes:prompt length:strlen(prompt)];
//	uint16_t promptLen = (uint16_t)[promptData length];
//	
//	uint16_t choicesIndexes[[choices count]];
//	NSMutableString *choicesString = [NSMutableString string];
//	
//	for (int c=0; c<[choices count]; c++) {
//		NSString *choice = (NSString *)choices[c];
//		[choicesString appendString:[choice uppercaseString]];
//		choicesIndexes[c] = [choicesString length] - 1;
//	}
//	
//	const char *choicesCStr = [choicesString cStringUsingEncoding:NSASCIIStringEncoding];
//	NSData *choicesData = [NSData dataWithBytes:choicesCStr length:strlen(choicesCStr)];
//	
//	uint16_t indexesArrayLen = (uint16_t)ceilf((float)sizeof(choicesIndexes)/2.0); // length in 2-byte incraments
//	NSMutableString *hexString = [NSMutableString stringWithFormat:@"%04X %@ %04X",
//								  promptLen,
//								  [promptData hexStringWithSpaceEvery:0],
//								  indexesArrayLen];
//	
//	for (int c=0; c<[choices count]; c++) {
//		[hexString appendString:[NSString stringWithFormat:@"%04X", choicesIndexes[c]]];
//	}
//	
//	[hexString appendString:[choicesData hexStringWithSpaceEvery:0]];
//	
//	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
//	hexString = [NSMutableString stringWithFormat:@"%04X %@",
//				 deckardArrayLen,
//				 hexString
//				 ];
//	
//	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDDialog
//																																		   action:BRDialogApplicationActionChooseOne
//																																	operatingData:[NSData dataWithHexString:hexString]];
//	[self.sensorsDevice sendMessage:command];
//	
//}
//
//- (void)showChooseMultipleDialogWithTopText:(NSString *)topText choices:(NSArray *)choices
//{
//	self.dialogChoices = choices;
//	
//	
//	
//	const char *prompt = [topText cStringUsingEncoding:NSASCIIStringEncoding];
//	NSData *promptData = [NSData dataWithBytes:prompt length:strlen(prompt)];
//	uint16_t promptLen = (uint16_t)[promptData length];
//	
//	uint16_t choicesIndexes[[choices count]];
//	NSMutableString *choicesString = [NSMutableString string];
//	
//	for (int c=0; c<[choices count]; c++) {
//		NSString *choice = (NSString *)choices[c];
//		[choicesString appendString:[choice uppercaseString]];
//		choicesIndexes[c] = [choicesString length] - 1;
//	}
//	
//	const char *choicesCStr = [choicesString cStringUsingEncoding:NSASCIIStringEncoding];
//	NSData *choicesData = [NSData dataWithBytes:choicesCStr length:strlen(choicesCStr)];
//	
//	uint16_t indexesArrayLen = (uint16_t)ceilf((float)sizeof(choicesIndexes)/2.0); // length in 2-byte incraments
//	NSMutableString *hexString = [NSMutableString stringWithFormat:@"%04X %@ %04X",
//								  promptLen,
//								  [promptData hexStringWithSpaceEvery:0],
//								  indexesArrayLen];
//	
//	for (int c=0; c<[choices count]; c++) {
//		[hexString appendString:[NSString stringWithFormat:@"%04X", choicesIndexes[c]]];
//	}
//	
//	[hexString appendString:[choicesData hexStringWithSpaceEvery:0]];
//	
//	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
//	hexString = [NSMutableString stringWithFormat:@"%04X %@",
//				 deckardArrayLen,
//				 hexString
//				 ];
//	
//	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDDialog
//																																		   action:BRDialogApplicationActionChooseMultiple
//																																	operatingData:[NSData dataWithHexString:hexString]];
//	[self.sensorsDevice sendMessage:command];
//}
//
//- (void)setDisplayReadoutForCharacteristic:(BRDisplayReadoutCharacteristic)characteristic enabled:(BOOL)enabled
//{
//	NSLog(@"setDisplayReadoutForCharacteristic: %d, enabled: %@", characteristic, (enabled ? @"YES" : @"NO"));
//	
//	NSData *enabledData = [NSData dataWithBytes:&enabled length:sizeof(BOOL)];
//	
//	BRConfigureApplicationCommad *command = [BRConfigureApplicationCommad commandWithFeatureID:BRFeatureIDDisplayReadout characteristic:characteristic configurationData:enabledData];
//	[self.sensorsDevice sendMessage:command];
//}
//
//- (void)setLockState:(BOOL)lockState
//{
//	NSMutableString *hexString = [NSMutableString stringWithFormat:@"%02X",
//								  lockState];
//	
//	uint16_t deckardArrayLen = (uint16_t)[[NSData dataWithHexString:hexString] length];
//	hexString = [NSMutableString stringWithFormat:@"%04X %@",
//				 deckardArrayLen,
//				 hexString
//				 ];
//	
//	BRPerformApplicationActionCommand *command = (BRPerformApplicationActionCommand *)[BRPerformApplicationActionCommand commandWithApplicationID:BRApplicationIDLock
//																																		   action:0
//																																	operatingData:[NSData dataWithHexString:hexString]];
//	[self.sensorsDevice sendMessage:command];
//}

#pragma mark - BRDeviceDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
    NSLog(@"BRDeviceDidConnect: %@", device);
    
	if (device == self.sensorsDevice) {
		self.connectedTextField.stringValue = @"Yeahh boi";
		[self enableUI];
	}
	
#warning temporary for EDGE
	self.connectedTextField.stringValue = @"Yeahh boi";
	[self enableUI];
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

    if ([event isKindOfClass:[BRWearingStateChangedEvent class]]) {
        BRWearingStateChangedEvent *e = (BRWearingStateChangedEvent *)event;
        self.wearingStateTextField.stringValue = (e.worn ? @"Yes" : @"No");
    }
    else if ([event isKindOfClass:[BRSignalStrengthEvent class]]) {
        BRSignalStrengthEvent *e = (BRSignalStrengthEvent *)event;
        self.signalStrengthTextField.stringValue = [NSString stringWithFormat:@"%d", e.strength];
    }
	else if ([event isKindOfClass:[BRSubscribedServiceDataEvent class]]) {
		BRSubscribedServiceDataEvent *serviceDataEvent = (BRSubscribedServiceDataEvent *)event;
		uint16_t serviceID = serviceDataEvent.serviceID;
		NSData *serviceData = serviceDataEvent.serviceData;

		switch (serviceID) {
			case BRServiceIDOrientationTracking: {
				PLTQuaternion quaternion = [self quaternionFromServiceData:serviceData];
				PLTEulerAngles eulerAngles = BREulerAnglesFromQuaternion(quaternion);		
				[self.headingIndicator setDoubleValue:-eulerAngles.x];
				[self.pitchIndicator setDoubleValue:eulerAngles.y];
				[self.rollIndicator setDoubleValue:eulerAngles.z];
				break; }
			case BRServiceIDPedometer: {
				uint32_t steps = [self pedometerCountFromServiceData:serviceData];
				self.pedometerTextField.stringValue = [NSString stringWithFormat:@"%d", steps];
				break; }
			case BRServiceIDFreeFall: {
				BOOL isInFreeFall = [self freeFallFromServiceData:serviceData];
				self.freeFallTextField.stringValue = (isInFreeFall ? @"Yes" : @"No");
				break; }
			case BRServiceIDTaps: {
				uint8_t count;
				uint8_t direction;
				[self getTapsFromServiceData:serviceData count:&count direction:&direction];
				if (count) self.tapsTextField.stringValue = [NSString stringWithFormat:@"%d in %@", count, NSStringFromTapDirection(direction)];
				else self.tapsTextField.stringValue = @"-";
				break; }
//			case BRServiceIDMagCal: {
//				BOOL cal = [self calibrationFromServiceData:serviceData];
//				break; }
			case BRServiceIDGyroCal: {
				BOOL isCalibrated = [self calibrationFromServiceData:serviceData];
				self.gyroCalTextField.stringValue = (isCalibrated ? @"Yes" : @"No");
				break; }
		}
	}
	
//    else if ([event isKindOfClass:[BROrientationTrackingEvent class]]) {
//        BROrientationTrackingEvent *e = (BROrientationTrackingEvent *)event;
//		BREulerAngles eulerAngles = BREulerAnglesFromQuaternion(e.quaternion);		
//        [self.headingIndicator setDoubleValue:-eulerAngles.x];
//        [self.pitchIndicator setDoubleValue:eulerAngles.y];
//        [self.rollIndicator setDoubleValue:eulerAngles.z];
//    }
//    else if ([event isKindOfClass:[BRTapsEvent class]]) {
//        BRTapsEvent *e = (BRTapsEvent *)event;
//        if (e.count) self.tapsTextField.stringValue = [NSString stringWithFormat:@"%d in %@", e.count, NSStringFromTapDirection(e.direction)];
//        else self.tapsTextField.stringValue = @"-";
//    }
//    else if ([event isKindOfClass:[BRFreeFallEvent class]]) {
//        BRFreeFallEvent *e = (BRFreeFallEvent *)event;
//        self.freeFallTextField.stringValue = (e.isInFreeFall ? @"Yes" : @"No");
//    }
//    else if ([event isKindOfClass:[BRPedometerEvent class]]) {
//        BRPedometerEvent *e = (BRPedometerEvent *)event;
//        self.pedometerTextField.stringValue = [NSString stringWithFormat:@"%d", e.steps];
//    }
//    else if ([event isKindOfClass:[BRGyroscopeCalStatusEvent class]]) {
//        BRGyroscopeCalStatusEvent *e = (BRGyroscopeCalStatusEvent *)event;
//        self.gyroCalTextField.stringValue = (e.isCalibrated ? @"Yes" : @"No");
//    }
//	
//	
//#warning BANGLE
//	else if ([event isKindOfClass:[BRApplicationActionResultEvent class]]) {
//		BRApplicationActionResultEvent *e = (BRApplicationActionResultEvent *)event;
//		if (e.applicationID == BRApplicationIDDialog) {
//			switch (e.action) {
//				case BRDialogApplicationActionTextAlert: {
//					// chaa
//					break; }
//				case BRDialogApplicationActionYesNo: {
//					// chaa
//					break; }
//				case BRDialogApplicationActionEnterNumber: {
//					uint8_t count;
//					[[e.resultData subdataWithRange:NSMakeRange(1, sizeof(uint8_t))] getBytes:&count length:sizeof(uint8_t)];
//					self.dialogInteractionResultField.stringValue = [NSString stringWithFormat:@"%d cookies.", count];
//					break; }
//				case BRDialogApplicationActionChooseOne: {
//					uint8_t index;
//					[[e.resultData subdataWithRange:NSMakeRange(1, sizeof(uint8_t))] getBytes:&index length:sizeof(uint8_t)];
//					self.dialogInteractionResultField.stringValue = self.dialogChoices[index];
//					break; }
//				case BRDialogApplicationActionChooseMultiple: {
//					//uint16_t len;
//					//[[e.resultData subdataWithRange:NSMakeRange(1, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
//					uint16_t len = [e.resultData length];
//					uint8_t indexes[len];
//					[[e.resultData subdataWithRange:NSMakeRange(0, len)] getBytes:&indexes length:len];
//					NSMutableString *choices = [NSMutableString string];
//					for (int i = 0; i<len; i++) {
//						uint8_t index = indexes[i];
//						if (i == len-1) {
//							[choices appendString:self.dialogChoices[index]];
//						}
//						else {
//							[choices appendString:[NSString stringWithFormat:@"%@, ", self.dialogChoices[index]]];
//						}
//					}
//					self.dialogInteractionResultField.stringValue = choices;
//					break; }
//				default:
//					break;
//			}
//		}
//	}
}

- (void)BRDevice:(BRDevice *)device didReceiveSettingResult:(BRSettingResult *)result
{
    NSLog(@"BRDevice: %@ didReceiveSettingResult: %@", device, result);
    
    if ([result isKindOfClass:[BRWearingStateSettingResult class]]) {
        BRWearingStateSettingResult *r = (BRWearingStateSettingResult *)result;
        self.wearingStateTextField.stringValue = (r.worn ? @"Yes" : @"No");
    }
    else if ([result isKindOfClass:[BRCurrentSignalStrengthSettingResult class]]) {
        BRCurrentSignalStrengthSettingResult *r = (BRCurrentSignalStrengthSettingResult *)result;
        self.signalStrengthTextField.stringValue = [NSString stringWithFormat:@"%d", r.strength];
    }
	else if ([result isKindOfClass:[BRQueryServicesDataSettingResult class]]) {
		BRQueryServicesDataSettingResult *serviceDataResult = (BRQueryServicesDataSettingResult *)result;
		uint16_t serviceID = serviceDataResult.serviceID;
		NSData *serviceData = serviceDataResult.servicedata;
		
		switch (serviceID) {
			case BRServiceIDOrientationTracking: {
				PLTQuaternion quaternion = [self quaternionFromServiceData:serviceData];
				PLTEulerAngles eulerAngles = BREulerAnglesFromQuaternion(quaternion);		
				[self.headingIndicator setDoubleValue:-eulerAngles.x];
				[self.pitchIndicator setDoubleValue:eulerAngles.y];
				[self.rollIndicator setDoubleValue:eulerAngles.z];
				break; }
			case BRServiceIDPedometer: {
				uint32_t steps = [self pedometerCountFromServiceData:serviceData];
				self.pedometerTextField.stringValue = [NSString stringWithFormat:@"%d", steps];
				break; }
			case BRServiceIDFreeFall: {
				BOOL isInFreeFall = [self freeFallFromServiceData:serviceData];
				self.freeFallTextField.stringValue = (isInFreeFall ? @"Yes" : @"No");
				break; }
			case BRServiceIDTaps: {
				uint8_t count;
				uint8_t direction;
				[self getTapsFromServiceData:serviceData count:&count direction:&direction];
				if (count) self.tapsTextField.stringValue = [NSString stringWithFormat:@"%d in %@", count, NSStringFromTapDirection(direction)];
				else self.tapsTextField.stringValue = @"-";
				break; }
//			case BRServiceIDMagCal: {
//				BOOL cal = [self calibrationFromServiceData:serviceData];
//				break; }
			case BRServiceIDGyroCal: {
				BOOL isCalibrated = [self calibrationFromServiceData:serviceData];
				self.gyroCalTextField.stringValue = (isCalibrated ? @"Yes" : @"No");
				break; }
		}
	}
	
//    else if ([result isKindOfClass:[BROrientationTrackingSettingResult class]]) {
//        BROrientationTrackingSettingResult *r = (BROrientationTrackingSettingResult *)result;
//		BREulerAngles eulerAngles = BREulerAnglesFromQuaternion(r.quaternion);		
//        [self.headingIndicator setDoubleValue:-eulerAngles.x];
//        [self.pitchIndicator setDoubleValue:eulerAngles.y];
//        [self.rollIndicator setDoubleValue:eulerAngles.z];
//    }
//    else if ([result isKindOfClass:[BRTapsSettingResult class]]) {
//        BRTapsSettingResult *r = (BRTapsSettingResult *)result;
//        if (r.count) self.tapsTextField.stringValue = [NSString stringWithFormat:@"%d in %@", r.count, NSStringFromTapDirection(r.direction)];
//        else self.tapsTextField.stringValue = @"-";
//    }
//    else if ([result isKindOfClass:[BRFreeFallSettingResult class]]) {
//        BRFreeFallSettingResult *r = (BRFreeFallSettingResult *)result;
//        self.freeFallTextField.stringValue = (r.isInFreeFall ? @"Yes" : @"No");
//    }
//    else if ([result isKindOfClass:[BRPedometerSettingResult class]]) {
//        BRPedometerSettingResult *r = (BRPedometerSettingResult *)result;
//        self.pedometerTextField.stringValue = [NSString stringWithFormat:@"%d", r.steps];
//    }
//    else if ([result isKindOfClass:[BRGyroscopeCalStatusSettingResult class]]) {
//        BRGyroscopeCalStatusSettingResult *r = (BRGyroscopeCalStatusSettingResult *)result;
//        self.gyroCalTextField.stringValue = (r.isCalibrated ? @"Yes" : @"No");
//    }
}

- (void)BRDevice:(BRDevice *)device didRaiseSettingException:(BRException *)exception
{
	NSLog(@"BRDevice: %@ didRaiseSettingException: %@", device, exception);
}

- (void)BRDevice:(BRDevice *)device didRaiseCommandException:(BRException *)exception
{
	NSLog(@"BRDevice: %@ didRaiseCommandException: %@", device, exception);
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

- (void)BRDevice:(BRDevice *)device willSendData:(NSData *)data
{
    NSString *hexString = [data hexStringWithSpaceEvery:2];
    NSLog(@"--> %@", hexString);
    self.dataTextField.stringValue = [NSString stringWithFormat:@"--> %@", hexString];
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
    NSString *hexString = [data hexStringWithSpaceEvery:2];
    NSLog(@"<-- %@", hexString);
    self.dataTextField.stringValue = [NSString stringWithFormat:@"<-- %@", hexString];
}

#pragma mark - NSWindowController

//- (id)init
//{
//	if (self = [super initWithWindowNibName:@"MainWindow.xib"]) {
//		return self;
//	}
//	return nil;
//}

- (NSString *)windowNibName
{
    return @"MainWindow";
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self disableUI];
    
    NSArray *devices = [PLTDevice availableDevices];
    NSLog(@"Available devices: %@", devices);
 }

@end
