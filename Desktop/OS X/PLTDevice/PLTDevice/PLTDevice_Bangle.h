//
//  PLTDevice_Bangle.h
//  PLTDevice
//
//  Created by Morgan Davis on 6/4/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

@class PLTDevice;
@protocol PLTDeviceActionSubscriber;


typedef NS_ENUM(NSUInteger, PLTService_Bangle) {
	PLTServiceAmbientHumidity =					0x0008,
	PLTServiceAmbientLight =					0x0009,
	// optical proximity
	PLTServiceAmbientTemperature =				0x000C,
	PLTServiceSkinTemperature =					0x000D,
	PLTServiceSkinConductivity =				0x000E,
	PLTServiceAmbientPressure =					0x000F,
	PLTServiceHeartRate =						0x0010
};

typedef NS_ENUM(NSUInteger, PLTDialogInteractionResultCode) {
	PLTDialogInteractionResultCodeCompleted =	0x0000,
	PLTDialogInteractionResultCodeCanceled =	0x0001,
	PLTDialogInteractionResultCodeInterrupted =	0x0002
};


@interface PLTDevice () <PLTDeviceActionSubscriber>

- (void)displayAlertDialogWithTopText:(NSString *)topText bottomText:(NSString *)bottomText;

@end


@protocol PLTDeviceActionSubscriber <NSObject>

- (void)PLTDevice:(PLTDevice *)device didDismissTextDialogWithCode:(PLTDialogInteractionResultCode)code;

@end
