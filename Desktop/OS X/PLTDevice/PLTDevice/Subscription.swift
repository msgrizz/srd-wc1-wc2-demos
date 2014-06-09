//
//  Subscription.swift
//  PLTDevice
//
//  Created by Morgan Davis on 6/3/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

import Foundation


class Subscription {
	
	// MARK: Properties
	
	//var service:		Device.Service
	//var mode:			Device.SubscriptionMode
	//var	period:			UInt16
	
	// MARK: Initializers
	
	init() {
//		self.service = Device.Service.OrientationTracking
//		self.mode = Device.SubscriptionMode.OnChange
//		self.period = 0
	}
	
	// PRIVATE ?!?!?!?!
	
	//var	subscribers:	NSMutableArray =		[]
	
//	convenience init(service: Device.Service, mode: Device.SubscriptionMode, period: UInt16, subscriber: DeviceSubscriber!) {
//		self.init()
//		self.service = service
//		self.mode = mode
//		self.period = period
//		self.subscribers.addObject(subscriber)
//	}
	
	func addSubscriber(subscriber: DeviceSubscriber!) {
//		removeSubscriber(subscriber)
//		if (!self.subscribers.containsObject(subscriber)) {
//			self.subscribers.addObject(subscriber);
//		}
	}
	
	func removeSubscriber(subscriber: DeviceSubscriber!) {
		//self.subscribers.removeObject(subscriber)
	}
	
	func privateDescription() -> String {
		return ""
	}
}
