//
//  BRIncomingMessageMux.m
//  BRDevice
//
//  Auto-generated from deckard.xml v2.3 on 10/08/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRIncomingMessageMux.h"
#import "BRIncomingMessage.h"
#import "BRTypeImports.h"
#import "PLTDLog.h"


@implementation BRIncomingMessageMux

+ (BRIncomingMessage *)messageWithData:(NSData *)data
{
	uint8_t messageType;
	NSData *messageTypeData = [data subdataWithRange:NSMakeRange(5, sizeof(uint8_t))];
	[messageTypeData getBytes:&messageType length:sizeof(uint8_t)];
	messageType &= 0x0F; // messageType is actually the second nibble in byte 5
	
	uint16_t deckardID;
	NSData *deckardIDData = [data subdataWithRange:NSMakeRange(6, sizeof(uint16_t))];
	[deckardIDData getBytes:&deckardID length:sizeof(uint16_t)];
	deckardID = ntohs(deckardID);
			
	Class class = nil;

	switch (messageType) {

		case BRMessageTypeCommandResultException:
		case BRMessageTypeSettingResultException:
			switch (deckardID) {
				case BR_SIMULATED_EXCEPTION_EXCEPTION:
					class = [BRSimulatedExceptionException class];
					break;
				case BR_TEST_INTERFACE_IS_DISABLED_EXCEPTION:
					class = [BRTestInterfaceIsDisabledException class];
					break;
				case BR_NO_GENES_GUID_EXCEPTION:
					class = [BRNoGenesGUIDException class];
					break;
				case BR_GENES_GUID_ALREADY_SET_EXCEPTION:
					class = [BRGenesGUIDAlreadySetException class];
					break;
				case BR_FEATURE_LOCK_ID_NOT_VALID_EXCEPTION:
					class = [BRFeatureLockIDNotValidException class];
					break;
				case BR_COMMAND_UNKNOWN_EXCEPTION:
					class = [BRCommandUnknownException class];
					break;
				case BR_SETTING_UNKNOWN_EXCEPTION:
					class = [BRSettingUnknownException class];
					break;
				case BR_INVALID_PACKET_LENGTH_EXCEPTION:
					class = [BRInvalidPacketLengthException class];
					break;
				case BR_INVALID_PACKET_TYPE_EXCEPTION:
					class = [BRInvalidPacketTypeException class];
					break;
				case BR_INVALID_MESSAGE_TYPE_EXCEPTION:
					class = [BRInvalidMessageTypeException class];
					break;
				case BR_MESSAGE_TOO_SHORT_EXCEPTION:
					class = [BRMessageTooShortException class];
					break;
				case BR_MEMORY_ALLOCATION_FAILED_EXCEPTION:
					class = [BRMemoryAllocationFailedException class];
					break;
				case BR_COMMAND_PEM_LOCKED_EXCEPTION:
					class = [BRCommandPEMLockedException class];
					break;
				case BR_NUMBER_OUT_OF_RANGE_EXCEPTION:
					class = [BRNumberOutOfRangeException class];
					break;
				case BR_ILLEGAL_VALUE_EXCEPTION:
					class = [BRIllegalValueException class];
					break;
				case BR_INVALID_POWER_STATE_EXCEPTION:
					class = [BRInvalidPowerStateException class];
					break;
				case BR_NO_TOMBSTONE_EXCEPTION:
					class = [BRNoTombstoneException class];
					break;
				case BR_INVALID_SERVICE_IDS_EXCEPTION:
					class = [BRInvalidServiceIDsException class];
					break;
				case BR_INVALID_CHARACTERISTICS_OR_OPCODES_EXCEPTION:
					class = [BRInvalidCharacteristicsOrOpcodesException class];
					break;
				case BR_INVALID_SERVICE_MODES_EXCEPTION:
					class = [BRInvalidServiceModesException class];
					break;
				case BR_INVALID_PAYLOAD_DATA_EXCEPTION:
					class = [BRInvalidPayloadDataException class];
					break;
				case BR_DEVICE_NOT_READY_EXCEPTION:
					class = [BRDeviceNotReadyException class];
					break;

				default:
					NSLog(@"Error: unknown Deckard exception 0x%04X", deckardID);
					// some way to relay this would be nice
					break;
			}
			break;
			
		case BRMessageTypeSettingResultSuccess:
			switch (deckardID) {
				case BR_ONE_BOOLEAN_SETTING_RESULT:
					class = [BROneBooleanSettingResult class];
					break;
				case BR_ONE_BYTE_SETTING_RESULT:
					class = [BROneByteSettingResult class];
					break;
				case BR_ONE_SHORT_SETTING_RESULT:
					class = [BROneShortSettingResult class];
					break;
				case BR_ONE_INT_SETTING_RESULT:
					class = [BROneIntSettingResult class];
					break;
				case BR_ONE_LONG_SETTING_RESULT:
					class = [BROneLongSettingResult class];
					break;
				case BR_ONE_STRING_SETTING_RESULT:
					class = [BROneStringSettingResult class];
					break;
				case BR_ONE_SHORT_ARRAY_SETTING_RESULT:
					class = [BROneShortArraySettingResult class];
					break;
				case BR_ONE_BYTE_ARRAY_SETTING_RESULT:
					class = [BROneByteArraySettingResult class];
					break;
				case BR_TWO_BOOLEANS_SETTING_RESULT:
					class = [BRTwoBooleansSettingResult class];
					break;
				case BR_TWO_STRINGS_SETTING_RESULT:
					class = [BRTwoStringsSettingResult class];
					break;
				case BR_THROW_SETTING_EXCEPTION_SETTING_RESULT:
					class = [BRThrowSettingExceptionSettingResult class];
					break;
				case BR_BUTTON_SIMULATION_CAPABILITIES_SETTING_RESULT:
					class = [BRButtonSimulationCapabilitiesSettingResult class];
					break;
				case BR_INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING_RESULT:
					class = [BRIndirectEventSimulationCapabilitiesSettingResult class];
					break;
				case BR_DEVICE_STATUS_CAPABILITIES_SETTING_RESULT:
					class = [BRDeviceStatusCapabilitiesSettingResult class];
					break;
				case BR_DEVICE_STATUS_SETTING_RESULT:
					class = [BRDeviceStatusSettingResult class];
					break;
				case BR_CUSTOM_DEVICE_STATUS_SETTING_RESULT:
					class = [BRCustomDeviceStatusSettingResult class];
					break;
				case BR_SINGLE_NVRAM_CONFIGURATION_READ_SETTING_RESULT:
					class = [BRSingleNVRAMConfigurationReadSettingResult class];
					break;
				case BR_SUPPORTED_TEST_INTERFACE_MESSAGE_IDS_SETTING_RESULT:
					class = [BRSupportedTestInterfaceMessageIDsSettingResult class];
					break;
				case BR_SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING_RESULT:
					class = [BRSingleNVRAMConfigurationReadWithAddressEchoSettingResult class];
					break;
				case BR_HARDWARE_BATTERY_METER_SETTING_RESULT:
					class = [BRHardwareBatteryMeterSettingResult class];
					break;
				case BR_SOFTWARE_COULOMB_COUNTER_SETTING_RESULT:
					class = [BRSoftwareCoulombCounterSettingResult class];
					break;
				case BR_WEARING_STATE_SETTING_RESULT:
					class = [BRWearingStateSettingResult class];
					break;
				case BR_AUTOANSWER_ON_DON_SETTING_RESULT:
					class = [BRAutoanswerOnDonSettingResult class];
					break;
				case BR_AUTOPAUSE_MEDIA_SETTING_RESULT:
					class = [BRAutopauseMediaSettingResult class];
					break;
				case BR_AUTOTRANSFER_CALL_SETTING_RESULT:
					class = [BRAutotransferCallSettingResult class];
					break;
				case BR_GET_AUTOLOCK_CALL_BUTTON_SETTING_RESULT:
					class = [BRGetAutolockCallButtonSettingResult class];
					break;
				case BR_WEARING_SENSOR_ENABLED_SETTING_RESULT:
					class = [BRWearingSensorEnabledSettingResult class];
					break;
				case BR_AUTOMUTE_CALL_SETTING_RESULT:
					class = [BRAutoMuteCallSettingResult class];
					break;
				case BR_CONFIGURATION_FOR_A_CONNECTED_HEADSET_SETTING_RESULT:
					class = [BRConfigurationForAConnectedHeadsetSettingResult class];
					break;
				case BR_GET_MUTE_TONE_VOLUME_SETTING_RESULT:
					class = [BRGetMuteToneVolumeSettingResult class];
					break;
				case BR_GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING_RESULT:
					class = [BRGetSecondInboundCallRingTypeSettingResult class];
					break;
				case BR_GET_MUTE_OFF_VP_SETTING_RESULT:
					class = [BRGetMuteOffVPSettingResult class];
					break;
				case BR_GET_SCO_OPEN_TONE_ENABLE_SETTING_RESULT:
					class = [BRGetSCOOpenToneEnableSettingResult class];
					break;
				case BR_GET_OLI_FEATURE_ENABLE_SETTING_RESULT:
					class = [BRGetOLIFeatureEnableSettingResult class];
					break;
				case BR_MUTE_ALERT_SETTING_RESULT:
					class = [BRMuteAlertSettingResult class];
					break;
				case BR_CURRENT_SIGNAL_STRENGTH_SETTING_RESULT:
					class = [BRCurrentSignalStrengthSettingResult class];
					break;
				case BR_CALLER_ANNOUNCEMENT_SETTING_RESULT:
					class = [BRCallerAnnouncementSettingResult class];
					break;
				case BR_SIGNAL_STRENGTH_CONFIGURATION_SETTING_RESULT:
					class = [BRSignalStrengthConfigurationSettingResult class];
					break;
				case BR_FIND_HEADSET_LED_ALERT_STATUS_SETTING_RESULT:
					class = [BRFindHeadsetLEDAlertStatusSettingResult class];
					break;
				case BR_TXPOWER_REPORTING_SETTING_RESULT:
					class = [BRTxPowerReportingSettingResult class];
					break;
				case BR_VOICE_SILENT_DETECTION_SETTING_RESULT:
					class = [BRVoiceSilentDetectionSettingResult class];
					break;
				case BR_PRODUCT_NAME_SETTING_RESULT:
					class = [BRProductNameSettingResult class];
					break;
				case BR_TATTOO_SERIAL_NUMBER_SETTING_RESULT:
					class = [BRTattooSerialNumberSettingResult class];
					break;
				case BR_USB_PID_SETTING_RESULT:
					class = [BRUSBPIDSettingResult class];
					break;
				case BR_TATTOO_BUILD_CODE_SETTING_RESULT:
					class = [BRTattooBuildCodeSettingResult class];
					break;
				case BR_FIRMWARE_VERSION_SETTING_RESULT:
					class = [BRFirmwareVersionSettingResult class];
					break;
				case BR_PART_NUMBER_SETTING_RESULT:
					class = [BRPartNumberSettingResult class];
					break;
				case BR_USER_ID_SETTING_RESULT:
					class = [BRUserIDSettingResult class];
					break;
				case BR_FIRST_DATE_USED_SETTING_RESULT:
					class = [BRFirstDateUsedSettingResult class];
					break;
				case BR_LAST_DATE_USED_SETTING_RESULT:
					class = [BRLastDateUsedSettingResult class];
					break;
				case BR_LAST_DATE_CONNECTED_SETTING_RESULT:
					class = [BRLastDateConnectedSettingResult class];
					break;
				case BR_TIME_USED_SETTING_RESULT:
					class = [BRTimeUsedSettingResult class];
					break;
				case BR_USER_DEFINED_STORAGE_SETTING_RESULT:
					class = [BRUserDefinedStorageSettingResult class];
					break;
				case BR_VR_CALL_REJECT_AND_ANSWER_SETTING_RESULT:
					class = [BRVRCallRejectAndAnswerSettingResult class];
					break;
				case BR_A2DP_IS_ENABLED_SETTING_RESULT:
					class = [BRA2DPIsEnabledSettingResult class];
					break;
				case BR_VOCALYST_PHONE_NUMBER_SETTING_RESULT:
					class = [BRVocalystPhoneNumberSettingResult class];
					break;
				case BR_VOCALYST_INFO_NUMBER_SETTING_RESULT:
					class = [BRVocalystInfoNumberSettingResult class];
					break;
				case BR_BATTERY_INFO_SETTING_RESULT:
					class = [BRBatteryInfoSettingResult class];
					break;
				case BR_BATTERY_EXTENDED_INFO_SETTING_RESULT:
					class = [BRBatteryExtendedInfoSettingResult class];
					break;
				case BR_GENES_GUID_SETTING_RESULT:
					class = [BRGenesGUIDSettingResult class];
					break;
				case BR_MUTE_REMINDER_TIMING_SETTING_RESULT:
					class = [BRMuteReminderTimingSettingResult class];
					break;
				case BR_PAIRING_MODE_SETTING_RESULT:
					class = [BRPairingModeSettingResult class];
					break;
				case BR_SPOKEN_ANSWERIGNORE_COMMAND_SETTING_RESULT:
					class = [BRSpokenAnswerignoreCommandSettingResult class];
					break;
				case BR_LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING_RESULT:
					class = [BRLyncDialToneOnCallPressSettingResult class];
					break;
				case BR_MANUFACTURER_SETTING_RESULT:
					class = [BRManufacturerSettingResult class];
					break;
				case BR_TOMBSTONE_SETTING_RESULT:
					class = [BRTombstoneSettingResult class];
					break;
				case BR_BLUETOOTH_ADDRESS_SETTING_RESULT:
					class = [BRBluetoothAddressSettingResult class];
					break;
				case BR_BLUETOOTH_CONNECTION_SETTING_RESULT:
					class = [BRBluetoothConnectionSettingResult class];
					break;
				case BR_DECKARD_VERSION_SETTING_RESULT:
					class = [BRDeckardVersionSettingResult class];
					break;
				case BR_CONNECTION_STATUS_SETTING_RESULT:
					class = [BRConnectionStatusSettingResult class];
					break;
				case BR_CALL_STATUS_SETTING_RESULT:
					class = [BRCallStatusSettingResult class];
					break;
				case BR_MICROPHONE_MUTE_STATE_SETTING_RESULT:
					class = [BRMicrophoneMuteStateSettingResult class];
					break;
				case BR_TRANSMIT_AUDIO_STATE_SETTING_RESULT:
					class = [BRTransmitAudioStateSettingResult class];
					break;
				case BR_RECEIVE_AUDIO_STATE_SETTING_RESULT:
					class = [BRReceiveAudioStateSettingResult class];
					break;
				case BR_LED_STATUS_GENERIC_SETTING_RESULT:
					class = [BRLEDStatusGenericSettingResult class];
					break;
				case BR_HEADSET_AVAILABLE_SETTING_RESULT:
					class = [BRHeadsetAvailableSettingResult class];
					break;
				case BR_TRAINING_HEADSET_CONNECTION_SETTING_RESULT:
					class = [BRTrainingHeadsetConnectionSettingResult class];
					break;
				case BR_SPEAKER_VOLUME_SETTING_RESULT:
					class = [BRSpeakerVolumeSettingResult class];
					break;
				case BR_SPOKEN_LANGUAGE_SETTING_RESULT:
					class = [BRSpokenLanguageSettingResult class];
					break;
				case BR_SUPPORTED_LANGUAGES_SETTING_RESULT:
					class = [BRSupportedLanguagesSettingResult class];
					break;
				case BR_GET_PARTITION_INFORMATION_SETTING_RESULT:
					class = [BRGetPartitionInformationSettingResult class];
					break;
				case BR_AUDIO_STATUS_SETTING_RESULT:
					class = [BRAudioStatusSettingResult class];
					break;
				case BR_LED_STATUS_SETTING_RESULT:
					class = [BRLEDStatusSettingResult class];
					break;
				case BR_HEADSET_CALL_STATUS_SETTING_RESULT:
					class = [BRHeadsetCallStatusSettingResult class];
					break;
				case BR_EXTENDED_CALL_STATUS_SETTING_RESULT:
					class = [BRExtendedCallStatusSettingResult class];
					break;
				case BR_DEVICE_INTERFACES_SETTING_RESULT:
					class = [BRDeviceInterfacesSettingResult class];
					break;
				case BR_RINGTONES_SETTING_RESULT:
					class = [BRRingtonesSettingResult class];
					break;
				case BR_BANDWIDTHS_SETTING_RESULT:
					class = [BRBandwidthsSettingResult class];
					break;
				case BR_RINGTONE_VOLUMES_SETTING_RESULT:
					class = [BRRingtoneVolumesSettingResult class];
					break;
				case BR_DEFAULT_OUTBOUND_INTERFACE_SETTING_RESULT:
					class = [BRDefaultOutboundInterfaceSettingResult class];
					break;
				case BR_TONE_CONTROLS_SETTING_RESULT:
					class = [BRToneControlsSettingResult class];
					break;
				case BR_AUDIO_SENSING_SETTING_RESULT:
					class = [BRAudioSensingSettingResult class];
					break;
				case BR_INTELLISTAND_AUTOANSWER_SETTING_RESULT:
					class = [BRIntellistandAutoAnswerSettingResult class];
					break;
				case BR_AUTOCONNECT_TO_MOBILE_SETTING_RESULT:
					class = [BRAutoConnectToMobileSettingResult class];
					break;
				case BR_STOP_AUTOCONNECT_ON_DOCK_SETTING_RESULT:
					class = [BRStopAutoConnectOnDockSettingResult class];
					break;
				case BR_BLUETOOTH_ENABLED_SETTING_RESULT:
					class = [BRBluetoothEnabledSettingResult class];
					break;
				case BR_OVERTHEAIR_SUBSCRIPTION_SETTING_RESULT:
					class = [BROvertheAirSubscriptionSettingResult class];
					break;
				case BR_SYSTEM_TONE_VOLUME_SETTING_RESULT:
					class = [BRSystemToneVolumeSettingResult class];
					break;
				case BR_POWER_LEVEL_SETTING_RESULT:
					class = [BRPowerLevelSettingResult class];
					break;
				case BR_MOBILE_VOICE_COMMANDS_SETTING_RESULT:
					class = [BRMobileVoiceCommandsSettingResult class];
					break;
				case BR_VOLUME_CONTROL_ORIENTATION_SETTING_RESULT:
					class = [BRVolumeControlOrientationSettingResult class];
					break;
				case BR_AAL_ACOUSTIC_INCIDENT_REPORTING_ENABLE_SETTING_RESULT:
					class = [BRAALAcousticIncidentReportingEnableSettingResult class];
					break;
				case BR_AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_SETTING_RESULT:
					class = [BRAALAcousticIncidentReportingThresholdsSettingResult class];
					break;
				case BR_AAL_ACOUSTIC_INCIDENT_REPORT_SETTING_RESULT:
					class = [BRAALAcousticIncidentReportSettingResult class];
					break;
				case BR_AAL_TWA_REPORTING_ENABLE_SETTING_RESULT:
					class = [BRAALTWAReportingEnableSettingResult class];
					break;
				case BR_AAL_TWA_REPORTING_TIME_PERIOD_SETTING_RESULT:
					class = [BRAALTWAReportingTimePeriodSettingResult class];
					break;
				case BR_ANTISTARTLE_SETTING_RESULT:
					class = [BRAntistartleSettingResult class];
					break;
				case BR_AAL_TWA_REPORT_SETTING_RESULT:
					class = [BRAALTWAReportSettingResult class];
					break;
				case BR_G616_SETTING_RESULT:
					class = [BRG616SettingResult class];
					break;
				case BR_CONVERSATION_DYNAMICS_REPORTING_ENABLE_SETTING_RESULT:
					class = [BRConversationDynamicsReportingEnableSettingResult class];
					break;
				case BR_TIMEWEIGHTED_AVERAGE_SETTING_RESULT:
					class = [BRTimeweightedAverageSettingResult class];
					break;
				case BR_CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_SETTING_RESULT:
					class = [BRConversationDynamicsReportingTimePeriodSettingResult class];
					break;
				case BR_TIMEWEIGHTED_AVERAGE_PERIOD_SETTING_RESULT:
					class = [BRTimeweightedAveragePeriodSettingResult class];
					break;
				case BR_CONVERSATION_DYNAMICS_REPORT_SETTING_RESULT:
					class = [BRConversationDynamicsReportSettingResult class];
					break;
				case BR_GET_SUPPORTED_DSP_CAPABILITIES_SETTING_RESULT:
					class = [BRGetSupportedDSPCapabilitiesSettingResult class];
					break;
				case BR_GET_DSP_PARAMETERS_SETTING_RESULT:
					class = [BRGetDSPParametersSettingResult class];
					break;
				case BR_FEATURE_LOCK_SETTING_RESULT:
					class = [BRFeatureLockSettingResult class];
					break;
				case BR_FEATURE_LOCK_MASK_SETTING_RESULT:
					class = [BRFeatureLockMaskSettingResult class];
					break;
				case BR_HAL_CURRENT_SCENARIO_SETTING_RESULT:
					class = [BRHalCurrentScenarioSettingResult class];
					break;
				case BR_HAL_CURRENT_VOLUME_SETTING_RESULT:
					class = [BRHalCurrentVolumeSettingResult class];
					break;
				case BR_HAL_CURRENT_EQ_SETTING_RESULT:
					class = [BRHalCurrentEQSettingResult class];
					break;
				case BR_HAL_GENERIC_SETTING_RESULT:
					class = [BRHalGenericSettingResult class];
					break;
				case BR_QUERY_SERVICES_CONFIGURATION_DATA_SETTING_RESULT:
					class = [BRQueryServicesConfigurationDataSettingResult class];
					break;
				case BR_QUERY_SERVICES_CALIBRATION_DATA_SETTING_RESULT:
					class = [BRQueryServicesCalibrationDataSettingResult class];
					break;
				case BR_QUERY_APPLICATION_CONFIGURATION_DATA_SETTING_RESULT:
					class = [BRQueryApplicationConfigurationDataSettingResult class];
					break;
				case BR_QUERY_SERVICES_DATA_SETTING_RESULT:
					class = [BRQueryServicesDataSettingResult class];
					break;
				case BR_GET_DEVICE_INFO_SETTING_RESULT:
					class = [BRGetDeviceInfoSettingResult class];
					break;

				default:
					NSLog(@"Error: unknown Deckard setting 0x%04X", deckardID);
					// some way to relay this would be nice
					break;
			}
			break;

		case BRMessageTypeEvent:
			switch (deckardID) {
				case BR_PERIODIC_TEST_EVENT_EVENT:
					class = [BRPeriodicTestEventEvent class];
					break;
				case BR_SET_ONE_BOOLEAN_EVENT:
					class = [BRSetOneBooleanEvent class];
					break;
				case BR_SET_ONE_BYTE_EVENT:
					class = [BRSetOneByteEvent class];
					break;
				case BR_SET_ONE_SHORT_EVENT:
					class = [BRSetOneShortEvent class];
					break;
				case BR_SET_ONE_INT_EVENT:
					class = [BRSetOneIntEvent class];
					break;
				case BR_SET_ONE_LONG_EVENT:
					class = [BRSetOneLongEvent class];
					break;
				case BR_SET_ONE_STRING_EVENT:
					class = [BRSetOneStringEvent class];
					break;
				case BR_SET_ONE_SHORT_ARRAY_EVENT:
					class = [BRSetOneShortArrayEvent class];
					break;
				case BR_SET_ONE_BYTE_ARRAY_EVENT:
					class = [BRSetOneByteArrayEvent class];
					break;
				case BR_SET_TWO_BOOLEANS_EVENT:
					class = [BRSetTwoBooleansEvent class];
					break;
				case BR_SET_TWO_STRINGS_EVENT:
					class = [BRSetTwoStringsEvent class];
					break;
				case BR_TEST_INTERFACE_ENABLEDISABLE_EVENT:
					class = [BRTestInterfaceEnableDisableEvent class];
					break;
				case BR_RAW_BUTTONTEST_EVENT_ENABLEDISABLE_EVENT:
					class = [BRRawButtonTestEventEnableDisableEvent class];
					break;
				case BR_RAW_BUTTON_TEST_EVENT_EVENT:
					class = [BRRawButtonTestEventEvent class];
					break;
				case BR_VOICE_RECOGNITION_TEST_EVENT_ENABLEDISABLE_EVENT:
					class = [BRVoiceRecognitionTestEventEnableDisableEvent class];
					break;
				case BR_VOICE_RECOGNITION_TEST_EVENT_EVENT:
					class = [BRVoiceRecognitionTestEventEvent class];
					break;
				case BR_RAW_DATA_EVENT_EVENT:
					class = [BRRawDataEventEvent class];
					break;
				case BR_RAW_DATA_EVENT_ENABLEDISABLE_EVENT:
					class = [BRRawDataEventEnableDisableEvent class];
					break;
				case BR_CAPSENSE_RAW_DATA_EVENT_EVENT:
					class = [BRCapsenseRawDataEventEvent class];
					break;
				case BR_SOFTWARE_BATTERY_DIAG_EVENT:
					class = [BRSoftwareBatteryDiagEvent class];
					break;
				case BR_HARDWARE_BATTERY_DIAG_EVENT:
					class = [BRHardwareBatteryDiagEvent class];
					break;
				case BR_COULOMB_COUNTER_DIAG_EVENT:
					class = [BRCoulombCounterDiagEvent class];
					break;
				case BR_WEARING_STATE_CHANGED_EVENT:
					class = [BRWearingStateChangedEvent class];
					break;
				case BR_AUTOANSWER_ON_DON_EVENT:
					class = [BRAutoanswerOnDonEvent class];
					break;
				case BR_CONFIGURE_AUTOPAUSE_MEDIA_EVENT:
					class = [BRConfigureAutopauseMediaEvent class];
					break;
				case BR_CONFIGURE_AUTOTRANSFER_CALL_EVENT:
					class = [BRConfigureAutotransferCallEvent class];
					break;
				case BR_CONFIGURE_AUTOLOCK_CALL_BUTTON_EVENT:
					class = [BRConfigureAutolockCallButtonEvent class];
					break;
				case BR_CONFIGURE_WEARING_SENSOR_ENABLED_EVENT:
					class = [BRConfigureWearingSensorEnabledEvent class];
					break;
				case BR_CONFIGURE_AUTOMUTE_CALL_EVENT:
					class = [BRConfigureAutoMuteCallEvent class];
					break;
				case BR_CONFIGURE_MUTE_TONE_VOLUME_EVENT:
					class = [BRConfigureMuteToneVolumeEvent class];
					break;
				case BR_CONFIGURATION_FOR_A_CONNECTED_HEADSET_EVENT:
					class = [BRConfigurationForAConnectedHeadsetEvent class];
					break;
				case BR_CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_EVENT:
					class = [BRConfigureSecondInboundCallRingTypeEvent class];
					break;
				case BR_MUTE_OFF_VP_ENABLE_STATUS_CHANGED_EVENT:
					class = [BRMuteOffVPEnableStatusChangedEvent class];
					break;
				case BR_SCO_OPEN_TONE_ENABLE_EVENT:
					class = [BRSCOOpenToneEnableEvent class];
					break;
				case BR_OLI_FEATURE_ENABLE_EVENT:
					class = [BROLIFeatureEnableEvent class];
					break;
				case BR_CONFIGURE_MUTE_ALERT_EVENT:
					class = [BRConfigureMuteAlertEvent class];
					break;
				case BR_CONFIGURE_SIGNAL_STRENGTH_EVENT_EVENT:
					class = [BRConfigureSignalStrengthEventEvent class];
					break;
				case BR_DSP_TUNING_DATA_EVENT:
					class = [BRDSPTuningDataEvent class];
					break;
				case BR_CUSTOM_BUTTON_EVENT:
					class = [BRCustomButtonEvent class];
					break;
				case BR_PLATFORM_SPECIFIC_INSTRUMENTATION_DATA_EVENT:
					class = [BRPlatformSpecificInstrumentationDataEvent class];
					break;
				case BR_CONFIGURE_CALLER_ANNOUNCEMENT_EVENT:
					class = [BRConfigureCallerAnnouncementEvent class];
					break;
				case BR_MANUFACTURING_TEST_MESSAGE_EVENT:
					class = [BRManufacturingTestMessageEvent class];
					break;
				case BR_SIGNAL_STRENGTH_EVENT:
					class = [BRSignalStrengthEvent class];
					break;
				case BR_FIND_HEADSET_LED_ALERT_STATUS_CHANGED_EVENT:
					class = [BRFindHeadsetLEDAlertStatusChangedEvent class];
					break;
				case BR_TRANSMIT_POWER_ENABLED_EVENT:
					class = [BRTransmitPowerEnabledEvent class];
					break;
				case BR_TRANSMIT_POWER_CHANGED_EVENT:
					class = [BRTransmitPowerChangedEvent class];
					break;
				case BR_VOICE_SILENT_DETECTION_SETTING_CHANGED_EVENT:
					class = [BRVoiceSilentDetectionSettingChangedEvent class];
					break;
				case BR_VOICE_SILENT_DETECTED_EVENT:
					class = [BRVoiceSilentDetectedEvent class];
					break;
				case BR_TATTOO_SERIAL_NUMBER_EVENT:
					class = [BRTattooSerialNumberEvent class];
					break;
				case BR_TATTOO_BUILD_CODE_EVENT:
					class = [BRTattooBuildCodeEvent class];
					break;
				case BR_PART_NUMBER_EVENT:
					class = [BRPartNumberEvent class];
					break;
				case BR_USER_ID_EVENT:
					class = [BRUserIDEvent class];
					break;
				case BR_FIRST_DATE_USED_EVENT:
					class = [BRFirstDateUsedEvent class];
					break;
				case BR_CONFIGURE_VR_CALL_REJECT_AND_ANSWER_EVENT:
					class = [BRConfigureVRCallRejectAndAnswerEvent class];
					break;
				case BR_LAST_DATE_USED_EVENT:
					class = [BRLastDateUsedEvent class];
					break;
				case BR_LAST_DATE_CONNECTED_EVENT:
					class = [BRLastDateConnectedEvent class];
					break;
				case BR_CONFIGURE_A2DP_EVENT:
					class = [BRConfigureA2DPEvent class];
					break;
				case BR_TIME_USED_EVENT:
					class = [BRTimeUsedEvent class];
					break;
				case BR_USER_DEFINED_STORAGE_CHANGED_EVENT:
					class = [BRUserDefinedStorageChangedEvent class];
					break;
				case BR_SET_VOCALYST_PHONE_NUMBER_EVENT:
					class = [BRSetVocalystPhoneNumberEvent class];
					break;
				case BR_VOCALYST_INFO_NUMBER_EVENT:
					class = [BRVocalystInfoNumberEvent class];
					break;
				case BR_BATTERY_STATUS_CHANGED_EVENT:
					class = [BRBatteryStatusChangedEvent class];
					break;
				case BR_SET_GENES_GUID_EVENT:
					class = [BRSetGenesGUIDEvent class];
					break;
				case BR_CONFIGURE_MUTE_REMINDER_TIMING_EVENT:
					class = [BRConfigureMuteReminderTimingEvent class];
					break;
				case BR_SET_PAIRING_MODE_EVENT:
					class = [BRSetPairingModeEvent class];
					break;
				case BR_CONFIGURE_SPOKEN_ANSWERIGNORE_COMMAND_EVENT:
					class = [BRConfigureSpokenAnswerignoreCommandEvent class];
					break;
				case BR_LOW_BATTERY_VOICE_PROMPT_EVENT:
					class = [BRLowBatteryVoicePromptEvent class];
					break;
				case BR_CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_EVENT:
					class = [BRConfigureLyncDialToneOnCallPressEvent class];
					break;
				case BR_CLEAR_TOMBSTONE_EVENT:
					class = [BRClearTombstoneEvent class];
					break;
				case BR_BLUETOOTH_CONNECTION_EVENT:
					class = [BRBluetoothConnectionEvent class];
					break;
				case BR_CONNECTED_DEVICE_EVENT:
					class = [BRConnectedDeviceEvent class];
					break;
				case BR_DISCONNECTED_DEVICE_EVENT:
					class = [BRDisconnectedDeviceEvent class];
					break;
				case BR_CALL_STATUS_CHANGE_EVENT:
					class = [BRCallStatusChangeEvent class];
					break;
				case BR_MICROPHONE_MUTE_STATE_EVENT:
					class = [BRMicrophoneMuteStateEvent class];
					break;
				case BR_TRANSMIT_AUDIO_STATE_EVENT:
					class = [BRTransmitAudioStateEvent class];
					break;
				case BR_RECEIVE_AUDIO_STATE_EVENT:
					class = [BRReceiveAudioStateEvent class];
					break;
				case BR_LED_STATUS_GENERIC_EVENT:
					class = [BRLEDStatusGenericEvent class];
					break;
				case BR_HEADSET_AVAILABLE_EVENT:
					class = [BRHeadsetAvailableEvent class];
					break;
				case BR_SPEAKER_VOLUME_EVENT:
					class = [BRSpeakerVolumeEvent class];
					break;
				case BR_TRAINING_HEADSET_CONNECTION_EVENT:
					class = [BRTrainingHeadsetConnectionEvent class];
					break;
				case BR_CURRENT_SELECTED_LANGUAGE_CHANGED_EVENT:
					class = [BRCurrentSelectedLanguageChangedEvent class];
					break;
				case BR_AUDIO_STATUS_EVENT:
					class = [BRAudioStatusEvent class];
					break;
				case BR_HEADSET_CALL_STATUS_EVENT:
					class = [BRHeadsetCallStatusEvent class];
					break;
				case BR_EXTENDED_CALL_STATUS_CHANGE_EVENT:
					class = [BRExtendedCallStatusChangeEvent class];
					break;
				case BR_SET_RINGTONE_EVENT:
					class = [BRSetRingtoneEvent class];
					break;
				case BR_SET_AUDIO_BANDWIDTH_EVENT:
					class = [BRSetAudioBandwidthEvent class];
					break;
				case BR_SET_RINGTONE_VOLUME_EVENT:
					class = [BRSetRingtoneVolumeEvent class];
					break;
				case BR_SET_DEFAULT_OUTBOUND_INTERFACE_EVENT:
					class = [BRSetDefaultOutboundInterfaceEvent class];
					break;
				case BR_SET_VOLUME_CONTROL_ORIENTATION_EVENT:
					class = [BRSetVolumeControlOrientationEvent class];
					break;
				case BR_AAL_ACOUSTIC_INCIDENT_REPORTING_ENABLE_EVENT:
					class = [BRAALAcousticIncidentReportingEnableEvent class];
					break;
				case BR_AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_EVENT:
					class = [BRAALAcousticIncidentReportingThresholdsEvent class];
					break;
				case BR_AAL_ACOUSTIC_INCIDENT_REPORT_EVENT:
					class = [BRAALAcousticIncidentReportEvent class];
					break;
				case BR_AAL_TWA_REPORTING_ENABLE_EVENT:
					class = [BRAALTWAReportingEnableEvent class];
					break;
				case BR_AAL_TWA_REPORTING_TIME_PERIOD_EVENT:
					class = [BRAALTWAReportingTimePeriodEvent class];
					break;
				case BR_AAL_TWA_REPORT_EVENT:
					class = [BRAALTWAReportEvent class];
					break;
				case BR_CONVERSATION_DYNAMICS_REPORTING_ENABLE_EVENT:
					class = [BRConversationDynamicsReportingEnableEvent class];
					break;
				case BR_CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_EVENT:
					class = [BRConversationDynamicsReportingTimePeriodEvent class];
					break;
				case BR_CONVERSATION_DYNAMICS_REPORT_EVENT:
					class = [BRConversationDynamicsReportEvent class];
					break;
				case BR_SET_ANTISTARTLE_EVENT:
					class = [BRSetAntistartleEvent class];
					break;
				case BR_SET_G616_EVENT:
					class = [BRSetG616Event class];
					break;
				case BR_SET_TIMEWEIGHTED_AVERAGE_EVENT:
					class = [BRSetTimeweightedAverageEvent class];
					break;
				case BR_SET_TIMEWEIGHTED_AVERAGE_PERIOD_EVENT:
					class = [BRSetTimeweightedAveragePeriodEvent class];
					break;
				case BR_BLUETOOTH_DSP_STATUS_CHANGED_EVENT:
					class = [BRBluetoothDSPStatusChangedEvent class];
					break;
				case BR_BLUETOOTH_DSP_STATUS_CHANGED_LONG_EVENT:
					class = [BRBluetoothDSPStatusChangedLongEvent class];
					break;
				case BR_BLUETOOTH_DSP_LOAD_CHANGED_EVENT:
					class = [BRBluetoothDSPLoadChangedEvent class];
					break;
				case BR_DSP_PARAMETERS_EVENT:
					class = [BRDSPParametersEvent class];
					break;
				case BR_SET_FEATURE_LOCK_EVENT:
					class = [BRSetFeatureLockEvent class];
					break;
				case BR_HAL_CURRENT_SCENARIO_EVENT:
					class = [BRHalCurrentScenarioEvent class];
					break;
				case BR_HAL_CONFIGURE_VOLUME_EVENT:
					class = [BRHalConfigureVolumeEvent class];
					break;
				case BR_HAL_EQ_CHANGED_EVENT:
					class = [BRHalEQChangedEvent class];
					break;
				case BR_SUBSCRIBE_TO_SERVICES_EVENT:
					class = [BRSubscribeToServicesEvent class];
					break;
				case BR_SUBSCRIBED_SERVICE_DATA_EVENT:
					class = [BRSubscribedServiceDataEvent class];
					break;
				case BR_SERVICE_CONFIGURATION_CHANGED_EVENT:
					class = [BRServiceConfigurationChangedEvent class];
					break;
				case BR_SERVICE_CALIBRATION_CHANGED_EVENT:
					class = [BRServiceCalibrationChangedEvent class];
					break;
				case BR_APPLICATION_CONFIGURATION_CHANGED_EVENT:
					class = [BRApplicationConfigurationChangedEvent class];
					break;
				case BR_APPLICATION_ACTION_RESULT_EVENT:
					class = [BRApplicationActionResultEvent class];
					break;
				case BR_PASS_THROUGH_PROTOCOL_EVENT:
					class = [BRPassThroughProtocolEvent class];
					break;

				default:
					NSLog(@"Error: unknown Deckard event 0x%04X", deckardID);
					// some way to relay this would be nice
					break;
			}
			break;

		default:
			DLog(DLogLevelWarn, @"Error: unknown message type 0x%01X", messageType);
			break;
	}

	if (class) {
		return [class messageWithData:data];
	}

	return nil;
}

@end
