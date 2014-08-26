//
//  Device.swift
//  PLTDevice
//
//  Created by Morgan Davis on 6/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

import Foundation
import PLTDeviceWatcher


class Device {
	
	// MARK: Types
	
	struct Notifications {
		struct NewDeviceAvailable {
			static let name = "Device.Notifications.NewDeviceAvailable"
			struct UserInfo {
				static let device = "Device.Notifications.NewDeviceAvailable.UserInfo.Device"
			}
		}
		struct DidOpenConnection {
			static let name = "Device.Notifications.DidOpenConnection"
			struct UserInfo {
				static let device = "Device.Notifications.NewDeviceAvailable.UserInfo.Device"
			}
		}
		struct DidFailOpenConnection {
			static let name = "Device.Notifications.DidFailOpenConnection"
			struct UserInfo {
				static let device = "Device.Notifications.NewDeviceAvailable.UserInfo.Device"
				static let error = "Device.Notifications.NewDeviceAvailable.UserInfo.Error"
			}
		}
		struct DidCloseConnection {
			static let name = "Device.Notifications.DidCloseConnection"
			struct UserInfo {
				static let device = "Device.Notifications.NewDeviceAvailable.UserInfo.Device"
			}
		}
	}
	
	enum Service: Int {
		case WearingState =					0x1000
		case Proximity =					0x1001
		case OrientationTracking =			0x0000
		case Pedometer =					0x0002
		case FreeFall =						0x0003
		case Taps =							0x0004
		case MagnetometerCalStatus =		0x0005
		case GyroscopeCalibrationStatus =	0x0006
	}
	
	enum SubscriptionMode: Int {
		case OnChange = 0x01
		case Periodic = 0x02
	}
	
	// MARK: Properties
	
	var isConnectionOpen:	Bool =		false
	var address:			String?
	var model:				String?
	var name:				String?
	var erialNumber:		String?
	var hardwareVersion:	String?
	var firmwareVersion:	String?
	var supportedServices:	String[]?
	
	// MARK: Initializers
	
	init(address: String) {
		self.address = address
	}
	
	// MARK: Discovering Devices
	
	class func availableDevices() -> Device[] {
//		var watcher: PLTDeviceWatcher
//		var devices = PLTDeviceWatcher.availableDevices()
//		println(devices)
		return []
	}
	
	// MARK: Connecting to and Disconnecting from Fevices
	
	func openConnection() {
		
	}
	
	func closeConnection() {
		
	}
	
	// MARK: Setting and Reading Service Configurations
	
	func setConfiguration(configuration: Configuration, forServive service: Service) -> NSError {
		 return NSError()
	}
	
	func configuration(configurationForService service: Service) -> Configuration {
		return Configuration()
	}
	
	// MARK: Setting and Reading Service Calibrations
	
	func setCalibration(configuration: Calibration, forServive service: Service) -> NSError {
		return NSError()
	}
	
	func calibration(calibrationForService service: Service) -> Calibration {
		return Calibration()
	}

	// MARK: Subscribing to and Unsubscribing from Service Info
	
	func subscribe(subscriber: DeviceSubscriber, toService service: Service, withMode mode: SubscriptionMode, andPeriod period: Int) -> NSError {
		return NSError()
	}
	
	func unsubscribe(subscriber: DeviceSubscriber, fromService service: Service) {
		
	}
	
	func unsubscribeFromAll(subscriber: DeviceSubscriber) {
		
	}

	// MARK: Querying Service Info
	
	func queryInfo(subscriber: DeviceSubscriber, service: Service) {
		
	}
	
	// MARK: Getting Cached Service Info
	
	func cachedInfo(forService service: Service) -> Info {
		return Info()
	}
}

// MARK: Protocols

protocol DeviceSubscriber {
	func device(device: Device, didUpdateInfo info: Info)
	func device(device: Device, didChangeSubscription oldSubscription: Subscription, toSubscription newSubscription: Subscription)
}
