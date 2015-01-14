//
//  ViewController.swift
//  WebRTC14DemoBeacon
//
//  Created by Morgan Davis on 10/16/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

import Cocoa
import CoreBluetooth


class ViewController: NSViewController, CBPeripheralManagerDelegate {
	
	let serviceUUID = "515A5123-1287-40E5-9805-7E49BA08A092"
	
	@IBOutlet var advertisingStateLabel: NSTextField!
	@IBOutlet var startStopAdvertisingButton: NSButton!
	
	var peripheralManager: CBPeripheralManager?
	var waitingForBTPowerOn: Bool = false
	
	
	// MARK: Private
	
	@IBAction func startStopAdvertisingButton(sender: AnyObject!) {
		NSLog("startStopButton()")
		
		if let pm = self.peripheralManager {
			if pm.state == .PoweredOn {
				if pm.isAdvertising {
					NSLog("Stopping advertising...")
					pm.stopAdvertising()
					updateUIForAdvertising(false)
				}
				else {
					NSLog("Starting advertising (service UUID %@)...", self.serviceUUID)
					var advertisingData = [CBAdvertisementDataLocalNameKey: "PLTBeacon",
						CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: self.serviceUUID)],
						CBAdvertisementDataIsConnectable: false]
					
					NSLog("advertisingData: \(advertisingData)");
					
					pm.startAdvertising(advertisingData)
				}
			}
			else {
				self.waitingForBTPowerOn = true
			}
		}
	}
	
	func updateUIForAdvertising(flag: Bool) {
		if flag {
			self.advertisingStateLabel.stringValue = "Advertising"
			self.startStopAdvertisingButton.title = "Stop Advertising"
		}
		else {
			self.advertisingStateLabel.stringValue = "Not Advertising"
			self.startStopAdvertisingButton.title = "Start Advertising"
		}
	}
	
	
	// MARK: CBPeripheralManagerDelegate
	
	func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
		NSLog("peripheralManagerDidUpdateState:")
		
		if let pm = self.peripheralManager {
			switch peripheral.state {
			case .PoweredOn:
				if self.waitingForBTPowerOn {
					startStopAdvertisingButton(self)
				}
			default:
				NSLog("state: \(peripheralManager?.state.rawValue)")
			}
		}
	}
	
	func peripheralManager(peripheral: CBPeripheralManager!, willRestoreState dict: [NSObject : AnyObject]!) {
		
	}
	
	func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
		NSLog("peripheralManagerDidStartAdvertising")
		
		if let e = error {
			if e.code != 0 {
				NSLog("ERROR: \(e)")
			}
		}
		
		updateUIForAdvertising(peripheral.isAdvertising)
		
		if peripheral.isAdvertising {
			NSLog("Yep, advertising.")
		}
		else {
			NSLog("Neg. Not Advertising.")
		}
	}
	
	func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!) {
		
	}
	
	func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
		
	}
	
	func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
		
	}
	
	func peripheralManager(peripheral: CBPeripheralManager!, didReceiveReadRequest request: CBATTRequest!) {
		
	}
	
	func peripheralManager(peripheral: CBPeripheralManager!, didReceiveWriteRequests requests: [AnyObject]!) {
		
	}
	
	func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
		
	}
	
	
	// MARK: NSViewController
	
	override func viewDidAppear() {
		super.viewDidAppear()
		startStopAdvertisingButton(self)
	}
	
	
	// MARK: Constructors
	
	required init!(coder: NSCoder!) { 
		super.init(coder: coder)
		self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
	}
}
