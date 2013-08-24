//
//  PLTContextServerMessage.h
//
//  Created by Antony Bayley on 15/06/2012.
//  Copyright (c) 2012 Plantronics Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
// #import "PLTMeetingRoom.h"
// #import "PLTPerson.h"

// enable or disable debug log messages for this module only
#define DEBUG_PRINT_ENABLED_CSM

#ifdef DEBUG_PRINT_ENABLED_CSM
#define debugLog_CSM(...) debugLog(__VA_ARGS__)
#define debugPrintf_CSM(...) printf(__VA_ARGS__)
#else
#define debugLog_CSM(...) do {} while (0)     // optimized out by the compiler
#define debugPrintf_CSM(...) do {} while (0)  // optimized out by the compiler
#endif


// message type
NSString *const MESSAGE_TYPE_AUTHENTICATE;
NSString *const MESSAGE_TYPE_REGISTER_DEVICE;
NSString *const MESSAGE_TYPE_EVENT;
NSString *const MESSAGE_TYPE_COMMAND;
NSString *const MESSAGE_TYPE_EXCEPTION;
NSString *const MESSAGE_TYPE_SETTING;

// authenticate message ID
NSString *const COULD_NOT_LOCATE_DEVICE_RECORD;
NSString *const AUTHENTICATE_FAILED;
NSString *const AUTHENTICATE_USERNAME_PASSWORD;
NSString *const AUTHENTICATE_SUCCESS;
NSString *const AUTHENTICATE_X509_CERTIFICATE;
NSString *const AUTHENTICATE_REQUIRED;

// register message ID
NSString *const REGISTER_DEVICE;
NSString *const UNREGISTER_DEVICE;
NSString *const GET_REGISTERED_DEVICES;
NSString *const REGISTER_SUCCESS;
NSString *const REGISTER_FAILED;
NSString *const UNREGISTER_SUCCESS;
NSString *const UNREGISTER_FAILED;

// event message ID
NSString *const EVENT_BUTTON_PRESS;
NSString *const EVENT_CUSTOM_BUTTON_PRESS;
NSString *const EVENT_BATTERY_STATUS_CHANGED;
NSString *const EVENT_LOW_BATTERY_VOICE_PROMPT;
NSString *const EVENT_CALL_STATUS_CHANGED;
NSString *const EVENT_PROXIMITY;
NSString *const EVENT_WEAR_STATE_CHANGED;
NSString *const EVENT_DOCKED;
NSString *const EVENT_CONNECTED;
NSString *const EVENT_LOCATION;
NSString *const EVENT_DEVICE_REGISTER;
NSString *const EVENT_DEVICE_UNREGISTER;
NSString *const EVENT_RSSI;
NSString *const EVENT_BEACON;
NSString *const EVENT_HEAD_TRACKING;
//NSString *const EVENT_HS_SENSORS;

// command message ID
NSString *const GET_REGISTERED_DEVICE;
NSString *const GET_REGISTERED_DEVICE_REPLY;
NSString *const GET_ALL_REGISTERED_DEVICES;
NSString *const GET_ALL_REGISTERED_DEVICES_REPLY;
NSString *const SELECT_REGISTERED_DEVICES ;
NSString *const SELECT_REGISTERED_DEVICES_REPLY;
NSString *const GET_LIST_OF_PEOPLE;
NSString *const GET_LIST_OF_PEOPLE_REPLY;
NSString *const SET_CALIBRATION;
NSString *const CLEAR_CALIBRATION;
NSString *const GET_CALIBRATION;

// settings message ID
NSString *const GET_BEACON_DATA;
NSString *const GET_BEACON_DATA_REPLY;


// ----------------------------------------------------------------------------
// PLTContextServerMessage
// ----------------------------------------------------------------------------

@interface PLTContextServerMessage : NSObject

@property (nonatomic, copy, readonly) NSString *type;           // message type
@property (nonatomic, copy, readonly) NSString *messageId;      // message ID
@property (nonatomic, copy, readonly) NSString *deviceId;       // device ID
@property (nonatomic, copy, readonly) NSNumber *sequenceNumber; // sequence number
@property (nonatomic, copy, readonly) NSDictionary *payload;    // payload
@property (nonatomic, copy, readonly) CLLocation *location;     // location
@property (nonatomic, copy, readonly) NSDate *timestamp;        // timestamp
@property (nonatomic, assign, readonly) BOOL isTransient;       // marker for transient data (not stored in database)
@property (nonatomic, copy, readonly) NSDictionary *otherData;  // other data in the top-level message's JSON dictionary


- (id) initWithType:(NSString *) type
          messageId:(NSString *) messageId
           deviceId:(NSString *) deviceId
            payload:(NSDictionary *) payload
           location:(CLLocation *) location
     sequenceNumber:(NSNumber *) sequenceNumber
        isTransient:(BOOL) isTransient
          otherData:(NSDictionary *) otherData;

- (id) initWithType:(NSString *)type
          messageId:(NSString *)messageId
           deviceId:(NSString *) deviceId
            payload:(NSDictionary *)payload
           location:(CLLocation *) location;

- (id) initWithType:(NSString *)type
          messageId:(NSString *)messageId
            payload:(NSDictionary *)payload
           location:(CLLocation *) location;

- (id) initWithType:(NSString *)type
          messageId:(NSString *)messageId
            payload:(NSDictionary *)payload;

- (id) initWithJsonData:(id)message;

- (id) initWithMessage:(PLTContextServerMessage *)message;

- (NSData *) copyAsJSONDataWithOption:(NSJSONWritingOptions)option;
- (NSString *) copyAsJSONStringWithOption:(NSJSONWritingOptions)option;

- (BOOL) hasType:(NSString *)type;
- (BOOL) hasMessageId:(NSString *)messageId;
- (BOOL) hasDeviceId:(NSString *)deviceId;


@end
