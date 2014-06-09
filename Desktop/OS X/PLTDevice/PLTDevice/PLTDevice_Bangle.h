//
//  PLTDevice_Bangle.h
//  PLTDevice
//
//  Created by Morgan Davis on 6/4/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

@class PLTDevice;
@protocol PLTDeviceActionSubscriber;


typedef NS_ENUM(NSUInteger, PLTService) {
	PLTDialogInteractionResultCodeCompleted =	0x0000,
	PLTDialogInteractionResultCodeCanceled =	0x0001,
	PLTDialogInteractionResultCodeInterrupted =	0x0002
} PLTDialogInteractionResultCode;


@interface BRDevice () <PLTDeviceActionSubscriber>

- (void)displayAlertDialogWithTopText:(NSString *)topText bottomText:(NSString *)bottomText;

@end


@protocol PLTDeviceActionSubscriber <NSObject>

- (void)PLTDevice:(PLTDevice *)device didDismissTextDialogWithCode:(PLTDialogInteractionResultCode)code;


@end
