//
//  ViewController.mm
//  BRPlayground
//
//  Created by Davis, Morgan on 12/3/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <bladerunner_ios_sdk/BladeRunnerDeviceManager.h>
#include "DeviceListenerImpl.h"
#include "DeviceOpenListenerImpl.h"
#include "DeviceMetadataListenerImpl.h"
#include "DeviceEventListenerImpl.h"
//#import <bladerunner_ios_sdk/BladeRunnerRemoteDevice.h>


using namespace std;
using namespace bladerunner;

#define TIME_OUT_INTERVAL 16.0


@interface ViewController () <DevicelistenerDelegate, DeviceOpenListenerDelegate, DeviceMetadataListenerDelegate, DeviceEventListenerDelegate>

- (IBAction)discoverDevicesButton:(id)sender;
- (IBAction)openConnectionButton:(id)sender;
- (IBAction)queryWearingStateButton:(id)sender;
//- (IBAction)muteButton:(id)sender;
//- (IBAction)unmuteButton:(id)sender;
- (IBAction)openRemoteConnection2Button:(id)sender;
- (IBAction)openRemoteConnection3Button:(id)sender;
- (IBAction)openRemoteConnection5Button:(id)sender;
- (IBAction)subscribeHTButton:(id)sender;
//- (void)setMicGain:(byte)gain;
- (void)timeout:(NSTimer *)theTimer;
- (void)connectToRemoteDeviceOnPort:(byte)port;
- (IBAction)queryRemoteCallStateButton:(id)sender;
- (IBAction)endRemoteCallButton:(id)sender;

@property(nonatomic, assign)    BladeRunnerDevice           *device;
@property(nonatomic, assign)    DeviceOpenListenerImpl      *openListener;
@property(nonatomic, assign)    DeviceMetadataListenerImpl  *metadataListener;
@property(nonatomic, assign)    DeviceEventListenerImpl     *eventListener;
@property(nonatomic, strong)    NSTimer                     *timeoutTimer;
@property(nonatomic, assign)    set<SignatureDescription>   settingsSignatures;
@property(nonatomic, assign)    set<SignatureDescription>   eventSignatures;
@property(nonatomic, strong)    NSTimer                     *htTimer;
@property(nonatomic, assign)    IBOutlet UILabel            *htLabel;

@property(nonatomic, assign)    BladeRunnerDevice           *remoteDevice;

@end


@implementation ViewController

#pragma mark - Private

- (IBAction)discoverDevicesButton:(id)sender
{
    BladeRunnerDeviceManager* manager = BladeRunnerDeviceManager::getManager();
    if (manager) {
        DeviceListenerImpl *listener = new DeviceListenerImpl();
        if (listener) {
            listener->delegate = (id)self;
            bool res = manager->discoverBladeRunnerDevices(listener);
            NSLog(@"Result: %@", (res ? @"YES" : @"NO"));
            delete listener;
        }
        else {
            NSLog(@"Listener is null.");
        }
    }
    else {
        NSLog(@"Device manager is null.");
    }
}

- (IBAction)openConnectionButton:(id)sender
{
    NSArray *connectedAccessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    NSLog(@"connectedAccessories: %@", connectedAccessories);
    if ([connectedAccessories count] > 0) {
        BladeRunnerDeviceManager *manager = BladeRunnerDeviceManager::getManager();
        
        if (manager) {
            std::string address = [[connectedAccessories[0] serialNumber] UTF8String];
            //if (address != NULL) {
                self.device = manager->newDevice(address);
                if (self.device) {
                    BRError error = BRError_Success;
                   
                    // register to receive setting outputs
                    self.settingsSignatures = SignatureDefinitions::Settings::getSignatures();
                    error = self.device->registerSettingOutputSignatures(_settingsSignatures); // why?
                    if (error != BRError_Success) {
                        NSLog(@"Failed to register setting output signatures: %d", error);
                        return;
                    }
                    
                    // register metadata listener
                    self.metadataListener = new DeviceMetadataListenerImpl();
                    self.metadataListener->delegate = self;
                    error = self.device->addMetadataListener(self.metadataListener);
                    if (error != BRError_Success) {
                        NSLog(@"Failed to add metadata listener: %d", error);
                        return;
                    }
                    
                    // register event listener
                    self.eventSignatures = SignatureDefinitions::Events::getSignatures();
                    
//                    vector<BRType> *HT_EVENT_PAYLOAD_OUT = new std::vector<BRType>;
//                    HT_EVENT_PAYLOAD_OUT->push_back(BR_TYPE_UNSIGNED_SHORT);
//                    HT_EVENT_PAYLOAD_OUT->push_back(BR_TYPE_BYTE_ARRAY);
//                    SignatureDescription *htEvent = new SignatureDescription(0xFF1A, *HT_EVENT_PAYLOAD_OUT);
//                    _eventSignatures.insert(*htEvent);
//                    
//                    for(set<SignatureDescription>::iterator i = _eventSignatures.begin(); i != _eventSignatures.end(); ++i) {
//                        //NSLog(@"Type: %d", (*i).getID());
//                    }
                    NSLog(@"%lu known events.", self.eventSignatures.size());
                    error = self.device->registerEventSignatures(_eventSignatures); // why?
                    self.eventListener = new DeviceEventListenerImpl();
                    self.eventListener->delegate = self;
                    error = self.device->addEventListener(self.eventListener);
                    if (error != BRError_Success) {
                        NSLog(@"Failed to add event listener: %d", error);
                        return;
                    }
                    
                    // register open listener
                    if (!self.openListener) {
                        self.openListener = new DeviceOpenListenerImpl();
                        self.openListener->delegate = self;
                        error = self.device->addOpenListener(self.openListener);
                        if (error != BRError_Success) {
                            NSLog(@"Failed to add open listener: %d", error);
                            return;
                        }
                    }
                    
                    // open device connection
                    byte port = 0;
                    error = self.device->open(port);
                    if (error == BRError_DeviceAlreadyOpen) {
                        NSLog(@"Device already open.");
                    }
                    if (error == BRError_Success) {
                        NSLog(@"Opening connection on port %d...", port);
                        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_OUT_INTERVAL target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
                    }
                    else {
                        NSLog(@"Failed to open connection: %d", error);
                    }
                }
                else {
                    NSLog(@"Device is null.");
                }
//            }
//            else {
//                result = @"Test Failed. No real device connected.";
//            }
        }
        else {
            NSLog(@"Device manager is null.");
        }
    }
    else {
        NSLog(@"No accessories connected.");
    }
}

- (IBAction)queryWearingStateButton:(id)sender
{
    if (self.device != NULL && self.device->isOpen()) {
        DeviceSettingType *dst = new DeviceSettingType(DEFAULT_TYPE);
        int16_t settingID = 0x0202; // wearing state
        BRError error = self.device->getSettingType(settingID, *dst);
        if (error == BRError_Success) {
            DeviceSetting *ds = new DeviceSetting(self.device, *dst);
            delete dst;
            error = self.device->fetch(*ds);
            //delete ds;
            
            if (error == BRError_Success) {
                NSLog(@"Fetch returned BRError_Success.");
                
                BRProtocolElement value = BRProtocolElement(false);
                error = ds->getValue(value);
                if (error == BRError_Success) {
                    bool flag;
                    value.getValue(flag);
                    NSLog(@"Got setting: %@", (flag ? @"WEARING" : @"NOT WEARING"));
                }
                else {
                    NSLog(@"Error getting setting value: %d", error);
                }
                
                delete ds;
            }
            else {
                NSLog(@"Fetch failed: %d", error);
            }
        }
        else {
            NSLog(@"Failed to get setting type for setting ID %04X: %d", settingID, error);
        }
    }
    else {
        NSLog(@"Device not open.");
    }
}

//- (IBAction)muteButton:(id)sender
//{
//    [self setMicGain:0x00];
//}
//
//- (IBAction)unmuteButton:(id)sender
//{
//    [self setMicGain:0x0F];
//}

- (IBAction)openRemoteConnection2Button:(id)sender
{
    [self connectToRemoteDeviceOnPort:2];
}

- (IBAction)openRemoteConnection3Button:(id)sender
{
    [self connectToRemoteDeviceOnPort:3];
}

- (IBAction)openRemoteConnection5Button:(id)sender
{
    [self connectToRemoteDeviceOnPort:5];
}

- (IBAction)subscribeHTButton:(id)sender
{
    NSLog(@"subscribeHTButton");
    if (self.device != NULL && self.device->isOpen()) {
        int16_t commandID = 0xFF0A; // subscribe to HT
        DeviceCommandType *dct = new DeviceCommandType(commandID);
        BRError error = self.device->getCommandType(commandID, *dct);
        if (error != BRError_Success ) {
            NSLog(@"Error getting command type: %d", error);
            return;
        }
        DeviceCommand *dc = new DeviceCommand(self.device ,*dct);
        delete dct;
        
        if (dc) {
            vector<BRProtocolElement> els;
            els.push_back(BRProtocolElement((short)0x0000));
            els.push_back(BRProtocolElement((short)0x0000));
            els.push_back(BRProtocolElement((short)1));
            els.push_back(BRProtocolElement((short)0));
            error = dc->perform(els);
            
            if (error == BRError_PerformCommandFailure) {
                if (dc->isSuccess() == PerformCommandSuccess_Failure) {
                    int16_t exceptionId;
                    vector<BRProtocolElement> data;
                    error = dc->getExceptionData(exceptionId, data);
                    delete dc;
                    
                    if (error == BRError_Success) {
#warning TODO - get exception data.
                        NSLog(@"Exception.");
                    }
                    else {
                        NSLog(@"Error getting exception data: %d", error);
                    }
                }
                else {
                    NSLog(@"Command executed (2).");
                }
            }
            else {
                NSLog(@"Command executed (1).");
            }
        }
        else {
            NSLog(@"Invalid command.");
        }
    }
    else {
        NSLog(@"Device not open.");
    }
}

- (void)setMicGain:(byte)gain
{
    NSLog(@"Set mic gain: %02X", gain);
    if (self.device != NULL && self.device->isOpen()) {
        int16_t commandID = 0x0E08; // audio transmit gain
        //        DeviceCommandType *dct = new DeviceCommandType(commandID);
        //        DeviceCommand *dc = new DeviceCommand(self.device ,*dct);
        //        delete dct;
        
        DeviceCommandType *dct = new DeviceCommandType(commandID);
        BRError error = self.device->getCommandType(commandID, *dct);
        if (error != BRError_Success ) {
            NSLog(@"Error getting command type: %d", error);
            return;
        }
        DeviceCommand *dc = new DeviceCommand(self.device ,*dct);
        delete dct;
        
        if (dc) {
            BRProtocolElement el1 = BRProtocolElement(gain);
            vector<BRProtocolElement> els;
            els.push_back(el1);
            error = dc->perform(els);
            //error = self.device->perform(*dc, els);
            
            if (error == BRError_PerformCommandFailure) {
                if (dc->isSuccess() == PerformCommandSuccess_Failure) {
                    int16_t exceptionId;
                    vector<BRProtocolElement> data;
                    error = dc->getExceptionData(exceptionId, data);
                    delete dc;
                    
                    if (error == BRError_Success) {
#warning TODO - get exception data.
                        NSLog(@"Exception.");
                    }
                    else {
                        NSLog(@"Error getting exception data: %d", error);
                    }
                }
                else {
                    NSLog(@"Command executed (2).");
                }
            }
            else {
                NSLog(@"Command executed (1).");
            }
        }
        else {
            NSLog(@"Invalid command.");
        }
    }
    else {
        NSLog(@"Device not open.");
    }
}

- (void)timeout:(NSTimer *)theTimer
{
    NSLog(@"Timeout.");
}

- (void)connectToRemoteDeviceOnPort:(byte)port
{
    BladeRunnerDeviceManager *manager = BladeRunnerDeviceManager::getManager();
    if (manager) {
        NSLog(@"Openning connection to remote device on port %d...", port);
        BRError error = manager->newDevice(*(_device), port, &(_remoteDevice));
        NSLog(@"error: %d", error);
        if (error == BRError_Success && self.remoteDevice) {
            BRError error = BRError_Success;
            
//            error = self.remoteDevice->checkOpen();
//            NSLog(@"open? %d", error);
            
            // register to receive setting outputs
            self.settingsSignatures = SignatureDefinitions::Settings::getSignatures();
            error = self.remoteDevice->registerSettingOutputSignatures(_settingsSignatures); // why?
            if (error != BRError_Success) {
                NSLog(@"Failed to register setting output signatures: %d", error);
                return;
            }
            
            // register metadata listener
            self.metadataListener = new DeviceMetadataListenerImpl();
            self.metadataListener->delegate = self;
            error = self.remoteDevice->addMetadataListener(self.metadataListener);
            if (error != BRError_Success) {
                NSLog(@"Failed to add metadata listener: %d", error);
                return;
            }
             
            // register event listener
            self.eventSignatures = SignatureDefinitions::Events::getSignatures();
            
            if (port==5) {
                // since the SDK was built with a Deckard version without BaDangle/WC1 messages, we artificially insert the "Subscribed service data" event payload signature
                vector<BRType> *HT_EVENT_PAYLOAD_OUT = new std::vector<BRType>;
                HT_EVENT_PAYLOAD_OUT->push_back(BR_TYPE_UNSIGNED_SHORT);
                HT_EVENT_PAYLOAD_OUT->push_back(BR_TYPE_UNSIGNED_SHORT);
                HT_EVENT_PAYLOAD_OUT->push_back(BR_TYPE_BYTE_ARRAY);
                HT_EVENT_PAYLOAD_OUT->push_back(BR_TYPE_BYTE_ARRAY);
                SignatureDescription *htEvent = new SignatureDescription(0xFF1A, *HT_EVENT_PAYLOAD_OUT);
                _eventSignatures.insert(*htEvent);
            }
            
            for(set<SignatureDescription>::iterator i = _eventSignatures.begin(); i != _eventSignatures.end(); ++i) {
                //NSLog(@"Type: %d", (*i).getID());
            }
            //NSLog(@"%lu events.", self.eventSignatures.size());
            error = self.remoteDevice->registerEventSignatures(_eventSignatures); // why?
            self.eventListener = new DeviceEventListenerImpl();
            self.eventListener->delegate = self;
            error = self.remoteDevice->addEventListener(self.eventListener);
            if (error != BRError_Success) {
                NSLog(@"Failed to add event listener: %d", error);
                return;
            }
            
            // register open listener
            //if (!self.openListener) {
                self.openListener = new DeviceOpenListenerImpl();
                self.openListener->delegate = self;
                error = self.remoteDevice->addOpenListener(self.openListener);
                if (error != BRError_Success) {
                    NSLog(@"Failed to add open listener: %d", error);
                    return;
                }
            //}
            
            // open device connection
            // NOTICE 'newPort' is never set to 'port' from the function arguments. in face, in the source for open(), newPort is SET to 1. (??)
            byte newPort;
            error = self.remoteDevice->open(newPort);
            if (error == BRError_DeviceAlreadyOpen) {
                NSLog(@"Device already open.");
            }
            if (error == BRError_Success) {
                NSLog(@"Opening remote connection on port %d...", newPort);
                self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_OUT_INTERVAL target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
            }
            else {
                NSLog(@"Failed to open connection: %d", error);
            }
        }
        else {
            NSLog(@"Device is null.");
        }
    }
    else {
        NSLog(@"Device manager is null.");
    }
}

- (IBAction)queryRemoteCallStateButton:(id)sender
{
#warning not implemented
    if (self.device != NULL && self.device->isOpen()) {
        DeviceSettingType *dst = new DeviceSettingType(DEFAULT_TYPE);
        int16_t settingID = 0x0202; // wearing state
        BRError error = self.device->getSettingType(settingID, *dst);
        if (error == BRError_Success) {
            DeviceSetting *ds = new DeviceSetting(self.device, *dst);
            delete dst;
            error = self.device->fetch(*ds);
            //delete ds;
            
            if (error == BRError_Success) {
                NSLog(@"Fetch returned BRError_Success.");
                
                BRProtocolElement value = BRProtocolElement(false);
                error = ds->getValue(value);
                if (error == BRError_Success) {
                    bool flag;
                    value.getValue(flag);
                    NSLog(@"Got setting: %@", (flag ? @"WEARING" : @"NOT WEARING"));
                }
                else {
                    NSLog(@"Error getting setting value: %d", error);
                }
                
                delete ds;
            }
            else {
                NSLog(@"Fetch failed: %d", error);
            }
        }
        else {
            NSLog(@"Failed to get setting type for setting ID %04X: %d", settingID, error);
        }
    }
    else {
        NSLog(@"Device not open.");
    }
}

- (IBAction)endRemoteCallButton:(id)sender
{
    if (self.device != NULL && self.device->isOpen()) {
        int16_t commandID = 0x0E06; // call end
        //int16_t commandID = 0x0E0C; // make call
        //        DeviceCommandType *dct = new DeviceCommandType(commandID);
        //        DeviceCommand *dc = new DeviceCommand(self.device ,*dct);
        //        delete dct;
        
        DeviceCommandType *dct = new DeviceCommandType(commandID);
        BRError error = self.device->getCommandType(commandID, *dct);
        if (error != BRError_Success ) {
            NSLog(@"Error getting command type: %d", error);
            return;
        }
        DeviceCommand *dc = new DeviceCommand(self.device ,*dct);
        delete dct;
        
        if (dc) {
            //BRProtocolElement el1 = BRProtocolElement("8008263792");
            std::vector<BRProtocolElement> els;
            //els.push_back(el1);
            error = dc->perform(els);
            //error = self.device->perform(*dc, els);
            
            if (error == BRError_PerformCommandFailure) {
                if (dc->isSuccess() == PerformCommandSuccess_Failure) {
                    int16_t exceptionId;
                    std::vector<BRProtocolElement> data;
                    error = dc->getExceptionData(exceptionId, data);
                    delete dc;
                    
                    if (error == BRError_Success) {
#warning TODO - get exception data.
                        
                        for(vector<BRProtocolElement>::iterator i = data.begin(); i != data.end(); ++i) {
                            NSLog(@"Type: %d", (*i).getType());
                        }
                        
                        //                        namespace bladerunner
                        //                        {
                        //                            enum BRType
                        //                            {
                        //                                BR_TYPE_BOOLEAN = 1,
                        //                                BR_TYPE_BYTE,
                        //                                BR_TYPE_SHORT,
                        //                                BR_TYPE_UNSIGNED_SHORT,
                        //                                BR_TYPE_INT,
                        //                                BR_TYPE_UNSIGNED_INT,
                        //                                BR_TYPE_LONG,
                        //                                BR_TYPE_UNSIGNED_LONG,
                        //                                BR_TYPE_BYTE_ARRAY,
                        //                                BR_TYPE_SHORT_ARRAY,
                        //                                BR_TYPE_STRING,
                        //                                BR_TYPE_ENUM
                        //                            };
                        //                        }
                        
                        NSLog(@"Exception.");
                    }
                    else {
                        NSLog(@"Error getting exception data: %d", error);
                    }
                }
                else {
                    NSLog(@"Command executed (2).");
                }
            }
            else {
                NSLog(@"Command executed (1).");
            }
        }
        else {
            NSLog(@"Invalid command.");
        }
    }
    else {
        NSLog(@"Device not open.");
    }
}

#pragma mark - DevicelistenerDelegate

- (void)listenerFoundDevice:(BladeRunnerDevice &)device
{
    NSLog(@"listenerFoundDevice: %s", device.getBladeRunnerDeviceAddress().c_str());
}

- (void)listenerDiscoveryStopped:(bool)success
{
    NSLog(@"listenerDiscoveryStopped: %@", (success ? @"YES" : @"NO"));
}

#pragma mark - DeviceOpenListenerDelegate

//- (void)openlistenerCallBackWithSuccess:(BOOL)success
- (void)openListenerCallBackWithError:(BRError)error
{
    if (error == BRError_Success) {
        NSLog(@"Connection open.");
    }
    else {
        NSLog(@"Error opening connection: %d", error);
    }
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

#pragma mark - DeviceMetadataListenerDelegate

- (void)metadataListenerCallBackWithCommands:(set<DeviceCommandType>)commands Settings:(set<DeviceSettingType>)settings Events:(set<DeviceEventType>)events
{
    NSLog(@"Got metadata.");
    
    NSLog(@"Supported commands:");
    for (set<DeviceCommandType>::iterator i = commands.begin(); i != commands.end(); ++i) NSLog(@"0x%04X", (*i).getID());
    NSLog(@"Supported settings:");
    for (set<DeviceSettingType>::iterator i = settings.begin(); i != settings.end(); ++i) NSLog(@"0x%04X", (*i).getID());
    NSLog(@"Supported events:");
    for (set<DeviceEventType>::iterator i = events.begin(); i != events.end(); ++i) NSLog(@"0x%04X", (*i).getID());
}

#pragma mark - DeviceEventListenerDelegate

- (void)eventListenerCallBackWithEvent:(DeviceEvent)deviceEvent
{
    int16_t eventID = deviceEvent.getType().getID();
    NSLog(@"Event received: 0x%04X", eventID);
    
    if (eventID == SignatureDefinitions::Events::CONNECTED_DEVICE_EVENT) {
        vector<BRProtocolElement> eventData = deviceEvent.getEventData();
        byte port;
        BRError error = eventData[0].getValue(port);
        if (error != BRError_Success) {
            NSLog(@"Error %d getting event data.", error);
            return;
        }
        
        set<byte> allPorts = self.device->getConnectedPorts();
        NSMutableString *allPortsString = [@"" mutableCopy];
        for (set<byte>::iterator i = allPorts.begin(); i != allPorts.end(); ++i) {
            if ([allPortsString length]) [allPortsString appendString:@", "];
            [allPortsString appendFormat:@"%d", *i];
        }
        
        NSLog(@"Remote port available: %d [%@]", port, allPortsString);
        
        set<byte> ports = self.device->getConnectedPorts();
        byte aPort = 0;
        NSLog(@"Connected ports:");
        for (set<byte>::iterator i = ports.begin(); i != ports.end(); ++i) {
            aPort = (*i);
            NSLog(@"%d", aPort);
        }
//        static bool already = false;
//        if ((aPort > 1) && (aPort < 4)) {
//            if (!already) {
//                [self connectToRemoteDeviceOnPort:aPort];
//                already = true;
//            }
//        }
    }
    else if (eventID == SignatureDefinitions::Events::WEARING_STATE_CHANGED_EVENT) {
        vector<BRProtocolElement> eventData = deviceEvent.getEventData();
        bool wearing;
        BRError error = eventData[0].getValue(wearing);
        if (error != BRError_Success) {
            NSLog(@"Error %d getting event data.", error);
            return;
        }
        NSLog(@"%@", (wearing ? @"WEARING" : @"NOT WEARING"));
    }
}

#pragma mark - ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ViewController" bundle:nil];
    return self;
}

@end
