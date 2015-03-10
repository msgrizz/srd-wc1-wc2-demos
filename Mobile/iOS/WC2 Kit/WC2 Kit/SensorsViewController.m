//
//  SensorsViewController.h
//  PLTSensor
//
//  Created by Davis, Morgan on 3/15/13.
//  Copyright (c) 2013 Cambridge Silicon Radio. All rights reserved.
//

#import "SensorsViewController.h"
#import "PLTDeviceHelper.h"
#import <PLTDevice_iOS/PLTDevice_iOS.h>
#import "PLTDevice_Internal.h"
#import "BRDeviceUtilities.h"
#import <SceneKit/SceneKit.h>


typedef enum {
    PLTSensorTableRowOrientation,
	PLTSensorTableRowWearingState,
	PLTSensorTableRowProximity,
	PLTSensorTableRowPedometer,
    PLTSensorTableRowFreeFall,
    PLTSensorTableRowTaps,
	PLTSensorTableRowHeading,
	PLTSensorTableRowAcceleration,
	PLTSensorTableRowAngularVelocity,
	PLTSensorTableRowMagnetism,
    PLTSensorTableRowMagCal,
    PLTSensorTableRowGyroCal
} PLTSensorTableRow;


@interface SensorsViewController () <PLTDeviceSubscriber>

- (void)subscribeToServices;
- (void)unsubscribeFromServices;
- (void)calOrientation;
- (void)resetPed:(id)sender;
- (void)deviceDidOpenConnectionNotification:(NSNotification *)note;
- (void)deviceWillSendDataNotification:(NSNotification *)note;
- (void)deviceDidReceiveDataNotification:(NSNotification *)note;

@property(nonatomic,strong) IBOutlet UITableViewCell    *rotationCell;
@property(nonatomic,strong) IBOutlet UIProgressView     *headingProgressView;
@property(nonatomic,strong) IBOutlet UIProgressView     *rollProgressView;
@property(nonatomic,strong) IBOutlet UIProgressView     *pitchProgressView;
@property(nonatomic,strong) IBOutlet UILabel            *headingTitleLabel;
@property(nonatomic,strong) IBOutlet UILabel            *rollTitleLabel;
@property(nonatomic,strong) IBOutlet UILabel            *pitchTitleLabel;
@property(nonatomic,strong) IBOutlet UILabel            *headingValueLabel;
@property(nonatomic,strong) IBOutlet UILabel            *rollValueLabel;
@property(nonatomic,strong) IBOutlet UILabel            *pitchValueLabel;
@property(nonatomic,strong) UILabel						*packetDataLabel;

@property(nonatomic,strong) SCNView						*orientationSceneView;
@property(nonatomic,strong) UILabel						*orientationDetailLabel;

@property(nonatomic,strong) UILabel						*headingDetailLabel;

//@property(nonatomic,strong) SCNView						*accelerationSceneView;
@property(nonatomic,strong) UILabel						*accelerationDetailLabel;

//@property(nonatomic,strong) SCNView						*angularVelocitySceneView;
@property(nonatomic,strong) UILabel						*angularVelocityDetailLabel;

//@property(nonatomic,strong) SCNView						*magnetismSceneView;
@property(nonatomic,strong) UILabel						*magnetismDetailLabel;

@end


@implementation SensorsViewController

#pragma mark - Private

- (void)subscribeToServices
{
	NSLog(@"subscribeToServices");
	
	PLTDevice *d = CONNECTED_DEVICE;
	if (d) {
		NSError *err = nil;
		
		// query those that don't update often
		
#warning proximity??
		
		[d queryInfo:self forService:PLTServiceWearingState error:&err];
		if (err) NSLog(@"Error querying wearing state service: %@", err);
		
//		[d queryInfo:self forService:PLTServicePedometer error:&err];
//		if (err) NSLog(@"Error querying pedometer service: %@", err);
//		
//		[d queryInfo:self forService:PLTServiceMagnetometerCalibrationStatus error:&err];
//		if (err) NSLog(@"Error querying magnetometer calibration service: %@", err);
//		
//		[d queryInfo:self forService:PLTServiceGyroscopeCalibrationStatus error:&err];
//		if (err) NSLog(@"Error querying gyroscope calibration service: %@", err);
		
		// subscribe to WC1
		
		[d subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
		
		[d subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to proximity service: %@", err);
		
		[d subscribe:self toService:PLTServiceOrientation withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to orientation tracking state service: %@", err);
		
		[d subscribe:self toService:PLTServicePedometer withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to pedometer service: %@", err);
		
		[d subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to free fall service: %@", err);
		
		[d subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to taps service: %@", err);
		
		[d subscribe:self toService:PLTServiceMagnetometerCalibrationStatus withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to magnetometer calibration service: %@", err);
		
		[d subscribe:self toService:PLTServiceGyroscopeCalibrationStatus withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to gyroscope calibration service: %@", err);
		
		// subscribe to WC2
		
		[d subscribe:self toService:PLTServiceAcceleration withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
		
		[d subscribe:self toService:PLTServiceAngularVelocity withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
		
		[d subscribe:self toService:PLTServiceMagnetism withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
		
		[d subscribe:self toService:PLTServiceHeading withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
		if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
	}
	else {
		NSLog(@"No device conenctions open.");
	}
}

- (void)unsubscribeFromServices
{
	NSLog(@"unsubscribeFromServices");
	
	PLTDevice *d = CONNECTED_DEVICE;
	if (CONNECTED_DEVICE) {
		[d unsubscribeFromAll:self];
	}
	else {
		NSLog(@"No device conenctions open.");
	}
}

- (void)calOrientation
{
	[CONNECTED_DEVICE setCalibration:nil forService:PLTServiceOrientation error:nil];
}

- (void)resetPed:(id)sender
{
    //self.pedStepOffset = self.pedCount;
	[CONNECTED_DEVICE setCalibration:nil forService:PLTServicePedometer error:nil];
	[self.tableView reloadData];
}

- (void)deviceDidOpenConnectionNotification:(NSNotification *)note
{
	[self subscribeToServices];
}

- (void)deviceWillSendDataNotification:(NSNotification *)note
{
	NSData *data = (NSData *)note.userInfo[PLTDeviceDataNotificationKey];
	//NSString *hexString = [data hexStringWithSpaceEvery:2];
	NSString *hexString = BRDeviceHexStringFromData(data, 2);
	self.packetDataLabel.text = [NSString stringWithFormat:@"--> %@", hexString];
}

- (void)deviceDidReceiveDataNotification:(NSNotification *)note
{
	NSData *data = (NSData *)note.userInfo[PLTDeviceDataNotificationKey];
	//NSString *hexString = [data hexStringWithSpaceEvery:2];
	NSString *hexString = BRDeviceHexStringFromData(data, 2);
	self.packetDataLabel.text = [NSString stringWithFormat:@"<-- %@", hexString];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PLTSensorTableRowGyroCal + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plain"];
	
	if (cell == nil) {
		if (IPAD) {
			cell = [[ExtendedLabelWidthTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"plain"];
			cell.textLabel.font = [UIFont systemFontOfSize:28];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
		}
		else {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"plain"];
		}
	}
	
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	
	switch (indexPath.row) {
		case PLTSensorTableRowOrientation: {
			cell.textLabel.text = @"orientation";
			cell.detailTextLabel.hidden = YES;
//			if (!self.orientationSceneView) {
//				CGRect frame = CGRectMake(-80, -20, 92, 92);
//				SCNView *sceneView = [[SCNView alloc] initWithFrame:frame];
//				sceneView.scene = [SCNScene sceneNamed:@"arrow"];
//				sceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
//				sceneView.allowsCameraControl = YES;
//				sceneView.autoenablesDefaultLighting = YES;
//				self.orientationSceneView = sceneView;
//			}
			if (!self.orientationDetailLabel) {
				UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(271, 1, 380, 94)];
				detailLabel.numberOfLines = 3;
				detailLabel.font = [UIFont systemFontOfSize:20];
				[cell.contentView addSubview:detailLabel];
				self.orientationDetailLabel = detailLabel;
			}
			cell.accessoryView = self.orientationSceneView;
			break; }
			
		case PLTSensorTableRowWearingState: {
			cell.textLabel.text = @"wearing state";
			NSString *state = @"";
			PLTWearingStateInfo *wearInfo = (PLTWearingStateInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceWearingState error:nil];
			if (wearInfo.isBeingWorn) state = @"Wearing";
			else state = @"Not Wearing";
			cell.detailTextLabel.text = state;
			break; }
			
		case PLTSensorTableRowProximity: {
			cell.textLabel.text = @"proximity";
			PLTProximityInfo *proximityInfo = (PLTProximityInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceProximity error:nil];
			if (proximityInfo) { 
				cell.detailTextLabel.text = [NSStringFromProximity(proximityInfo.localProximity) capitalizedString];
			}
			else {
				cell.detailTextLabel.text = @"-";
			}
			break; }
			
			//			case PLTSensorTableRowLocalProximity: {
			//				cell.textLabel.text = @"local proximity";
			//				PLTProximityInfo *proximityInfo = (PLTProximityInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceProximity error:nil];
			//				if (proximityInfo) { 
			//					cell.detailTextLabel.text = [NSStringFromProximity(proximityInfo.localProximity) capitalizedString];
			//				}
			//				else {
			//					cell.detailTextLabel.text = @"-";
			//				}
			//				break; }
			//				
			//			case PLTSensorTableRowRemoteProximity: {
			//				cell.textLabel.text = @"remote proximity";
			//				PLTProximityInfo *proximityInfo = (PLTProximityInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceProximity error:nil];
			//				if (proximityInfo) { 
			//					cell.detailTextLabel.text = [NSStringFromProximity(proximityInfo.remoteProximity) capitalizedString];
			//				}
			//				else {
			//					cell.detailTextLabel.text = @"-";
			//				}
			//				break; }
			
		case PLTSensorTableRowFreeFall: {
			cell.textLabel.text = @"free fall";
			PLTFreeFallInfo *freeFallInfo = (PLTFreeFallInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceFreeFall error:nil];
			BOOL freeFall = freeFallInfo.isInFreeFall;
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", (freeFall?@"Yes":@"No")];
			cell.detailTextLabel.textColor = (freeFall ? [UIColor redColor] : [UIColor blackColor]);
			break; }
			
		case PLTSensorTableRowPedometer: {
			cell.textLabel.text = @"pedometer";
			PLTPedometerInfo *pedometerInfo = (PLTPedometerInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServicePedometer error:nil];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d steps", pedometerInfo.steps];
			break; }
			
		case PLTSensorTableRowTaps: {
			cell.textLabel.text = @"taps";
			PLTTapsInfo *tapsInfo = (PLTTapsInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceTaps error:nil];
			if (tapsInfo.count) {
				NSString *tapDirStr = [NSStringFromTapDirection(tapsInfo.direction) capitalizedString];
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@, %@", tapsInfo.count,(tapsInfo.count==1 ? @"Tap" : @"Taps"),tapDirStr];
				cell.detailTextLabel.textColor = [UIColor blackColor];
			}
			else {
				cell.detailTextLabel.text = @"";
				cell.detailTextLabel.textColor = [UIColor blackColor];
			}
			break; }
			
		case PLTSensorTableRowHeading: {
			cell.textLabel.text = @"heading";
			PLTHeadingInfo *headingInfo = (PLTHeadingInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceHeading error:nil];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"% 3.0f°", headingInfo.heading];
			self.headingDetailLabel = cell.detailTextLabel;
			break; }
			
		case PLTSensorTableRowAcceleration: {
			cell.textLabel.text = @"acceleration";
			cell.detailTextLabel.hidden = YES;
			//				if (!self.accelerationSceneView) {
			//					CGRect frame = CGRectMake(-80, -20, 92, 92);
			//					SCNView *sceneView = [[SCNView alloc] initWithFrame:frame];
			//					sceneView.scene = [SCNScene sceneNamed:@"arrow"];
			//					sceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
			//					sceneView.allowsCameraControl = YES;
			//					sceneView.autoenablesDefaultLighting = YES;
			//					self.accelerationSceneView = sceneView;
			//				}
			if (!self.accelerationDetailLabel) {
				UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(271, 1, 380, 94)];
				detailLabel.numberOfLines = 3;
				detailLabel.font = [UIFont systemFontOfSize:20];
				[cell.contentView addSubview:detailLabel];
				self.accelerationDetailLabel = detailLabel;
			}
			//cell.accessoryView = self.accelerationSceneView;
			break; }
			
		case PLTSensorTableRowAngularVelocity: {
			cell.textLabel.text = @"angular velocity";
			cell.detailTextLabel.hidden = YES;
			//				if (!self.angularVelocitySceneView) {
			//					CGRect frame = CGRectMake(-80, -20, 92, 92);
			//					SCNView *sceneView = [[SCNView alloc] initWithFrame:frame];
			//					sceneView.scene = [SCNScene sceneNamed:@"arrow"];
			//					sceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
			//					sceneView.allowsCameraControl = YES;
			//					sceneView.autoenablesDefaultLighting = YES;
			//					self.angularVelocitySceneView = sceneView;
			//				}
			if (!self.angularVelocityDetailLabel) {
				UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(271, 1, 380, 94)];
				detailLabel.numberOfLines = 3;
				detailLabel.font = [UIFont systemFontOfSize:20];
				[cell.contentView addSubview:detailLabel];
				self.angularVelocityDetailLabel = detailLabel;
			}
			//cell.accessoryView = self.angularVelocitySceneView;
			break; }
			
		case PLTSensorTableRowMagnetism: {
			cell.textLabel.text = @"magnetism";
			cell.detailTextLabel.hidden = YES;
			//				if (!self.magnetismSceneView) {
			//					CGRect frame = CGRectMake(-80, -20, 92, 92);
			//					SCNView *sceneView = [[SCNView alloc] initWithFrame:frame];
			//					sceneView.scene = [SCNScene sceneNamed:@"arrow"];
			//					sceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
			//					sceneView.allowsCameraControl = YES;
			//					sceneView.autoenablesDefaultLighting = YES;
			//					self.magnetismSceneView = sceneView;
			//				}
			if (!self.magnetismDetailLabel) {
				UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(271, 1, 380, 94)];
				detailLabel.numberOfLines = 3;
				detailLabel.font = [UIFont systemFontOfSize:20];
				[cell.contentView addSubview:detailLabel];
				self.magnetismDetailLabel = detailLabel;
			}
			//cell.accessoryView = self.magnetismSceneView;
			break; }
			
		case PLTSensorTableRowMagCal: {
			cell.textLabel.text = @"magnetometer";
			PLTMagnetometerCalibrationInfo	*magCalInfo = (PLTMagnetometerCalibrationInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceMagnetometerCalibrationStatus error:nil];
			NSString *magCalStr = nil;
			//UIColor *color = [UIColor blackColor];
			if (magCalInfo.isCalibrated) {
				magCalStr = @"Calibrated";
				//color = [UIColor colorWithRed:0 green:(150.0/256.0) blue:0 alpha:1.0];
			}
			else {
				magCalStr = @"Not Calibrated";
				//color = [UIColor redColor];
			}
			cell.detailTextLabel.text = magCalStr;
			//cell.detailTextLabel.textColor = color;
			break; }
			
		case PLTSensorTableRowGyroCal: {
			cell.textLabel.text = @"gyroscope";
			PLTGyroscopeCalibrationInfo	*gyroCalInfo = (PLTGyroscopeCalibrationInfo *)[CONNECTED_DEVICE cachedInfoForService:PLTServiceGyroscopeCalibrationStatus error:nil];
			NSString *gyroCalStr = nil;
			//UIColor *color = [UIColor blackColor];
			if (gyroCalInfo.isCalibrated) {
				gyroCalStr = @"Calibrated";
				//color = [UIColor colorWithRed:0 green:(150.0/256.0) blue:0 alpha:1.0];
			}
			else {
				gyroCalStr = @"Not Calibrated";
				//color = [UIColor redColor];
			}
			cell.detailTextLabel.text = gyroCalStr;
			//cell.detailTextLabel.textColor = color;
			break; }
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (IPAD) {
		switch (indexPath.row) {
			case PLTSensorTableRowOrientation:
			case PLTSensorTableRowAcceleration:
			case PLTSensorTableRowAngularVelocity:
			case PLTSensorTableRowMagnetism:
				return 96;
		}
		return 56;
	}
	else {

	}
	return 44;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case PLTSensorTableRowPedometer:
        //case PLTSensorTableRowTemperature:
            return YES;
            break;
        default:
            break;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
		case PLTSensorTableRowOrientation:
			[self calOrientation];
			break;
        case PLTSensorTableRowPedometer:
            [self resetPed:tableView];
            break;
//        case PLTSensorTableRowTemperature:
//            [self configTemp:tableView];
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTQuaternion quaternion = ((PLTOrientationTrackingInfo *)theInfo).quaternion;
		SCNNode *arrow = self.orientationSceneView.scene.rootNode;
		arrow.orientation = SCNVector4Make(quaternion.x, quaternion.z, quaternion.y , -quaternion.w);
		
		PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
		self.orientationDetailLabel.text = [NSString stringWithFormat:@"Heading: % 4.0f°\nPitch: % 4.0f°\nRoll: % 4.0f°",
											eulerAngles.x, eulerAngles.y, eulerAngles.z];
	}
	else if ([theInfo isKindOfClass:[PLTHeadingInfo class]]) {
		PLTHeading heading = ((PLTHeadingInfo *)theInfo).heading;
		
//		NSString *label = @"";
//		if (heading>=0 && heading<22.5) {
//			label = @"NNE";
//		}
//		else if (heading>=0 && heading<30) {
//			label = @"NE";
//		}
//		else if (heading>=30 && heading<60) {
//			label = @"ENE";
//		}
//		else if (heading>=60 && heading<90) {
//			label = @"ESE";
//		}
//		else if (heading>=90 && heading<120) {
//			label = @"";
//		}
//		else if (heading>=120 && heading<150) {
//			label = @"";
//		}
//		else if (heading>=150 && heading<180) {
//			label = @"";
//		}
//		else if (heading>=210 && heading<240) {
//			label = @"";
//		}
//		else if (heading>=240 && heading<270) {
//			label = @"";
//		}
//		else if (heading>=270 && heading<300) {
//			label = @"";
//		}
//		else if (heading>=300 && heading<330) {
//			label = @"";
//		}
//		else if (heading>=330 && heading<=360) {
//			label = @"";
//		}
		
		self.headingDetailLabel.text = [NSString stringWithFormat:@"% 3.0f°", heading];
	}
	else if ([theInfo isKindOfClass:[PLTAccelerationInfo class]]) {
		PLTAcceleration acceleration = ((PLTAccelerationInfo *)theInfo).acceleration;
		self.accelerationDetailLabel.text = [NSString stringWithFormat:@"X: % 4.1f g\nY: % 4.1f g\nZ: % 4.1f g",
											 acceleration.x, acceleration.y, acceleration.z];
		
//		SCNNode *arrow = self.accelerationSceneView.scene.rootNode;
//		arrow.eulerAngles = SCNVector3Make(acceleration.x * 90, acceleration.y, acceleration.z);
	}
	else if ([theInfo isKindOfClass:[PLTAngularVelocityInfo class]]) {
		PLTAngularVelocity angularVelocity = ((PLTAngularVelocityInfo *)theInfo).angularVelocity;
		self.angularVelocityDetailLabel.text = [NSString stringWithFormat:@"X: % 4.0f deg/sec\nY: % 4.0f deg/sec\nZ: % 4.0f deg/sec",
											 angularVelocity.x, angularVelocity.y, angularVelocity.z];
		
//		SCNNode *arrow = self.angularVelocitySceneView.scene.rootNode;
//		arrow.eulerAngles = SCNVector3Make(angularVelocity.x, angularVelocity.y, angularVelocity.z);
	}
	else if ([theInfo isKindOfClass:[PLTMagnetismInfo class]]) {
		PLTMagnetism magnetism = ((PLTMagnetismInfo *)theInfo).magnetism;
		self.magnetismDetailLabel.text = [NSString stringWithFormat:@"X: % 5.0f µT\nY: % 5.0f µT\nZ: % 5.0f µT",
											 magnetism.x, magnetism.y, magnetism.z];
		
//		SCNNode *arrow = self.magnetismSceneView.scene.rootNode;
//		arrow.eulerAngles = SCNVector3Make(magnetism.x, magnetism.y, magnetism.z);
	}
	else {
		[self.tableView reloadData];
	}
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self = [super initWithNibName:@"SensorsViewController_iPhone" bundle:nibBundleOrNil];
    else
        self = [super initWithNibName:@"SensorsViewController_iPad" bundle:nibBundleOrNil];
    
    self.tabBarItem.title = @"Sensors";
    self.tabBarItem.image = [UIImage imageNamed:@"sensors_tab_icon.png"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationController.navigationBarHidden = NO;
	
	UIImage *pltImage = [UIImage imageNamed:@"pltlabs_nav_banner.png"];
	CGRect navFrame = self.navigationController.navigationBar.frame;
	CGRect pltFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
								 (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
								 pltImage.size.width + 2,
								 pltImage.size.height + 2);
	
	UIImageView *view = [[UIImageView alloc] initWithFrame:pltFrame];
	view.contentMode = UIViewContentModeCenter;
	view.image = pltImage;
	self.navigationItem.titleView = view;
	
	UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_nav_icon.png"]
																   style:UIBarButtonItemStylePlain
																  target:[UIApplication sharedApplication].delegate
																  action:@selector(settingsButton:)];
	self.navigationItem.rightBarButtonItem = actionItem;
    
    [self resetPed:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

	[self subscribeToServices];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceDidOpenConnectionNotification:) name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc addObserver:self selector:@selector(deviceWillSendDataNotification:) name:PLTDeviceWillSendDataNotification object:nil];
	[nc addObserver:self selector:@selector(deviceDidReceiveDataNotification:) name:PLTDeviceDidReceiveDataNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
	[self unsubscribeFromServices];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:PLTDeviceDidOpenConnectionNotification object:nil];
	[nc removeObserver:self name:PLTDeviceWillSendDataNotification object:nil];
	[nc removeObserver:self name:PLTDeviceDidReceiveDataNotification object:nil];
}

@end


#pragma mark - ExtendedLabelWidthTableViewCell

@implementation ExtendedLabelWidthTableViewCell

- (void)layoutSubviews
{
	[super layoutSubviews]; // lays out the cell as UITableViewCellStyleValue2 would normally look like

	CGRect frame = self.textLabel.frame;
	frame.size.width += 128;
	self.textLabel.frame = frame;
    
    CGFloat xSpace = (IPAD ? 32 : 20);
	
	CGFloat x = frame.origin.x + frame.size.width + xSpace;
	frame = CGRectMake(x, 17, 256, 22);
	self.detailTextLabel.frame = frame;
}

@end

