//
//  PLTContextServerMessage.m
//
//  Created by Antony Bayley on 15/06/2012.
//  Copyright (c) 2012 Plantronics Limited. All rights reserved.
//

#import "PLTContextServerMessage.h"

// message type
NSString *const MESSAGE_TYPE_AUTHENTICATE        = @"authenticate";
NSString *const MESSAGE_TYPE_REGISTER_DEVICE     = @"registerdevice";
NSString *const MESSAGE_TYPE_EVENT               = @"event";
NSString *const MESSAGE_TYPE_COMMAND             = @"command";
NSString *const MESSAGE_TYPE_EXCEPTION           = @"exception";
NSString *const MESSAGE_TYPE_SETTING             = @"setting";

// authenticate message ID
NSString *const COULD_NOT_LOCATE_DEVICE_RECORD   = @"0X08AB";
NSString *const AUTHENTICATE_FAILED              = @"0X0CAA";
NSString *const AUTHENTICATE_USERNAME_PASSWORD   = @"0X0CAB";
NSString *const AUTHENTICATE_SUCCESS             = @"0X0CAC";
NSString *const AUTHENTICATE_X509_CERTIFICATE    = @"0X0CAD";
NSString *const AUTHENTICATE_REQUIRED            = @"0X0CAF";

// register message ID
NSString *const REGISTER_DEVICE                  = @"0X0BAA";
NSString *const UNREGISTER_DEVICE                = @"0X0BAB";
NSString *const GET_REGISTERED_DEVICES           = @"0X0BAC";
NSString *const REGISTER_SUCCESS                 = @"0X0BAD";
NSString *const REGISTER_FAILED                  = @"0X0BAE";
NSString *const UNREGISTER_SUCCESS               = @"0X0BAF";
NSString *const UNREGISTER_FAILED				 = @"0X0BB1";

// event message ID
NSString *const EVENT_BUTTON_PRESS               = @"0X0600";
NSString *const EVENT_CUSTOM_BUTTON_PRESS        = @"0X0806";
NSString *const EVENT_BATTERY_STATUS_CHANGED     = @"0X0A1C";
NSString *const EVENT_LOW_BATTERY_VOICE_PROMPT   = @"0X0A28";
NSString *const EVENT_CALL_STATUS_CHANGED        = @"0X0E00";
NSString *const EVENT_PROXIMITY                  = @"0X0100";
NSString *const EVENT_WEAR_STATE_CHANGED         = @"0X0200";
NSString *const EVENT_DOCKED                     = @"0X0E01";
NSString *const EVENT_CONNECTED                  = @"0X0E04";
NSString *const EVENT_LOCATION                   = @"0X0E05";
NSString *const EVENT_DEVICE_REGISTER            = @"0X0E06";
NSString *const EVENT_DEVICE_UNREGISTER          = @"0X0E07";
NSString *const EVENT_RSSI                       = @"0X0E08";
NSString *const EVENT_BEACON                     = @"0X0E09";
NSString *const EVENT_HEAD_TRACKING              = @"0X0E0A";
//NSString *const EVENT_HS_SENSORS                 = @"0XCAFE";

// command message ID
NSString *const GET_REGISTERED_DEVICE            = @"0X0D00";
NSString *const GET_REGISTERED_DEVICE_REPLY      = @"0X0D03";
NSString *const GET_ALL_REGISTERED_DEVICES       = @"0X0D01";
NSString *const GET_ALL_REGISTERED_DEVICES_REPLY = @"0X0D04";
NSString *const SELECT_REGISTERED_DEVICES        = @"0X0D02";
NSString *const SELECT_REGISTERED_DEVICES_REPLY  = @"0X0D05";
NSString *const GET_LIST_OF_PEOPLE               = @"0X0D06";
NSString *const GET_LIST_OF_PEOPLE_REPLY         = @"0X0D07";
NSString *const SET_CALIBRATION					 = @"0X0D11";
NSString *const CLEAR_CALIBRATION				 = @"0X0D12";
NSString *const GET_CALIBRATION					 = @"0X0D13";

// settings message ID
NSString *const GET_BEACON_DATA                  = @"0X0F00";
NSString *const GET_BEACON_DATA_REPLY            = @"0X0F01";


// ----------------------------------------------------------------------------
// PLTContextServerMessage class
// ----------------------------------------------------------------------------

@interface PLTContextServerMessage()

// properties are read-write internally
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSNumber *sequenceNumber;
@property (nonatomic, copy) NSDictionary *payload;
@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, copy) NSDate *timestamp;
@property(nonatomic,assign) BOOL isTransient;
@property (nonatomic, copy) NSDictionary *otherData;

@end


@implementation PLTContextServerMessage

@synthesize otherData = _otherData;
@synthesize type = _type;
@synthesize messageId = _messageId;
@synthesize deviceId = _deviceId;
@synthesize sequenceNumber = _sequenceNumber;
@synthesize payload = _payload;
@synthesize location = _location;
@synthesize timestamp = _timestamp;
@synthesize isTransient = _isTransient;


// initialise all required and optional properties
- (id) initWithType:(NSString *) type
          messageId:(NSString *) messageId
           deviceId:(NSString *) deviceId
            payload:(NSDictionary *) payload
           location:(CLLocation *) location
     sequenceNumber:(NSNumber *) sequenceNumber
        isTransient:(BOOL)isTransient
          otherData:(NSDictionary *) otherData
{
    // call the superclass' initializer
    self = [super init];
    
    // initialize the instance variables
    if (self) {
        self.type = type;
        self.messageId = messageId;
        self.deviceId = deviceId;
        self.payload = payload;
        self.location = location;
        self.sequenceNumber = sequenceNumber;
        self.isTransient = isTransient;
        self.otherData = otherData;
        self.timestamp = [[NSDate alloc] init];
    }
    return self;
}


// initialize only the required properties and deviceId, and set optional properties to nil
- (id) initWithType:(NSString *)type
          messageId:(NSString *)messageId
          deviceId:(NSString *) deviceId
          payload:(NSDictionary *)payload
          location:(CLLocation *)location
{
    self = [self initWithType:type messageId:messageId deviceId:deviceId payload:payload location:location sequenceNumber:nil isTransient:NO otherData:nil ];
    return self;
}


// initialize only the required properties, and set optional properties to nil
- (id) initWithType:(NSString *)type
          messageId:(NSString *)messageId
          payload:(NSDictionary *)payload
          location:(CLLocation *)location
{
    self = [self initWithType:type messageId:messageId deviceId:nil payload:payload location:location sequenceNumber:nil isTransient:NO otherData:nil ];
    return self;
}


// initialize only the required properties, and set optional properties to nil
- (id) initWithType:(NSString *)type
          messageId:(NSString *)messageId
          payload:(NSDictionary *)payload
{
    self = [self initWithType:type messageId:messageId deviceId:nil payload:payload location:nil sequenceNumber:nil isTransient:NO otherData:nil ];
    return self;
}


// initialize from JSON data received from the context server, or return nil on error
- (id) initWithJsonData:(id)message
{
    NSError *error = nil;
    NSData *jsonData;
    
    // message may be NSString or NSData, depending on WebSocket frame type
    if ([message isKindOfClass:[NSString class]]){
        jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];        
    }
    if ([message isKindOfClass:[NSData class]]){
        jsonData = message;
    }
    
    if ([jsonData length] > 0) {
        // If data was returned, parse it as a PLTMessage
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        if (!jsonObject || ![jsonObject isKindOfClass:[NSDictionary class]]) {
            // JSON parsing failure if the parsed object is not of type NSDictionary
			NSLog(@"[CS] JSON parsing failed: %@", error);
            //debugLog_CSM(@"[CS] JSON parsing failed: %@", error);
        }
        else {
            // JSON parsing success - set PLTMessage properties
            NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
            
            NSString *type = [jsonDictionary objectForKey:@"type"];
            if (type) {
                [jsonDictionary removeObjectForKey:@"type"];
            }
            
            NSString *messageId = [jsonDictionary objectForKey:@"id"];
            if (messageId) {
                [jsonDictionary removeObjectForKey:@"id"];
            }
            
            NSString *deviceId = [jsonDictionary objectForKey:@"deviceId"];
            if (deviceId) {
                [jsonDictionary removeObjectForKey:@"deviceId"];
            }

            NSNumber *sequenceNumber = [jsonDictionary objectForKey:@"sequenceNumber"];
            if (sequenceNumber) {
                [jsonDictionary removeObjectForKey:@"sequenceNumber"];
            }

            BOOL isTransient = NO;
            NSNumber *isTransientAsNumber = [jsonDictionary objectForKey:@"isTransient"];
            if (isTransientAsNumber) {
                isTransient = [isTransientAsNumber boolValue];
                [jsonDictionary removeObjectForKey:@"isTransient"];
            }
            
            NSDictionary *payload = [jsonDictionary objectForKey:@"payload"];
            if (payload) {
                [jsonDictionary removeObjectForKey:@"payload"];
            }
            
            CLLocation *location = nil;
            NSString *locationString = [jsonDictionary objectForKey:@"locationStamp"];
            if (locationString) {
                NSArray *locationStringArray = [locationString componentsSeparatedByString:@","];
                NSString *latitudeString = [locationStringArray objectAtIndex:0];
                NSString *longitudeString = [locationStringArray objectAtIndex:1];
                CLLocationDegrees latitude = [latitudeString doubleValue];
                CLLocationDegrees longitude = [longitudeString doubleValue];
                location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                [jsonDictionary removeObjectForKey:@"locationStamp"];
            }
            
            NSDate  *timestamp = nil;
            NSNumber *millisecondsSince1970 = [jsonDictionary objectForKey:@"timestamp"];
            if (millisecondsSince1970) {
                NSTimeInterval secondsSince1970 = [millisecondsSince1970 doubleValue] / 1000;
                timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:secondsSince1970];
                [jsonDictionary removeObjectForKey:@"timestamp"];
            }
            
            NSDictionary *otherData = [[NSDictionary alloc] initWithDictionary:jsonDictionary];
            
            // create PLTMessage object
            self = [self initWithType:type messageId:messageId deviceId:deviceId payload:payload location:location sequenceNumber:sequenceNumber isTransient:isTransient otherData:otherData ];
            if (self) {
                self.timestamp = timestamp;
                
                // replace PLTMessage object by PLTMessage subclass object, if applicable

                return self;
            }
        }
    }
    return nil;
}


// Copy an existing message.  This method is primarily used in subclass initializers.
- (id) initWithMessage:(PLTContextServerMessage *)message
{
    self = [self initWithType:message.type messageId:message.messageId deviceId:message.deviceId payload:message.payload location:message.location sequenceNumber:message.sequenceNumber isTransient:message.isTransient otherData:message.otherData ];
    self.timestamp = message.timestamp;
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<PLTContextServerMessage: %p> %@", self, [self copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]];
}


- (NSData *) copyAsJSONDataWithOption:(NSJSONWritingOptions)option
{
    // return this message as an NSData object containing a UTF8 JSON string
    //
    // option:  NSJSONWritingPrettyPrinted - add whitespace and indenting
    //          kNilOptions                - no added whitespace

    // starting the method name with 'copy' forces the return value to be a
    // strong pointer with retain count equal to 1.  Otherwise the return value
    // is added to the autorelease pool and deallocated when the calling 
    // function returns.
    
    // convert properties to JSON serializable objects
    long long timestampAsLongLong = (long long)(1000 * [self.timestamp timeIntervalSince1970]);
    NSNumber *timeStampAsNSNumber = [[NSNumber alloc] initWithLongLong:timestampAsLongLong];
    NSString *locationStamp = [[NSString alloc] initWithFormat:@"%f,%f",
                               self.location.coordinate.latitude,
                               self.location.coordinate.longitude];
    
    // assemble the message
    NSMutableDictionary *data;
    if (self.otherData) {
        // if "other data" exists, add it to the top-level JSON dictionary
        data = [[NSMutableDictionary alloc] initWithDictionary:self.otherData];
    }
    else {
        data = [[NSMutableDictionary alloc] init];
    }
    [data setObject:self.type forKey:@"type"];
    [data setObject:self.messageId forKey:@"id"];
    if (self.deviceId) {
        [data setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.sequenceNumber) {
        [data setObject:self.sequenceNumber forKey:@"sequenceNumber"];
    }
    if (self.payload) {
        [data setObject:self.payload forKey:@"payload"];
    }
    if (self.location) {
        [data setObject:locationStamp forKey:@"locationStamp"];
    }
    if (self.isTransient) {
        [data setObject:[NSNumber numberWithBool:self.isTransient] forKey:@"isTransient"];
    }
    [data setObject:timeStampAsNSNumber forKey:@"timestamp"];
    
    // convert message to JSON data
    NSError* error = nil;
    NSData* json = [NSJSONSerialization dataWithJSONObject:data options:option error:&error];
    if (error != nil) return nil;
    return json;
}


- (NSString *) copyAsJSONStringWithOption:(NSJSONWritingOptions)option
{
    // return this message as a JSON NSString object
    //
    // option:  NSJSONWritingPrettyPrinted - add whitespace and indenting
    //          kNilOptions                - no added whitespace
    
    // starting the method name with 'copy' forces the return value to be a
    // strong pointer with retain count equal to 1.  Otherwise the return value
    // is added to the autorelease pool and deallocated when the calling 
    // function returns.

    NSData *jsonData = [self copyAsJSONDataWithOption:option];
    NSString *jsonDataAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonDataAsString;
}


- (BOOL) hasType:(NSString *)type
{
    return[self.type isEqualToString:type];
}


- (BOOL) hasMessageId:(NSString *)messageId
{
    return [self.messageId isEqualToString:messageId];
}


- (BOOL) hasDeviceId:(NSString *)deviceId
{
    return [self.deviceId isEqualToString:deviceId];
}

@end
