//
//  SignatureDefinitions.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 7/9/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_SignatureDefinitions_h
#define bladerunner_ios_sdk_SignatureDefinitions_h

#include <vector>
#include <set>
#include "BRType.h"
#include "CommonTypes.h"
#include "SignatureDescription.h"

namespace bladerunner
{
    class SignatureDefinitions
    {
        
    public:
        /**
         * This method must be called before any access to exception signatures
         */
        static void declareAllSignatures();



        /**
         * Exceptions.
         */
        class Exceptions
        {
            
        public:
            static void declareAllSignatures();
            
            static std::set<SignatureDescription>& getSignatures()
            {
                return mExceptions;
            }
            
            static std::set<SignatureDescription>& getInputSignatures()
            {
                return mExceptions;
            }
            
            static std::set<SignatureDescription>& getOutputSignatures()
            {
                return mExceptions;
            }
            
            static void declare(int16_t id)
            {
                mExceptions.insert(SignatureDescription(id));
            }
            
            static void declare(int16_t id, const std::vector<BRType>& signature)
            {
                mExceptions.insert(SignatureDescription(id, signature));
            }
            
            static void declare(int16_t id, const std::vector<BRType>& inputSignature, const std::vector<BRType>& outputSignature)
            {
                mExceptions.insert(SignatureDescription(id, inputSignature, outputSignature));
            }
            
            static std::vector<int16_t>* getIDs(const std::set<SignatureDescription>& signatures)
            {
                return SignatureDefinitions::getIDs(signatures);
            }
            
            static std::vector<BRType>* getSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getSignature(signatures, id);
            }
            
            static std::vector<BRType>* getInputSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getInputSignature(signatures, id);
            }
            
            static std::vector<BRType>* getOutputSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getOutputSignature(signatures, id);
            }
            
            
            /**
             * A general-purpose exception used to signal that a numeric value is out of range.
             */
            static const uint16_t NUMBER_OUT_OF_RANGE_EXCEPTION = (uint16_t)0x0806;
            
            /**
             * Payload for NUMBER_OUT_OF_RANGE_EXCEPTION.
             */
            static std::vector<BRType>* NUMBER_OUT_OF_RANGE_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for NUMBER_OUT_OF_RANGE_EXCEPTION.
             */
            static std::vector<BRType>* NUMBER_OUT_OF_RANGE_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_LONG);
                res->push_back(BR_TYPE_LONG);
                return res;
            };
            
            /**
             * This exception is sent in response to a call to the Set feature lock command or
             Feature lock setting when not in Protected mode.
             */
            static const uint16_t NO_FEATURE_LOCK_WHEN_NOT_PROTECTED_EXCEPTION = (uint16_t)0x0F12;
            
            /**
             * Payload for NO_FEATURE_LOCK_WHEN_NOT_PROTECTED_EXCEPTION.
             */
            static std::vector<BRType>* NO_FEATURE_LOCK_WHEN_NOT_PROTECTED_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for NO_FEATURE_LOCK_WHEN_NOT_PROTECTED_EXCEPTION.
             */
            static std::vector<BRType>* NO_FEATURE_LOCK_WHEN_NOT_PROTECTED_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * The recipient sends this exception then the initiator requests the "Throw setting exception"
             setting or executes the "Throw command exception" command.
             */
            static const uint16_t SIMULATED_EXCEPTION_EXCEPTION = (uint16_t)0x0100;
            
            /**
             * Payload for SIMULATED_EXCEPTION_EXCEPTION.
             */
            static std::vector<BRType>* SIMULATED_EXCEPTION_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SIMULATED_EXCEPTION_EXCEPTION.
             */
            static std::vector<BRType>* SIMULATED_EXCEPTION_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * The device throws this exception when it's sent a command it doesn't implement.
             */
            static const uint16_t COMMAND_UNKNOWN_EXCEPTION = (uint16_t)0x0010;
            
            /**
             * Payload for COMMAND_UNKNOWN_EXCEPTION.
             */
            static std::vector<BRType>* COMMAND_UNKNOWN_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for COMMAND_UNKNOWN_EXCEPTION.
             */
            static std::vector<BRType>* COMMAND_UNKNOWN_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * The device throws this exception when it receives a packet containing an invalid
             length field, like zero.
             */
            static const uint16_t INVALID_PACKET_LENGTH_EXCEPTION = (uint16_t)0x0014;
            
            /**
             * Payload for INVALID_PACKET_LENGTH_EXCEPTION.
             */
            static std::vector<BRType>* INVALID_PACKET_LENGTH_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for INVALID_PACKET_LENGTH_EXCEPTION.
             */
            static std::vector<BRType>* INVALID_PACKET_LENGTH_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Thrown by the device in response to a request for the last tombstone (crash log),
             when there is none.
             There won't be one if the device has never panicked, or after it executes the
             command "Clear tombstone".
             */
            static const uint16_t NO_TOMBSTONE_EXCEPTION = (uint16_t)0x0A38;
            
            /**
             * Payload for NO_TOMBSTONE_EXCEPTION.
             */
            static std::vector<BRType>* NO_TOMBSTONE_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for NO_TOMBSTONE_EXCEPTION.
             */
            static std::vector<BRType>* NO_TOMBSTONE_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * The device throws this exception when it receives a packet containing an invalid
             message type field.
             */
            static const uint16_t INVALID_MESSAGE_TYPE_EXCEPTION = (uint16_t)0x0018;
            
            /**
             * Payload for INVALID_MESSAGE_TYPE_EXCEPTION.
             */
            static std::vector<BRType>* INVALID_MESSAGE_TYPE_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for INVALID_MESSAGE_TYPE_EXCEPTION.
             */
            static std::vector<BRType>* INVALID_MESSAGE_TYPE_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * The Genes GUID Command throws this exception if an initiator attempts to set the
             Genes GUID after one has been set.
             */
            static const uint16_t GENES_GUID_ALREADY_SET_EXCEPTION = (uint16_t)0x0A20;
            
            /**
             * Payload for GENES_GUID_ALREADY_SET_EXCEPTION.
             */
            static std::vector<BRType>* GENES_GUID_ALREADY_SET_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for GENES_GUID_ALREADY_SET_EXCEPTION.
             */
            static std::vector<BRType>* GENES_GUID_ALREADY_SET_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * The device throws this exception when it's asked for the value of a setting it
             doesn't implement.
             */
            static const uint16_t SETTING_UNKNOWN_EXCEPTION = (uint16_t)0x0012;
            
            /**
             * Payload for SETTING_UNKNOWN_EXCEPTION.
             */
            static std::vector<BRType>* SETTING_UNKNOWN_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SETTING_UNKNOWN_EXCEPTION.
             */
            static std::vector<BRType>* SETTING_UNKNOWN_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * The device throws this exception when it encounters the delimiter marking the start
             of a            
             new packet              
             while consuming another.
             */
            static const uint16_t MESSAGE_TOO_SHORT_EXCEPTION = (uint16_t)0x001A;
            
            /**
             * Payload for MESSAGE_TOO_SHORT_EXCEPTION.
             */
            static std::vector<BRType>* MESSAGE_TOO_SHORT_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for MESSAGE_TOO_SHORT_EXCEPTION.
             */
            static std::vector<BRType>* MESSAGE_TOO_SHORT_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * The device throws this exception when attempts to allocate memory, as for an
             incoming packet, and fails.
             */
            static const uint16_t MEMORY_ALLOCATION_FAILED_EXCEPTION = (uint16_t)0x001C;
            
            /**
             * Payload for MEMORY_ALLOCATION_FAILED_EXCEPTION.
             */
            static std::vector<BRType>* MEMORY_ALLOCATION_FAILED_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for MEMORY_ALLOCATION_FAILED_EXCEPTION.
             */
            static std::vector<BRType>* MEMORY_ALLOCATION_FAILED_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * The device throws this exception when it receives a packet containing an invalid
             packet type field.
             */
            static const uint16_t INVALID_PACKET_TYPE_EXCEPTION = (uint16_t)0x0016;
            
            /**
             * Payload for INVALID_PACKET_TYPE_EXCEPTION.
             */
            static std::vector<BRType>* INVALID_PACKET_TYPE_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for INVALID_PACKET_TYPE_EXCEPTION.
             */
            static std::vector<BRType>* INVALID_PACKET_TYPE_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * A general-purpose exception used to signal that a provided numeric value is illegal.
             */
            static const uint16_t ILLEGAL_VALUE_EXCEPTION = (uint16_t)0x0808;
            
            /**
             * Payload for ILLEGAL_VALUE_EXCEPTION.
             */
            static std::vector<BRType>* ILLEGAL_VALUE_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for ILLEGAL_VALUE_EXCEPTION.
             */
            static std::vector<BRType>* ILLEGAL_VALUE_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_LONG);
                return res;
            };
            
            /**
             * The Genes GUID Setting throws this exception if an initiator requests the Genes GUID before one
             is set.
             */
            static const uint16_t NO_GENES_GUID_EXCEPTION = (uint16_t)0x0A1E;
            
            /**
             * Payload for NO_GENES_GUID_EXCEPTION.
             */
            static std::vector<BRType>* NO_GENES_GUID_EXCEPTION_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for NO_GENES_GUID_EXCEPTION.
             */
            static std::vector<BRType>* NO_GENES_GUID_EXCEPTION_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
        private:
            static std::set<SignatureDescription> mExceptions;
        };
        
        
        
        
        /**
         * Commands.
         */
        class Commands
        {
            
        public:
            static void declareAllSignatures();
            
            static std::set<SignatureDescription>& getSignatures()
            {
                return mCommands;
            }
            
            static std::set<SignatureDescription>& getInputSignatures()
            {
                return mCommands;
            }
            
            static std::set<SignatureDescription>& getOutputSignatures()
            {
                return mCommands;
            }
            
            static void declare(int16_t id)
            {
                mCommands.insert(SignatureDescription(id));
            }
            
            static void declare(int16_t id, const std::vector<BRType>& signature)
            {
                mCommands.insert(SignatureDescription(id, signature));
            }
            
            static void declare(int16_t id, const std::vector<BRType>& inputSignature, const std::vector<BRType>& outputSignature)
            {
                mCommands.insert(SignatureDescription(id, inputSignature, outputSignature));
            }
            
            static std::vector<int16_t>* getIDs(const std::set<SignatureDescription>& signatures)
            {
                return SignatureDefinitions::getIDs(signatures);
            }
            
            static std::vector<BRType>* getSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getSignature(signatures, id);
            }
            
            static std::vector<BRType>* getInputSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getInputSignature(signatures, id);
            }
            
            static std::vector<BRType>* getOutputSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getOutputSignature(signatures, id);
            }
            
            
            
            /**
             * To be implemented only in Bluetooth devices.
             Put the Bluetooth-capable device into pairing mode (enable = true), or turn off pairing
             mode (enable = false).<br/>
             It is <b>not</b> an error to call this with enable = true when already
             in pairing mode. Similarly,
             it is acceptable to call this with enable = false when not in pairing mode. In either
             case there will be no effect.
             */
            static const uint16_t SET_PAIRING_MODE_COMMAND = (uint16_t)0x0A24;
            
            /**
             * Payload for SET_PAIRING_MODE_COMMAND.
             */
            static std::vector<BRType>* SET_PAIRING_MODE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for SET_PAIRING_MODE_COMMAND.
             */
            static std::vector<BRType>* SET_PAIRING_MODE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the device's Genes Globally Unique ID (GUID). If the device is designed not to
             contain a Genes GUID, it must not implement this Command.
             */
            static const uint16_t SET_GENES_GUID_COMMAND = (uint16_t)0x0A1E;
            
            /**
             * Payload for SET_GENES_GUID_COMMAND.
             */
            static std::vector<BRType>* SET_GENES_GUID_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * Payload for SET_GENES_GUID_COMMAND.
             */
            static std::vector<BRType>* SET_GENES_GUID_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * This command controls the headset hook switch's ability to dial calls.
             If enabled, the headset's hook switch cannot initiate outgoing calls when the
             headset is not worn.
             (The purpose is to eliminate pocket dialing. If the headset is in your pocket, the
             theory goes, it is not on your head and shouldn't be making a call.)
             */
            static const uint16_t CONFIGURE_AUTO_LOCK_CALL_BUTTON_COMMAND = (uint16_t)0x0210;
            
            /**
             * Payload for CONFIGURE_AUTO_LOCK_CALL_BUTTON_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_LOCK_CALL_BUTTON_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_AUTO_LOCK_CALL_BUTTON_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_LOCK_CALL_BUTTON_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Configure whether the device should answer incoming calls when the user dons the
             headset. If true, answer on don. If false, donning the headset during an incoming
             call will have no effect.
             */
            static const uint16_t AUTO_ANSWER_ON_DON_COMMAND = (uint16_t)0x0204;
            
            /**
             * Payload for AUTO_ANSWER_ON_DON_COMMAND.
             */
            static std::vector<BRType>* AUTO_ANSWER_ON_DON_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for AUTO_ANSWER_ON_DON_COMMAND.
             */
            static std::vector<BRType>* AUTO_ANSWER_ON_DON_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Command to request to simulate a user button action for one or more buttons simultaneously.
             */
            static const uint16_t BUTTON_SIMULATION_COMMAND = (uint16_t)0x1002;
            
            /**
             * Payload for BUTTON_SIMULATION_COMMAND.
             */
            static std::vector<BRType>* BUTTON_SIMULATION_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_SHORT_ARRAY);
                return res;
            };
            
            /**
             * Payload for BUTTON_SIMULATION_COMMAND.
             */
            static std::vector<BRType>* BUTTON_SIMULATION_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Clears the last panic (device crash) dump, a so-called "tombstone." It is not an
             error to call this when there is no tombstone.
             */
            static const uint16_t CLEAR_TOMBSTONE_COMMAND = (uint16_t)0x0A3A;
            
            /**
             * Payload for CLEAR_TOMBSTONE_COMMAND.
             */
            static std::vector<BRType>* CLEAR_TOMBSTONE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CLEAR_TOMBSTONE_COMMAND.
             */
            static std::vector<BRType>* CLEAR_TOMBSTONE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Dial a telephone number. Whitespace (ASCII space, tab, LF, CR) is ignored.  This is intended only
             for devices (like Bluetooth headsets) with the ability to tell the audio gateway (AG) to do so.
             */
            static const uint16_t MAKE_CALL_COMMAND = (uint16_t)0x0E0C;
            
            /**
             * Payload for MAKE_CALL_COMMAND.
             */
            static std::vector<BRType>* MAKE_CALL_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Payload for MAKE_CALL_COMMAND.
             */
            static std::vector<BRType>* MAKE_CALL_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For testing only: tell the recipient to say that a device has attached to one of its ports.
             */
            static const uint16_t SEND_DEVICE_ATTACHED_EVENT_COMMAND = (uint16_t)0x0104;
            
            /**
             * Payload for SEND_DEVICE_ATTACHED_EVENT_COMMAND.
             */
            static std::vector<BRType>* SEND_DEVICE_ATTACHED_EVENT_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Payload for SEND_DEVICE_ATTACHED_EVENT_COMMAND.
             */
            static std::vector<BRType>* SEND_DEVICE_ATTACHED_EVENT_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For testing only: tell the recipient to close the physical channel after some delay.
             */
            static const uint16_t CLOSE_PHYSICAL_CONNECTION_COMMAND = (uint16_t)0x0103;
            
            /**
             * Payload for CLOSE_PHYSICAL_CONNECTION_COMMAND.
             */
            static std::vector<BRType>* CLOSE_PHYSICAL_CONNECTION_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Payload for CLOSE_PHYSICAL_CONNECTION_COMMAND.
             */
            static std::vector<BRType>* CLOSE_PHYSICAL_CONNECTION_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * This command instructs the device to answer the current incoming (ringing) call.  This is intended only
             for devices (like Bluetooth headsets) with the ability to tell the audio gateway (AG) to do so.
             */
            static const uint16_t CALL_ANSWER_COMMAND = (uint16_t)0x0E04;
            
            /**
             * Payload for CALL_ANSWER_COMMAND.
             */
            static std::vector<BRType>* CALL_ANSWER_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CALL_ANSWER_COMMAND.
             */
            static std::vector<BRType>* CALL_ANSWER_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the ring tone volume for the given interface.
             */
            static const uint16_t SET_RINGTONE_VOLUME_COMMAND = (uint16_t)0x0F06;
            
            /**
             * Payload for SET_RINGTONE_VOLUME_COMMAND.
             */
            static std::vector<BRType>* SET_RINGTONE_VOLUME_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for SET_RINGTONE_VOLUME_COMMAND.
             */
            static std::vector<BRType>* SET_RINGTONE_VOLUME_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For unit testing: Set a boolean value for later retrieval and comparison.
             */
            static const uint16_t SET_ONE_BOOLEAN_COMMAND = (uint16_t)0x0050;
            
            /**
             * Payload for SET_ONE_BOOLEAN_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_BOOLEAN_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for SET_ONE_BOOLEAN_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_BOOLEAN_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Change the interval between mute reminders (voice prompt or tone) in the headset.
             The device will make a best effort to play the reminders on this schedule, though
             exact timing is not guaranteed.
             */
            static const uint16_t CONFIGURE_MUTE_REMINDER_TIMING_COMMAND = (uint16_t)0x0A20;
            
            /**
             * Payload for CONFIGURE_MUTE_REMINDER_TIMING_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_MUTE_REMINDER_TIMING_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_MUTE_REMINDER_TIMING_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_MUTE_REMINDER_TIMING_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the bandwidth (narrowband or wideband) for the given interface.
             */
            static const uint16_t SET_AUDIO_BANDWIDTH_COMMAND = (uint16_t)0x0F04;
            
            /**
             * Payload for SET_AUDIO_BANDWIDTH_COMMAND.
             */
            static std::vector<BRType>* SET_AUDIO_BANDWIDTH_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for SET_AUDIO_BANDWIDTH_COMMAND.
             */
            static std::vector<BRType>* SET_AUDIO_BANDWIDTH_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Command to verify the Text to Speech engine of a device. The test interface enable message
             must be enabled prior to this command being issued. The test interface is disabled by default so that
             production devices do not have this functionality enabled.
             */
            static const uint16_t TEXT_TO_SPEECH_TEST_COMMAND = (uint16_t)0x100C;
            
            /**
             * Payload for TEXT_TO_SPEECH_TEST_COMMAND.
             */
            static std::vector<BRType>* TEXT_TO_SPEECH_TEST_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Payload for TEXT_TO_SPEECH_TEST_COMMAND.
             */
            static std::vector<BRType>* TEXT_TO_SPEECH_TEST_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Turn A2DP on or off after the next device reboot.
             */
            static const uint16_t CONFIGURE_A2DP_COMMAND = (uint16_t)0x0A0C;
            
            /**
             * Payload for CONFIGURE_A2DP_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_A2DP_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_A2DP_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_A2DP_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For testing only: tell the recipient to throw a "Simulated exception" in response to this command.
             */
            static const uint16_t THROW_COMMAND_EXCEPTION_COMMAND = (uint16_t)0x0100;
            
            /**
             * Payload for THROW_COMMAND_EXCEPTION_COMMAND.
             */
            static std::vector<BRType>* THROW_COMMAND_EXCEPTION_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for THROW_COMMAND_EXCEPTION_COMMAND.
             */
            static std::vector<BRType>* THROW_COMMAND_EXCEPTION_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Sets the current Vocalyst information ("411") telephone number.
             */
            static const uint16_t VOCALYST_INFO_NUMBER_COMMAND = (uint16_t)0x0A16;
            
            /**
             * Payload for VOCALYST_INFO_NUMBER_COMMAND.
             */
            static std::vector<BRType>* VOCALYST_INFO_NUMBER_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Payload for VOCALYST_INFO_NUMBER_COMMAND.
             */
            static std::vector<BRType>* VOCALYST_INFO_NUMBER_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the device's password value.  If equal to the default password (a model-specific
             value), this will cause the device to exit Protected mode.  Otherwise this sets the password to the new
             value and causes the device to enter Protected mode.
             */
            static const uint16_t SET_PASSWORD_COMMAND = (uint16_t)0x0F16;
            
            /**
             * Payload for SET_PASSWORD_COMMAND.
             */
            static std::vector<BRType>* SET_PASSWORD_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Payload for SET_PASSWORD_COMMAND.
             */
            static std::vector<BRType>* SET_PASSWORD_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For unit testing: set a short value for later retrieval and comparison.
             */
            static const uint16_t SET_ONE_SHORT_COMMAND = (uint16_t)0x0052;
            
            /**
             * Payload for SET_ONE_SHORT_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_SHORT_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Payload for SET_ONE_SHORT_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_SHORT_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * This command controls the headset ability to provide don-doff events.
             If enabled, the headset will provide don events when the user dons the headset, and doff events when the headset is removed.
             This must be enabled to provide auto answer, anto pause, auto lock, auto transfer functionality.
             */
            static const uint16_t CONFIGURE_WEARING_SENSOR_ENABLED_COMMAND = (uint16_t)0x0216;
            
            /**
             * Payload for CONFIGURE_WEARING_SENSOR_ENABLED_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_WEARING_SENSOR_ENABLED_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_WEARING_SENSOR_ENABLED_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_WEARING_SENSOR_ENABLED_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the new anti-startle value, true or false.
             */
            static const uint16_t SET_ANTI_STARTLE_COMMAND = (uint16_t)0x0F0A;
            
            /**
             * Payload for SET_ANTI_STARTLE_COMMAND.
             */
            static std::vector<BRType>* SET_ANTI_STARTLE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for SET_ANTI_STARTLE_COMMAND.
             */
            static std::vector<BRType>* SET_ANTI_STARTLE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Command to enable and disable Voice Recognition messaging from a device. The test interface enable message
             must be enabled prior to this command being issued. The test interface is disabled by default so that
             production devices do not Voice recognition events.
             */
            static const uint16_t VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_COMMAND = (uint16_t)0x100A;
            
            /**
             * Payload for VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_COMMAND.
             */
            static std::vector<BRType>* VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_COMMAND.
             */
            static std::vector<BRType>* VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the new time-weighted average value.
             */
            static const uint16_t SET_TIME_WEIGHTED_AVERAGE_COMMAND = (uint16_t)0x0F0E;
            
            /**
             * Payload for SET_TIME_WEIGHTED_AVERAGE_COMMAND.
             */
            static std::vector<BRType>* SET_TIME_WEIGHTED_AVERAGE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for SET_TIME_WEIGHTED_AVERAGE_COMMAND.
             */
            static std::vector<BRType>* SET_TIME_WEIGHTED_AVERAGE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For unit testing: set a byte array value for later retrieval and comparison.
             */
            static const uint16_t SET_ONE_BYTE_ARRAY_COMMAND = (uint16_t)0x0057;
            
            /**
             * Payload for SET_ONE_BYTE_ARRAY_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_BYTE_ARRAY_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * Payload for SET_ONE_BYTE_ARRAY_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_BYTE_ARRAY_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Disable the specified commands.  It is not an error to supply the ID of a command
             that's not implemented on this device; the device will ignore it.<br/>
             
             It is legal to call this multiple times.  Successive calls replace the values supplied
             in earlier calls.<br/>
             
             It is not an error to disable the same ID multiple times in the same command.
             */
            static const uint16_t SET_FEATURE_LOCK_COMMAND = (uint16_t)0x0F12;
            
            /**
             * Payload for SET_FEATURE_LOCK_COMMAND.
             */
            static std::vector<BRType>* SET_FEATURE_LOCK_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT_ARRAY);
                return res;
            };
            
            /**
             * Payload for SET_FEATURE_LOCK_COMMAND.
             */
            static std::vector<BRType>* SET_FEATURE_LOCK_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the new time-weighted average period value.
             */
            static const uint16_t SET_TIME_WEIGHTED_AVERAGE_PERIOD_COMMAND = (uint16_t)0x0F10;
            
            /**
             * Payload for SET_TIME_WEIGHTED_AVERAGE_PERIOD_COMMAND.
             */
            static std::vector<BRType>* SET_TIME_WEIGHTED_AVERAGE_PERIOD_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for SET_TIME_WEIGHTED_AVERAGE_PERIOD_COMMAND.
             */
            static std::vector<BRType>* SET_TIME_WEIGHTED_AVERAGE_PERIOD_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Configure the second inbound call ring type.
             */
            static const uint16_t CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_COMMAND = (uint16_t)0x0404;
            
            /**
             * Payload for CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For unit testing: set a string value for later retrieval and comparison.
             */
            static const uint16_t SET_ONE_STRING_COMMAND = (uint16_t)0x0055;
            
            /**
             * Payload for SET_ONE_STRING_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_STRING_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Payload for SET_ONE_STRING_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_STRING_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Enable or disable the VR call reject / answer feature, which provides the user the
             ability to speak to the headset to answer or reject an incoming call.
             */
            static const uint16_t CONFIGURE_VR_CALL_REJECT_AND_ANSWER_COMMAND = (uint16_t)0x0A08;
            
            /**
             * Payload for CONFIGURE_VR_CALL_REJECT_AND_ANSWER_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_VR_CALL_REJECT_AND_ANSWER_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_VR_CALL_REJECT_AND_ANSWER_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_VR_CALL_REJECT_AND_ANSWER_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For testing only: tell the recipient to send a Command Success packet with a given length.
             */
            static const uint16_t SEND_COMMAND_SUCCESS_PACKET_WITH_LENGTH_COMMAND = (uint16_t)0x0101;
            
            /**
             * Payload for SEND_COMMAND_SUCCESS_PACKET_WITH_LENGTH_COMMAND.
             */
            static std::vector<BRType>* SEND_COMMAND_SUCCESS_PACKET_WITH_LENGTH_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Payload for SEND_COMMAND_SUCCESS_PACKET_WITH_LENGTH_COMMAND.
             */
            static std::vector<BRType>* SEND_COMMAND_SUCCESS_PACKET_WITH_LENGTH_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For unit testing: set two booleans for later retrieval and comparison.
             */
            static const uint16_t SET_TWO_BOOLEANS_COMMAND = (uint16_t)0x0060;
            
            /**
             * Payload for SET_TWO_BOOLEANS_COMMAND.
             */
            static std::vector<BRType>* SET_TWO_BOOLEANS_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for SET_TWO_BOOLEANS_COMMAND.
             */
            static std::vector<BRType>* SET_TWO_BOOLEANS_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * This command instructs the device to terminate (hang up) the current call.  This is intended only
             for devices (like Bluetooth headsets) with the ability to tell the audio gateway (AG) to do so.
             */
            static const uint16_t CALL_END_COMMAND = (uint16_t)0x0E06;
            
            /**
             * Payload for CALL_END_COMMAND.
             */
            static std::vector<BRType>* CALL_END_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CALL_END_COMMAND.
             */
            static std::vector<BRType>* CALL_END_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the interface to be the default for subsequent outgoing calls.
             */
            static const uint16_t SET_DEFAULT_OUTBOUND_INTERFACE_COMMAND = (uint16_t)0x0F08;
            
            /**
             * Payload for SET_DEFAULT_OUTBOUND_INTERFACE_COMMAND.
             */
            static std::vector<BRType>* SET_DEFAULT_OUTBOUND_INTERFACE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for SET_DEFAULT_OUTBOUND_INTERFACE_COMMAND.
             */
            static std::vector<BRType>* SET_DEFAULT_OUTBOUND_INTERFACE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the new G.616 value, true or false.
             */
            static const uint16_t SET_G616_COMMAND = (uint16_t)0x0F0C;
            
            /**
             * Payload for SET_G616_COMMAND.
             */
            static std::vector<BRType>* SET_G616_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for SET_G616_COMMAND.
             */
            static std::vector<BRType>* SET_G616_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Command to enable and disable raw button messaging from a device. The test interface enable message
             must be enabled prior to this command being issued. The test interface is disabled by default so that
             production devices do not provide raw button events.
             */
            static const uint16_t RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_COMMAND = (uint16_t)0x1007;
            
            /**
             * Payload for RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_COMMAND.
             */
            static std::vector<BRType>* RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_COMMAND.
             */
            static std::vector<BRType>* RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For testing only: tell the recipient to send a Command Exception packet with a given length.
             */
            static const uint16_t SEND_COMMAND_EXCEPTION_PACKET_WITH_LENGTH_COMMAND = (uint16_t)0x0102;
            
            /**
             * Payload for SEND_COMMAND_EXCEPTION_PACKET_WITH_LENGTH_COMMAND.
             */
            static std::vector<BRType>* SEND_COMMAND_EXCEPTION_PACKET_WITH_LENGTH_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Payload for SEND_COMMAND_EXCEPTION_PACKET_WITH_LENGTH_COMMAND.
             */
            static std::vector<BRType>* SEND_COMMAND_EXCEPTION_PACKET_WITH_LENGTH_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For unit testing: set a long value for later retrieval and comparison.
             */
            static const uint16_t SET_ONE_LONG_COMMAND = (uint16_t)0x0054;
            
            /**
             * Payload for SET_ONE_LONG_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_LONG_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_LONG);
                return res;
            };
            
            /**
             * Payload for SET_ONE_LONG_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_LONG_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Configure how (if) the device should play a tone on mute. (Some headsets may play a
             voice prompt instead or in addition.  This setting does not affect voice prompts.)
             */
            static const uint16_t CONFIGURE_MUTE_TONE_VOLUME_COMMAND = (uint16_t)0x0400;
            
            /**
             * Payload for CONFIGURE_MUTE_TONE_VOLUME_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_MUTE_TONE_VOLUME_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_MUTE_TONE_VOLUME_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_MUTE_TONE_VOLUME_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the ring tone for a particular interface.
             */
            static const uint16_t SET_RINGTONE_COMMAND = (uint16_t)0x0F02;
            
            /**
             * Payload for SET_RINGTONE_COMMAND.
             */
            static std::vector<BRType>* SET_RINGTONE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for SET_RINGTONE_COMMAND.
             */
            static std::vector<BRType>* SET_RINGTONE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Enable or disable the 'say "answer" or "ignore"' prompt for incoming calls,
             and turn on or off recognition of the voice commands that allow it.
             */
            static const uint16_t CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND_COMMAND = (uint16_t)0x0A2E;
            
            /**
             * Payload for CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Start generating "Periodic test event" events. The arguments are: the number of events to
             generate, the number of milliseconds to pause between events, and the length of the byte
             array to include in each generated event.
             */
            static const uint16_t START_GENERATING_EVENTS_COMMAND = (uint16_t)0x0001;
            
            /**
             * Payload for START_GENERATING_EVENTS_COMMAND.
             */
            static std::vector<BRType>* START_GENERATING_EVENTS_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_INT);
                res->push_back(BR_TYPE_INT);
                res->push_back(BR_TYPE_INT);
                return res;
            };
            
            /**
             * Payload for START_GENERATING_EVENTS_COMMAND.
             */
            static std::vector<BRType>* START_GENERATING_EVENTS_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For unit testing: set a short[] value for later retrieval and comparison.
             */
            static const uint16_t SET_ONE_SHORT_ARRAY_COMMAND = (uint16_t)0x0056;
            
            /**
             * Payload for SET_ONE_SHORT_ARRAY_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_SHORT_ARRAY_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT_ARRAY);
                return res;
            };
            
            /**
             * Payload for SET_ONE_SHORT_ARRAY_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_SHORT_ARRAY_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For unit testing: set two strings for later retrieval and comparison.
             */
            static const uint16_t SET_TWO_STRINGS_COMMAND = (uint16_t)0x0061;
            
            /**
             * Payload for SET_TWO_STRINGS_COMMAND.
             */
            static std::vector<BRType>* SET_TWO_STRINGS_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Payload for SET_TWO_STRINGS_COMMAND.
             */
            static std::vector<BRType>* SET_TWO_STRINGS_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the current Vocalyst telephone number.
             */
            static const uint16_t SET_VOCALYST_PHONE_NUMBER_COMMAND = (uint16_t)0x0A12;
            
            /**
             * Payload for SET_VOCALYST_PHONE_NUMBER_COMMAND.
             */
            static std::vector<BRType>* SET_VOCALYST_PHONE_NUMBER_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Payload for SET_VOCALYST_PHONE_NUMBER_COMMAND.
             */
            static std::vector<BRType>* SET_VOCALYST_PHONE_NUMBER_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Allows configuration of rssi and near far events.
             */
            static const uint16_t CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND = (uint16_t)0x0800;
            
            /**
             * Payload for CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Enable or disable the Lync Dial-tone feature (in USB adapter or base). When enabled
             (the default per Microsoft certification requirements), pressing the call button on             
             the headset while it is in an idle state will bring Lync to the foreground and initiate             
             a dial-tone.<br/>             
             This is configurable to allow users to disable it in the case they do not like the             
             default behavior - a lesson learned with our DECT devices.<br/>             
             This is a adapter/base setting and no special messaging is required from the             
             headset.
             */
            static const uint16_t CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_COMMAND = (uint16_t)0x0A32;
            
            /**
             * Payload for CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Command to enable and disable test messaging to and from a device.  The test interface enable message             
             must be sent to a device before any other test messages will be received as valid.  The test interface             
             is disabled by default so that production devices cannot be stimulated by test messages under normal             
             operation.
             */
            static const uint16_t TEST_INTERFACE_ENABLE_DISABLE_COMMAND = (uint16_t)0x1000;
            
            /**
             * Payload for TEST_INTERFACE_ENABLE_DISABLE_COMMAND.
             */
            static std::vector<BRType>* TEST_INTERFACE_ENABLE_DISABLE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for TEST_INTERFACE_ENABLE_DISABLE_COMMAND.
             */
            static std::vector<BRType>* TEST_INTERFACE_ENABLE_DISABLE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For unit testing: set a byte value for later retrieval and comparison.
             */
            static const uint16_t SET_ONE_BYTE_COMMAND = (uint16_t)0x0051;
            
            /**
             * Payload for SET_ONE_BYTE_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_BYTE_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for SET_ONE_BYTE_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_BYTE_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For unit testing: set an int value for later retrieval and comparison.
             */
            static const uint16_t SET_ONE_INT_COMMAND = (uint16_t)0x0053;
            
            /**
             * Payload for SET_ONE_INT_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_INT_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_INT);
                return res;
            };
            
            /**
             * Payload for SET_ONE_INT_COMMAND.
             */
            static std::vector<BRType>* SET_ONE_INT_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * This command selects the effect of doffing and donning the headset while streaming             
             audio to it. If enabled (autoPauseMedia = true), removing the headset will             
             automatically pause audio (by sending AVRCP Pause); donning the headset             
             will resume streaming audio (by sending AVRCP Play).
             */
            static const uint16_t CONFIGURE_AUTO_PAUSE_MEDIA_COMMAND = (uint16_t)0x0208;
            
            /**
             * Payload for CONFIGURE_AUTO_PAUSE_MEDIA_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_PAUSE_MEDIA_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_AUTO_PAUSE_MEDIA_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_PAUSE_MEDIA_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Command to request to simulate a device indirect event, such as don/doff, battery level change, etc.
             */
            static const uint16_t INDIRECT_EVENT_SIMULATION_COMMAND = (uint16_t)0x1004;
            
            /**
             * Payload for INDIRECT_EVENT_SIMULATION_COMMAND.
             */
            static std::vector<BRType>* INDIRECT_EVENT_SIMULATION_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * Payload for INDIRECT_EVENT_SIMULATION_COMMAND.
             */
            static std::vector<BRType>* INDIRECT_EVENT_SIMULATION_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * For testing only: tell the recipient to say that a device has detached from one of its ports.
             */
            static const uint16_t SEND_DEVICE_DETACHED_EVENT_COMMAND = (uint16_t)0x0105;
            
            /**
             * Payload for SEND_DEVICE_DETACHED_EVENT_COMMAND.
             */
            static std::vector<BRType>* SEND_DEVICE_DETACHED_EVENT_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Payload for SEND_DEVICE_DETACHED_EVENT_COMMAND.
             */
            static std::vector<BRType>* SEND_DEVICE_DETACHED_EVENT_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Redial the most recently-dialed telephone number. If the device has not dialed a             
             number             
             previously, this command is ignored.             
             This is intended only             
             for devices (like Bluetooth headsets) with the ability to tell the audio gateway (AG) to redial.
             */
            static const uint16_t REDIAL_COMMAND = (uint16_t)0x0E0E;
            
            /**
             * Payload for REDIAL_COMMAND.
             */
            static std::vector<BRType>* REDIAL_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for REDIAL_COMMAND.
             */
            static std::vector<BRType>* REDIAL_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Set the desired caller announcement configuration.
             */
            static const uint16_t CONFIGURE_CALLER_ANNOUNCEMENT_COMMAND = (uint16_t)0x0804;
            
            /**
             * Payload for CONFIGURE_CALLER_ANNOUNCEMENT_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_CALLER_ANNOUNCEMENT_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_CALLER_ANNOUNCEMENT_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_CALLER_ANNOUNCEMENT_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * 
             */
            static const uint16_t SET_AUDIO_TRANSMIT_GAIN_COMMAND = (uint16_t)0x0E08;
            
            /**
             * Payload for SET_AUDIO_TRANSMIT_GAIN_COMMAND.
             */
            static std::vector<BRType>* SET_AUDIO_TRANSMIT_GAIN_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for SET_AUDIO_TRANSMIT_GAIN_COMMAND.
             */
            static std::vector<BRType>* SET_AUDIO_TRANSMIT_GAIN_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Configure whether the device should switch the audio of an in-progress call based on             
             wearing state.<br/>             
             
             If enabled, then during an active call, route the audio to the headset upon the user             
             donning the headset;             
             route it to the phone upon the user doffing the headset.<br/>            
             
             If disabled, the headset will always open its audio (SCO) channel if the phone             
             requests it.
             */
            static const uint16_t CONFIGURE_AUTO_TRANSFER_CALL_COMMAND = (uint16_t)0x020C;
            
            /**
             * Payload for CONFIGURE_AUTO_TRANSFER_CALL_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_TRANSFER_CALL_COMMAND_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Payload for CONFIGURE_AUTO_TRANSFER_CALL_COMMAND.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_TRANSFER_CALL_COMMAND_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            
        private:
            static std::set<SignatureDescription> mCommands;
        };




        /**
         * Events.
         */
        class Events
        {
            
        public:
            static void declareAllSignatures();
            
            static std::set<SignatureDescription>& getSignatures()
            {
                return mEvents;
            }
            
            static std::set<SignatureDescription>& getInputSignatures()
            {
                return mEvents;
            }
            
            static std::set<SignatureDescription>& getOutputSignatures()
            {
                return mEvents;
            }
            
            static void declare(int16_t id)
            {
                mEvents.insert(SignatureDescription(id));
            }
            
            static void declare(int16_t id, const std::vector<BRType>& signature)
            {
                mEvents.insert(SignatureDescription(id, signature));
            }
            
            static void declare(int16_t id, const std::vector<BRType>& inputSignature, const std::vector<BRType>& outputSignature)
            {
                mEvents.insert(SignatureDescription(id, inputSignature, outputSignature));
            }
            
            static std::vector<int16_t>* getIDs(const std::set<SignatureDescription>& signatures)
            {
                return SignatureDefinitions::getIDs(signatures);
            }
            
            static std::vector<BRType>* getSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getSignature(signatures, id);
            }
            
            static std::vector<BRType>* getInputSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getInputSignature(signatures, id);
            }
            
            static std::vector<BRType>* getOutputSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getOutputSignature(signatures, id);
            }
            
            
            
            
            /**
             * Notification that the Wearing State Sensor configuration of the device has been changed.
             */
            static const uint16_t CONFIGURE_WEARING_SENSOR_ENABLED_EVENT = (uint16_t)0x0216;
            
            /**
             * Payload for CONFIGURE_WEARING_SENSOR_ENABLED_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_WEARING_SENSOR_ENABLED_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_WEARING_SENSOR_ENABLED_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_WEARING_SENSOR_ENABLED_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Event to notify a Host that the status of the Test Interface has been changed.
             Either enabled or disabled.
             */
            static const uint16_t TEST_INTERFACE_ENABLE_DISABLE_EVENT = (uint16_t)0x1000;
            
            /**
             * Payload for TEST_INTERFACE_ENABLE_DISABLE_EVENT.
             */
            static std::vector<BRType>* TEST_INTERFACE_ENABLE_DISABLE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for TEST_INTERFACE_ENABLE_DISABLE_EVENT.
             */
            static std::vector<BRType>* TEST_INTERFACE_ENABLE_DISABLE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Notification that the current Vocalyst information ("411") telephone number has changed.
             */
            static const uint16_t VOCALYST_INFO_NUMBER_EVENT = (uint16_t)0x0A16;
            
            /**
             * Payload for VOCALYST_INFO_NUMBER_EVENT.
             */
            static std::vector<BRType>* VOCALYST_INFO_NUMBER_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for VOCALYST_INFO_NUMBER_EVENT.
             */
            static std::vector<BRType>* VOCALYST_INFO_NUMBER_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * The physical button event, and the button ID.             
             The Short contains  the button pressed, and the type of button press event             
             The short is split into 2 bytes, with low byte denoting the button ID (eg hook-switch),             
             and high byte denoting the button press type (eg double button press)
             */
            static const uint16_t RAW_BUTTON_TEST_EVENT_EVENT = (uint16_t)0x1008;
            
            /**
             * Payload for RAW_BUTTON_TEST_EVENT_EVENT.
             */
            static std::vector<BRType>* RAW_BUTTON_TEST_EVENT_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for RAW_BUTTON_TEST_EVENT_EVENT.
             */
            static std::vector<BRType>* RAW_BUTTON_TEST_EVENT_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * For unit testing: Notification that a boolean value has been changed.
             */
            static const uint16_t SET_ONE_BOOLEAN_EVENT = (uint16_t)0x0050;
            
            /**
             * Payload for SET_ONE_BOOLEAN_EVENT.
             */
            static std::vector<BRType>* SET_ONE_BOOLEAN_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_ONE_BOOLEAN_EVENT.
             */
            static std::vector<BRType>* SET_ONE_BOOLEAN_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Notification that the Pairing Mode of the Device has changed.
             */
            static const uint16_t SET_PAIRING_MODE_EVENT = (uint16_t)0x0A24;
            
            /**
             * Payload for SET_PAIRING_MODE_EVENT.
             */
            static std::vector<BRType>* SET_PAIRING_MODE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_PAIRING_MODE_EVENT.
             */
            static std::vector<BRType>* SET_PAIRING_MODE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * For unit testing: Notification that a byte value has been changed.
             */
            static const uint16_t SET_ONE_BYTE_EVENT = (uint16_t)0x0051;
            
            /**
             * Payload for SET_ONE_BYTE_EVENT.
             */
            static std::vector<BRType>* SET_ONE_BYTE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_ONE_BYTE_EVENT.
             */
            static std::vector<BRType>* SET_ONE_BYTE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Notification that the ring tone volume for the given interface has been updated.
             */
            static const uint16_t SET_RINGTONE_VOLUME_EVENT = (uint16_t)0x0F06;
            
            /**
             * Payload for SET_RINGTONE_VOLUME_EVENT.
             */
            static std::vector<BRType>* SET_RINGTONE_VOLUME_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_RINGTONE_VOLUME_EVENT.
             */
            static std::vector<BRType>* SET_RINGTONE_VOLUME_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Notification that the Mute Tone Volume configuration of the device has been updated.
             */
            static const uint16_t CONFIGURE_MUTE_TONE_VOLUME_EVENT = (uint16_t)0x0400;
            
            /**
             * Payload for CONFIGURE_MUTE_TONE_VOLUME_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_MUTE_TONE_VOLUME_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_MUTE_TONE_VOLUME_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_MUTE_TONE_VOLUME_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * For unit testing: Notification that a short array has been changed.
             */
            static const uint16_t SET_ONE_SHORT_ARRAY_EVENT = (uint16_t)0x0056;
            
            /**
             * Payload for SET_ONE_SHORT_ARRAY_EVENT.
             */
            static std::vector<BRType>* SET_ONE_SHORT_ARRAY_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_ONE_SHORT_ARRAY_EVENT.
             */
            static std::vector<BRType>* SET_ONE_SHORT_ARRAY_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT_ARRAY);
                return res;
            };
            
            /**
             * In order to allow devices to learn about other devices' eligible connections,             
             we define two standard BladeRunner events,             
             "Connected device" and "Disconnected device".             
             <p>             
             Upon Device A being connected to a new BladeRunner-capable Device B, Device A must             
             send the "Connected device" event (this event) to all of its linked initiators.             
             <p>             
             Any device capable of initiating a session with another, or which will expose             
             internal emulated devices to other initiators, must implement both of the             
             "Connected device" and "Disconnected device" events.             
             <p>             
             Presence (absence) of these events in a recipient device's metadata implies its             
             ability (inability) to connect to and disconnect from other devices dynamically.             
             <p>             
             <i>This event is also specified in the BladeRunner 1.1 Specification.</i>
             */
            static const uint16_t CONNECTED_DEVICE_EVENT = (uint16_t)0x0C00;
            
            /**
             * Payload for CONNECTED_DEVICE_EVENT.
             */
            static std::vector<BRType>* CONNECTED_DEVICE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONNECTED_DEVICE_EVENT.
             */
            static std::vector<BRType>* CONNECTED_DEVICE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Notification that the Auto Transfer Call configuration of the device has been changed..
             */
            static const uint16_t CONFIGURE_AUTO_TRANSFER_CALL_EVENT = (uint16_t)0x020C;
            
            /**
             * Payload for CONFIGURE_AUTO_TRANSFER_CALL_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_TRANSFER_CALL_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_AUTO_TRANSFER_CALL_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_TRANSFER_CALL_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Notification that the Set Feature Lock feature has been updated.
             */
            static const uint16_t SET_FEATURE_LOCK_EVENT = (uint16_t)0x0F12;
            
            /**
             * Payload for SET_FEATURE_LOCK_EVENT.
             */
            static std::vector<BRType>* SET_FEATURE_LOCK_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_FEATURE_LOCK_EVENT.
             */
            static std::vector<BRType>* SET_FEATURE_LOCK_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT_ARRAY);
                return res;
            };
            
            /**
             * For unit testing: Notification that a two bool value has been changed.
             */
            static const uint16_t SET_TWO_BOOLEANS_EVENT = (uint16_t)0x0060;
            
            /**
             * Payload for SET_TWO_BOOLEANS_EVENT.
             */
            static std::vector<BRType>* SET_TWO_BOOLEANS_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_TWO_BOOLEANS_EVENT.
             */
            static std::vector<BRType>* SET_TWO_BOOLEANS_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * This Event reports the current audio status, as in the <a href="#Audio status">             
             Audio status</a> Setting.             
             <p>             
             The recipient device sends it to its initiator(s) whenever its audio status changes.            
             
             <p>If the codec is CVSD, G.726, G.722, or mSBC, the value of             
             the Speaker Gain field refers to SCO audio volume.  If the codec is A2DP,             
             Speaker Gain holds the A2DP streaming audio volume.  If codec is None, Speaker             
             Gain holds the previously-used SCO audio volume.</p>             
             
             <p><b>[Implementation note</b>: Some devices use only two             
             values for mic gain: zero, meaning muted, and not-zero, meaning not muted.]</p>
             */
            static const uint16_t AUDIO_STATUS_EVENT = (uint16_t)0x0E1E;
            
            /**
             * Payload for AUDIO_STATUS_EVENT.
             */
            static std::vector<BRType>* AUDIO_STATUS_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for AUDIO_STATUS_EVENT.
             */
            static std::vector<BRType>* AUDIO_STATUS_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Notification that the time-weighted average period value has been updated.
             */
            static const uint16_t SET_TIME_WEIGHTED_AVERAGE_PERIOD_EVENT = (uint16_t)0x0F10;
            
            /**
             * Payload for SET_TIME_WEIGHTED_AVERAGE_PERIOD_EVENT.
             */
            static std::vector<BRType>* SET_TIME_WEIGHTED_AVERAGE_PERIOD_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_TIME_WEIGHTED_AVERAGE_PERIOD_EVENT.
             */
            static std::vector<BRType>* SET_TIME_WEIGHTED_AVERAGE_PERIOD_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * For unit testing: Notification that a string value has been changed.
             */
            static const uint16_t SET_ONE_STRING_EVENT = (uint16_t)0x0055;
            
            /**
             * Payload for SET_ONE_STRING_EVENT.
             */
            static std::vector<BRType>* SET_ONE_STRING_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_ONE_STRING_EVENT.
             */
            static std::vector<BRType>* SET_ONE_STRING_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * For unit testing: Notification that an int value has been changed.
             */
            static const uint16_t SET_ONE_INT_EVENT = (uint16_t)0x0053;
            
            /**
             * Payload for SET_ONE_INT_EVENT.
             */
            static std::vector<BRType>* SET_ONE_INT_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_ONE_INT_EVENT.
             */
            static std::vector<BRType>* SET_ONE_INT_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_INT);
                return res;
            };
            
            /**
             * Indication that the Voice Recognition Test Events status has changed.
             */
            static const uint16_t VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_EVENT = (uint16_t)0x100A;
            
            /**
             * Payload for VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_EVENT.
             */
            static std::vector<BRType>* VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_EVENT.
             */
            static std::vector<BRType>* VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Notification that the Mute Reminder timing has been changed
             */
            static const uint16_t CONFIGURE_MUTE_REMINDER_TIMING_EVENT = (uint16_t)0x0A20;
            
            /**
             * Payload for CONFIGURE_MUTE_REMINDER_TIMING_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_MUTE_REMINDER_TIMING_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_MUTE_REMINDER_TIMING_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_MUTE_REMINDER_TIMING_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Notification that the Lync Dial Tone Setting of a device has been changed.
             */
            static const uint16_t CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_EVENT = (uint16_t)0x0A32;
            
            /**
             * Payload for CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Implemented only in devices (typically headsets) equipped with a battery.             
             The device sends this event whenever its battery status changes. (It is acceptable             
             for the device to             
             limit how often it sends this, for instance no more than once per minute.)             
             Includes the current battery state: battery level, minutes of talk time, and             
             charging ornot.
             */
            static const uint16_t BATTERY_STATUS_CHANGED_EVENT = (uint16_t)0x0A1C;
            
            /**
             * Payload for BATTERY_STATUS_CHANGED_EVENT.
             */
            static std::vector<BRType>* BATTERY_STATUS_CHANGED_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for BATTERY_STATUS_CHANGED_EVENT.
             */
            static std::vector<BRType>* BATTERY_STATUS_CHANGED_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_SHORT);
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * The wearing state (donned/doffed) has changed.
             */
            static const uint16_t WEARING_STATE_CHANGED_EVENT = (uint16_t)0x0200;
            
            /**
             * Payload for WEARING_STATE_CHANGED_EVENT.
             */
            static std::vector<BRType>* WEARING_STATE_CHANGED_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for WEARING_STATE_CHANGED_EVENT.
             */
            static std::vector<BRType>* WEARING_STATE_CHANGED_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Notification that the VR call reject / answer feature has been changed.
             */
            static const uint16_t CONFIGURE_VR_CALL_REJECT_AND_ANSWER_EVENT = (uint16_t)0x0A08;
            
            /**
             * Payload for CONFIGURE_VR_CALL_REJECT_AND_ANSWER_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_VR_CALL_REJECT_AND_ANSWER_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_VR_CALL_REJECT_AND_ANSWER_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_VR_CALL_REJECT_AND_ANSWER_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Notification that the Auto Pause Media configuration of the device has been changed.
             */
            static const uint16_t CONFIGURE_AUTO_PAUSE_MEDIA_EVENT = (uint16_t)0x0208;
            
            /**
             * Payload for CONFIGURE_AUTO_PAUSE_MEDIA_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_PAUSE_MEDIA_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_AUTO_PAUSE_MEDIA_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_PAUSE_MEDIA_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * For unit testing: Notification that a long value has been changed.
             */
            static const uint16_t SET_ONE_LONG_EVENT = (uint16_t)0x0054;
            
            /**
             * Payload for SET_ONE_LONG_EVENT.
             */
            static std::vector<BRType>* SET_ONE_LONG_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_ONE_LONG_EVENT.
             */
            static std::vector<BRType>* SET_ONE_LONG_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_LONG);
                return res;
            };
            
            /**
             * The headset sends this when the user presses the custom button (which may actually             
             be a special dedicated press or sequence of some existing button(s)).  The payload             
             field is reserved for future use.
             */
            static const uint16_t CUSTOM_BUTTON_EVENT = (uint16_t)0x0802;
            
            /**
             * Payload for CUSTOM_BUTTON_EVENT.
             */
            static std::vector<BRType>* CUSTOM_BUTTON_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CUSTOM_BUTTON_EVENT.
             */
            static std::vector<BRType>* CUSTOM_BUTTON_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Notification that the caller announcement configuration has changed.
             */
            static const uint16_t CONFIGURE_CALLER_ANNOUNCEMENT_EVENT = (uint16_t)0x0804;
            
            /**
             * Payload for CONFIGURE_CALLER_ANNOUNCEMENT_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_CALLER_ANNOUNCEMENT_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_CALLER_ANNOUNCEMENT_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_CALLER_ANNOUNCEMENT_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * The device sends this event upon request.             
             See the "Send signal strength events" command.
             */
            static const uint16_t SIGNAL_STRENGTH_EVENT = (uint16_t)0x0806;
            
            /**
             * Payload for SIGNAL_STRENGTH_EVENT.
             */
            static std::vector<BRType>* SIGNAL_STRENGTH_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SIGNAL_STRENGTH_EVENT.
             */
            static std::vector<BRType>* SIGNAL_STRENGTH_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Notification that the time-weighted average value has been updated.
             */
            static const uint16_t SET_TIME_WEIGHTED_AVERAGE_EVENT = (uint16_t)0x0F0E;
            
            /**
             * Payload for SET_TIME_WEIGHTED_AVERAGE_EVENT.
             */
            static std::vector<BRType>* SET_TIME_WEIGHTED_AVERAGE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_TIME_WEIGHTED_AVERAGE_EVENT.
             */
            static std::vector<BRType>* SET_TIME_WEIGHTED_AVERAGE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * In order to allow devices to learn about other devices' eligible connections,             
             we define two standard BladeRunner events, "Connected device" and "Disconnected device".             
             <p>             
             When Device B disconnects from Device A, both devices should tell all of their             
             remaining linked BladeRunner initiators using the "Disconnected device" event             
             (this event), with the "address" value set to the (former) port number of the             
             disconnected port.             
             <p>             
             Any device capable of initiating a session with another, or which will expose             
             internal emulated devices to other initiators, must implement both events.             
             <p>             
             Presence (absence) of these events in a recipient device's metadata implies its             
             ability (inability) to connect to and disconnect from other devices dynamically.             
             <p>             
             <i>This event is also specified in the BladeRunner 1.1 Specification.</i>
             */
            static const uint16_t DISCONNECTED_DEVICE_EVENT = (uint16_t)0x0C02;
            
            /**
             * Payload for DISCONNECTED_DEVICE_EVENT.
             */
            static std::vector<BRType>* DISCONNECTED_DEVICE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for DISCONNECTED_DEVICE_EVENT.
             */
            static std::vector<BRType>* DISCONNECTED_DEVICE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Notification that the A2DP configuration has changed.
             */
            static const uint16_t CONFIGURE_A2DP_EVENT = (uint16_t)0x0A0C;
            
            /**
             * Payload for CONFIGURE_A2DP_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_A2DP_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_A2DP_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_A2DP_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Implemented only in devices equipped with a battery.             
             The device (typically a headset) sends this event when it "speaks" a low battery voice prompt - or would             
             speak it,             
             if the prompt is disabled. The purpose is to allow the application that receives             
             the event to display an on-screen notice that's synchronized with the in-ear             
             warning.
             */
            static const uint16_t LOW_BATTERY_VOICE_PROMPT_EVENT = (uint16_t)0x0A28;
            
            /**
             * Payload for LOW_BATTERY_VOICE_PROMPT_EVENT.
             */
            static std::vector<BRType>* LOW_BATTERY_VOICE_PROMPT_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for LOW_BATTERY_VOICE_PROMPT_EVENT.
             */
            static std::vector<BRType>* LOW_BATTERY_VOICE_PROMPT_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Indication that the Raw Button Test Mode status has changed.
             */
            static const uint16_t RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_EVENT = (uint16_t)0x1007;
            
            /**
             * Payload for RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_EVENT.
             */
            static std::vector<BRType>* RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_EVENT.
             */
            static std::vector<BRType>* RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * For unit testing: Notification that a byte array has been changed.
             */
            static const uint16_t SET_ONE_BYTE_ARRAY_EVENT = (uint16_t)0x0057;
            
            /**
             * Payload for SET_ONE_BYTE_ARRAY_EVENT.
             */
            static std::vector<BRType>* SET_ONE_BYTE_ARRAY_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_ONE_BYTE_ARRAY_EVENT.
             */
            static std::vector<BRType>* SET_ONE_BYTE_ARRAY_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * Event issued by the device when its telephone call status changes. The "Call status"             
             setting will always reflect the current call status.
             */
            static const uint16_t CALL_STATUS_CHANGE_EVENT = (uint16_t)0x0E00;
            
            /**
             * Payload for CALL_STATUS_CHANGE_EVENT.
             */
            static std::vector<BRType>* CALL_STATUS_CHANGE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CALL_STATUS_CHANGE_EVENT.
             */
            static std::vector<BRType>* CALL_STATUS_CHANGE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Notification that the spoken answer/ignore recognition feature status has changed
             */
            static const uint16_t CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND_EVENT = (uint16_t)0x0A2E;
            
            /**
             * Payload for CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Notification that the Auto Lock Button configuration of the device has been changed.
             */
            static const uint16_t CONFIGURE_AUTO_LOCK_CALL_BUTTON_EVENT = (uint16_t)0x0210;
            
            /**
             * Payload for CONFIGURE_AUTO_LOCK_CALL_BUTTON_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_LOCK_CALL_BUTTON_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_AUTO_LOCK_CALL_BUTTON_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_AUTO_LOCK_CALL_BUTTON_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Notification that the anti-startle value has been updated.
             */
            static const uint16_t SET_ANTI_STARTLE_EVENT = (uint16_t)0x0F0A;
            
            /**
             * Payload for SET_ANTI_STARTLE_EVENT.
             */
            static std::vector<BRType>* SET_ANTI_STARTLE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_ANTI_STARTLE_EVENT.
             */
            static std::vector<BRType>* SET_ANTI_STARTLE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * The voice recognition event, and the VR event ID.             
             The Short contains  the VR event event ID
             */
            static const uint16_t VOICE_RECOGNITION_TEST_EVENT_EVENT = (uint16_t)0x100B;
            
            /**
             * Payload for VOICE_RECOGNITION_TEST_EVENT_EVENT.
             */
            static std::vector<BRType>* VOICE_RECOGNITION_TEST_EVENT_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for VOICE_RECOGNITION_TEST_EVENT_EVENT.
             */
            static std::vector<BRType>* VOICE_RECOGNITION_TEST_EVENT_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Set the bandwidth (narrowband or wideband) for the given interface.
             */
            static const uint16_t SET_AUDIO_BANDWIDTH_EVENT = (uint16_t)0x0F04;
            
            /**
             * Payload for SET_AUDIO_BANDWIDTH_EVENT.
             */
            static std::vector<BRType>* SET_AUDIO_BANDWIDTH_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_AUDIO_BANDWIDTH_EVENT.
             */
            static std::vector<BRType>* SET_AUDIO_BANDWIDTH_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * A test event generated by the "Start generating events" command. It contains             
             the time the event was generated (as the number of milliseconds since 00:00:00             
             UTC 1/1/1970, though this is not strictly required; any increasing LONG value will             
             suffice) and a byte array of test data of unspecified content.
             */
            static const uint16_t PERIODIC_TEST_EVENT_EVENT = (uint16_t)0x0004;
            
            /**
             * Payload for PERIODIC_TEST_EVENT_EVENT.
             */
            static std::vector<BRType>* PERIODIC_TEST_EVENT_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for PERIODIC_TEST_EVENT_EVENT.
             */
            static std::vector<BRType>* PERIODIC_TEST_EVENT_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_LONG);
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * Notification that the Answer on Don configuration of the device has been changed.
             */
            static const uint16_t AUTO_ANSWER_ON_DON_EVENT = (uint16_t)0x0204;
            
            /**
             * Payload for AUTO_ANSWER_ON_DON_EVENT.
             */
            static std::vector<BRType>* AUTO_ANSWER_ON_DON_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for AUTO_ANSWER_ON_DON_EVENT.
             */
            static std::vector<BRType>* AUTO_ANSWER_ON_DON_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * For unit testing: Notification that a two string value has been changed.
             */
            static const uint16_t SET_TWO_STRINGS_EVENT = (uint16_t)0x0061;
            
            /**
             * Payload for SET_TWO_STRINGS_EVENT.
             */
            static std::vector<BRType>* SET_TWO_STRINGS_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_TWO_STRINGS_EVENT.
             */
            static std::vector<BRType>* SET_TWO_STRINGS_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Notification the the Second Inbound Call ring type configuration has changed.
             */
            static const uint16_t CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_EVENT = (uint16_t)0x0404;
            
            /**
             * Payload for CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Notification that the G.616 value has been updated.
             */
            static const uint16_t SET_G616_EVENT = (uint16_t)0x0F0C;
            
            /**
             * Payload for SET_G616_EVENT.
             */
            static std::vector<BRType>* SET_G616_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_G616_EVENT.
             */
            static std::vector<BRType>* SET_G616_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Notification that the default interface for subsequent outgoing calls has been changed.
             */
            static const uint16_t SET_DEFAULT_OUTBOUND_INTERFACE_EVENT = (uint16_t)0x0F08;
            
            /**
             * Payload for SET_DEFAULT_OUTBOUND_INTERFACE_EVENT.
             */
            static std::vector<BRType>* SET_DEFAULT_OUTBOUND_INTERFACE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_DEFAULT_OUTBOUND_INTERFACE_EVENT.
             */
            static std::vector<BRType>* SET_DEFAULT_OUTBOUND_INTERFACE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Notification that the ring tone for a particular interface has been updated.
             */
            static const uint16_t SET_RINGTONE_EVENT = (uint16_t)0x0F02;
            
            /**
             * Payload for SET_RINGTONE_EVENT.
             */
            static std::vector<BRType>* SET_RINGTONE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_RINGTONE_EVENT.
             */
            static std::vector<BRType>* SET_RINGTONE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * For unit testing: Notification that a short value has been changed.
             */
            static const uint16_t SET_ONE_SHORT_EVENT = (uint16_t)0x0052;
            
            /**
             * Payload for SET_ONE_SHORT_EVENT.
             */
            static std::vector<BRType>* SET_ONE_SHORT_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_ONE_SHORT_EVENT.
             */
            static std::vector<BRType>* SET_ONE_SHORT_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Notification that the current Vocalyst telephone number has been changed.
             */
            static const uint16_t SET_VOCALYST_PHONE_NUMBER_EVENT = (uint16_t)0x0A12;
            
            /**
             * Payload for SET_VOCALYST_PHONE_NUMBER_EVENT.
             */
            static std::vector<BRType>* SET_VOCALYST_PHONE_NUMBER_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_VOCALYST_PHONE_NUMBER_EVENT.
             */
            static std::vector<BRType>* SET_VOCALYST_PHONE_NUMBER_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Notification that the Tombstone has been cleared.
             */
            static const uint16_t CLEAR_TOMBSTONE_EVENT = (uint16_t)0x0A3A;
            
            /**
             * Payload for CLEAR_TOMBSTONE_EVENT.
             */
            static std::vector<BRType>* CLEAR_TOMBSTONE_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CLEAR_TOMBSTONE_EVENT.
             */
            static std::vector<BRType>* CLEAR_TOMBSTONE_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Notification that the Genes Globally Unique ID (GUID) has been updated.
             */
            static const uint16_t SET_GENES_GUID_EVENT = (uint16_t)0x0A1E;
            
            /**
             * Payload for SET_GENES_GUID_EVENT.
             */
            static std::vector<BRType>* SET_GENES_GUID_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SET_GENES_GUID_EVENT.
             */
            static std::vector<BRType>* SET_GENES_GUID_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * Notification that the Signal Strength Monitoring configuration has changed.
             */
            static const uint16_t CONFIGURE_SIGNAL_STRENGTH_EVENT_EVENT = (uint16_t)0x0800;
            
            /**
             * Payload for SET_GENES_GUID_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_SIGNAL_STRENGTH_EVENT_EVENT_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CONFIGURE_SIGNAL_STRENGTH_EVENT_EVENT.
             */
            static std::vector<BRType>* CONFIGURE_SIGNAL_STRENGTH_EVENT_EVENT_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            
        private:
            static std::set<SignatureDescription> mEvents;
        };




        /**
         * Settings.
         */
        class Settings
        {
            
        public:
            static void declareAllSignatures();
            
            static std::set<SignatureDescription>& getSignatures()
            {
                return mSettings;
            }
            
            static std::set<SignatureDescription>& getInputSignatures()
            {
                return mSettings;
            }
            
            static std::set<SignatureDescription>& getOutputSignatures()
            {
                return mSettings;
            }
            
            static void declare(int16_t id)
            {
                mSettings.insert(SignatureDescription(id));
            }
            
            static void declare(int16_t id, const std::vector<BRType>& signature)
            {
                mSettings.insert(SignatureDescription(id, signature));
            }
            
            static void declare(int16_t id, const std::vector<BRType>& inputSignature, const std::vector<BRType>& outputSignature)
            {
                mSettings.insert(SignatureDescription(id, inputSignature, outputSignature));
            }
            
            static std::vector<int16_t>* getIDs(const std::set<SignatureDescription>& signatures)
            {
                return SignatureDefinitions::getIDs(signatures);
            }
            
            static std::vector<BRType>* getSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getSignature(signatures, id);
            }
            
            static std::vector<BRType>* getInputSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getInputSignature(signatures, id);
            }
            
            static std::vector<BRType>* getOutputSignature(std::set<SignatureDescription>& signatures, int16_t id)
            {
                return SignatureDefinitions::getOutputSignature(signatures, id);
            }
            
            
            
            
            
            /**
             * Returns the dump of the last panic (device crash), in a device-dependent format. The app
             that receives must use the device type (and possibly the firmware version) to decode it.
             Different devices have different capabilities and requirements, so we cannot
             define a cross-platform structure for this payload.<br/>
             Throws a "no tombstone" exception if the device has never created a panic tombstone, or has not created
             one since the last call to Clear tombstone.
             */
            static const uint16_t TOMBSTONE_SETTING = (uint16_t)0x0A38;
            
            /**
             * Payload for TOMBSTONE_SETTING.
             */
            static std::vector<BRType>* TOMBSTONE_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for TOMBSTONE_SETTING.
             */
            static std::vector<BRType>* TOMBSTONE_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * For unit testing: fetch the two boolean values set by the "Set two booleans"
             command.
             */
            static const uint16_t TWO_BOOLEANS_SETTING = (uint16_t)0x0060;
            
            /**
             * Payload for TWO_BOOLEANS_SETTING.
             */
            static std::vector<BRType>* TWO_BOOLEANS_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for TWO_BOOLEANS_SETTING.
             */
            static std::vector<BRType>* TWO_BOOLEANS_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Return the current caller announcement configuration.
             */
            static const uint16_t CALLER_ANNOUNCEMENT_SETTING = (uint16_t)0x0804;
            
            /**
             * Payload for CALLER_ANNOUNCEMENT_SETTING.
             */
            static std::vector<BRType>* CALLER_ANNOUNCEMENT_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CALLER_ANNOUNCEMENT_SETTING.
             */
            static std::vector<BRType>* CALLER_ANNOUNCEMENT_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Query for the IDs specifying the buttons that are supported to be simulated.
             */
            static const uint16_t BUTTON_SIMULATION_CAPABILITIES_SETTING = (uint16_t)0x1001;
            
            /**
             * Payload for BUTTON_SIMULATION_CAPABILITIES_SETTING.
             */
            static std::vector<BRType>* BUTTON_SIMULATION_CAPABILITIES_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for BUTTON_SIMULATION_CAPABILITIES_SETTING.
             */
            static std::vector<BRType>* BUTTON_SIMULATION_CAPABILITIES_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT_ARRAY);
                return res;
            };
            
            /**
             * Returns the current Vocalyst information ("411") telephone number.
             */
            static const uint16_t VOCALYST_INFO_NUMBER_SETTING = (uint16_t)0x0A14;
            
            /**
             * Payload for VOCALYST_INFO_NUMBER_SETTING.
             */
            static std::vector<BRType>* VOCALYST_INFO_NUMBER_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for VOCALYST_INFO_NUMBER_SETTING.
             */
            static std::vector<BRType>* VOCALYST_INFO_NUMBER_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Get the second inbound call ring type.
             */
            static const uint16_t GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING = (uint16_t)0x0406;
            
            /**
             * Payload for GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING.
             */
            static std::vector<BRType>* GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING.
             */
            static std::vector<BRType>* GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Returns whether the device should switch the audio of an in-progress call based on
             wearing state.
             See the "Configure auto-transfer call" command for more details.
             */
            static const uint16_t AUTO_TRANSFER_CALL_SETTING = (uint16_t)0x020E;
            
            /**
             * Payload for AUTO_TRANSFER_CALL_SETTING.
             */
            static std::vector<BRType>* AUTO_TRANSFER_CALL_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for AUTO_TRANSFER_CALL_SETTING.
             */
            static std::vector<BRType>* AUTO_TRANSFER_CALL_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Returns the current signal strength.
             */
            static const uint16_t CURRENT_SIGNAL_STRENGTH_SETTING = (uint16_t)0x0800;
            
            /**
             * Payload for CURRENT_SIGNAL_STRENGTH_SETTING.
             */
            static std::vector<BRType>* CURRENT_SIGNAL_STRENGTH_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for CURRENT_SIGNAL_STRENGTH_SETTING.
             */
            static std::vector<BRType>* CURRENT_SIGNAL_STRENGTH_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Query for the IDs specifying the indirect events that are supported to be simulated.
             */
            static const uint16_t INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING = (uint16_t)0x1003;
            
            /**
             * Payload for INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING.
             */
            static std::vector<BRType>* INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING.
             */
            static std::vector<BRType>* INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT_ARRAY);
                return res;
            };
            
            /**
             * For testing only: tell the recipient to throw a "Simulated exception" in
             response to this Setting.
             */
            static const uint16_t THROW_SETTING_EXCEPTION_SETTING = (uint16_t)0x0100;
            
            /**
             * Payload for THROW_SETTING_EXCEPTION_SETTING.
             */
            static std::vector<BRType>* THROW_SETTING_EXCEPTION_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for THROW_SETTING_EXCEPTION_SETTING.
             */
            static std::vector<BRType>* THROW_SETTING_EXCEPTION_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Query for the configuration item specified in the Setting request.
             */
            static const uint16_t SINGLE_NVRAM_CONFIGURATION_READ_SETTING = (uint16_t)0x1009;
            
            /**
             * Payload for SINGLE_NVRAM_CONFIGURATION_READ_SETTING.
             */
            static std::vector<BRType>* SINGLE_NVRAM_CONFIGURATION_READ_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_LONG);
                return res;
            };
            
            /**
             * Payload for SINGLE_NVRAM_CONFIGURATION_READ_SETTING.
             */
            static std::vector<BRType>* SINGLE_NVRAM_CONFIGURATION_READ_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * If enabled (autoPauseMedia = true), removing the headset will
             automatically pause audio (by sending AVRCP Pause); donning the headset
             will resume streaming audio (by sending AVRCP Play).
             */
            static const uint16_t AUTO_PAUSE_MEDIA_SETTING = (uint16_t)0x020A;
            
            /**
             * Payload for AUTO_PAUSE_MEDIA_SETTING.
             */
            static std::vector<BRType>* AUTO_PAUSE_MEDIA_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for AUTO_PAUSE_MEDIA_SETTING.
             */
            static std::vector<BRType>* AUTO_PAUSE_MEDIA_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Reads configuration of rssi and near far.
             */
            static const uint16_t SIGNAL_STRENGTH_CONFIGURATION_SETTING = (uint16_t)0x0806;
            
            /**
             * Payload for SIGNAL_STRENGTH_CONFIGURATION_SETTING.
             */
            static std::vector<BRType>* SIGNAL_STRENGTH_CONFIGURATION_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Payload for SIGNAL_STRENGTH_CONFIGURATION_SETTING.
             */
            static std::vector<BRType>* SIGNAL_STRENGTH_CONFIGURATION_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Returns a byte array containing the interface types for every interface the device includes.
             */
            static const uint16_t DEVICE_INTERFACES_SETTING = (uint16_t)0x0F00;
            
            /**
             * Payload for DEVICE_INTERFACES_SETTING.
             */
            static std::vector<BRType>* DEVICE_INTERFACES_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for DEVICE_INTERFACES_SETTING.
             */
            static std::vector<BRType>* DEVICE_INTERFACES_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * Return the current time-weighted average period value.
             */
            static const uint16_t TIME_WEIGHTED_AVERAGE_PERIOD_SETTING = (uint16_t)0x0F10;
            
            /**
             * Payload for TIME_WEIGHTED_AVERAGE_PERIOD_SETTING.
             */
            static std::vector<BRType>* TIME_WEIGHTED_AVERAGE_PERIOD_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for TIME_WEIGHTED_AVERAGE_PERIOD_SETTING.
             */
            static std::vector<BRType>* TIME_WEIGHTED_AVERAGE_PERIOD_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * The wearing state (donned/doffed). True = donned/worn.
             */
            static const uint16_t WEARING_STATE_SETTING = (uint16_t)0x0202;
            
            /**
             * Payload for WEARING_STATE_SETTING.
             */
            static std::vector<BRType>* WEARING_STATE_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for WEARING_STATE_SETTING.
             */
            static std::vector<BRType>* WEARING_STATE_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Return the interval between mute reminders (voice prompt or tone) in the headset.
             */
            static const uint16_t MUTE_REMINDER_TIMING_SETTING = (uint16_t)0x0A22;
            
            /**
             * Payload for MUTE_REMINDER_TIMING_SETTING.
             */
            static std::vector<BRType>* MUTE_REMINDER_TIMING_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for MUTE_REMINDER_TIMING_SETTING.
             */
            static std::vector<BRType>* MUTE_REMINDER_TIMING_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * For unit testing: fetch the string value set by the "Set one string" command.
             */
            static const uint16_t ONE_STRING_SETTING = (uint16_t)0x0055;
            
            /**
             * Payload for ONE_STRING_SETTING.
             */
            static std::vector<BRType>* ONE_STRING_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for ONE_STRING_SETTING.
             */
            static std::vector<BRType>* ONE_STRING_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Query for the internal device status of a device under test.
             */
            static const uint16_t DEVICE_STATUS_SETTING = (uint16_t)0x1006;
            
            /**
             * Payload for DEVICE_STATUS_SETTING.
             */
            static std::vector<BRType>* DEVICE_STATUS_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for DEVICE_STATUS_SETTING.
             */
            static std::vector<BRType>* DEVICE_STATUS_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * This setting provides information that identifies the manufacturer of the device in
             "reverse DNS" style.  Generally, this will always be "COM.PLANTRONICS".
             */
            static const uint16_t MANUFACTURER_SETTING = (uint16_t)0x0A36;
            
            /**
             * Payload for MANUFACTURER_SETTING.
             */
            static std::vector<BRType>* MANUFACTURER_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for MANUFACTURER_SETTING.
             */
            static std::vector<BRType>* MANUFACTURER_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * For unit testing: fetch the byte array value set by the "Set one byte array"
             command.
             */
            static const uint16_t ONE_BYTE_ARRAY_SETTING = (uint16_t)0x0057;
            
            /**
             * Payload for ONE_BYTE_ARRAY_SETTING.
             */
            static std::vector<BRType>* ONE_BYTE_ARRAY_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for ONE_BYTE_ARRAY_SETTING.
             */
            static std::vector<BRType>* ONE_BYTE_ARRAY_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * Return the device's Genes Globally Unique ID (GUID). If the device should contain no Genes
             GUID, it must not implement this Setting.
             */
            static const uint16_t GENES_GUID_SETTING = (uint16_t)0x0A1E;
            
            /**
             * Payload for GENES_GUID_SETTING.
             */
            static std::vector<BRType>* GENES_GUID_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for GENES_GUID_SETTING.
             */
            static std::vector<BRType>* GENES_GUID_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * This contains the telephone call state of the device. The device will issue
             "Call status change" events whenever the state changes.
             */
            static const uint16_t CALL_STATUS_SETTING = (uint16_t)0x0E02;
            
            /**
             * Payload for CALL_STATUS_SETTING.
             */
            static std::vector<BRType>* CALL_STATUS_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for CALL_STATUS_SETTING.
             */
            static std::vector<BRType>* CALL_STATUS_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Return the ring tone for all three interface types.
             */
            static const uint16_t RINGTONES_SETTING = (uint16_t)0x0F02;
            
            /**
             * Payload for RINGTONES_SETTING.
             */
            static std::vector<BRType>* RINGTONES_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for RINGTONES_SETTING.
             */
            static std::vector<BRType>* RINGTONES_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * Is A2DP currently enabled? Return true if it is, false if not.
             */
            static const uint16_t A2DP_IS_ENABLED_SETTING = (uint16_t)0x0A0E;
            
            /**
             * Payload for A2DP_IS_ENABLED_SETTING.
             */
            static std::vector<BRType>* A2DP_IS_ENABLED_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for A2DP_IS_ENABLED_SETTING.
             */
            static std::vector<BRType>* A2DP_IS_ENABLED_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Return the current time-weighted average value.
             */
            static const uint16_t TIME_WEIGHTED_AVERAGE_SETTING = (uint16_t)0x0F0E;
            
            /**
             * Payload for TIME_WEIGHTED_AVERAGE_SETTING.
             */
            static std::vector<BRType>* TIME_WEIGHTED_AVERAGE_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for TIME_WEIGHTED_AVERAGE_SETTING.
             */
            static std::vector<BRType>* TIME_WEIGHTED_AVERAGE_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Describes whether the wearing sensor is enabled.  If the sensor is disabled,
             for example through the Morini control panel, the device will not generate "Wearing state" events.
             This setting must be implemented in all devices equipped with a wearing state sensor.
             */
            static const uint16_t WEARING_SENSOR_ENABLED_SETTING = (uint16_t)0x214;
            
            /**
             * Payload for WEARING_SENSOR_ENABLED_SETTING.
             */
            static std::vector<BRType>* WEARING_SENSOR_ENABLED_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for WEARING_SENSOR_ENABLED_SETTING.
             */
            static std::vector<BRType>* WEARING_SENSOR_ENABLED_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * This setting returns the headset hook switch's ability to dial calls.
             If enabled, the headset's hook switch cannot initiate outgoing calls when the
             headset is not worn.
             (The purpose is to eliminate pocket dialing. If the headset is in your pocket, the
             theory goes, it is not on your head and shouldn't be making a call.)
             */
            static const uint16_t GET_AUTO_LOCK_CALL_BUTTON_SETTING = (uint16_t)0x0212;
            
            /**
             * Payload for GET_AUTO_LOCK_CALL_BUTTON_SETTING.
             */
            static std::vector<BRType>* GET_AUTO_LOCK_CALL_BUTTON_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for GET_AUTO_LOCK_CALL_BUTTON_SETTING.
             */
            static std::vector<BRType>* GET_AUTO_LOCK_CALL_BUTTON_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Reports if the 'say "answer" or "ignore"' prompt and recognition feature is enabled.
             */
            static const uint16_t SPOKEN_ANSWER_IGNORE_COMMAND_SETTING = (uint16_t)0x0A30;
            
            /**
             * Payload for SPOKEN_ANSWER_IGNORE_COMMAND_SETTING.
             */
            static std::vector<BRType>* SPOKEN_ANSWER_IGNORE_COMMAND_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SPOKEN_ANSWER_IGNORE_COMMAND_SETTING.
             */
            static std::vector<BRType>* SPOKEN_ANSWER_IGNORE_COMMAND_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * For unit testing: fetch the int value set by the "Set one int" command.
             */
            static const uint16_t ONE_INT_SETTING = (uint16_t)0x0053;
            
            /**
             * Payload for ONE_INT_SETTING.
             */
            static std::vector<BRType>* ONE_INT_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for ONE_INT_SETTING.
             */
            static std::vector<BRType>* ONE_INT_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_INT);
                return res;
            };
            
            /**
             * Return whether the VR call reject / answer feature is enabled or not.
             */
            static const uint16_t VR_CALL_REJECT_AND_ANSWER_SETTING = (uint16_t)0x0A0A;
            
            /**
             * Payload for VR_CALL_REJECT_AND_ANSWER_SETTING.
             */
            static std::vector<BRType>* VR_CALL_REJECT_AND_ANSWER_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for VR_CALL_REJECT_AND_ANSWER_SETTING.
             */
            static std::vector<BRType>* VR_CALL_REJECT_AND_ANSWER_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * <a name="Audio status">This Setting reports the audio status,</a>
             including headset speaker and microphone
             volume levels and codec type.
             
             <p>If the codec is CVSD, G.726, G.722, or mSBC, the value of
             the Speaker Gain field refers to SCO audio volume.  If the codec is A2DP,
             Speaker Gain holds the A2DP streaming audio volume.  If codec is None, Speaker
             Gain holds the previously-used SCO audio volume.</p>
             
             <p><b>[Implementation note</b>: Some devices use only two
             values for mic gain: zero, meaning muted, and not-zero, meaning not muted.]</p>
             */
            static const uint16_t AUDIO_STATUS_SETTING = (uint16_t)0x0E1E;
            
            /**
             * Payload for AUDIO_STATUS_SETTING.
             */
            static std::vector<BRType>* AUDIO_STATUS_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for AUDIO_STATUS_SETTING.
             */
            static std::vector<BRType>* AUDIO_STATUS_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Whether the device should answer incoming calls when the user dons the headset.
             If true, answer on don. If false, donning the headset during an incoming call
             will have no effect.
             */
            static const uint16_t AUTO_ANSWER_ON_DON_SETTING = (uint16_t)0x0206;
            
            /**
             * Payload for AUTO_ANSWER_ON_DON_SETTING.
             */
            static std::vector<BRType>* AUTO_ANSWER_ON_DON_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for AUTO_ANSWER_ON_DON_SETTING.
             */
            static std::vector<BRType>* AUTO_ANSWER_ON_DON_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * The returned commands are considered to be disabled, though
             <b>they will all still function if called.</b>
             The value will only contain the IDs of
             commands actually implemented on this device, regardless of the value supplied in
             earlier "Set feature lock" commands.
             */
            static const uint16_t FEATURE_LOCK_SETTING = (uint16_t)0x0F12;
            
            /**
             * Payload for FEATURE_LOCK_SETTING.
             */
            static std::vector<BRType>* FEATURE_LOCK_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for FEATURE_LOCK_SETTING.
             */
            static std::vector<BRType>* FEATURE_LOCK_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT_ARRAY);
                return res;
            };
            
            /**
             * For unit testing: fetch the byte value set by the "Set one byte" command.
             */
            static const uint16_t ONE_BYTE_SETTING = (uint16_t)0x0051;
            
            /**
             * Payload for ONE_BYTE_SETTING.
             */
            static std::vector<BRType>* ONE_BYTE_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for ONE_BYTE_SETTING.
             */
            static std::vector<BRType>* ONE_BYTE_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Return the user-facing product name (market name).
             */
            static const uint16_t PRODUCT_NAME_SETTING = (uint16_t)0x0A00;
            
            /**
             * Payload for PRODUCT_NAME_SETTING.
             */
            static std::vector<BRType>* PRODUCT_NAME_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for PRODUCT_NAME_SETTING.
             */
            static std::vector<BRType>* PRODUCT_NAME_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Returns the USB LANGID for the device's spoken language.  The full list of LANGID
             values is <a href="http://www.usb.org/developers/docs/USB_LANGIDs.pdf">here</a>.
             <p>
             For example, here are some non-normative values.  Please refer to the standard for the latest correct values:
             <br><br>
             <table>
             <tbody>
             <tr><th class="topLeft"><b>Language</b></th><th class="topLeft"><b>Value (hexadecimal)</b></th></tr>
             <tr><td>English (U.S.)</td><td>0x0409</td></tr>
             <tr><td>English (U.K.)</td><td>0x0809</td></tr>
             <tr><td>Japanese</td><td>0x0411</td></tr>
             <tr><td>Portuguese (Brazil)</td><td>0x0416</td></tr>
             <tr><td>Portuguese (Portugal)</td><td>0x0816</td></tr>
             <tr><td>French (France)</td><td>0x040c</td></tr>
             <tr><td>Spanish (Mexico)</td><td>0x080a</td></tr>
             </tbody>
             </table>
             <br>
             This must be implemented on all devices that feature spoken prompts.
             */
            static const uint16_t SPOKEN_LANGUAGE_SETTING = (uint16_t)0x0E1A;
            
            /**
             * Payload for SPOKEN_LANGUAGE_SETTING.
             */
            static std::vector<BRType>* SPOKEN_LANGUAGE_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for SPOKEN_LANGUAGE_SETTING.
             */
            static std::vector<BRType>* SPOKEN_LANGUAGE_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Return the device's Protected state: true true if the password is equal to something other
             than the device default value, false otherwise.
             */
            static const uint16_t PROTECTED_STATE_SETTING = (uint16_t)0x0F18;
            
            /**
             * Payload for PROTECTED_STATE_SETTING.
             */
            static std::vector<BRType>* PROTECTED_STATE_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for PROTECTED_STATE_SETTING.
             */
            static std::vector<BRType>* PROTECTED_STATE_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * For unit testing: fetch the short value set by the "Set one short" command.
             */
            static const uint16_t ONE_SHORT_SETTING = (uint16_t)0x0052;
            
            /**
             * Payload for ONE_SHORT_SETTING.
             */
            static std::vector<BRType>* ONE_SHORT_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for ONE_SHORT_SETTING.
             */
            static std::vector<BRType>* ONE_SHORT_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Return the device's password value.
             */
            static const uint16_t PASSWORD_SETTING = (uint16_t)0x0F16;
            
            /**
             * Payload for PASSWORD_SETTING.
             */
            static std::vector<BRType>* PASSWORD_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for PASSWORD_SETTING.
             */
            static std::vector<BRType>* PASSWORD_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Configure how the device should play a tone on mute.
             */
            static const uint16_t GET_MUTE_TONE_VOLUME_SETTING = (uint16_t)0x0402;
            
            /**
             * Payload for GET_MUTE_TONE_VOLUME_SETTING.
             */
            static std::vector<BRType>* GET_MUTE_TONE_VOLUME_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for GET_MUTE_TONE_VOLUME_SETTING.
             */
            static std::vector<BRType>* GET_MUTE_TONE_VOLUME_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                return res;
            };
            
            /**
             * Returns whether the Lync Dialtone feature is enabled. See the command "Configure
             Lync dial tone on Call press" for more details.
             */
            static const uint16_t LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING = (uint16_t)0x0A34;
            
            /**
             * Payload for LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING.
             */
            static std::vector<BRType>* LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING.
             */
            static std::vector<BRType>* LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * This returns the device's USB product ID, a 16-bit unsigned quantity.
             */
            static const uint16_t USB_PID_SETTING = (uint16_t)0x0A02;
            
            /**
             * Payload for USB_PID_SETTING.
             */
            static std::vector<BRType>* USB_PID_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for USB_PID_SETTING.
             */
            static std::vector<BRType>* USB_PID_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * Returns the current Vocalyst telephone number.
             */
            static const uint16_t VOCALYST_PHONE_NUMBER_SETTING = (uint16_t)0x0A10;
            
            /**
             * Payload for VOCALYST_PHONE_NUMBER_SETTING.
             */
            static std::vector<BRType>* VOCALYST_PHONE_NUMBER_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for VOCALYST_PHONE_NUMBER_SETTING.
             */
            static std::vector<BRType>* VOCALYST_PHONE_NUMBER_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * For unit testing: fetch the boolean value set by the "Set one boolean" command.
             */
            static const uint16_t ONE_BOOLEAN_SETTING = (uint16_t)0x0050;
            
            /**
             * Payload for ONE_BOOLEAN_SETTING.
             */
            static std::vector<BRType>* ONE_BOOLEAN_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for ONE_BOOLEAN_SETTING.
             */
            static std::vector<BRType>* ONE_BOOLEAN_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * For unit testing: fetch the two strings set by the "Set two strings" command.
             */
            static const uint16_t TWO_STRINGS_SETTING = (uint16_t)0x0061;
            
            /**
             * Payload for TWO_STRINGS_SETTING.
             */
            static std::vector<BRType>* TWO_STRINGS_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for TWO_STRINGS_SETTING.
             */
            static std::vector<BRType>* TWO_STRINGS_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_STRING);
                res->push_back(BR_TYPE_STRING);
                return res;
            };
            
            /**
             * Implemented only in devices (typically headsets) equipped with a battery.
             The current battery state: battery level, minutes of talk time, if the talk time is
             a high estimate, and charging or not.
             */
            static const uint16_t BATTERY_INFO_SETTING = (uint16_t)0x0A1A;
            
            /**
             * Payload for BATTERY_INFO_SETTING.
             */
            static std::vector<BRType>* BATTERY_INFO_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for BATTERY_INFO_SETTING.
             */
            static std::vector<BRType>* BATTERY_INFO_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BYTE);
                res->push_back(BR_TYPE_BOOLEAN);
                res->push_back(BR_TYPE_SHORT);
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * To be implemented only in Bluetooth devices.
             Is the device in Bluetooth pairing mode?
             Returns true if in pairing mode, false if not.
             */
            static const uint16_t PAIRING_MODE_SETTING = (uint16_t)0x0A26;
            
            /**
             * Payload for PAIRING_MODE_SETTING.
             */
            static std::vector<BRType>* PAIRING_MODE_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for PAIRING_MODE_SETTING.
             */
            static std::vector<BRType>* PAIRING_MODE_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Return the bandwidth for all three interface types.
             */
            static const uint16_t BANDWIDTHS_SETTING = (uint16_t)0x0F04;
            
            /**
             * Payload for BANDWIDTHS_SETTING.
             */
            static std::vector<BRType>* BANDWIDTHS_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for BANDWIDTHS_SETTING.
             */
            static std::vector<BRType>* BANDWIDTHS_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * The firmware ID is a pair of numbers. The buildTarget field describes the headset 
             build-target, the release field contains the release number.
             */
            static const uint16_t FIRMWARE_VERSION_SETTING = (uint16_t)0x0A04;
            
            /**
             * Payload for FIRMWARE_VERSION_SETTING.
             */
            static std::vector<BRType>* FIRMWARE_VERSION_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for FIRMWARE_VERSION_SETTING.
             */
            static std::vector<BRType>* FIRMWARE_VERSION_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT);
                res->push_back(BR_TYPE_SHORT);
                return res;
            };
            
            /**
             * For unit testing: fetch the long value set by the "Set one long" command.
             */
            static const uint16_t ONE_LONG_SETTING = (uint16_t)0x0054;
            
            /**
             * Payload for ONE_LONG_SETTING.
             */
            static std::vector<BRType>* ONE_LONG_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for ONE_LONG_SETTING.
             */
            static std::vector<BRType>* ONE_LONG_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_LONG);
                return res;
            };
            
            /**
             * For unit testing: fetch the short[] value set by the "Set one short array" command.
             */
            static const uint16_t ONE_SHORT_ARRAY_SETTING = (uint16_t)0x0056;
            
            /**
             * Payload for ONE_SHORT_ARRAY_SETTING.
             */
            static std::vector<BRType>* ONE_SHORT_ARRAY_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for ONE_SHORT_ARRAY_SETTING.
             */
            static std::vector<BRType>* ONE_SHORT_ARRAY_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT_ARRAY);
                return res;
            };
            
            /**
             * Return the volume for all three interface types.
             */
            static const uint16_t RINGTONE_VOLUMES_SETTING = (uint16_t)0x0F06;
            
            /**
             * Payload for RINGTONE_VOLUMES_SETTING.
             */
            static std::vector<BRType>* RINGTONE_VOLUMES_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for RINGTONE_VOLUMES_SETTING.
             */
            static std::vector<BRType>* RINGTONE_VOLUMES_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BYTE_ARRAY);
                return res;
            };
            
            /**
             * Return the current anti-startle value.
             */
            static const uint16_t ANTI_STARTLE_SETTING = (uint16_t)0x0F0A;
            
            /**
             * Payload for ANTI_STARTLE_SETTING.
             */
            static std::vector<BRType>* ANTI_STARTLE_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for ANTI_STARTLE_SETTING.
             */
            static std::vector<BRType>* ANTI_STARTLE_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
            /**
             * Query for the IDs specifying the device status data that will be provided upon a device status query.
             */
            static const uint16_t DEVICE_STATUS_CAPABILITIES_SETTING = (uint16_t)0x1005;
            
            /**
             * Payload for DEVICE_STATUS_CAPABILITIES_SETTING.
             */
            static std::vector<BRType>* DEVICE_STATUS_CAPABILITIES_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for DEVICE_STATUS_CAPABILITIES_SETTING.
             */
            static std::vector<BRType>* DEVICE_STATUS_CAPABILITIES_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_SHORT_ARRAY);
                return res;
            };
            
            /**
             * Return the current G.616 value.
             */
            static const uint16_t G616_SETTING = (uint16_t)0x0F0C;
            
            /**
             * Payload for G616_SETTING.
             */
            static std::vector<BRType>* G616_SETTING_PAYLOAD_IN()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                return res;
            };
            
            /**
             * Payload for G616_SETTING.
             */
            static std::vector<BRType>* G616_SETTING_PAYLOAD_OUT()
            {
                std::vector<BRType>* res = new std::vector<BRType>;
                res->push_back(BR_TYPE_BOOLEAN);
                return res;
            };
            
        private:
            static std::set<SignatureDescription> mSettings;
        };
        
    protected:
        static std::vector<int16_t>* getIDs(const std::set<SignatureDescription>& signatures);
        
        static std::vector<BRType>* getSignature(std::set<SignatureDescription>& signatures, int16_t id);
        
        static std::vector<BRType>* getInputSignature(std::set<SignatureDescription>& signatures, int16_t id);
        
        static std::vector<BRType>* getOutputSignature(std::set<SignatureDescription>& signatures, int16_t id);
        
        
    private:
        
        /*
         * You can't instantiate this class.  It exists only to provide
         * public static methods.
         */
        SignatureDefinitions() {}
        
    };
}

#endif
