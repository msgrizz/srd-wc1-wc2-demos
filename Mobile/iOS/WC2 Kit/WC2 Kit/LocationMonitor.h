//
//  LocationMonitor.h
//
//  Created by Morgan Davis on 3/26/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


extern NSString *const LocationMonitorDidUpdateNotification;


@protocol LocationMonitorDelegate;


@interface LocationMonitor : NSObject

@property(nonatomic,assign) id <LocationMonitorDelegate>    delegate;
@property(nonatomic,retain) CLLocation                      *location;
@property(nonatomic,retain) CLLocation                      *realLocation;
@property(nonatomic,retain) NSString                        *fullAddress;
@property(nonatomic,retain) NSString                        *realFullAddress;
@property(nonatomic,assign) CLLocationDirection             heading;
@property(nonatomic,retain) CLPlacemark                     *placemark;
@property(nonatomic,retain) CLPlacemark                     *realPlacemark;
@property(nonatomic,assign) CLLocationAccuracy              designedAccuracy;

+ (LocationMonitor *)sharedMonitor;

// Public

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)updateLocationNow;

@end


@protocol LocationMonitorDelegate <NSObject>

- (CLLocation *)locationMonitor:(LocationMonitor *)monitor overrideAtLocation:(CLLocation *)realLocation;

@end

