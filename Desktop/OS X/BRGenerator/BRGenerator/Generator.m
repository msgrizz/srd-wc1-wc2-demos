//
//  Generator.m
//  BRSDKGenerator
//
//  Created by Morgan Davis on 8/27/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "Generator.h"
#import "DeckardMessage.h"


NSString *const		TKey_MessageName =							@"message_name";
NSString *const		TKey_DeckardVersion =						@"deckard_version";
NSString *const		TKey_MDY =									@"mdy";
NSString *const		TKey_YYYY =									@"yyyy";
NSString *const		TKey_IdentifierConstantName =				@"identifier_constant_name";
NSString *const		TKey_DefinedValuesBlock =					@"defined_values_block";
NSString *const		TKey_ConstructorPrototype =					@"constructor_prototype";
NSString *const		TKey_PublicPropertiesBlock =				@"public_properties_block";
NSString *const		TKey_PrivatePropertiesBlock =				@"private_properties_block";
NSString *const		TKey_ConstructorPropertiesInitBlock =		@"constructor_properties_init_block";
NSString *const		TKey_MessageIdentifier =					@"message_identifier";
NSString *const		TKey_PayloadDescriptorsBlock =				@"payload_descriptors_block";
NSString *const		TKey_DescriptionFormat =					@"description_format";
NSString *const		TKey_DescriptionArguments =					@"description_arguments";

NSString *const		TKey_ParseDataBlock =						@"parse_data_block";

NSString *const		TKey_SettingResultSuccessDecoderCaseBlock =	@"setting_result_success_decoder_case_block";
NSString *const		TKey_EventDecoderCaseBlock =				@"event_decoder_case_block";
NSString *const		TKey_ExceptionCaseBlock =					@"exception_decoder_case_block";

NSString *const		TKey_FileImportsBlock =						@"file_imports_block";


typedef enum {
	DeckardParserStateIdle,
	DeckardParserStateParsingCommand,
	DeckardParserStateParsingSettingRequest,
	DeckardParserStateParsingSettingResult,
	DeckardParserStateParsingEvent,
	DeckardParserStateParsingException
} DeckardParserState;

typedef enum {
	DeckardParserSubstateWaiting,
	DeckardParserSubstateParsingPayloadIn,
	DeckardParserSubstateParsingPayloadOut
} DeckardParserSubstate;

typedef enum {
	PropertyAccessRegular,
	PropertyAccessReadonly,
	PropertyAccessReadwrite
} PropertyAccess;

typedef enum {
	BRPayloadItemTypeBoolean,
	BRPayloadItemTypeByte,
	BRPayloadItemTypeShort,
	BRPayloadItemTypeUnsignedShort,
	BRPayloadItemTypeLong,
	BRPayloadItemTypeUnsignedLong,
	BRPayloadItemTypeInt,
	BRPayloadItemTypeUnsignedInt,
	BRPayloadItemTypeByteArray,
	BRPayloadItemTypeShortArray,
	BRPayloadItemTypeString
} BRPayloadItemType;


@interface Generator() <NSXMLParserDelegate>

- (void)setup;
- (void)parseXML;
- (void)generateCode;
- (void)setupOutputDirectory;

- (NSString *)definedValuesBlockForMessage:(DeckardMessage *)message;
- (NSString *)constructorPrototypeForMessage:(DeckardMessage *)message;
- (NSString *)propertiesBlockForPayload:(NSArray *)payload access:(PropertyAccess)access;
- (NSString *)constructorPropertiesInitBlockForMessage:(DeckardMessage *)message;
- (void)getDescriptionFormatBlock:(NSString **)format arguments:(NSString **)arguments forMessage:(DeckardMessage *)message;
- (NSString *)objcTypeStringForBRType:(BRPayloadItemType)brType;
- (NSString *)escapeSequenceForBRType:(BRPayloadItemType)brType;
- (NSString *)stringForBRType:(BRPayloadItemType)brType;
- (NSString *)payloadDescriptorsBlockForMessage:(DeckardMessage *)message;
//- (NSString *)stringForDefinedTypeItemType:(BRPayloadItemType)brType;

- (void)populateTemplate:(NSMutableString *)template withString:(NSString *)fill forKey:(NSString *)key;
- (NSString *)capitalizedString:(NSString *)lower;
- (NSString *)decapitalizedString:(NSString *)upper;

@property(nonatomic,assign)		DeckardParserState		parserState;
@property(nonatomic,assign)		DeckardParserSubstate	parserSubstate;
@property(nonatomic,strong)		NSMutableArray			*commands;
@property(nonatomic,strong)		NSMutableArray			*settings;
@property(nonatomic,strong)		NSMutableArray			*events;
@property(nonatomic,strong)		NSMutableArray			*exceptions;
@property(nonatomic,assign)		NSString				*deckardVersion;

@property(nonatomic,assign)		NSString				*cSection;
@property(nonatomic,strong)		DeckardMessage			*cMessage;
@property(nonatomic,strong)		NSDate					*startDate;

@end


@implementation Generator


- (void)generate
{
	[self setup];
	[self parseXML];
	// wait for XML parser to finish document to start generating code
}

- (void)setup
{
	self.parserState = DeckardParserStateIdle;
	self.parserSubstate = DeckardParserSubstateWaiting;
	
	self.commands = [NSMutableArray array];
	self.settings = [NSMutableArray array];
	self.events = [NSMutableArray array];
	self.exceptions = [NSMutableArray array];
	
	self.deckardVersion = nil;
	self.cSection = nil;
	self.cMessage = nil;
	
	self.startDate = [NSDate date];
}

- (void)parseXML
{
	NSURL *deckardURL = [NSURL fileURLWithPath:@"deckard.xml"];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:deckardURL];
	parser.delegate = self;
	[parser parse];
}

- (void)generateCode
{
	NSLog(@"Generating code...");
	
	[self setupOutputDirectory];
	

	NSMutableString *tval_settingResultSuccessDecoderCaseBlock = [NSMutableString string];
	NSMutableString *tval_eventDecoderCaseBlock = [NSMutableString string];
	NSMutableString *tval_exceptionDecoderCaseBlock = [NSMutableString string];
	NSMutableString *tval_fileImportsBlock = [NSMutableString string];
	
	
	NSString *tval_DeckardVersion = self.deckardVersion;
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MM/dd/YY"];
	NSString *tval_MDY = [dateFormat stringFromDate:self.startDate];
	dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy"];
	NSString *tval_YYYY = [dateFormat stringFromDate:self.startDate];


	NSMutableArray *allMessages = [NSMutableArray array];
	[allMessages addObjectsFromArray:self.commands];
	NSArray *settingRequests = [[NSArray alloc] initWithArray:self.settings copyItems:YES];
	for (DeckardMessage *m in settingRequests) {
		m.type = DeckardMessageTypeSettingRequest;
		m.payloadOut = nil;
	}
	[allMessages addObjectsFromArray:settingRequests];
	NSArray *settingResults = [[NSArray alloc] initWithArray:self.settings copyItems:YES];
	for (DeckardMessage *m in settingResults) {
		m.type = DeckardMessageTypeSettingResult;
		m.payloadIn = nil;
	}
	[allMessages addObjectsFromArray:settingResults];
	[allMessages addObjectsFromArray:self.events];
	[allMessages addObjectsFromArray:self.exceptions];
	
	
	for (DeckardMessage *message in allMessages) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *pwd = [fm currentDirectoryPath];
		
		NSString *typeString;
		switch (message.type) {
			case DeckardMessageTypeCommand:
				typeString = @"Command";
				break;
			case DeckardMessageTypeSetting: // shouldn't happen
				break;
			case DeckardMessageTypeSettingRequest:
				typeString = @"SettingRequest";
				break;
			case DeckardMessageTypeSettingResult:
				typeString = @"SettingResult";
				break;
			case DeckardMessageTypeEvent:
				typeString = @"Event";
				break;
			case DeckardMessageTypeException:
				typeString = @"Exception";
				break;
		}
		
		NSMutableString *templateHBody = [NSMutableString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Templates/%@.h.template", pwd, typeString]
																		  encoding:NSUTF8StringEncoding error:nil];
		NSMutableString *templateMBody = [NSMutableString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Templates/%@.m.template", pwd, typeString]
																		  encoding:NSUTF8StringEncoding error:nil];
		
		NSString *tval_MessageName = [self capitalizedString:message.name];
		tval_MessageName = [tval_MessageName stringByReplacingOccurrencesOfString:@" " withString:@""];
		tval_MessageName = [tval_MessageName stringByReplacingOccurrencesOfString:@"-" withString:@""];
		tval_MessageName = [tval_MessageName stringByReplacingOccurrencesOfString:@"/" withString:@""];
		tval_MessageName = [tval_MessageName stringByAppendingString:typeString];
		
		NSString *tval_IdentifierConstantName = [message.name uppercaseString];
		tval_IdentifierConstantName = [tval_IdentifierConstantName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
		tval_IdentifierConstantName = [tval_IdentifierConstantName stringByReplacingOccurrencesOfString:@"-" withString:@""];
		tval_IdentifierConstantName = [tval_IdentifierConstantName stringByReplacingOccurrencesOfString:@"/" withString:@""];
		tval_IdentifierConstantName = [@"BR_" stringByAppendingString:tval_IdentifierConstantName];
		switch (message.type) {
			case DeckardMessageTypeCommand:
				break;
			case DeckardMessageTypeSetting: // shouldn't happen
				break;
			case DeckardMessageTypeSettingRequest:
				tval_IdentifierConstantName = [tval_IdentifierConstantName stringByAppendingString:@"_SETTING_REQUEST"];
				break;
			case DeckardMessageTypeSettingResult:
				tval_IdentifierConstantName = [tval_IdentifierConstantName stringByAppendingString:@"_SETTING_RESULT"];
				break;
			case DeckardMessageTypeEvent:
				tval_IdentifierConstantName = [tval_IdentifierConstantName stringByAppendingString:@"_EVENT"];
				break;
			case DeckardMessageTypeException: 
				tval_IdentifierConstantName = [tval_IdentifierConstantName stringByAppendingString:@"_EXCEPTION"];
				break;
		}
		
		NSString *tval_ConstructorPrototype = [self constructorPrototypeForMessage:message];
		
		NSString *tval_PublicPropertiesBlock = @"";
		NSString *tval_PrivatePropertiesBlock = @"";
		//[self getPublicPropertiesBlock:&tval_PublicPropertiesBlock private:&tval_PrivatePropertiesBlock forMessage:message];
		
		switch (message.type) {
			case DeckardMessageTypeCommand:
			case DeckardMessageTypeSetting: // shouldn't happen
			case DeckardMessageTypeSettingRequest:
				tval_PublicPropertiesBlock = [self propertiesBlockForPayload:message.payloadIn access:PropertyAccessRegular];
				break;
			case DeckardMessageTypeSettingResult:
			case DeckardMessageTypeEvent:
			case DeckardMessageTypeException:
				tval_PublicPropertiesBlock = [self propertiesBlockForPayload:message.payloadOut access:PropertyAccessReadonly];
				tval_PrivatePropertiesBlock = [self propertiesBlockForPayload:message.payloadOut access:PropertyAccessReadwrite];
				if (message.payloadOut) {
					
				}
				break;
		}
		
		NSString *tval_ConstructorPropertiesInitBlock = [self constructorPropertiesInitBlockForMessage:message];
		NSString *tval_MessageIdentifier = [NSString stringWithFormat:@"0x%04lX", (unsigned long)message.identifier];
		NSString *tval_PayloadDescriptorsBlock = [self payloadDescriptorsBlockForMessage:message];
		NSString *tval_DescriptionFormat;
		NSString *tval_DescriptionArguments;
		[self getDescriptionFormatBlock:&tval_DescriptionFormat arguments:&tval_DescriptionArguments forMessage:message];
		
		NSString *tval_DefinedValuesBlock = [self definedValuesBlockForMessage:message];
		
		// .h and .m
		
		[self populateTemplate:templateHBody withString:tval_MessageName forKey:TKey_MessageName];
		[self populateTemplate:templateMBody withString:tval_MessageName forKey:TKey_MessageName];
		
		[self populateTemplate:templateHBody withString:tval_DeckardVersion forKey:TKey_DeckardVersion];
		[self populateTemplate:templateMBody withString:tval_DeckardVersion forKey:TKey_DeckardVersion];
		
		[self populateTemplate:templateHBody withString:tval_MDY forKey:TKey_MDY];
		[self populateTemplate:templateMBody withString:tval_MDY forKey:TKey_MDY];
		
		[self populateTemplate:templateHBody withString:tval_YYYY forKey:TKey_YYYY];
		[self populateTemplate:templateMBody withString:tval_YYYY forKey:TKey_YYYY];
		
		[self populateTemplate:templateHBody withString:tval_IdentifierConstantName forKey:TKey_IdentifierConstantName];
		[self populateTemplate:templateMBody withString:tval_IdentifierConstantName forKey:TKey_IdentifierConstantName];
		
		[self populateTemplate:templateHBody withString:tval_ConstructorPrototype forKey:TKey_ConstructorPrototype];
		[self populateTemplate:templateMBody withString:tval_ConstructorPrototype forKey:TKey_ConstructorPrototype];
		
		// .h only
		
		[self populateTemplate:templateHBody withString:tval_MessageIdentifier forKey:TKey_MessageIdentifier];
		[self populateTemplate:templateHBody withString:tval_DefinedValuesBlock forKey:TKey_DefinedValuesBlock];
		[self populateTemplate:templateHBody withString:tval_PublicPropertiesBlock forKey:TKey_PublicPropertiesBlock];
		
		// .m only
		
		[self populateTemplate:templateMBody withString:tval_PrivatePropertiesBlock forKey:TKey_PrivatePropertiesBlock];
		[self populateTemplate:templateMBody withString:tval_ConstructorPropertiesInitBlock forKey:TKey_ConstructorPropertiesInitBlock];
		[self populateTemplate:templateMBody withString:tval_PayloadDescriptorsBlock forKey:TKey_PayloadDescriptorsBlock];
		[self populateTemplate:templateMBody withString:tval_MessageName forKey:TKey_MessageName];
		[self populateTemplate:templateMBody withString:tval_DescriptionFormat forKey:TKey_DescriptionFormat];
		[self populateTemplate:templateMBody withString:tval_DescriptionArguments forKey:TKey_DescriptionArguments];
		
		NSString *dir;
		if (message.type == DeckardMessageTypeSettingRequest) {
			dir = [NSString stringWithFormat:@"%@/Output/Messages/Settings/Requests/", pwd];
		}
		else if (message.type == DeckardMessageTypeSettingResult) {
			dir = [NSString stringWithFormat:@"%@/Output/Messages/Settings/Results/", pwd];
		}
		else {
			NSString *resultDirectoryName = [typeString stringByAppendingString:@"s"];
			dir = [NSString stringWithFormat:@"%@/Output/Messages/%@/", pwd, resultDirectoryName];
		}
		NSString *hFilePath = [NSString stringWithFormat:@"%@BR%@.h", dir, tval_MessageName];
		NSString *mFilePath = [NSString stringWithFormat:@"%@BR%@.m", dir, tval_MessageName];
		[templateHBody writeToFile:hFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
		[templateMBody writeToFile:mFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
		
		// add this class's header to the master "BRMessages.h" file
		[tval_fileImportsBlock appendFormat:@"#import \"BR%@.h\"\n", tval_MessageName];
		
		
		// pre-message template completion is done. if it's in incoming message, add the apropriate bits to the incoming message decoder
		if (message.type == DeckardMessageTypeSettingResult) {
			[tval_settingResultSuccessDecoderCaseBlock appendFormat:@"\t\t\t\tcase %@: class = [BR%@ class]; break;\n", tval_IdentifierConstantName, tval_MessageName];
		}
		else if (message.type == DeckardMessageTypeEvent) {
			[tval_eventDecoderCaseBlock appendFormat:@"\t\t\t\tcase %@: class = [BR%@ class]; break;\n", tval_IdentifierConstantName, tval_MessageName];
		}
		else if (message.type == DeckardMessageTypeException) {
			[tval_exceptionDecoderCaseBlock appendFormat:@"\t\t\t\tcase %@: class = [BR%@ class]; break;\n", tval_IdentifierConstantName, tval_MessageName];
		}
	}
	
	// write incoming decoder file
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *pwd = [fm currentDirectoryPath];
	NSMutableString *decoderHBody = [NSMutableString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Templates/BRIncomingMessageDecoder.h.template", pwd]
																		 encoding:NSUTF8StringEncoding error:nil];
	NSMutableString *decoderMBody = [NSMutableString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Templates/BRIncomingMessageDecoder.m.template", pwd]
																		 encoding:NSUTF8StringEncoding error:nil];
	NSMutableString *typeImportsHBody = [NSMutableString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Templates/BRTypeImports.h.template", pwd]
																		 encoding:NSUTF8StringEncoding error:nil];
	
	[self populateTemplate:decoderHBody withString:tval_DeckardVersion forKey:TKey_DeckardVersion];
	[self populateTemplate:decoderMBody withString:tval_DeckardVersion forKey:TKey_DeckardVersion];
	[self populateTemplate:typeImportsHBody withString:tval_DeckardVersion forKey:TKey_DeckardVersion];
	
	[self populateTemplate:decoderHBody withString:tval_MDY forKey:TKey_MDY];
	[self populateTemplate:decoderMBody withString:tval_MDY forKey:TKey_MDY];
	[self populateTemplate:typeImportsHBody withString:tval_MDY forKey:TKey_MDY];
	
	[self populateTemplate:decoderHBody withString:tval_YYYY forKey:TKey_YYYY];
	[self populateTemplate:decoderMBody withString:tval_YYYY forKey:TKey_YYYY];
	[self populateTemplate:typeImportsHBody withString:tval_YYYY forKey:TKey_YYYY];
	
	[self populateTemplate:decoderMBody withString:tval_settingResultSuccessDecoderCaseBlock forKey:TKey_SettingResultSuccessDecoderCaseBlock];
	[self populateTemplate:decoderMBody withString:tval_eventDecoderCaseBlock forKey:TKey_EventDecoderCaseBlock];
	[self populateTemplate:decoderMBody withString:tval_exceptionDecoderCaseBlock forKey:TKey_ExceptionCaseBlock];
	
	[self populateTemplate:typeImportsHBody withString:tval_fileImportsBlock forKey:TKey_FileImportsBlock];
	
	NSString *dir = [NSString stringWithFormat:@"%@/Output/", pwd];
	NSString *decoderHFilePath = [dir stringByAppendingPathComponent:@"BRIncomingMessageDecoder.h"];
	NSString *decoderMFilePath = [dir stringByAppendingPathComponent:@"BRIncomingMessageDecoder.m"];
	NSString *typeImportsHFilePath = [dir stringByAppendingPathComponent:@"BRTypeImports.h"];
	[decoderHBody writeToFile:decoderHFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	[decoderMBody writeToFile:decoderMFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	[typeImportsHBody writeToFile:typeImportsHFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	NSLog(@"Done.");
}

- (void)setupOutputDirectory
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *pwd = [fm currentDirectoryPath];
	
	[fm removeItemAtPath:[pwd stringByAppendingPathComponent:@"Output"] error:nil];
	[fm createDirectoryAtPath:[pwd stringByAppendingPathComponent:@"Output/Messages/Commands"] withIntermediateDirectories:YES attributes:nil error:nil];
	[fm createDirectoryAtPath:[pwd stringByAppendingPathComponent:@"Output/Messages/Settings/Requests"] withIntermediateDirectories:YES attributes:nil error:nil];
	[fm createDirectoryAtPath:[pwd stringByAppendingPathComponent:@"Output/Messages/Settings/Results"] withIntermediateDirectories:YES attributes:nil error:nil];
	[fm createDirectoryAtPath:[pwd stringByAppendingPathComponent:@"Output/Messages/Events"] withIntermediateDirectories:YES attributes:nil error:nil];
	[fm createDirectoryAtPath:[pwd stringByAppendingPathComponent:@"Output/Messages/Exceptions"] withIntermediateDirectories:YES attributes:nil error:nil];
}

- (NSString *)definedValuesBlockForMessage:(DeckardMessage *)message
{
	NSMutableString *str = [NSMutableString string];
	
	NSArray *payload = message.payloadIn;
	if (message.type == DeckardMessageTypeSettingResult || message.type == DeckardMessageTypeEvent || message.type == DeckardMessageTypeException) {
		payload = message.payloadOut;
	}
	
	if (payload) {
		NSString *typeString;
		switch (message.type) {
			case DeckardMessageTypeCommand:
				typeString = @"Command";
				break;
			case DeckardMessageTypeSetting: // shouldn't happen
				break;
			case DeckardMessageTypeSettingRequest:
				typeString = @"SettingRequest";
				break;
			case DeckardMessageTypeSettingResult:
				typeString = @"SettingResult";
				break;
			case DeckardMessageTypeEvent:
				typeString = @"Event";
				break;
			case DeckardMessageTypeException:
				typeString = @"Exception";
				break;
		}
		
		NSString *messageName = [self capitalizedString:message.name];
		messageName = [messageName stringByReplacingOccurrencesOfString:@" " withString:@""];
		messageName = [messageName stringByReplacingOccurrencesOfString:@"-" withString:@""];
		messageName = [messageName stringByReplacingOccurrencesOfString:@"/" withString:@""];
		messageName = [messageName stringByAppendingString:typeString];
		
		for (NSDictionary *item in payload) {
			NSArray *definedValues = item[@"definedValues"];
			NSString *itemName = [self capitalizedString:item[@"name"]];
			for (NSDictionary *defined in definedValues) {
				uint16_t type = [item[@"type"] shortValue];
				if (type==BRPayloadItemTypeByteArray || type==BRPayloadItemTypeShortArray || type==BRPayloadItemTypeString) continue;
				NSString *definedName = defined[@"name"];
				NSString *definedValue = defined[@"value"];
				[str appendFormat:@"#define BRDefinedValue_%@_%@_%@ %@\n", messageName, itemName, definedName, definedValue];
			}
		}
	}

	return str;
}

- (NSString *)constructorPrototypeForMessage:(DeckardMessage *)message
{
	NSMutableString *str = [NSMutableString string];
	
	NSString *typeString;
	NSString *shortTypeString;
	switch (message.type) {
		case DeckardMessageTypeCommand:
			typeString = @"Command";
			shortTypeString = @"Command";
			break;
		case DeckardMessageTypeSetting: // shouldn't happen
			break;
		case DeckardMessageTypeSettingRequest:
			typeString = @"SettingRequest";
			shortTypeString = @"Request";
			break;
		case DeckardMessageTypeSettingResult:
			typeString = @"SettingResult";
			shortTypeString = @"Result";
			break;
		case DeckardMessageTypeEvent:
			typeString = @"Event";
			shortTypeString = @"Event";
			break;
		case DeckardMessageTypeException:
			typeString = @"Exception";
			shortTypeString = @"Exception";
			break;
	}
	
	NSString *name = message.name;
	name = [self capitalizedString:message.name];
	name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"-" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"/" withString:@""];
	name = [name stringByAppendingString:typeString];
	
	if ([message.payloadIn count]) {
		NSDictionary *firstPayloadItem = message.payloadIn[0];
		
		[str appendFormat:@"+ (BR%@ *)%@With%@:(%@)%@",
		 name,
		 [self decapitalizedString:shortTypeString],
		 [self capitalizedString:firstPayloadItem[@"name"]],
		 [self objcTypeStringForBRType:[firstPayloadItem[@"type"] intValue]],
		 firstPayloadItem[@"name"]];
		
		for (int i=1; i<[message.payloadIn count]; i++) {
			NSDictionary *item = message.payloadIn[i];
			NSString *name = item[@"name"];
			BRPayloadItemType type = [item[@"type"] intValue];
			
			[str appendFormat:@" %@:(%@)%@",
			 item[@"name"],
			 [self objcTypeStringForBRType:type],
			 name];
		}
	}
	else {
		[str appendFormat:@"+ (BR%@ *)%@",
		 name,
		 [self decapitalizedString:shortTypeString]];
	}
	
	return str;
}

- (NSString *)propertiesBlockForPayload:(NSArray *)payload access:(PropertyAccess)access
{
	NSMutableString *propertiesStr = [NSMutableString string];
	
	if ([payload count]) {
		for (int i=0; i<[payload count]; i++) {
			NSDictionary *item = payload[i];
			NSString *name = item[@"name"];
			BRPayloadItemType type = [item[@"type"] intValue];
			
			NSString *memModifier = @"";
			if (access != PropertyAccessReadonly) {
				if (type == BRPayloadItemTypeByteArray || type == BRPayloadItemTypeShortArray || type == BRPayloadItemTypeString) {
					memModifier = @",strong";
				}
				else {
					memModifier = @",assign";
				}
			}
			
			NSString *accessModifier = @"";
			if (access == PropertyAccessReadonly) {
				accessModifier = @",readonly";
			}
			else if (access == PropertyAccessReadwrite) {
				accessModifier = @",readwrite";
			}
			
			[propertiesStr appendFormat:@"@property(nonatomic%@%@) %@ %@;\n",
			 memModifier,
			 accessModifier,
			 [self objcTypeStringForBRType:type],
			 name];
		}
	}
	return propertiesStr;
}

- (NSString *)constructorPropertiesInitBlockForMessage:(DeckardMessage *)message
{
	if ([message.payloadIn count]) {
		NSMutableString *str = [NSMutableString string];
		
		for (int i=0; i<[message.payloadIn count]; i++) {
			NSDictionary *item = message.payloadIn[i];
			NSString *name = item[@"name"];
			[str appendFormat:@"\tinstance.%@ = %@;\n",name,name];
		}
		
		return [str substringToIndex:str.length-1];
	}
	return @"";
}

- (NSString *)payloadDescriptorsBlockForMessage:(DeckardMessage *)message
{
	NSArray *payload = message.payloadIn;
	if (message.type == DeckardMessageTypeSettingResult || message.type == DeckardMessageTypeEvent || message.type == DeckardMessageTypeException) {
		payload = message.payloadOut;
	}
	
	if ([payload count]) {
		NSMutableString *str = [NSMutableString string];
		
		for (int i=0; i<[payload count]; i++) {
			NSDictionary *item = payload[i];
			NSString *name = item[@"name"];
			BRPayloadItemType type = [item[@"type"] intValue];
			[str appendFormat:@"\t\t\t@{@\"name\": @\"%@\", @\"type\": @(%@)},\n",
			 name,
			 [self stringForBRType:type]];
		}
		
		return [str substringToIndex:str.length-2];
	}
	return @"";
}

- (void)getDescriptionFormatBlock:(NSString **)format arguments:(NSString **)arguments forMessage:(DeckardMessage *)message
{
	NSArray *payload = message.payloadIn;
	if (message.type == DeckardMessageTypeSettingResult || message.type == DeckardMessageTypeEvent || message.type == DeckardMessageTypeException) {
		payload = message.payloadOut;
	}
	
	if ([payload count]) {
		NSMutableString *formatStr = [NSMutableString string];
		NSMutableString *argumentsStr = [NSMutableString string];
		
		for (int i=0; i<[payload count]; i++) {
			NSDictionary *item = payload[i];
			NSString *name = item[@"name"];
			BRPayloadItemType type = [item[@"type"] intValue];
			if (i==0) {
				[formatStr appendFormat:@" %@=%@",
				 name,
				 [self escapeSequenceForBRType:type]];
			}
			else {
				[formatStr appendFormat:@", %@=%@",
				 name,
				 [self escapeSequenceForBRType:type]];
			}
			
			if (type == BRPayloadItemTypeBoolean) {
				[argumentsStr appendFormat:@", (self.%@ ? @\"YES\" : @\"NO\")",
				 name];
			}
			else {
				[argumentsStr appendFormat:@", self.%@",
				 name];
			}
		}
		
		*format = formatStr;
		*arguments = argumentsStr;
	}
	else {
		*format = @"";
		*arguments = @"";
	}
}

- (NSString *)objcTypeStringForBRType:(BRPayloadItemType)brType
{
	switch (brType) {
		case BRPayloadItemTypeBoolean:
			return @"BOOL";
			break;
		case BRPayloadItemTypeByte:
			return @"uint8_t";
			break;
		case BRPayloadItemTypeShort:
			return @"int16_t";
			break;
		case BRPayloadItemTypeUnsignedShort:
			return @"uint16_t";
			break;
		case BRPayloadItemTypeLong:
			return @"int32_t";
			break;
		case BRPayloadItemTypeUnsignedLong:
			return @"uint32_t";
			break;
		case BRPayloadItemTypeInt:
			return @"int32_t";
			break;
		case BRPayloadItemTypeUnsignedInt:
			return @"uint32_t";
			break;
		case BRPayloadItemTypeByteArray:
			return @"NSData *";
			break;
		case BRPayloadItemTypeShortArray:
			return @"NSData *";
			break;
		case BRPayloadItemTypeString:
			return @"NSString *";
			break;
	}
}

- (NSString *)escapeSequenceForBRType:(BRPayloadItemType)brType
{
	switch (brType) {
		case BRPayloadItemTypeBoolean:
			return @"%@";
			break;
		case BRPayloadItemTypeByte:
			return @"0x%02X";
			break;
		case BRPayloadItemTypeShort:
		case BRPayloadItemTypeUnsignedShort:
			return @"0x%04X";
			break;
		case BRPayloadItemTypeLong:
		case BRPayloadItemTypeUnsignedLong:
		case BRPayloadItemTypeInt:
		case BRPayloadItemTypeUnsignedInt:
			return @"0x%08X";
			break;
		case BRPayloadItemTypeByteArray:
		case BRPayloadItemTypeShortArray:
		case BRPayloadItemTypeString:
			return @"%@";
			break;
	}
}

- (NSString *)stringForBRType:(BRPayloadItemType)brType
{
	switch (brType) {
		case BRPayloadItemTypeBoolean:
			return @"BRPayloadItemTypeBoolean";
			break;
		case BRPayloadItemTypeByte:
			return @"BRPayloadItemTypeByte";
			break;
		case BRPayloadItemTypeShort:
			return @"BRPayloadItemTypeShort";
			break;
		case BRPayloadItemTypeUnsignedShort:
			return @"BRPayloadItemTypeUnsignedShort";
			break;
		case BRPayloadItemTypeLong:
			return @"BRPayloadItemTypeLong";
			break;
		case BRPayloadItemTypeUnsignedLong:
			return @"BRPayloadItemTypeUnsignedLong";
			break;
		case BRPayloadItemTypeInt:
			return @"BRPayloadItemTypeInt";
			break;
		case BRPayloadItemTypeUnsignedInt:
			return @"BRPayloadItemTypeUnsignedInt";
			break;
		case BRPayloadItemTypeByteArray:
			return @"BRPayloadItemTypeByteArray";
			break;
		case BRPayloadItemTypeShortArray:
			return @"BRPayloadItemTypeShortArray";
			break;
		case BRPayloadItemTypeString:
			return @"BRPayloadItemTypeString";
			break;
	}
}

//- (NSString *)stringForDefinedTypeItemType:(BRPayloadItemType)brType
//{
//	switch (brType) {
//		case BRPayloadItemTypeBoolean:
//			return @"const BOOL";
//			break;
//		case BRPayloadItemTypeByte:
//			return @"const uint8_t";
//			break;
//		case BRPayloadItemTypeShort:
//			return @"const int16_t";
//			break;
//		case BRPayloadItemTypeUnsignedShort:
//			return @"const uint16_t";
//			break;
//		case BRPayloadItemTypeLong:
//			return @"const int32_t";
//			break;
//		case BRPayloadItemTypeUnsignedLong:
//			return @"const uint32_t";
//			break;
//		case BRPayloadItemTypeInt:
//			return @"const int32_t";
//			break;
//		case BRPayloadItemTypeUnsignedInt:
//			return @"const uint32_t";
//			break;
//			//		case BRPayloadItemTypeByteArray:
//			//			return @"NSData *";
//			//			break;
//			//		case BRPayloadItemTypeShortArray:
//			//			return @"NSData *";
//			//			break;
//		case BRPayloadItemTypeString:
//			return @"NSString *const";
//			break;
//		default:
//			return nil;
//	}
//}

- (void)populateTemplate:(NSMutableString *)template withString:(NSString *)fill forKey:(NSString *)key
{
	[template replaceOccurrencesOfString:[NSString stringWithFormat:@"<#%@#>",key]
							  withString:fill
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [template length])];
}

- (NSString *)capitalizedString:(NSString *)lower
{
	// unlike NSString's capitalizedString method, this method will not un-capitalize other characters
	NSMutableString *upper = [lower mutableCopy];
	BOOL lastWasSpace = YES;
	for (NSUInteger i=0; i<[upper length]; i++) {
		NSString *c = [lower substringWithRange:NSMakeRange(i, 1)];
		BOOL isSpace = [c isEqualToString:@" "];
		if (lastWasSpace && !isSpace) {
			[upper replaceCharactersInRange:NSMakeRange(i, 1) withString:[c uppercaseString]];
		}
		lastWasSpace = isSpace;
	}
	return upper;
}

- (NSString *)decapitalizedString:(NSString *)upper
{
	// unlike NSString's lowercaseString method, this method only operates on the first character of each word -- not all characters
	NSMutableString *lower = [upper mutableCopy];
	BOOL lastWasSpace = YES;
	for (NSUInteger i=0; i<[lower length]; i++) {
		NSString *c = [lower substringWithRange:NSMakeRange(i, 1)];
		BOOL isSpace = [c isEqualToString:@" "];
		if (lastWasSpace && !isSpace) {
			[lower replaceCharactersInRange:NSMakeRange(i, 1) withString:[c lowercaseString]];
		}
		lastWasSpace = isSpace;
	}
	return lower;
}

#pragma mark - NSXMLParserDelegate 

// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	NSLog(@"parserDidStartDocument:");
}

// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	NSLog(@"parserDidEndDocument:");
	
//	NSLog(@"commands: %@", self.commands);
//	NSLog(@"settings: %@", self.settings);
//	NSLog(@"events: %@", self.events);
//	NSLog(@"exceptions: %@", self.exceptions);
	
	self.parserState = DeckardParserStateIdle;
	self.parserSubstate = DeckardParserSubstateWaiting;
	
	[self generateCode];
}

// sent when the parser has completed parsing. If this is encountered, the parse was successful.

// DTD handling methods for various declarations.
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
	NSLog(@"parser:foundNotationDeclarationWithName: %@ publicID: %@ systemID: %@", name, publicID, systemID);
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
	NSLog(@"parser:foundUnparsedEntityDeclarationWithName: %@ publicID: %@ systemID: %@ notationName: %@", name, publicID, systemID, notationName);
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
	NSLog(@"parser:foundAttributeDeclarationWithName: %@ forElement: %@ type: %@ defaultValue: %@", attributeName, elementName, type, defaultValue);
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
	NSLog(@"parser:foundElementDeclarationWithName: %@ model: %@", elementName, model);
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
	NSLog(@"parser:foundInternalEntityDeclarationWithName: %@ value: %@", name, value);
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
	NSLog(@"parser:foundExternalEntityDeclarationWithName: %@ publicID: %@ systemID: %@", name, publicID, systemID);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	NSLog(@"parser:didStartElement: %@ namespaceURI: %@ qualifiedName: %@ attributes: %@", elementName, namespaceURI, qName, attributeDict);
	
	if ([elementName isEqualToString:@"section"]) {
		self.cSection = attributeDict[@"title"];
	}
	else if ([elementName isEqualToString:@"command"]) {
		self.parserState = DeckardParserStateParsingCommand;
		NSString *name = attributeDict[@"name"];
		unsigned identifier;
		NSScanner *scanner = [NSScanner scannerWithString:attributeDict[@"id"]];
		[scanner setScanLocation:2];
		[scanner scanHexInt:&identifier];
		self.cMessage = [DeckardMessage messageWithType:DeckardMessageTypeCommand name:name identifier:identifier section:self.cSection];
	}
	else if ([elementName isEqualToString:@"setting"]) {
		self.parserState = DeckardParserStateParsingSettingRequest;
		NSString *name = attributeDict[@"name"];
		unsigned identifier;
		NSScanner *scanner = [NSScanner scannerWithString:attributeDict[@"id"]];
		[scanner setScanLocation:2];
		[scanner scanHexInt:&identifier];
		self.cMessage = [DeckardMessage messageWithType:DeckardMessageTypeSetting name:name identifier:identifier section:self.cSection];
	}
	else if ([elementName isEqualToString:@"event"]) {
		self.parserState = DeckardParserStateParsingEvent;
		NSString *name = attributeDict[@"name"];
		unsigned identifier;
		NSScanner *scanner = [NSScanner scannerWithString:attributeDict[@"id"]];
		[scanner setScanLocation:2];
		[scanner scanHexInt:&identifier];
		self.cMessage = [DeckardMessage messageWithType:DeckardMessageTypeEvent name:name identifier:identifier section:self.cSection];
	}
	else if ([elementName isEqualToString:@"exception"]) {
		self.parserState = DeckardParserStateParsingException;
		NSString *name = attributeDict[@"name"];
		unsigned identifier;
		NSScanner *scanner = [NSScanner scannerWithString:attributeDict[@"id"]];
		[scanner setScanLocation:2];
		[scanner scanHexInt:&identifier];
		self.cMessage = [DeckardMessage messageWithType:DeckardMessageTypeException name:name identifier:identifier section:self.cSection];
	}
	else if ([elementName isEqualToString:@"payload_in"]) {
		self.parserSubstate = DeckardParserSubstateParsingPayloadIn;
	}
	else if ([elementName isEqualToString:@"payload_out"]) {
		self.parserSubstate = DeckardParserSubstateParsingPayloadOut;
	}
	else if ([elementName isEqualToString:@"item"]) {
		NSString *name = attributeDict[@"name"];
		
		name = [self capitalizedString:name];
		name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
		name = [name stringByReplacingOccurrencesOfString:@"-" withString:@""];
		name = [name stringByReplacingOccurrencesOfString:@"/" withString:@""];
		name = [name stringByReplacingOccurrencesOfString:@"_" withString:@""];
		name = [self decapitalizedString:name];
		// special cases -- c/obj-c keywords or interfering BRDevice property names
		if ([name isEqualToString:@"release"]) {
			name = @"_release";
		}
		else if ([name isEqualToString:@"data"]) {
			name = @"_data";
		}
		NSString *typeStr = attributeDict[@"type"];
		BRPayloadItemType type;
		
		if ([typeStr isEqualToString:@"BOOLEAN"]) type = BRPayloadItemTypeBoolean;
		else if ([typeStr isEqualToString:@"BYTE"]) type = BRPayloadItemTypeByte;
		else if ([typeStr isEqualToString:@"SHORT"]) type = BRPayloadItemTypeShort;
		else if ([typeStr isEqualToString:@"UNSIGNED_SHORT"]) type = BRPayloadItemTypeUnsignedShort;
		else if ([typeStr isEqualToString:@"LONG"]) type = BRPayloadItemTypeLong;
		else if ([typeStr isEqualToString:@"UNSIGNED_LONG"]) type = BRPayloadItemTypeUnsignedLong;
		else if ([typeStr isEqualToString:@"INT"]) type = BRPayloadItemTypeInt;
		else if ([typeStr isEqualToString:@"UNSIGNED_INT"]) type = BRPayloadItemTypeUnsignedInt;
		else if ([typeStr isEqualToString:@"BYTE_ARRAY"]) type = BRPayloadItemTypeByteArray;
		else if ([typeStr isEqualToString:@"SHORT_ARRAY"]) type = BRPayloadItemTypeShortArray;
		else if ([typeStr isEqualToString:@"STRING"]) type = BRPayloadItemTypeString;
		
		NSMutableDictionary *item = [@{@"name": name, @"type": @(type), @"definedValues": [NSMutableArray array]} mutableCopy];
		
		if (self.parserSubstate == DeckardParserSubstateParsingPayloadIn) {
			[self.cMessage.payloadIn addObject:item];
		}
		else if (self.parserSubstate == DeckardParserSubstateParsingPayloadOut) {
			[self.cMessage.payloadOut addObject:item];
		}
	}
	else if ([elementName isEqualToString:@"definedValue"]) {
		NSString *name = attributeDict[@"name"];
		NSString *value = attributeDict[@"value"];
		
		NSMutableDictionary *item;
		if (self.parserSubstate == DeckardParserSubstateParsingPayloadIn) {
			item = [self.cMessage.payloadIn lastObject];
		}
		else if (self.parserSubstate == DeckardParserSubstateParsingPayloadOut) {
			item = [self.cMessage.payloadIn lastObject];
		}

		NSMutableArray *definedValues = item[@"definedValues"];
		NSDictionary *definedValue = @{@"name": name, @"value": value};
		[definedValues addObject:definedValue];
	}
}

// sent when the parser finds an element start tag.
// In the case of the cvslog tag, the following is what the delegate receives:
//   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
// In the case of the radar tag, the following is what's passed in:
//    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
// If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	NSLog(@"parser:didEndElement: %@ namespaceURI: %@ qualifiedName: %@", elementName, namespaceURI, qName);
	
	if ([elementName isEqualToString:@"command"]) {
		[self.commands addObject:self.cMessage];
	}
	else if ([elementName isEqualToString:@"setting"]) {
		[self.settings addObject:self.cMessage];
	}
	else if ([elementName isEqualToString:@"event"]) {
		[self.events addObject:self.cMessage];
	}
	else if ([elementName isEqualToString:@"exception"]) {
		[self.exceptions addObject:self.cMessage];
	}
	else if ([elementName isEqualToString:@"payload_in"]) {
		self.parserSubstate = DeckardParserSubstateWaiting;
	}
	else if ([elementName isEqualToString:@"payload_out"]) {
		self.parserSubstate = DeckardParserSubstateWaiting;
	}
}

// sent when an end tag is encountered. The various parameters are supplied as above.

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
	NSLog(@"parser:didStartMappingPrefix: %@ toURI: %@", prefix, namespaceURI);
}

// sent when the parser first sees a namespace attribute.
// In the case of the cvslog tag, before the didStartElement:, you'd get one of these with prefix == @"" and namespaceURI == @"http://xml.apple.com/cvslog" (i.e. the default namespace)
// In the case of the radar:radar tag, before the didStartElement: you'd get one of these with prefix == @"radar" and namespaceURI == @"http://xml.apple.com/radar"

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
	NSLog(@"parser:didEndMappingPrefix: %@", prefix);
}

// sent when the namespace prefix in question goes out of scope.

//- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
//{
//	NSLog(@"parser:foundCharacters: %@", string);
//}

// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
	NSLog(@"parser:foundIgnorableWhitespace: %@", whitespaceString);
}

// The parser reports ignorable whitespace in the same way as characters it's found.

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
	NSLog(@"parser:foundProcessingInstructionWithTarget: %@ data: %@", target, data);
}

// The parser reports a processing instruction to you using this method. In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
	NSLog(@"parser:foundComment: %@", comment);
	
	if (!self.deckardVersion) {
		NSArray *components = [comment componentsSeparatedByString:@"Deckard Feature Registry v"];
		if ([components count]) {
			self.deckardVersion = [(NSString *)components[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
	}
}

// A comment (Text in a <!-- --> block) is reported to the delegate as a single string

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	NSLog(@"parser:foundCDATA: %@", CDATABlock);
}

// this reports a CDATA block to the delegate as an NSData.

//- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
//{
//	
//}

// this gives the delegate an opportunity to resolve an external entity itself and reply with the resulting data.

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"parser:parseErrorOccurred: %@", parseError);
}

// ...and this reports a fatal error to the delegate. The parser will stop parsing.

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
	NSLog(@"parser:validationErrorOccurred: %@", validationError);
}

// If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.

@end
