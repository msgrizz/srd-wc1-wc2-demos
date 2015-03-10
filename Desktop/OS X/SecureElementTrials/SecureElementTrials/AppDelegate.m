//
//  AppDelegate.m
//  SecureElementTrials
//
//  Created by Morgan Davis on 12/25/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "AppDelegate.h"
#import <PLTDevice/PLTDevice.h>
#import <CommonCrypto/CommonDigest.h>
#import "BRDevice.h"
#import "BRDevice_Private.h"
#import "BRRemoteDevice.h"
#import "BRPassThroughProtocolCommand.h"
#import "BRPassThroughProtocolEvent.h"


//NSString *const PLTFIDOServerAddress =	@"http://localhost:8080";
//NSString *const PLTFIDOServerAddress =	@"http://10.1.47.196:8080";
NSString *const PLTFIDOServerAddress =	@"http://10.50.8.2:8080"; // CES
NSString *const PLTFIDOUsername =		@"joe";
//NSString *const PLTFIDOUsername =		@"plt02";
NSString *const PLTFIDOPassword =		@"1234";


typedef enum {
	PLTFIDOThingStateIdle,
	PLTFIDOThingStatePinging,
	PLTFIDOThingStateRequestingEnrollmentData,
	PLTFIDOThingStateEnrollingDevice,
	PLTFIDOThingStateSendingEnrollment,
	PLTFIDOThingStateRequestingSignData,
	PLTFIDOThingStateSigning,
	PLTFIDOThingStateSendingSignature
} PLTFIDOThingState;


NSData *PLTDataFromHexString(NSString *hexString) {
	// shamelessly stolen from somewhere
	NSString *str = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSMutableData *data= [[NSMutableData alloc] init];
	unsigned char whole_byte;
	char byte_chars[3] = {'\0','\0','\0'};
	for (int i = 0; i < ([str length] / 2); i++) {
		byte_chars[0] = [str characterAtIndex:i*2];
		byte_chars[1] = [str characterAtIndex:i*2+1];
		whole_byte = strtol(byte_chars, NULL, 16);
		[data appendBytes:&whole_byte length:1]; 
	}
	return data;
}

NSString *PLTHexStringFromData(NSData *data, unsigned spaceInterval) {
	// shamelessly stolen from somewhere
	const unsigned char* bytes = (const unsigned char*)[data bytes];
	NSUInteger nbBytes = [data length];
	//If spaces is true, insert a space every this many input bytes (twice this many output characters).
	NSUInteger spaceEveryThisManyBytes = spaceInterval;
	NSUInteger strLen = 2*nbBytes + (spaceInterval>0 ? nbBytes/spaceEveryThisManyBytes : 0);
	
	NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:strLen];
	for(NSUInteger i=0; i<nbBytes; ) {
		[hex appendFormat:@"%02X", bytes[i]];
		//We need to increment here so that the every-n-bytes computations are right.
		++i;
		
		if (spaceInterval>0) {
			if (i % spaceEveryThisManyBytes == 0) [hex appendString:@" "];
		}
	}
	return hex;
}

NSData *PLTSHA256Hash(NSData *input) {
	uint8_t *buf = malloc([input length]);
	[input getBytes:buf length:[input length]];
	unsigned char result[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256(buf, (CC_LONG)[input length], result);
	free(buf);
	return [NSData dataWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
}

NSString *PLTURLSafeBase64Encode(NSData *input) {
	NSString *base64 = [input base64EncodedStringWithOptions:0];
	base64 = [base64 stringByReplacingOccurrencesOfString:@"=" withString:@"*"];
	base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
	return base64;
}

NSData *PLTURLSafeBase64Decode(NSString *input) {
	NSString *base64 = [input copy];
	base64 = [base64 stringByReplacingOccurrencesOfString:@"*" withString:@"="];
	base64 = [base64 stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
	base64 = [base64 stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
	NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
	//NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
	return decodedData;
}


@interface AppDelegate () <BRDeviceDelegate, NSURLConnectionDelegate>

- (void)sendCommandAPDU:(NSData *)apduData;
- (void)parseResultAPDU:(NSData *)apduData;
- (void)ping;
- (void)sendPingCommand;
- (BOOL)pingResponseIsValid:(NSData *)responseAPDU;
- (void)enroll;
- (void)requestEnrollmentDataFromServer;
- (void)parseEnrollmentDataFromServer:(NSDictionary *)enrollmentData;
- (void)sendEnrollmentCommandToDevice:(NSDictionary *)enrollRequest;
- (void)sendEnrollmentToServer:(NSData *)enrollmentAPDU;
- (void)parseEnrollmentResponceFromServer:(NSDictionary *)responce;
- (void)sign;
- (void)requestSignDataFromServer;
- (void)parseSignDataFromServer:(NSArray *)signData;
- (void)sendSignCommandToDevice:(NSDictionary *)signRequest;
- (void)sendSignatureToServer:(NSData *)checkAPDU;
- (void)parseSignatureResponceFromServer:(NSDictionary *)response;
- (IBAction)connectButton:(id)sender;
- (IBAction)pingButton:(id)sender;
- (IBAction)enrollButton:(id)sender;
- (IBAction)signButton:(id)sender;

@property (nonatomic,assign)	PLTFIDOThingState		state;
@property (nonatomic,retain)	BRDevice				*device;
@property (nonatomic,retain)	BRRemoteDevice			*sensorsDevice;
@property (nonatomic,weak)		IBOutlet NSWindow		*window;
@property (nonatomic,weak)		IBOutlet NSTextField	*textField;
@property (nonatomic,retain)	NSDictionary			*enrollRequest;
@property (nonatomic,assign)	unsigned				apduChunkCount;
@property (nonatomic,retain)	NSString				*apduGetChunkHeader;
@property (nonatomic,retain)	NSMutableData			*apduResponseAccum;
@property (nonatomic,retain)	NSDictionary			*signRequest;

@end


@implementation AppDelegate

#pragma mark - Private

- (void)sendCommandAPDU:(NSData *)apduData
{
	BRPassThroughProtocolCommand *cmd = [BRPassThroughProtocolCommand commandWithProtocolid:BRDefinedValue_PassThroughProtocolCommand_Protocolid_ProtocolAPDU
																				messageData:apduData];
	[self.sensorsDevice sendMessage:cmd];
}

- (void)parseResultAPDU:(NSData *)apduData
{
	NSLog(@"parseResultAPDU: %@", apduData);
	
	switch (self.state) {
		case PLTFIDOThingStatePinging:
			if ([self pingResponseIsValid:apduData]) {
				NSLog(@"*** Ping valid! ***");
				self.textField.stringValue = @"Ping valid!";
			}
			else {
				NSLog(@"*** Ping NOT valid! ***");
				self.textField.stringValue = @"Ping NOT valid!";
			}
			self.state = PLTFIDOThingStateIdle;
			break;
			
		case PLTFIDOThingStateEnrollingDevice:
		case PLTFIDOThingStateSigning: {
			unsigned status = 0;
			NSData *statusData = [apduData subdataWithRange:NSMakeRange([apduData length]-2, 2)];
			NSLog(@"statusData: %@", statusData);
			[statusData getBytes:&status length:[statusData length]];
			
			if (status != 0x0090) { // 0x9000 with byte swap
				NSLog(@"*** Bad return APDU status! ***");
			}
			else {
				NSLog(@"Good status.");
				
				NSData *thisChunk = [apduData subdataWithRange:NSMakeRange(1, [apduData length]-4)];
				NSLog(@"Add chunk: %@", PLTHexStringFromData(thisChunk, 0));
				[self.apduResponseAccum appendData:thisChunk];
				
				unsigned more = 0;
				NSData *moreData = [apduData subdataWithRange:NSMakeRange(0, 1)];
				NSLog(@"moreData: %@", moreData);
				[apduData getBytes:&more length:[moreData length]];
				
				if (more == 0x80) {
					// more data to get
					NSLog(@"Still more data");
					self.apduChunkCount = self.apduChunkCount + 1;
					NSLog(@"self.apduChunkCount: %d", self.apduChunkCount);
					
					NSString *giveMeMoreAPDUString = [NSString stringWithFormat:@"%@%02X", self.apduGetChunkHeader, self.apduChunkCount];
					NSLog(@"giveMeMoreAPDUString: %@", giveMeMoreAPDUString);
					NSData *giveMeMoreAPDUData = PLTDataFromHexString(giveMeMoreAPDUString);
					
					[self sendCommandAPDU:giveMeMoreAPDUData];
				}
				else {
					// all done
					NSLog(@"All Done");
					
					if (self.state == PLTFIDOThingStateEnrollingDevice) {
						[self sendEnrollmentToServer:self.apduResponseAccum];
					}
					else if (self.state == PLTFIDOThingStateSigning) {
						[self sendSignatureToServer:self.apduResponseAccum];
					}
				}
			}
			break; }
		default:
			break;
	}
}

- (void)ping
{
	NSLog(@"ping");
	[self sendPingCommand];
}

- (void)sendPingCommand
{
	NSLog(@"sendPingCommand");
	
	self.textField.stringValue = @"Pinging...";
	self.state = PLTFIDOThingStatePinging;
	
	static NSString *const FIDO_INS_VERSION = @"06";
	NSString *pingStringHex = @"000102030405060708090a0b0c0d0e0f";
	unsigned long len = pingStringHex.length / 2;
	NSString *lenHex = [NSString stringWithFormat:@"%02X", (unsigned)len];
	NSString *APDUHex = [NSString stringWithFormat:@"00%@0000%@%@",
						 FIDO_INS_VERSION,
						 lenHex,
						 pingStringHex];
	NSData *pingAPDU = PLTDataFromHexString(APDUHex);
	
	[self sendCommandAPDU:pingAPDU];
}

- (BOOL)pingResponseIsValid:(NSData *)responseAPDU
{
	NSLog(@"pingResponseIsValid: %@", responseAPDU);
	
	uint8_t rawBuffer[[responseAPDU length]];
	[responseAPDU getBytes:rawBuffer length:[responseAPDU length]];
	
	int endOfString = -1;
	NSString *versString = nil;
	for (int i = 0; i<[responseAPDU length] - 2; i++) {
		uint8_t chunk = rawBuffer[i];
		if (chunk == 0) {
			endOfString = i;
			versString = [[NSString alloc] initWithBytes:rawBuffer length:i+1 encoding:NSUTF8StringEncoding];
			break;
		}
	}
	
	NSLog(@"versString: %@", versString);

	NSData *validResponse = PLTDataFromHexString(@"0102030405060708090a0b0c0d0e0f10");
	NSData *ourResponse = [responseAPDU subdataWithRange:NSMakeRange(endOfString+1, [responseAPDU length] - endOfString - 1 -3)];
	
	NSLog(@"validResponse: %@", validResponse);
	NSLog(@"ourResponse: %@", ourResponse);
	
	if ([ourResponse isEqualToData:validResponse]) return YES;
	return NO;
}

- (void)enroll
{
	NSLog(@"enroll");
	
	self.textField.stringValue = @"Enrolling...";
	self.state = PLTFIDOThingStateRequestingEnrollmentData;
	
	[self requestEnrollmentDataFromServer];
}

- (void)requestEnrollmentDataFromServer
{
	NSLog(@"requestEnrollDataFromServer");
	
	NSString *urlString = [NSString stringWithFormat:@"%@/enrollData.js?userName=%@&password=%@", PLTFIDOServerAddress, PLTFIDOUsername, PLTFIDOPassword];
	NSLog(@"urlString: %@", urlString);
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)parseEnrollmentDataFromServer:(NSDictionary *)enrollmentData
{
	NSLog(@"parseEnrollmentData: %@", enrollmentData);

	NSString *appID = enrollmentData[@"appId"];
	NSString *sessionID = enrollmentData[@"sessionId"];
	NSString *version = enrollmentData[@"version"];
	NSString *challenge = enrollmentData[@"challenge"];
	
	NSLog(@"appID: %@", appID);
	NSLog(@"sessionID: %@", sessionID);
	NSLog(@"version: %@", version);
	NSLog(@"challenge: %@", challenge);
	
	self.enrollRequest = @{@"sessionId": sessionID,
						   @"enrollChallenge": @{@"appId": appID,
												 @"version": version,
												 @"browserData": @{@"typ": @"navigator.id.finishEnrollment",
																   @"challenge": challenge}}};
	
	NSLog(@"self.enrollRequest: %@", self.enrollRequest);
	
	[self sendEnrollmentCommandToDevice:self.enrollRequest];
}

- (void)sendEnrollmentCommandToDevice:(NSDictionary *)enrollRequest
{
	NSLog(@"sendEnrollmentCommand: %@", enrollRequest);
	
	self.state = PLTFIDOThingStateEnrollingDevice;

	NSError *err = nil;
	NSDictionary *browserData = enrollRequest[@"enrollChallenge"][@"browserData"];
	NSData *browserDataJSONData = [NSJSONSerialization dataWithJSONObject:browserData
													   options:(NSJSONWritingOptions)0
														 error:&err];
	
	if (err) {
		NSLog(@"*** Error creating JSON string: %@ ***", err);
	}
	else {
		// hash browser data
		NSString *browserDataString = [[NSString alloc] initWithData:browserDataJSONData encoding:NSUTF8StringEncoding];
		NSLog(@"browserDataString: %@", browserDataString); // something like "{"typ":"navigator.id.finishEnrollment","challenge":"EjQ"}"
		NSData *browserHashData = PLTSHA256Hash(browserDataJSONData);
		NSLog(@"browserHashData: %@", browserHashData); // something like "7dfcb4a2c2c3a9664bf0e24a3b48122979547f6472d521e82b2632f8280f6ca8"
		
		// hash app ID
		NSString *appID = enrollRequest[@"enrollChallenge"][@"appId"]; // "http://10.0.1.37:8080"
		NSData *appIDUTF8Data = [appID dataUsingEncoding:NSUTF8StringEncoding];
		NSData *appIDHashData = PLTSHA256Hash(appIDUTF8Data);
		NSLog(@"appIDHashData: %@", appIDHashData); // something like "3ce0bfe2c155a17e65e71d53300cfe2eec090d97d26169bac0c4c41d46be9ac5"
		
		// create and send APDU
		static NSString *const U2F_ENROLL = @"02";
		static NSString *const XAPDU_XMIT_BIT = @"40";
		unsigned long len = [browserHashData length] + [appIDHashData length];
		NSString *enrollAPDUHex = [NSString stringWithFormat:@"00%@0000%02X%@%@%@",
								   U2F_ENROLL,
								   (int)len,
								   XAPDU_XMIT_BIT,
								   PLTHexStringFromData(browserHashData, 0),
								   PLTHexStringFromData(appIDHashData, 0)];
		NSData *enrollAPDU = PLTDataFromHexString(enrollAPDUHex);
		
		self.apduResponseAccum = [NSMutableData data];
		self.apduChunkCount = 0;
		self.apduGetChunkHeader = [NSString stringWithFormat:@"%@%@", [enrollAPDUHex substringToIndex:8], @"01"];
		[self sendCommandAPDU:enrollAPDU];
	}
}

- (void)sendEnrollmentToServer:(NSData *)enrollmentAPDU
{
	NSLog(@"sendEnrollmentToServer: %@", enrollmentAPDU);
	
	NSString *base64APDU = PLTURLSafeBase64Encode(enrollmentAPDU);
	base64APDU = [base64APDU stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"base64APDU: %@", base64APDU);
	
	NSError *err = nil;
	NSDictionary *browserData = self.enrollRequest[@"enrollChallenge"][@"browserData"];
	NSData *browserDataJSONData = [NSJSONSerialization dataWithJSONObject:browserData
																  options:(NSJSONWritingOptions)0
																	error:&err];
	
	if (err) {
		NSLog(@"*** Error creating JSON string: %@ ***", err);
	}
	else {
		NSString *base64BrowserDataJSONData = [browserDataJSONData base64EncodedStringWithOptions:0];
		
		NSString *sessionID = self.enrollRequest[@"sessionId"];
		NSString *challenge = self.enrollRequest[@"enrollChallenge"][@"browserData"][@"challenge"];
		
		// http://localhost:8080/enrollFinish?sessionId=sessionId_0_joe&browserData=
		NSString *urlString = [NSString stringWithFormat:@"%@/enrollFinish?sessionId=%@&browserData=%@&challenge=%@&enrollData=%@",
							   PLTFIDOServerAddress,
							   sessionID,
							   base64BrowserDataJSONData,
							   challenge,
							   base64APDU];
		NSLog(@"urlString: %@", urlString);
		
		self.state = PLTFIDOThingStateSendingEnrollment;
		
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
		[request setHTTPMethod:@"GET"];
		[NSURLConnection connectionWithRequest:request delegate:self];
	}
}

- (void)parseEnrollmentResponceFromServer:(NSDictionary *)responce
{
	NSLog(@"parseEnrollmentResponceFromServer: %@", responce);
	
	if (responce[@"attestationCertificate"]) {
		NSLog(@"Succesfully enrolled!");
		self.textField.stringValue = @"Successfully enrolled!";
	}
	else {
		NSLog(@"*** Error enrolling device: %@ ***", @"sometgubg");
		self.textField.stringValue = @"Error enrolling.";
	}
	
	self.state = PLTFIDOThingStateIdle;
}

- (void)sign
{
	NSLog(@"sign");
	
	self.textField.stringValue = @"Signing...";
	self.state = PLTFIDOThingStateRequestingSignData;
	
	[self requestSignDataFromServer];
}

- (void)requestSignDataFromServer
{
	NSLog(@"requestSignDataFromServer");
	
	NSString *urlString = [NSString stringWithFormat:@"%@/signData.js?userName=%@&password=%@", PLTFIDOServerAddress, PLTFIDOUsername, PLTFIDOPassword];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)parseSignDataFromServer:(NSArray *)signData
{
	NSLog(@"parseSignDataFromServer: %@", signData);
	
//	{
//		appId = "http://10.0.1.37:8080";
//		challenge = EjQ;
//		keyHandle = 5KeoF6JjbWGMzFI12Gt32HM673QXJWnvIpG3lMJvrOXzhYrJ8x8MIjIdAalx2csMD0tXuVGlzUaKsgBBbxGh8IHHNDXaLUFx;
//		sessionId = "sessionId_6_joe";
//		version = "U2F_V2";
//	}
	
	if ([signData count]) {
		NSDictionary *theChosenData = signData[0];
		NSLog(@"theChosenData: %@", theChosenData);
		
		self.signRequest = @{@"type": @"sign_web_request",
							 @"signData": theChosenData};
		[self sendSignCommandToDevice:self.signRequest];
	}
	else {
		NSLog(@"*** No enrollments found on server ***");
		self.textField.stringValue = @"No enrollments found.";
		self.state = PLTFIDOThingStateIdle;
	}
}

- (void)sendSignCommandToDevice:(NSDictionary *)signRequest
{
	NSLog(@"sendSignCommandToDevice: %@", signRequest);
	
	self.state = PLTFIDOThingStateSigning;
	
	NSDictionary *signData = signRequest[@"signData"];
	
	// neccessary becuase Chrome constructs it like this: var bd = {typ:"navigator.id.getAssertion", challenge:JSON.stringify(signRequest.signData.challenge)};
	NSString *challengeString = [NSString stringWithFormat:@"\"%@\"", signData[@"challenge"]];
	NSDictionary *browserData = @{@"typ": @"navigator.id.getAssertion",
								  @"challenge": challengeString};
	
	BOOL signAndCheck = ( [signRequest[@"type"] isEqualToString:@"sign_check_keyhandle"] ? YES : NO );
	
	NSString *typeCommand = nil;
	NSString *commandString = nil;
	if (signAndCheck) {
		typeCommand = @"07";
		commandString = @"sign_check";
	}
	else {
		typeCommand = @"03";
		commandString = @"sign";
	}
	
	NSError *err = nil;
	//NSDictionary *browserData = enrollRequest[@"enrollChallenge"][@"browserData"];
	NSData *browserDataJSONData = [NSJSONSerialization dataWithJSONObject:browserData
																  options:(NSJSONWritingOptions)0
																	error:&err];
	
	if (err) {
		NSLog(@"*** Error creating JSON string: %@ ***", err);
	}
	else {
		// hash browser data
		// stream read as '{"typ":"navigator.id.getAssertion","challenge":"\"EjQ\""}' in JS console
		NSString *browserDataString = [[NSString alloc] initWithData:browserDataJSONData encoding:NSUTF8StringEncoding];
		//NSString *browserDataString = @"{\"typ\":\"navigator.id.getAssertion\",\"challenge\":\"\\\"EjQ\\\"\"}";
		NSLog(@"browserDataString: %@", browserDataString);
		//NSString *cheatingBrowserDataHex = @"a8a755a920dae0f6c243cfd72f62fff83aac83366f3f5f8d79bf2b8fec023b90";
		NSData *browserHashData = PLTSHA256Hash(browserDataJSONData);
		NSLog(@"browserHashData: %@", PLTHexStringFromData(browserHashData, 0));
		
		// hash app ID
		NSString *appID = signRequest[@"signData"][@"appId"];
		NSLog(@"appID: %@", appID);
		NSData *appIDUTF8Data = [appID dataUsingEncoding:NSUTF8StringEncoding];
		NSData *appIDHashData = PLTSHA256Hash(appIDUTF8Data);
		NSLog(@"appIDHashData: %@", PLTHexStringFromData(appIDHashData, 0));

		// unpack key handle
		NSData *keyHandleData = PLTURLSafeBase64Decode(signData[@"keyHandle"]);
		NSLog(@"keyHandleData: %@", PLTHexStringFromData(keyHandleData, 0));

		
		// create and send APDU
		static NSString *const U2F_SIGN = @"04";
		static NSString *const XAPDU_XMIT_BIT = @"40";
		unsigned long len = [browserHashData length] + [appIDHashData length] + [keyHandleData length] + 2;
		//unsigned long len = [cheatingBrowserDataHex length]/2 + [appIDHashData length] + [keyHandleData length] + 2;
		NSString *signAPDUHex = [NSString stringWithFormat:@"00%@0000%02X%@%@%@%@%@",
								 U2F_SIGN,
								 (int)len,
								 XAPDU_XMIT_BIT,
								 typeCommand,
								 //cheatingBrowserDataHex,
								 PLTHexStringFromData(browserHashData, 0),
								 PLTHexStringFromData(appIDHashData, 0),
								 PLTHexStringFromData(keyHandleData, 0)];
		NSData *signAPDU = PLTDataFromHexString(signAPDUHex);
		NSLog(@"signAPDU: %@", PLTHexStringFromData(signAPDU, 0));
		
		self.apduResponseAccum = [NSMutableData data];
		self.apduChunkCount = 0;
		self.apduGetChunkHeader = [NSString stringWithFormat:@"%@%@", [signAPDUHex substringToIndex:8], @"01"];
		[self sendCommandAPDU:signAPDU];
	}
}

- (void)sendSignatureToServer:(NSData *)signedAPDU
{
	NSLog(@"sendSignatureToServer: %@", signedAPDU);
	
	NSDictionary *signData = self.signRequest[@"signData"];
	
	// neccessary becuase Chrome constructs it like this: var bd = {typ:"navigator.id.getAssertion", challenge:JSON.stringify(signRequest.signData.challenge)};
	NSString *challengeString = [NSString stringWithFormat:@"\"%@\"", signData[@"challenge"]];
	NSDictionary *browserData = @{@"typ": @"navigator.id.getAssertion",
								  @"challenge": challengeString};
	
	NSString *sessionID = signData[@"sessionId"];
	NSString *challenge = signData[@"challenge"];
	NSString *appID = signData[@"appId"];
//	NSString *challenge = @"challenge";
//	NSString *appID = @"appId";
	
	NSString *base64APDU = PLTURLSafeBase64Encode(signedAPDU);
	base64APDU = [base64APDU stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"base64APDU: %@", base64APDU);
	
	NSError *err = nil;
	NSData *browserDataJSONData = [NSJSONSerialization dataWithJSONObject:browserData
																  options:(NSJSONWritingOptions)0
																	error:&err];
	
	if (err) {
		NSLog(@"*** Error creating JSON string: %@ ***", err);
	}
	else {
		NSString *jsonString = [[NSString alloc] initWithData:browserDataJSONData encoding:NSUTF8StringEncoding];
		NSString *base64BrowserDataJSONData = [browserDataJSONData base64EncodedStringWithOptions:0];
		//NSString *base64BrowserDataJSONData = @"eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiXCJFalFcIiJ9"; // verbatim from Chrome app
		
		NSString *urlString = [NSString stringWithFormat:@"%@/signFinish?sessionId=%@&appId=%@&browserData=%@&challenge=%@&signData=%@",
							   PLTFIDOServerAddress,
							   sessionID,
							   appID,
							   base64BrowserDataJSONData,
							   challenge,
							   base64APDU];
		NSLog(@"urlString: %@", urlString);
		
		self.state = PLTFIDOThingStateSendingSignature;
		
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
		[request setHTTPMethod:@"GET"];
		[NSURLConnection connectionWithRequest:request delegate:self];
	}
}

- (void)parseSignatureResponceFromServer:(NSDictionary *)response
{
	NSLog(@"parseSignatureResponceFromServer: %@", response);
	
	if ([response[@"result"] isEqualToString:@"success"]) {
		NSLog(@"Signature verified!");
		self.textField.stringValue = @"Signature verified!";
	}
	else {
		NSLog(@"*** Error verifying signature: %@ ***", response);
		self.textField.stringValue = @"Error verifying signature.";
	}
}

- (IBAction)connectButton:(id)sender
{
	NSLog(@"connectButton:");
	
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

- (IBAction)pingButton:(id)sender
{
	NSLog(@"pingButton:");
	[self ping];
}

- (IBAction)enrollButton:(id)sender
{
	NSLog(@"enrollButton:");
	[self enroll];
}

- (IBAction)signButton:(id)sender
{
	NSLog(@"signButton:");
	[self sign];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"connection:didReceiveResponse: %@", response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"connection:didReceiveData: %@", data);
	
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"string: %@", string);
	
	NSError *error;
	id parsedObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error) {
		NSLog(@"Error deserializing JSON data: %@", error);
	}
	else {
		NSLog(@"parsedObj: (%@) %@", NSStringFromClass([parsedObj class]), parsedObj);
		
		switch (self.state) {
			case PLTFIDOThingStateRequestingEnrollmentData:
				if ([parsedObj isKindOfClass:[NSDictionary class]]) {
					[self parseEnrollmentDataFromServer:parsedObj];
				}
				else {
					NSLog(@"*** Unexpected JSON data! ***");
				}
				break;
				
			case PLTFIDOThingStateSendingEnrollment:
				if ([parsedObj isKindOfClass:[NSDictionary class]]) {
					[self parseEnrollmentResponceFromServer:parsedObj];
				}
				else {
					NSLog(@"*** Unexpected JSON data! ***");
				}
				break;
				
			case PLTFIDOThingStateRequestingSignData:
				if ([parsedObj isKindOfClass:[NSArray class]]) {
					[self parseSignDataFromServer:parsedObj];
				}
				else {
					NSLog(@"*** Unexpected JSON data! ***");
				}
				break;
				
			case PLTFIDOThingStateSendingSignature:
				if ([parsedObj isKindOfClass:[NSDictionary class]]) {
					[self parseSignatureResponceFromServer:parsedObj];
				}
				else {
					NSLog(@"*** Unexpected JSON data! ***");
				}
				break;
				
			default:
				break;
		}
	}
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
{
	NSLog(@"connection:didSendBodyData: %lu", bytesWritten);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"connectionDidFinishLoading: %@", connection);
}

#pragma mark - BRDeviceDelegate

- (void)BRDeviceDidConnect:(BRDevice *)device
{
	NSLog(@"BRDeviceDidConnect: %@", device);
	
	if (device == self.sensorsDevice) {
		self.textField.stringValue = @"Snap into a slim jim";
	}
}

- (void)BRDeviceDidDisconnect:(BRDevice *)device
{
	NSLog(@"BRDeviceDidDisconnect: %@", device);

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
	
	if ([event isKindOfClass:[BRPassThroughProtocolEvent class]]) {
		BRPassThroughProtocolEvent *e = (BRPassThroughProtocolEvent *)event;
		NSLog(@"Result APDU: %@", PLTHexStringFromData(e.messageData, 0));
		[self parseResultAPDU:e.messageData];
	}
}

- (void)BRDevice:(BRDevice *)device didReceiveSettingResult:(BRSettingResult *)result
{
	NSLog(@"BRDevice: %@ didReceiveSettingResult: %@", device, result);
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
	NSString *hexString = PLTHexStringFromData(data, 2);
	NSLog(@"--> %@", hexString);
}

- (void)BRDevice:(BRDevice *)device didReceiveData:(NSData *)data
{
	NSString *hexString = PLTHexStringFromData(data, 2);
	NSLog(@"<-- %@", hexString);
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSLog(@"applicationDidFinishLaunching:");
	self.state = PLTFIDOThingStateIdle;
}

@end
