//
//  Global.h
//  WC2 Kit
//
//  Created by Morgan Davis on 12/30/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//


#define OS_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define OS_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define OS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define OS_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define OS_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IPAD                                    ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IPHONE5									(([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && [UIDevice hasFourInchDisplay])

#define D2R(a)									((a) / 180.0 * M_PI)
#define R2D(a)									((a) * 180.0 / M_PI)

//#define SECURITY_FIDO_ADDRESS					@"http://10.1.47.196:8080"
//#define SECURITY_FIDO_ADDRESS					@"http://10.0.1.33:8080" // Media booth
//#define SECURITY_FIDO_ADDRESS					@"http://172.20.10.9:8080" // Cary NXP
//#define SECURITY_FIDO_ADDRESS					@"http://10.50.8.2:8080" // CES
//#define SECURITY_FIDO_ADDRESS					@"http://10.1.47.230:8080" // SCZ Dell #1
#define SECURITY_FIDO_ADDRESS					@"http://10.0.1.100:8080" // temp
#define SECURITY_FIDO_PASSWORD					@"1234"
#define MIN_PERIODIC_SUBSCRIPTION_PERIOD		100
