//
//  CommonDefinitions.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 5/14/13.
//  Copyright (c) 2013 plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_CommonDefinitions_h
#define bladerunner_ios_sdk_CommonDefinitions_h

#include "CommonTypes.h"

/*
    Packet types
*/

#define ADDRESS_BASED_PACKET_TYPE_MASK (byte)0x10
#define POINT_TO_POINT_PACKET_TYPE_MASK (byte)0x20


/*
    Message types
*/

// Host -> Device
#define HOST_BLADERUNNER_PROTOCOL_VERSION_MSG (byte)0x1
#define GET_SETTING_VALUE_MSG (byte)0x2
#define PERFORM_COMMAND_MSG (byte)0x5
#define CLOSE_SESSION_MSG (byte)0xB

// Device -> Host
#define SETTING_RESULT_SUCCESS_MSG (byte)0x3
#define SETTING_RESULT_EXCEPTION_MSG (byte)0x4
#define PERFORM_COMMAND_RESULT_SUCCESS_MSG (byte)0x6
#define PERFORM_COMMAND_RESULT_EXCEPTION_MSG (byte)0x7
#define DEVICE_BLADERUNNER_PROTOCOL_VERSION_MSG (byte)0x8
#define METADATA_MSG (byte)0x9
#define EVENT_OCCURRED_MSG (byte)0xA
#define PROTOCOL_VERSION_NEGOTIATION_REJECTION_MSG (byte)0xC 


/*
    Packet structure constants
*/

// Primitive sizes in bytes
#define BOOLEAN_BYTES 1
#define BYTE_BYTES 1
#define SHORT_BYTES 2
#define INT_BYTES 4
#define LONG_BYTES 8
#define ENUM_BYTES 2

// Complex type overhead sizes in unsigned chars
#define STRING_OVERHEAD_BYTES 2 
#define BYTE_ARRAY_OVERHEAD_BYTES 2 
#define SHORT_ARRAY_OVERHEAD_BYTES 2 

// Message lengths
#define PROTOCOL_VERSION_MESSAGE_LENGTH 3 
#define GET_SETTING_VALUE_MESSAGE_LENGTH 3 

// Other values
#define BOOLEAN_TRUE_AS_BYTE (byte)0x1
#define BOOLEAN_FALSE_AS_BYTE (byte)0x0 

// Field sizes, as a count of bytes.
#define PACKET_TYPE_LENGTH 1   // 4 bits
#define PACKET_LENGTH_LENGTH 2   // Actual 12 bits
#define MESSAGE_TYPE_LENGTH 1   // 4 bits
#define PACKET_ADDRESS_LENGTH 4   // Actual 7 tuples= 28 bits
#define PACKET_ADDRESS_TUPLES 7

// Indices start after the address field is read;   (Address is 12 bits after the first 4 bits)
// Indices to the packet address fields - 7 tuples
#define ADDRESS_TUPLE_1 0 // first 4 bits of the byte at index 0
#define ADDRESS_TUPLE_2 0
#define ADDRESS_TUPLE_3 1 // first 4 bits of the byte at index 1
#define ADDRESS_TUPLE_4 1 // last 4 bits of the byte at index 1
#define ADDRESS_TUPLE_5 2 // first 4 bits of the byte at index 2
#define ADDRESS_TUPLE_6 2
#define ADDRESS_TUPLE_7 3 // first 4 bits of the byte at index 3

// Indices into the packet relative to the packet type
#define MESSAGE_TYPE_INDEX 3   // last 4 bits of the unsigned char at index 3
#define MESSAGE_TYPE2_INDEX 0 //1st byte

//  Address field
#define PACKET_ADDRESS0 (int)0x0000//0x0312 
#define PACKET_ADDRESS1 (int)0x0000//0x5678 

// Byte values.
#define DELIMITER (byte)0x7E
#define ESCAPE (byte)0x7D
#define ESCAPE_XOR (byte)0x20

// Byte masks.
#define BYTE_MASK_0 (uint64_t)0xFF00000000000000L
#define BYTE_MASK_1 (uint64_t)0xFF000000000000L
#define BYTE_MASK_2 (uint64_t)0xFF0000000000L
#define BYTE_MASK_3 (uint64_t)0xFF00000000L
#define BYTE_MASK_4 (uint64_t)0xFF000000L
#define BYTE_MASK_5 (uint64_t)0xFF0000L
#define BYTE_MASK_6 (uint64_t)0xFF00L
#define BYTE_MASK_7 (uint64_t)0xFFL

// short
#define SHORT_MASK (uint16_t)0xFFFF
#define SHORT_BYTE_MASK_0 (uint16_t)0xFF00
#define SHORT_BYTE_MASK_1 (uint16_t)0xFF

// byte
#define BITS_MASK_0 (byte)0xF0
#define BITS_MASK_1 (byte)0x0F


/**
 * Defaults
 */
#define DEFAULT_MIN_PROTOCOL_VERSION 1
#define DEFAULT_MAX_PROTOCOL_VERSION 1
#define DEFAULT_EXCEPTION_ID -1

#endif
