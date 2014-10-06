//
//  Device_Internal.swift
//  PLTDevice
//
//  Created by Morgan Davis on 6/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

import Foundation


extension Device {
	
	// MARK: Private Properties
	
//	// Accessor Redeclarations
//	var address:							String
//	var isConnectionOpen:					Boolean;
//	var model:								String
//	var name:								String
//	var serialNumber:						String
//	var hardwareVersion:					String
//	var firmwareVersion:					String
//
//	
//	// Private Accessors
//	var brDevice:							BRDevice
//	var brSensorsDevice:					BRDevice
//	var subscriptions:						NSMutableDictionary
//	var querySubscribers:					NSMutableDictionary
//	var cachedInfo:							NSMutableDictionary
//	
//
//
//	
//	@property(nonatomic,strong,readwrite)	NSArray								*supportedServices;
//	
//	@property(nonatomic,assign)				int8_t								remotePort;
//	@property(nonatomic,strong)				NSTimer								*wearingStateTimer;
//	@property(nonatomic,strong)				NSTimer								*signalStrengthTimer;
//	
//	@property(nonatomic,assign)				BOOL								waitingForRemoteSignalStrengthEvent;
//	@property(nonatomic,assign)				BOOL								waitingForLocalSignalStrengthEvent;
//	@property(nonatomic,strong)				BRSignalStrengthEvent				*localQuerySignalStrengthEvent;
//	@property(nonatomic,strong)				BRSignalStrengthEvent				*remoteQuerySignalStrengthEvent;
//	@property(nonatomic,assign)				BOOL								waitingForRemoteSignalStrengthSettingResult;
//	@property(nonatomic,assign)				BOOL								waitingForLocalSignalStrengthSettingResult;
//	@property(nonatomic,strong)				BRSignalStrengthSettingResult		*localQuerySignalStrengthResponse;
//	@property(nonatomic,strong)				BRSignalStrengthSettingResult		*remoteQuerySignalStrengthResponse;
//	
//	#warning reset these on open/close/whatever
//	@property(nonatomic,strong)				PLTOrientationTrackingCalibration	*orientationTrackingCalibration;
//	@property(nonatomic,assign)				NSUInteger							pedometerOffset;
//	@property(nonatomic,assign)				BOOL								queryingOrientationTrackingForCalibration;
	
	// MARK: Private Methods
	
	func didOpenConnection() {
		
	}
	
	func didCloseConnection(notify: Bool) {
		
	}
	
//	func didGet(productNameSettingResponce : BRProductNameSettingResult) {
//		
//	}
//	
//	func didGet(genesGUIDSettingResult : BRGenesGUIDSettingResult) {
//		
//	}
//	
//	func didGet(deviceInfoSettingResult : BRDeviceInfoSettingResult) {
//		
//	}

	func configureSignalStrengthEvents(enabled: Boolean, connectionID: UInt8) {
		
	}
	
	func querySignalStrength(connectionID: UInt8) {
		
	}
	
	func startWearingStateTimer(period: UInt16) {
		
	}
	
	func startSignalStrengthTimer(period: UInt16) {
		
	}

	func wearingStateTimer(timer: NSTimer) {
		
	}
	
	func signalStrengthTimer(timer: NSTimer) {
		
	}
}

