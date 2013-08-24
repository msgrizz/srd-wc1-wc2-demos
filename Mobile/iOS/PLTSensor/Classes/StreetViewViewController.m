//
//  StreetViewViewController.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/21/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "StreetViewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PLTContextServer.h"
#import "NSData+Base64.h"
#import "UIDevice+ScreenSize.h"
#import "NSURLRequest+GETParams.h"
#import "LocationMonitor.h"
#import "AppDelegate.h"
#import "PLTHeadsetManager.h"
#import "CC3Foundation.h"
#import "StatusWatcher.h"
#import "HeadsetManager.h"
#import "SettingsViewController.h"


#define RENDER_RATE						30.0 // Hz
#define API_KEY							@"AIzaSyDbFPnLMLK5S5nwl9L6gD6gyNi3XhVmkr4"
#define DEVICE_IPAD						([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define FRAME_SIZE						(DEVICE_IPAD ? CGSizeMake(540, 640) : ( [UIDevice hasFourInchDisplay] ? CGSizeMake(450, 640) : CGSizeMake(558, 640) ) )
#define FRAME_FOV						90.0
#define FRAME_CACHE_PATH				[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"streetViewFrameCache.plist"]
#define MAX_LOADING_FRAMES_LIVE			3
#define MAX_LOADING_FRAMES_PRECACHE		20
#define BASE_PRECACHE_PITCH				-50
#define PRECACHE_REQUEST_RATE			100000000 // Hz
#define PRECACHE_TIMEOUT				.25
//#define FORCE_RELOAD_FOR_PRECACHE // define to force already loaded frames to be re-fetched during precache
#define FPS_UPDATE_RATE					2.0 // Hz
#define MSG_RECV_AVG_ROLLOVER			3.0
#define FPS_AVG_ROLLOVER				3.0




NSInteger roundToNearestMultiple(NSInteger input, NSInteger round_multiple) {
    NSInteger multiple = input / round_multiple;
    NSInteger remainder = input % round_multiple;
    
    if ((abs(input) > round_multiple) && (multiple == 0)) return input;
    
    if (fabsf((float)remainder) >= ((float)round_multiple/2.0)) {
        return (input>0 ?
                round_multiple * (multiple+1) :
                round_multiple * (multiple-1));
    }
    else {
        return round_multiple * multiple;
    }
    return input;
}


@interface StreetViewViewController () <PLTContextServerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>

- (void)renderNextFrame;
- (void)displayFrame:(UIImage *)frameImage;
//- (UIImage *)cachedFrameForURL:(NSURL *)url;
- (UIImage *)cachedFrameForLocation:(CLLocationCoordinate2D)location angle:(Vec2)angle;
- (void)saveFrameToCache:(NSDictionary *)frameDict;
- (void)loadFrameCacheFromDisk;
- (void)saveFrameCacheToDisk;
- (NSMutableArray *)newFrameCacheLine;
- (void)logMsgRecvTime;
- (void)logFrameTime;
- (void)rateUpdateTimer:(NSTimer *)theTimer;
- (void)renderTimer:(NSTimer *)theTimer;
- (BOOL)loadFrameForURL:(NSURL *)url;
- (void)startRendering;
- (void)stopRendering;
- (void)didFinishLoadingFrame:(NSDictionary *)frameObject;
- (void)didUpdateLocationNotification:(NSNotification *)note;
- (void)_precache;
- (void)updatePrecacheStatusView;
- (void)flushCache;
- (void)checkPrecachingDone;
- (void)stopPrecaching;
- (void)didFinishPrecachingLoadingRequests;
- (void)didFinishPrecaching;
- (void)headsetDidConnectNotification:(NSNotification *)note;
- (void)headsetInfoDidUpdateNotification:(NSNotification *)note;
- (NSDictionary *)currentOverrideLocation;
- (void)checkAskPrecache;
- (void)settingsPopoverDidDisappearNotification:(NSNotification *)note;

@property(nonatomic,strong) PLTContextServerMessage     *latestMessage;
@property(atomic,strong)    NSMutableDictionary         *frameCache;
@property(nonatomic,assign) NSInteger                   loadedCacheNum;
@property(nonatomic,strong) NSTimer                     *rateUpdateTimer;
@property(nonatomic,strong) NSMutableArray              *msgRecvHistory;
@property(nonatomic,strong) NSMutableArray              *frameHistory;
@property(nonatomic,strong) NSTimer                     *renderTimer;
@property(nonatomic,strong) NSMutableDictionary         *loadingFrames;
@property(nonatomic,assign) BOOL                        precaching;
@property(nonatomic,assign) NSInteger                   precachePitch;
@property(nonatomic,assign) NSInteger                   precacheHeading;
@property(nonatomic,assign) NSInteger                   totalPrecacheFrames;
@property(nonatomic,assign) NSInteger                   finishedPrecacheFrames;
//@property(nonatomic,assign) NSUInteger                  roundingMultiple;
@property(nonatomic,assign) NSUInteger                  totalPrecacheNewFrames;
@property(nonatomic,assign) NSUInteger                  totalPrecacheSize;
@property(nonatomic,assign) BOOL                        didFinishPrecachingRequests;
//@property(nonatomic,strong)	NSLock						*cacheLock;
@property(nonatomic,strong) NSDictionary				*latestHeadsetInfo;
@property(nonatomic,assign) BOOL                        didCheckAskPrecache;
@property(nonatomic,strong) NSString					*latestOverrideLocation;

@end


@implementation StreetViewViewController

#pragma mark - Public

- (void)precache
{
	NSUInteger roundingMultiple = [DEFAULTS integerForKey:PLTDefaultsKeyStreetViewRoundingMultiple];
	
	NSLog(@"Beginning precache with rounding multiple %d",roundingMultiple);
	
    [self stopRendering];
    
    self.precaching = YES;
    self.precachePitch = BASE_PRECACHE_PITCH;
    self.precacheHeading = -180;
    self.totalPrecacheNewFrames = 0;
    self.totalPrecacheSize = 0;
    self.finishedPrecacheFrames = 0;
    self.didFinishPrecachingRequests = NO;
	self.precachingProgressBar.progress = 0;
	[self displayFrame:nil];
	
	// assumes a symmetric pitch and heading across 0
    NSInteger totalPitchFrames = 0;
    totalPitchFrames = abs(self.precachePitch) / roundingMultiple;
    if (self.precachePitch < 0) totalPitchFrames *= 2;
    totalPitchFrames += 1;
    NSInteger totalHeadingFrames = abs(self.precacheHeading) / roundingMultiple;
    if (self.precacheHeading < 0) totalHeadingFrames *= 2;
    totalHeadingFrames += 1;
    self.totalPrecacheFrames = totalPitchFrames * totalHeadingFrames;
    
	self.precachingLabel.text = @"Precaching...";
	self.precachingLabel.hidden = NO;
	self.precachingProgressBar.hidden = NO;
    self.messageRateLabel.hidden = YES;
	self.frameRateLabel.hidden = YES;
    
    [self _precache];
}

#pragma mark - Private

- (void)renderNextFrame
{
	//	NSLog(@"renderNextFrame");
	//if ( (HEADSET_CONNECTED && self.latestHeadsetInfo) || self.latestMessage) {
		CLLocationDegrees lat;
		CLLocationDegrees lng;
		NSInteger heading;
		NSInteger pitch;
		NSData *rotationVectorData = nil;
		
		if (HEADSET_CONNECTED && self.latestHeadsetInfo) {
			lat = [LocationMonitor sharedMonitor].location.coordinate.latitude;
			lng = [LocationMonitor sharedMonitor].location.coordinate.longitude;
			rotationVectorData = self.latestHeadsetInfo[PLTHeadsetInfoKeyRotationVectorData];
		}
		else if ([self.latestMessage.type isEqualToString:MESSAGE_TYPE_EVENT]) {
			lat = self.latestMessage.location.coordinate.latitude;
			lng = self.latestMessage.location.coordinate.longitude;
			NSDictionary *info = [[PLTHeadsetManager sharedManager] infoFromPacketData:[self.latestMessage.payload[@"quaternion"] base64DecodedData]];
			if (!info) return;
			rotationVectorData = info[PLTHeadsetInfoKeyRotationVectorData];
		}
//		else if (HEADSET_CONNECTED) {
//			lat = [LocationMonitor sharedMonitor].location.coordinate.latitude;
//			lng = [LocationMonitor sharedMonitor].location.coordinate.longitude;
//			Vec3 vec = {0,0,0};
//			rotationVectorData = [NSData dataWithBytes:&vec length:sizeof(Vec3)];
//		}
		else {
			return;
		}
	
	NSString *overrideLocation = [DEFAULTS objectForKey:PLTDefaultsKeyOverrideSelectedLocation];
	if (![overrideLocation isEqualToString:self.latestOverrideLocation]) {
		self.geolocationLabel.text = @"";
	}
	self.latestOverrideLocation = overrideLocation;
		
		NSUInteger roundingMultiple = [DEFAULTS integerForKey:PLTDefaultsKeyStreetViewRoundingMultiple];
		Vec3 rotationVector;
		[rotationVectorData getBytes:&rotationVector length:[rotationVectorData length]];
		heading = roundToNearestMultiple(rotationVector.x, roundingMultiple);
		pitch = roundToNearestMultiple(rotationVector.y, roundingMultiple);
		//NSLog(@"heading: %d, pitch: %d",heading, pitch);
	
		// see https://developers.google.com/maps/documentation/streetview/
		NSString *urlString = [NSString stringWithFormat:
							   @"http://maps.googleapis.com/maps/api/streetview?size=%dx%d&location=%f,%%20%f&fov=%.1f&heading=%d&pitch=%d&sensor=false&key=%@",
							   (int)FRAME_SIZE.width, (int)FRAME_SIZE.height, lat, lng, FRAME_FOV, heading, pitch, API_KEY];
		//NSLog(@"urlString: %@",urlString);
		NSURL *requestURL = [NSURL URLWithString:urlString];
		
		//UIImage *frameImage = [self cachedFrameForURL:requestURL];
	CLLocationCoordinate2D loc = { lat, lng };
	Vec2 angle = { heading, pitch };
		UIImage *frameImage = [self cachedFrameForLocation:loc angle:angle];
		if (frameImage) {
			[self displayFrame:frameImage];
		}
		else {
			if ([self loadFrameForURL:requestURL] ) {
				NSLog(@"(%d parallel connections.)",[self.loadingFrames count]);
			}
			else {
				NSLog(@"Skipping frame (%d, %d).",heading,pitch);
			}
		}
	//}
}

- (void)startRendering
{
	[self stopRendering];
    self.renderTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/RENDER_RATE) target:self selector:@selector(renderTimer:) userInfo:nil repeats:YES];
}

- (void)stopRendering
{
    if ([self.renderTimer isValid]) {
        [self.renderTimer invalidate];
        self.renderTimer = nil;
    }
}

- (void)renderTimer:(NSTimer *)theTimer
{
    [self renderNextFrame];
}

- (BOOL)loadFrameForURL:(NSURL *)url
{
	NSString *urlString = [url absoluteString];

    
	if ([self.loadingFrames count] < (self.precaching ? MAX_LOADING_FRAMES_PRECACHE : MAX_LOADING_FRAMES_LIVE)) {
		
		NSArray *keys = [self.loadingFrames allKeys];
		__block BOOL found = NO;
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		dispatch_apply([keys count], queue, ^(size_t i) {
			if (!found) {
				NSDictionary *dict = self.loadingFrames[keys[i]];
				NSString *urlStr = dict[@"url"];
				if ([urlStr isEqualToString:urlString]) {
					found = YES;
				}
			}
		});
		
//		BOOL found = NO;
//		for (NSString *key in [self.loadingFrames allKeys]) {
//			NSDictionary *dict = self.loadingFrames[key];
//			NSString *urlStr = dict[@"url"];
//			if ([urlStr isEqualToString:urlString]) {
//				found = YES;
//				break;
//			}
//		}
		
		if (!found) {
			//NSLog(@"Loading new frame: %@",url);
			
//			// since the location could change while the frame is loading, save the location at the time the load request is made
//			CLLocationDegrees lat = 0;
//			CLLocationDegrees lng = 0;
//			if (HEADSET_CONNECTED && self.latestHeadsetInfo) {
//				lat = [LocationMonitor sharedMonitor].location.coordinate.latitude;
//				lng = [LocationMonitor sharedMonitor].location.coordinate.longitude;
//			}
//			else if ([self.latestMessage.type isEqualToString:MESSAGE_TYPE_EVENT]) {
//				lat = self.latestMessage.location.coordinate.latitude;
//				lng = self.latestMessage.location.coordinate.longitude;
//			}
//			CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
			
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
			[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
			
//			NSDictionary *getParams = [request GETParams];
//			NSString *location = getParams[@"location"];
//			NSLog(@"load new\t%@",location);
			
			NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
			NSMutableDictionary *connectionObject = [@{@"url" : url.absoluteString,
													 @"connection" : connection,
													 @"data" : [NSMutableData data],
													 @"startDate" : [NSDate date]} mutableCopy];
													 //@"location" : location} mutableCopy];
			self.loadingFrames[connection.originalRequest] = connectionObject;
			
			[connection start];
		}
		else {
			//NSLog(@"Frame already loading.");
		}
	}
	else {
		//NSLog(@"Max parallel connections (%d).",(self.precaching ? MAX_LOADING_FRAMES_PRECACHE : MAX_LOADING_FRAMES_LIVE));
		return NO;
	}
    return YES;
}

- (void)displayFrame:(UIImage *)frameImage
{
	self.imageView.image = frameImage;
    [self logFrameTime];
}

- (UIImage *)cachedFrameForLocation:(CLLocationCoordinate2D)location angle:(Vec2)angle
{
	NSInteger heading = angle.x;
	NSInteger pitch = angle.y;
	NSString *locationKey = [NSString stringWithFormat:@"%f,%%20%f",location.latitude,location.longitude];
	
	//NSLog(@"lookup location: %@",locationKey);
	if ((abs(pitch) > 180) || (abs(heading) > 180)) {
		NSLog(@"Invalid angle! (%d, %d)", pitch, heading);
	}
	else {
		//Class nullClass = [NSNull class];
		NSMutableArray *hArray = self.frameCache[locationKey];
		if (hArray) {
			NSMutableArray *pArray = hArray[heading + 180];
			//if (![pArray isKindOfClass:nullClass]) {
				NSData *frameData = pArray[pitch + 180];
				//if (![frameData isKindOfClass:nullClass]) {
			if ([frameData length]) {
					return [UIImage imageWithData:frameData];
				}
			//}
		}
	}
    return nil;
}

//- (UIImage *)cachedFrameForURL:(NSURL *)url
//{
//    //[self.cacheLock lock];
//    NSString *urlString = [url absoluteString];
//    
//    NSArray *keys = [self.frameCache allKeys];
//    __block BOOL found = NO;
//    __block NSDictionary *frameDict = nil;
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_apply([keys count], queue, ^(size_t i) {
//        if (!found) {
//            NSDictionary *dict = self.frameCache[keys[i]];
//            NSString *urlStr = dict[@"url"];
//            if ([urlStr isEqualToString:urlString]) {
//                frameDict = dict;
//                found = YES;
//            }
//        }
//    });
//    
//    
////    BOOL found = NO;
////    NSDictionary *frameDict = nil;
////    for (id key in self.frameCache) {
////        NSDictionary *dict = self.frameCache[key];
////        NSString *urlStr = dict[@"url"];
////        if ([urlStr isEqualToString:urlString]) {
////            frameDict = dict;
////            found = YES;
////            break;
////        }
////    }
//    
//    if (frameDict) {
//        UIImage *image = [UIImage imageWithData:frameDict[@"data"]];
//        if (image) {
////            NSURLConnection *conn = frameDict[@"connection"];
////            NSDictionary *queryParams = [conn.originalRequest GETParams];
////            NSString *location = queryParams[@"location"];
////            NSArray *locationComponents = [location componentsSeparatedByString:@",%20"];
////            NSLog(@"--- Cache hit (location: (%@, %@), angle: (%@, %@)) ---",
////                  locationComponents[0], locationComponents[1], queryParams[@"heading"], queryParams[@"pitch"]);
//           // [self.cacheLock unlock];
//            return image;
//        }
//        else {
//            //NSLog(@"--- Cache miss. ---");
//        }
//    }
//    
//    //[self.cacheLock unlock];
//    return nil;
//}

- (void)saveFrameToCache:(NSMutableDictionary *)frameDict
{
	NSURLConnection *connection = frameDict[@"connection"];
	NSURLRequest *request = [connection originalRequest];
	NSDictionary *getParams = [request GETParams];
	NSInteger pitch = [getParams[@"pitch"] intValue];
	NSInteger heading = [getParams[@"heading"] intValue];
	NSString *location = getParams[@"location"];
	
	if ((abs(pitch) > 180) || (abs(heading) > 180)) {
		NSLog(@"Invalid angle! (%d, %d)", pitch, heading);
	}
	else {
		NSMutableArray *hArray = self.frameCache[location];
		NSMutableArray *pArray = nil;
		if (!hArray) {
			self.frameCache[location] = [self newFrameCacheLine];
			hArray = [self.frameCache objectForKey:location];
		}
		pArray = hArray[heading + 180];
		//NSLog(@"ADDING (%d %d)",pitch + 180, heading + 180);
		[pArray replaceObjectAtIndex:(pitch + 180) withObject:frameDict[@"data"]];
		
		//NSLog(@"add location: %@", location);
		self.frameCache[location] = hArray;
		
//		static int count = 0;
//		if (count < 5) {
//			NSLog(@"self.frameCache[location]: %@",self.frameCache[location]);
//			count++;
//		}
	}
	
	
//    //[self.cacheLock lock];
//    [frameDict removeObjectForKey:@"connection"];
//    [frameDict removeObjectForKey:@"error"];
//    NSString *urlStr = frameDict[@"url"];
//    self.frameCache[urlStr] = frameDict;
//    //[self.cacheLock unlock];
}

- (NSMutableArray *)newFrameCacheLine
{
	NSMutableArray *hArray = nil;
	if (!hArray) {
		
		NSMutableArray *pitchLine = nil;
		if (!pitchLine) pitchLine = [NSMutableArray arrayWithCapacity:361];
		for (NSUInteger p=0 ; p<361 ; p++) {
			[pitchLine addObject:[NSData data]];
		}
		
		hArray = [NSMutableArray arrayWithCapacity:361];
		for (NSUInteger h=0 ; h<361 ; h++) {
			[hArray addObject:[pitchLine mutableCopy]];
		}
	}
	return [hArray mutableCopy];
}

- (void)loadFrameCacheFromDisk
{
    //[self.cacheLock lock];
    NSLog(@"Loading frame cache...");
    self.frameCache = [NSMutableDictionary dictionary];
	
	NSData *data = [[NSMutableData alloc] initWithContentsOfFile:FRAME_CACHE_PATH];
	//NSDictionary *fromDisk = [NSMutableDictionary dictionaryWithContentsOfFile:FRAME_CACHE_PATH];
    if (data) {
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		NSDictionary *fromDisk = [unarchiver decodeObjectForKey:@"frameCache"];
		[unarchiver finishDecoding];
		
        [self.frameCache addEntriesFromDictionary:fromDisk];
        self.loadedCacheNum = (int)[self.frameCache count];
		
		NSUInteger size = 0;
		//Class nullClass = [NSNull class];
		NSArray *hArray = nil;
		NSArray *pArray = nil;
		for (id key in self.frameCache) {
			hArray = self.frameCache[key];
			for (NSUInteger h=0 ; h<360 ; h++) {
				pArray = hArray[h];
				//if (![hArray[h] isKindOfClass:nullClass]) {
					for (NSUInteger p=0 ; p<360 ; p++) {
						NSData *f = pArray[p];
						if ([f length]) {
							size += [f length];
						}
					}
				//}
			}
		}
		
//		NSUInteger size = 0;
//		for (id key in self.frameCache) {
//			NSDictionary *dict = self.frameCache[key];
//			NSData *frameData = dict[@"data"];
//			size += [frameData length];
//		}
        NSLog(@"%d entries (%.2f MB).",self.loadedCacheNum,(((float)size)/1024.0)/1024.0);
//        NSLog(@"Frame cache:");
//        for (NSString *key in self.frameCache) {
//            NSLog(@"%@",key);
//        }
        
        //NSLog(@"ya? %@",self.frameCache[@"http://maps.googleapis.com/maps/api/streetview?size=492x640&location=36.997169,%20-122.055382&fov=90.0&heading=75&pitch=45&sensor=false&key=AIzaSyDbFPnLMLK5S5nwl9L6gD6gyNi3XhVmkr4"]);
    }
    else {
        NSLog(@"No frame cache.");
    }
    //[self.cacheLock unlock];
}

- (void)saveFrameCacheToDisk
{
    //NSInteger numNewFrames = [self.frameCache count] - self.loadedCacheNum;
	NSInteger numNewFrames = 0;
	NSUInteger size = 0;
	//Class nullClass = [NSNull class];
	NSArray *hArray = nil;
	NSArray *pArray = nil;
	for (id key in self.frameCache) {
		hArray = self.frameCache[key];
		for (NSUInteger h=0 ; h<360 ; h++) {
			pArray = hArray[h];
			//if (![hArray[h] isKindOfClass:nullClass]) {
				for (NSUInteger p=0 ; p<360 ; p++) {
					NSData *f = pArray[p];
					//if (![f isKindOfClass:nullClass]) {
					if ([f length]) {
						size += [f length];
						numNewFrames++;
					}
				}
			//}
		}
		
		//			NSData *frameData = dict[@"data"];
		//			size += [frameData length];
	}
	
    if (numNewFrames) {
        NSLog(@"Saving %d frames (%.1f MB) to %@...", numNewFrames, (float)size / 1024.0 / 1024.0, FRAME_CACHE_PATH);
//        if (![self.frameCache writeToFile:FRAME_CACHE_PATH atomically:YES]) {
//            NSLog(@"*** Error saving frame cache. ***");
//        }
		NSMutableData *data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:self.frameCache forKey:@"frameCache"];
		[archiver finishEncoding];
		NSError *err = nil;
		[data writeToFile:FRAME_CACHE_PATH options:NSDataWritingAtomic error:&err];
		if (err) {
			NSLog(@"*** Error saving frame cache: %@ ***",err);
		}
    }
}

- (void)logMsgRecvTime
{
    [self.msgRecvHistory addObject:[NSDate date]];
}

- (void)logFrameTime
{
    [self.frameHistory addObject:[NSDate date]];
}

- (void)rateUpdateTimer:(NSTimer *)theTimer
{
    //if (self.precaching) return; // work-around for a strange crash
    
    //  maintain histories
    NSMutableArray *toRemove = [NSMutableArray array];
    NSDate *nowish = [NSDate date];
    NSTimeInterval absNowish = [nowish timeIntervalSinceReferenceDate];
    // msg recv
    for (NSDate *time in self.msgRecvHistory) {
        if ((absNowish - [time timeIntervalSinceReferenceDate]) > MSG_RECV_AVG_ROLLOVER) {
            [toRemove addObject:time];
        }
    }
    [self.msgRecvHistory removeObjectsInArray:toRemove];
    // frames
    toRemove = [NSMutableArray array];
    for (NSDate *time in self.frameHistory) {
        if ((absNowish - [time timeIntervalSinceReferenceDate]) > FPS_AVG_ROLLOVER) {
            [toRemove addObject:time];
        }
    }
    [self.frameHistory removeObjectsInArray:toRemove];
    
    // compute averages
    float msgAvg = 0;
    NSTimeInterval oldest = MAXFLOAT;
    NSTimeInterval newest = 0;
    // msg recv
	if ([self.msgRecvHistory count]) {
		for (NSDate *time in self.msgRecvHistory) {
			NSTimeInterval absTime = [time timeIntervalSinceReferenceDate];
			if (absTime < oldest) oldest = absTime;
			if (absTime > newest) newest = absTime;
		}
		msgAvg = (float)[self.msgRecvHistory count] / (newest - oldest);
	}
    
    // frames
    float fps = 0;
    oldest = MAXFLOAT;
    newest = 0;
	if ([self.frameHistory count]) {
		for (NSDate *time in self.frameHistory) {
			NSTimeInterval absTime = [time timeIntervalSinceReferenceDate];
			if (absTime < oldest) oldest = absTime;
			if (absTime > newest) newest = absTime;
		}
		fps = (float)[self.frameHistory count] / (newest - oldest);
	}
    
	if (HEADSET_CONNECTED) self.messageRateLabel.text = @"";
	else self.messageRateLabel.text = [NSString stringWithFormat:@"%.1f messages/sec",msgAvg];
    self.frameRateLabel.text = [NSString stringWithFormat:@"%.1f frames/sec",fps];
    //NSLog(@"%.2f messages/sec, %.2f frames/sec",msgAvg,fps);
}

- (void)didFinishLoadingFrame:(NSDictionary *)frameObject
{
    if (frameObject) {
        NSTimeInterval gap = [[NSDate date] timeIntervalSinceDate:frameObject[@"startDate"]]; // time since last request
        NSData *data = frameObject[@"data"];
        NSLog(@"Finished loading new frame (size: %.1f KB, time: %.2f, url: %@).", (float)[data length] / 1024.0, gap, frameObject[@"url"]);
        
        NSURLConnection *connection = frameObject[@"connection"];
        [self.loadingFrames removeObjectForKey:connection.originalRequest];
        
        [self saveFrameToCache:frameObject];
        
        if (self.precaching) {
            //[self displayFrame:[UIImage imageWithData:frameObject[@"data"]]];
            self.finishedPrecacheFrames = self.finishedPrecacheFrames + 1;
            self.totalPrecacheNewFrames = self.totalPrecacheNewFrames + 1;
            self.totalPrecacheSize = self.totalPrecacheSize + [frameObject[@"data"] length];
            [self updatePrecacheStatusView];
            [self checkPrecachingDone];
		}
    }
}

- (void)didUpdateLocationNotification:(NSNotification *)note
{
	PLTContextServer *server = [PLTContextServer sharedContextServer];
	LocationMonitor *lm = [LocationMonitor sharedMonitor];
	
	PLTContextServerMessage *latestMessage = server.latestMessage;
	if (HEADSET_CONNECTED || [latestMessage.type isEqualToString:MESSAGE_TYPE_EVENT]) {
		if (lm.placemark) {
			NSString *labelString = [NSString stringWithFormat:@"%@, %@, %@", [lm.placemark name],[lm.placemark locality],[lm.placemark administrativeArea]];
			self.geolocationLabel.text = labelString;
		}
		else {
			self.geolocationLabel.text = [NSString stringWithFormat:@"%f, %f",lm.location.coordinate.latitude,lm.location.coordinate.longitude];
		}
	}
	else {
		self.geolocationLabel.text = @"";
	}
}

- (void)_precache
{
    if (self.precaching) {
		NSUInteger roundingMultiple = [DEFAULTS integerForKey:PLTDefaultsKeyStreetViewRoundingMultiple];
        void (^advance)(int) = ^(int delay) {
            self.precacheHeading += roundingMultiple;
            if (self.precacheHeading > 180) {
                self.precacheHeading = -180;
                self.precachePitch += roundingMultiple;
                if (self.precachePitch > abs(BASE_PRECACHE_PITCH)) {
                    [self didFinishPrecachingLoadingRequests];
                    return;
                }
            }
            [self performSelector:@selector(_precache) withObject:nil afterDelay:delay];
        };
		
		CLLocationDegrees lat;
		CLLocationDegrees lng;
		if (HEADSET_CONNECTED) {
			lat = [LocationMonitor sharedMonitor].location.coordinate.latitude;
			lng = [LocationMonitor sharedMonitor].location.coordinate.longitude;
		}
		else {
			lat = self.latestMessage.location.coordinate.latitude;
			lng = self.latestMessage.location.coordinate.longitude;
		}
		
        // see https://developers.google.com/maps/documentation/streetview/
        NSString *urlString = [NSString stringWithFormat:
                               @"http://maps.googleapis.com/maps/api/streetview?size=%dx%d&location=%f,%%20%f&fov=%.1f&heading=%d&pitch=%d&sensor=false&key=%@",
                               (int)FRAME_SIZE.width, (int)FRAME_SIZE.height, lat, lng, FRAME_FOV, self.precacheHeading, self.precachePitch, API_KEY];
        //NSLog(@"urlString: %@",urlString);
        NSURL *requestURL = [NSURL URLWithString:urlString];
        
#ifdef FORCE_RELOAD_FOR_PRECACHE
		CLLocationCoordinate2D loc = { lat, lng };
		Vec2 angle = { self.precacheHeading, self.precachePitch };
		UIImage *frameImage = [self cachedFrameForLocation:loc angle:angle];
        if (frameImage) {
            //NSLog(@"Already cached.");
            //[self displayFrame:frameImage];
            self.finishedPrecacheFrames = self.finishedPrecacheFrames + 1;
            [self updatePrecacheStatusView];
            advance(1.0/PRECACHE_REQUEST_RATE);
        }
        else {
#endif
			if ([self loadFrameForURL:requestURL] ) {
				//NSLog(@"(%d parallel connections.)",[self.loadingFrames count]);
				advance(1.0/PRECACHE_REQUEST_RATE);
			}
			else {
				//NSLog(@"Skipping frame (%d, %d) for now.",self.precacheHeading,self.precachePitch);
				[self performSelector:@selector(_precache) withObject:nil afterDelay:PRECACHE_TIMEOUT];
			}
#ifdef FORCE_RELOAD_FOR_PRECACHE
        }
#endif
    }
}

- (void)updatePrecacheStatusView
{
    float percent = (float)self.finishedPrecacheFrames/(float)self.totalPrecacheFrames;
    [self.precachingProgressBar setProgress:percent];
}

- (void)flushCache
{
    NSLog(@"---------- Flushing cache ----------");
    // forces in-memory cache to be saved to disk, and the read LAZILY back in.
    [self saveFrameCacheToDisk];
    self.frameCache = nil;
    [self loadFrameCacheFromDisk];
}

- (void)checkPrecachingDone
{
    if ( self.didFinishPrecachingRequests && ![[self loadingFrames] count]) [self didFinishPrecaching];
    //if (![self.loadingFrames count]) [self didFinishPrecaching];
}

- (void)stopPrecaching
{
	if (self.precaching) {
        [self saveFrameCacheToDisk];
		self.precachingLabel.hidden = YES;
		self.precachingProgressBar.hidden = YES;
        self.messageRateLabel.hidden = NO;
		self.frameRateLabel.hidden = NO;
        NSLog(@"Precaching canceled.");
    }
}

- (void)didFinishPrecachingLoadingRequests
{
    NSLog(@"Done with precache requests.");
    
    self.didFinishPrecachingRequests = YES;
    
    if ([self.loadingFrames count]) {
        // wait for loading to finish
    }
    else {
        // we never sent out any requests, so there is nothing to wait for. we're done.
        [self didFinishPrecaching];
    }
    
//    if (self.latestPrecacheRequest) {
//        self.lastPrecacheRequest = self.latestPrecacheRequest;
//        self.latestPrecacheRequest = nil;
//        // wait for loading to finish
//    }
//    else {
//        // we never sent out any requests, so there is nothing to wait for. we're done.
//        [self didFinishPrecaching];
//    }
}

- (void)didFinishPrecaching
{
    NSLog(@"Done precaching. New frames: %d, total size: %.1f MB", self.totalPrecacheNewFrames, (((float)self.totalPrecacheSize) / 1024.0) / 1024.0);
    
	self.precachingLabel.text = @"Saving...";
	//self.precachingProgressBar.hidden = YES;
	
//	int64_t delayInSeconds = 1.0;
//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self saveFrameCacheToDisk];
		self.precaching = NO;
		
		// mark location "precached"
		NSString *selectedLabel = [DEFAULTS objectForKey:PLTDefaultsKeyOverrideSelectedLocation];
		if (![selectedLabel isEqualToString:@"__none"]) {
			NSMutableDictionary *location = nil;
			NSArray *locations = (NSArray *)[DEFAULTS objectForKey:PLTDefaultsKeyOverrideLocations];
			NSInteger index = 0;
			for (NSInteger i=0; i<[locations count]; i++) {
				NSDictionary *l = locations[i];
				NSString *label = l[PLTDefaultsKeyOverrideLocationLabel];
				if ([label isEqualToString:selectedLabel]) {
					location = [l mutableCopy];
					NSMutableArray *newLocations = [locations mutableCopy];
					NSInteger currentRoundingMultiple = [DEFAULTS integerForKey:PLTDefaultsKeyStreetViewRoundingMultiple];
					location[PLTDefaultsKeyOverrideLocationStreetViewPrecacheRoundingMultiple] = @(currentRoundingMultiple);
					[newLocations replaceObjectAtIndex:index withObject:location];
					[DEFAULTS setObject:newLocations forKey:PLTDefaultsKeyOverrideLocations];
					break;
				}
				index++;
			}
		}
		
		//[self.precachingView removeFromSuperview];
		self.precachingLabel.hidden = YES;
		self.precachingProgressBar.hidden = YES;
		self.messageRateLabel.hidden = NO;
		self.frameRateLabel.hidden = NO;
		[self startRendering];
//	});
}

- (void)headsetDidConnectNotification:(NSNotification *)note
{
	[self checkAskPrecache];
}

- (void)headsetInfoDidUpdateNotification:(NSNotification *)note
{
    //if (HEADSET_CONNECTED) {
	// when Street View was first implemented the rotation vector was calculated differently. we're going to screw with it
	NSMutableDictionary *modInfo = [note.userInfo mutableCopy];
//	NSData *rotationVectorData = modInfo[PLTHeadsetInfoKeyRotationVectorData];
//	Vec3 rotationVector;
//	[rotationVectorData getBytes:&rotationVector length:[rotationVectorData length]];
//	
//	Vec3 newRotationVector = rotationVector;
//	if ((rotationVector.y == 180) || (rotationVector.y == -180)) {
//		newRotationVector.y = 0;
//	}
//	else if (rotationVector.y > 0) {
//		newRotationVector.y = (180 - rotationVector.y);
//	}
//	else if (rotationVector.y < 0) {
//		newRotationVector.y = -(180 + rotationVector.y);
//	}
//	
//	modInfo[PLTHeadsetInfoKeyRotationVectorData] = [NSData dataWithBytes:&newRotationVector length:sizeof(Vec3)];
	self.latestHeadsetInfo = modInfo;
	//}
}

- (void)checkAskPrecache
{
	NSLog(@"checkAskPrecache");
	
	if (HEADSET_CONNECTED) {
		if (!self.precaching && !self.didCheckAskPrecache) {
			NSString *selectedLabel = [DEFAULTS objectForKey:PLTDefaultsKeyOverrideSelectedLocation];
			if (![selectedLabel isEqualToString:@"__none"]) {
				NSMutableDictionary *location = nil;
				NSArray *locations = (NSArray *)[DEFAULTS objectForKey:PLTDefaultsKeyOverrideLocations];
				//NSLog(@"class: %@",NSStringFromClass([overrideLocations class]));
				NSInteger index = 0;
				for (NSInteger i=0; i<[locations count]; i++) {
					NSDictionary *l = locations[i];
					NSString *label = l[PLTDefaultsKeyOverrideLocationLabel];
					if ([label isEqualToString:selectedLabel]) {
						location = [l mutableCopy];
						break;
					}
					index++;
				}
				NSInteger precacheRoundingMultiple = [location[PLTDefaultsKeyOverrideLocationStreetViewPrecacheRoundingMultiple] intValue];
				NSInteger currentRoundingMultiple = [DEFAULTS integerForKey:PLTDefaultsKeyStreetViewRoundingMultiple];
				if (precacheRoundingMultiple == -1) {
					if ([location[PLTDefaultsKeyOverrideLocationAskedPrecacheStreetViewRoundingMultiple] intValue] == -1) {
						NSMutableArray *newLocations = [locations mutableCopy];
						location[PLTDefaultsKeyOverrideLocationAskedPrecacheStreetViewRoundingMultiple] = @(-2);
						[newLocations replaceObjectAtIndex:index withObject:location];
						[DEFAULTS setObject:newLocations forKey:PLTDefaultsKeyOverrideLocations];
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Precached"
																		message:@"Would you like to precache this location for best performance? You can cancel precaching by tapping another tab."
																	   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
						
						[alert show];
					}
					else {
						NSLog(@"already asked");
					}
				}
				else if (precacheRoundingMultiple > currentRoundingMultiple) {
					if ([location[PLTDefaultsKeyOverrideLocationAskedPrecacheStreetViewRoundingMultiple] integerValue] != currentRoundingMultiple) {
						NSMutableArray *newLocations = [locations mutableCopy];
						location[PLTDefaultsKeyOverrideLocationAskedPrecacheStreetViewRoundingMultiple] = @(currentRoundingMultiple);
						[newLocations replaceObjectAtIndex:index withObject:location];
						[DEFAULTS setObject:newLocations forKey:PLTDefaultsKeyOverrideLocations];
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Low Precache Resolution"
																		message:@"This location was precached with a lower angular resolution than the current setting. Would you like to precache it agian?"
																	   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
						[alert show];
					}
					else {
						NSLog(@"already asked re-precache");
					}
				}
				else {
					NSLog(@"already precached");
				}
			}
		}
		else {
			NSLog(@"Currently precaching or already checekd.");
		}
		
		self.didCheckAskPrecache = YES;
	}
}

- (void)settingsPopoverDidDisappearNotification:(NSNotification *)note
{
	NSLog(@"settingsPopoverDidDisappearNotification");
	[[LocationMonitor sharedMonitor] updateLocationNow];
	// give LocationMonitor time to update. Yuck.
	double delayInSeconds = .5;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		self.didCheckAskPrecache = NO;
		[self checkAskPrecache];
	});
}

#pragma mark - PLTContextServerDelegate

- (void)server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message
{
    if (!HEADSET_CONNECTED && !self.precaching) {
        if ([message hasType:@"event"]) {
			if ([[message messageId] isEqualToString:EVENT_HEAD_TRACKING]) {
                [self logMsgRecvTime];
                self.latestMessage = message;
				
				if (!HEADSET_CONNECTED) {
					[self checkAskPrecache];
				}
				else {
//					if (!HEADSET_CONNECTED) {
//						self.geolocationLabel.text = [LocationMonitor sharedMonitor].placemark.name;
//					}
				}
            }
        }
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSInteger code = [httpResponse statusCode];
    NSMutableDictionary *frameObject = self.loadingFrames[connection.originalRequest];
    if (code==200) {
        frameObject[@"length"] = @(response.expectedContentLength);
    }
    else if (code==403){
        [connection cancel];
        NSLog(@"*** Status: %d: Bandwidth/request limit exceeded. ***",code);
        [self.loadingFrames removeObjectForKey:frameObject[@"url"]];
        if (self.precaching) {
            self.finishedPrecacheFrames = self.finishedPrecacheFrames + 1;
            [self checkPrecachingDone];
        }
    }
    else {
        NSLog(@"*** Received response %d for connection %@. ***", code, connection);
        [self.loadingFrames removeObjectForKey:frameObject[@"url"]];
        if (self.precaching) {
            self.finishedPrecacheFrames = self.finishedPrecacheFrames + 1;
            [self checkPrecachingDone];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"*** Connection failed with error: %@ ***",error);
    //[self loadNextFrame];
     NSMutableDictionary *frameObject = self.loadingFrames[connection.originalRequest];
//    frameObject[@"error"] = error;
    [self.loadingFrames removeObjectForKey:frameObject[@"url"]];
    
    if (self.precaching) {
        self.finishedPrecacheFrames = self.finishedPrecacheFrames + 1;
        [self checkPrecachingDone];
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"Got frame chunk (size: %d).",[data length]);
    //[self.frameDataAccumulator appendData:data];
    NSMutableDictionary *frameObject = self.loadingFrames[connection.originalRequest];
    NSMutableData *accumData = frameObject[@"data"];
    [accumData appendData:data];
    
    if ([accumData length] >= [frameObject[@"length"] longLongValue] ) {
        frameObject[@"endTime"] = [NSDate date];
        [self didFinishLoadingFrame:frameObject];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSTimeInterval gap = [[NSDate date] timeIntervalSinceDate:self.frameLoadStartDate]; // time since last request
//    NSLog(@"Finished loading new frame (size: %.1f KB, time: %.2f).", (float)[self.frameDataAccumulator length] / 1024.0, gap);
//    
//    UIImage *frameImage = [UIImage imageWithData:self.frameDataAccumulator];
//    [self displayFrame:frameImage];
//    
//    [self saveFrameDataToCache:self.frameDataAccumulator url:connection.originalRequest.URL];
//    
//    if (gap >= MIN_FRAME_GAP) {
//        [self loadNextFrame];
//    }
//    else {
//        NSTimeInterval wait = (MIN_FRAME_GAP - gap);
//        NSLog(@"Waiting %.2f seconds to load next frame...",wait);
//        self.loadNextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:wait target:self selector:@selector(loadNextFrameTimer:) userInfo:nil repeats:NO];
//    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// precache alert
	if (buttonIndex != [alertView cancelButtonIndex]) [self precache];
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (!DEVICE_IPAD)
		self = [super initWithNibName:@"StreetViewViewController" bundle:nibBundleOrNil];
	else
		self = [super initWithNibName:@"StreetViewViewController_iPad" bundle:nibBundleOrNil];

    self.title = @"Street View";
    self.tabBarItem.title = @"Street View";
    self.tabBarItem.image = [UIImage imageNamed:@"buildings_icon.png"];
    //self.cacheLock = [NSLock new];
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        [self loadFrameCacheFromDisk];
    //});
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup PLT nav bar image
    UIImage *pltImage = [UIImage imageNamed:@"plt_logo_nav.png"];
    CGRect navFrame = self.navBar.frame;
    CGRect viewFrame = CGRectMake((navFrame.size.width/2.0) - (pltImage.size.width/2.0) - 1,
                                  (navFrame.size.height/2.0) - (pltImage.size.height/2.0) - 1,
                                  pltImage.size.width + 2,
                                  pltImage.size.height + 2);
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:viewFrame];
    view.contentMode = UIViewContentModeCenter;
    view.image = pltImage;
    [self.navBar addSubview:view];
	
    // setup Settings cog nav button
    UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cogBarButton.png"]
																   style:UIBarButtonItemStyleBordered
                                                                  target:[UIApplication sharedApplication].delegate
                                                                  action:@selector(settingsButton:)];
	((UINavigationItem *)self.navBar.items[0]).rightBarButtonItem = actionItem;
    
    // setup precaching status view
//    self.precachingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
//    self.precachingView.layer.masksToBounds = YES;
//    self.precachingView.layer.cornerRadius = 20.0;
//    self.precachingProgressBar.progress = 0;
//    CGPoint superCenter = CGPointMake([self.view bounds].size.width / 2.0, [self.view bounds].size.height / 2.0);
//    [self.precachingView setCenter:superCenter];
	
	self.precachingLabel.hidden = YES;
	self.precachingProgressBar.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[[StatusWatcher sharedWatcher] setActiveNavigationBar:self.navBar animated:NO];
    
    self.latestMessage = nil;
    [[PLTContextServer sharedContextServer] addDelegate:self];
    self.loadingFrames = [NSMutableDictionary dictionary];
    
    self.msgRecvHistory = [NSMutableArray array];
    self.frameHistory = [NSMutableArray array];
    self.rateUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/FPS_UPDATE_RATE)
                                                           target:self selector:@selector(rateUpdateTimer:) userInfo:nil repeats:YES];
    
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(headsetDidConnectNotification:) name:PLTHeadsetDidConnectNotification object:nil];
    [nc addObserver:self selector:@selector(headsetInfoDidUpdateNotification:) name:PLTHeadsetInfoDidUpdateNotification object:nil];
	[nc addObserverForName:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]
					 queue:nil usingBlock:^(NSNotification *note) {
						 [self saveFrameCacheToDisk];
					 }];
	[nc addObserver:self selector:@selector(settingsPopoverDidDisappearNotification:) name:PLTSettingsPopoverDidDismissNotification object:nil];
    
    if ([DEFAULTS boolForKey:PLTDefaultsKeyStreetViewInfoOverlay]) {
        self.geolocationLabel.hidden = NO;
		self.geolocationLabel.text = @"";
        //self.geolocationLabel.text = [LocationMonitor sharedMonitor].placemark.name;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocationNotification:) name:LocationMonitorDidUpdateNotification object:nil];
    }
    else {
        self.geolocationLabel.hidden = YES;
    }
    
    if ([DEFAULTS boolForKey:PLTDefaultsKeyStreetViewDebugOverlay]) {
        self.frameRateLabel.hidden = NO;
        self.messageRateLabel.hidden = NO;
    }
    else {
        self.frameRateLabel.hidden = YES;
        self.messageRateLabel.hidden = YES;
    }
	
    if (!self.precaching) {
        [self startRendering];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//if (HEADSET_CONNECTED) {
		[self checkAskPrecache];
	//}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.didCheckAskPrecache = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLTSettingsPopoverDidDismissNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	
	if ([self.rateUpdateTimer isValid]) {
		[self.rateUpdateTimer invalidate];
		self.rateUpdateTimer = nil;
	}
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:LocationMonitorDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PLTHeadsetInfoDidUpdateNotification object:nil];
    
    [self stopRendering];
    [[PLTContextServer sharedContextServer] removeDelegate:self];
    
	[self stopPrecaching];
    
    self.precaching = NO;
    
//    for (NSString *key in self.loadingFrames) {
//        NSDictionary *frameObject = self.loadingFrames[key];
//        NSURLConnection *connection = frameObject[@"connection"];
//        [connection cancel];
//    }
}

@end
