//
//  LocationMonitor.m
//
//  Created by Morgan Davis on 3/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "LocationMonitor.h"
#import <objc/message.h>

NSString *const LocationMonitorDidUpdateNotification =      @"LocationMonitorDidUpdateNotification";


@interface LocationMonitor () <CLLocationManagerDelegate>

- (void)updateFullAddress;

@property(nonatomic,retain) CLLocationManager   *locationManager;

@end


@implementation LocationMonitor

@dynamic designedAccuracy;

- (CLLocationAccuracy)designedAccuracy
{
    return self.locationManager.desiredAccuracy;
}

- (void)setDesignedAccuracy:(CLLocationAccuracy)designedAccuracy
{
    self.locationManager.desiredAccuracy = designedAccuracy;
}

#pragma mark -
#pragma mark Public

+ (LocationMonitor *)sharedMonitor
{
	static LocationMonitor *monitor = nil;
	if( !monitor ) monitor = [[LocationMonitor alloc] init];
	return monitor;
}

- (void)startUpdatingLocation
{
	[self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
	[self.locationManager stopUpdatingLocation];
}

- (void)updateLocationNow
{
	[self stopUpdatingLocation];
	[self startUpdatingLocation];
#warning Added 14/09/12 by Morgan
	//[self locationManager:self.locationManager didUpdateToLocation:self.realLocation fromLocation:nil];
	[self locationManager:self.locationManager didUpdateLocations:@[self.realLocation]];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	NSLog(@"locationManager:didChangeAuthorizationStatus: %d", status);
	
	switch (status) {
		case kCLAuthorizationStatusNotDetermined:
			NSLog(@"kCLAuthorizationStatusNotDetermined");
			break;
		case kCLAuthorizationStatusRestricted:
			NSLog(@"kCLAuthorizationStatusRestricted");
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
			break;
//		case kCLAuthorizationStatusAuthorized:
//			NSLog(@"kCLAuthorizationStatusAuthorized");
//			break;
		case kCLAuthorizationStatusAuthorizedAlways:
			NSLog(@"kCLAuthorizationStatusAuthorizedAlways");
			break;
		case kCLAuthorizationStatusAuthorizedWhenInUse:
			NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse");
			break;
  default:
			break;
	}
}

#warning 14/12/03 Morgan: DEPRECATED. Doesn't appear to be called anymore in iOS 8. Replaced with locationManager:didUpdateLocations: below.
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//	//AOLogL(AODebugLogLevel,@"newLocation: %@",newLocation);
//    
//    self.realLocation = newLocation;
//    self.location = [self.delegate locationMonitor:self overrideAtLocation:newLocation];
//    if (!self.location ) {
//		self.location = newLocation;
//	}
//
//	[self updateFullAddress];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:LocationMonitorDidUpdateNotification object:nil];
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	// looks like this holds a history of locations, and the most recent location is always last
	
	NSLog(@"locationManager:didUpdateLocations: %@", locations);
	
	CLLocation *newLocation = [locations lastObject];
	
	self.realLocation = newLocation;
	self.location = [self.delegate locationMonitor:self overrideAtLocation:newLocation];
	if (!self.location ) {
		self.location = newLocation;
	}
	
	[self updateFullAddress];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:LocationMonitorDidUpdateNotification object:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"*** locationManager:didFailWithError: %@ ***", error);
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
	NSLog(@"*** didFinishDeferredUpdatesWithError: %@ ***", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy < 0) return;
    
    // Use the true heading if it is valid.
    CLLocationDirection theHeading = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading);
    self.heading = theHeading;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LocationMonitorDidUpdateNotification object:nil];
}

#pragma mark -
#pragma mark NSObject

- (id)init
{
	if (self = [super init]) {
		self.locationManager = [[CLLocationManager alloc] init];
//		if (!self.locationManager.locationServicesEnabled) {
//			NSLog(@"*** Location Services not enabled!!! ***");
//		}
		//if (OS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
			[self.locationManager requestWhenInUseAuthorization];
		//}
		self.locationManager.activityType = CLActivityTypeOther;
		//self.locationManager.distanceFilter = 0;
		self.locationManager.pausesLocationUpdatesAutomatically = NO;
        self.locationManager.delegate = self;
        self.designedAccuracy = kCLLocationAccuracyBest;
	}
	return self;
}

- (void)updateFullAddress
{
    NSArray *locations = @[self.location, self.realLocation];
	
//	objc_setAssociatedObject(self.location, @"real", @YES, OBJC_ASSOCIATION_RETAIN);
//	objc_setAssociatedObject(self.realLocation, @"real", @NO, OBJC_ASSOCIATION_RETAIN);
//	
//	NSLog(@"real: %p",self.location);
//	NSLog(@"fake: %p",self.realLocation);
	
    for( CLLocation *location in locations) {
        CLGeocoder *reverseGeo = [[CLGeocoder alloc] init];
        [reverseGeo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
			if (error) {
				//NSLog(@"*** reverseGeocodeLocation error: %@ ***",error);
			}
			else {
				CLPlacemark *placemark = placemarks[0];
				//for (CLPlacemark *placemark in placemarks) {
				
				//			NSLog(@"loc: %p",location);
				//			NSLog(@"Real? %@",objc_getAssociatedObject(location, @"real"));
				
				NSString *fullAddressString = [NSString stringWithFormat:@"%@, %@, %@, %@ %@",
											   [placemark name],[placemark locality],[placemark administrativeArea],[placemark country],[placemark postalCode]];
				
				//NSLog(@"Full address: %@",fullAddressString);
				
				//                NSLog(@"[placemark name]: %@",[placemark name]);
				//                NSLog(@"[placemark locality]: %@",[placemark locality]);
				//                NSLog(@"[placemark administrativeArea]: %@",[placemark administrativeArea]);
				//                NSLog(@"[placemark country]: %@",[placemark country]);
				//                NSLog(@"[placemark postalCode]: %@",[placemark postalCode]);
				
				//if ([placemark.location isEqual:locations[1]]) { // "real" location
				// crappy way to tell if this is the reverse-geolocation for the real location or fake location
				// (considered real if <= 5m from realLocation before reverse-geolocation)
				//if ([placemark.location distanceFromLocation:locations[1]] <= 100.0) {
				if (location == self.realLocation) {
					//NSLog(@"Real address: %@",fullAddressString);
					self.realPlacemark = placemark;
					self.realFullAddress = fullAddressString;
					if (locations[0] == locations[1]) {
						self.placemark = placemark;
						self.fullAddress = fullAddressString;
					}
				}
				else {
					//NSLog(@"\"Fake\" address: %@",fullAddressString);
					self.placemark = placemark;
					self.fullAddress = fullAddressString;
				}
				
                [[NSNotificationCenter defaultCenter] postNotificationName:LocationMonitorDidUpdateNotification object:nil];
				//}
			}
        }];
		
//		if (locations[0] == locations[1]) {
//			NSLog(@"No fake location.");
//		}
    }
}

@end
