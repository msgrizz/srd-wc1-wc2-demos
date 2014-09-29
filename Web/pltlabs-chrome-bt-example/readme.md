#PLT Labs Javascript Library
=============
* http://pltlabs.com
* Twitter: [@pltlabs](http://twitter.com/pltlabs)
* Author: [@carybran](http://twitter.com/carybran)
---------
The source code in this repository is a Google Chrome packaged applicaiton.  The applicaiton highlights Plantronics device access over Bluetooth and will run on build 37 and greater of the Chrome browser (tested on Mac) as well as Chrome OS.  

Please make sure you have paired and connected your Plantronics Edge or Wearable Concept device with the host system.

Install the packaged application on Chrome, load it as an unpackaged app and make sure you have enabled debug mode and have signed into Google on the browser.


How to use this library
----------
The plt.msg library is used to create and parse messages that are sent to or origniate from PLT devices
that have M2M capabilities - for example the WC1, Voyager Edge

##Connecting to Plantronics through Google Chrome/Chrome OS
```javascript
//connecting to the PLT device that is paired and connected via Bluetooth with Chrome

//register event listeners for device lifecycle events
plt.addEventListener(function(event){ console.log('event -> ' + JSON.stringify(event));});
plt.addSettingsListener(function(settings){ console.log('settings -> ' + JSON.stringify(settings));});
plt.addCommandSuccessListener(function(commandResult){ console.log('command result -> ' + JSON.stringify(commandResult));});
plt.addOnConnectionListener(function(device){
  console.log("connection opened: callback has been invoked from plt api");
  console.log("device ->" + JSON.stringify(device));
  });
  
plt.addOnDisconnectListener(function(device){
  console.log("device disconnect from plt api -> device: " + JSON.stringify(device));
  });


//connecting to the PLT Labs device
plt.addDeviceListener(function(deviceList){
   console.log("device list connecting to device -> " + JSON.stringify(deviceList[0]));
   plt.connect(deviceList[0]);
   });

//gets the devices and calls back to the device listener   
plt.getDevices();

```
##Message Types:
* [Settings](#settings)
* [Commands](#commands)

##How to use the PLT Labs message library
```javascript
//if you create your own library to connect to PLT over BT Smart or USB, you can use the plt.msg library to create and parse
//messages that are sent and recieved from the PLT Device

//parsing a raw message regardless of type returns a JSON object representation of the raw message

var parsedMessage = plt.msg.parse(rawMessage);

//JSON format of the parsed message returned from the plt.msg.parse function call
// { 
//  type: packetType,
//  messageType: messageType,
//  messageTypeName: "message type friendly name",
//  length: length,
//  address: address,
//  payloadNibbles: arrayofnibbles,
//  messageBytes: bytearray,
//  payload: jsonobjectofnamevaluepairs
// }

//all PLT messages, regardless if it is a get setting request or a command have a type.
//A message type is a number the, plt.msg library contains constants for all
//of the available message types.
var commandId = plt.msg.CONFIGURE_MUTE_TONE_VOLUME_COMMAND; //value is 0x0400
var settingId = plt.msg.DEVICE_STATUS_SETTING; //value is 0x1006
  
   
//Regardless if you are creating a get setting or command message, the pattern is the same
//the first thing is to determine if the message requires additional properites beyond the message type
//to be passed into the plt.msg create message function.
//For example, the command create below shows how you would enable proximity events on the
//Plantronics device - to do so you create an options object and set the required attributes for
//the message creation.  
var options = {}
options.enable =  true;
options.sensitivity = 5;
options.nearThreshold = 0x3C;
options.maxTimeout = 0xFFFF;
var command = plt.msg.createCommand(plt.msg.CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND, options);

//send the command to connected device 
plt.sendMessage(device, command);

//In this example a get setting request message is created that does not require additional parameters
//when this request returns from the device it will contain the device's battery level information
var getSetting = plt.msg.createGetSetting(plt.msg.BATTERY_INFO_SETTING);

//send the command to connected device 
plt.sendMessage(device, getSetting);

//how to create a command to enable headtracking sensor data output
//This command takes advantage of the message addressing
//note that we have specified the sensor port on the device - which is port 5
//when the message is sent to the device, it will be routed to the address specified, which in this case is the sensor port
//for headtracking data.
var sensorPortAddress = new ArrayBuffer(4);
var sensorPortAddress_view = new Uint8Array(sensorPortAddress);
sensorPortAddress_view[0] = 0x50;
options = {};
options.address = sensorPortAddress;
options.serviceID = plt.msg.TYPE_SERVICEID_HEADORIENTATION;
options.mode = plt.msg.TYPE_MODEONCCHANGE;
var headtrackingCommand = plt.msg.createCommand(plt.msg.SUBSCRIBE_TO_SERVICES_COMMAND, options);

//send the command to connected device 
plt.sendMessage(device, headtrackingCommand);
  
```
<h3><a name="settings"></a>PLT Setting Messages</h3>
<b>When do you use this message?</b><br>
Setting messages are used to retrieve settings from the device.  Think of them as reading the configuration from the device and returning it.
To receive the settings response you must register a callback with the plt.addSettingsListener function.
<br>
Below is an exhaustive listing of all of the get settings messages that the device should support.
<br>
 
<h2>Settings Messages</h2>
<h3><a id="BUTTON_SIMULATION_CAPABILITIES_SETTING">Button Simulation Capabilities Setting</a></h3>
<b>Description:</b> Query for the IDs specifying the buttons that are supported to be simulated.<br>
<b>Message Id:</b> <i>plt.msg.BUTTON_SIMULATION_CAPABILITIES_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING">Indirect Event Simulation Capabilities Setting</a></h3>
<b>Description:</b> Query for the IDs specifying the indirect events that are supported to be simulated.<br>
<b>Message Id:</b> <i>plt.msg.INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="DEVICE_STATUS_CAPABILITIES_SETTING">Device Status Capabilities Setting</a></h3>
<b>Description:</b> Query for the IDs specifying the device status data that will be provided upon a device status query.<br>
<b>Message Id:</b> <i>plt.msg.DEVICE_STATUS_CAPABILITIES_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="DEVICE_STATUS_SETTING">Device Status Setting</a></h3>
<b>Description:</b> Query for the internal device status of a device under test.<br>
<b>Message Id:</b> <i>plt.msg.DEVICE_STATUS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CUSTOM_DEVICE_STATUS_SETTING">Custom Device Status Setting</a></h3>
<b>Description:</b> Query for the internal device specific custom status of a device under test with engineering defined formatting for the specific device.<br>
<b>Message Id:</b> <i>plt.msg.CUSTOM_DEVICE_STATUS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SINGLE_NVRAM_CONFIGURATION_READ_SETTING">Single NVRAM Configuration Read Setting</a></h3>
<b>Description:</b> Query for the configuration item specified in the Setting request.<br>
<b>Message Id:</b> <i>plt.msg.SINGLE_NVRAM_CONFIGURATION_READ_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> configurationItemAddress </td><td> long </td><td> The address of the NVRAM Storage to be read.</td></tr>
      </table>
<h3><a id="SUPPORTED_TEST_INTERFACE_MESSAGE_IDS_SETTING">Supported Test Interface Message IDs Setting</a></h3>
<b>Description:</b> Query for the set of supported Test Interface Deckard Message IDs for the device.<br>
<b>Message Id:</b> <i>plt.msg.SUPPORTED_TEST_INTERFACE_MESSAGE_IDS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING">Single NVRAM Configuration Read With Address Echo Setting</a></h3>
<b>Description:</b> Query for the configuration item specified in the Setting request.<br>
<b>Message Id:</b> <i>plt.msg.SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> configurationItemAddress </td><td> long </td><td> The address of the NVRAM Storage to be read.</td></tr>
      </table>
<h3><a id="WEARING_STATE_SETTING">Wearing state Setting</a></h3>
<b>Description:</b> The wearing state (donned/doffed). True = donned/worn.<br>
<b>Message Id:</b> <i>plt.msg.WEARING_STATE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUTO_ANSWER_ON_DON_SETTING">Auto-answer on don Setting</a></h3>
<b>Description:</b> Whether the device should answer incoming calls when the user dons the headset.
                If true, answer on don. If false, donning the headset during an incoming call
                will have no effect.<br>
<b>Message Id:</b> <i>plt.msg.AUTO_ANSWER_ON_DON_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUTO_PAUSE_MEDIA_SETTING">Auto-pause media Setting</a></h3>
<b>Description:</b> If enabled (autoPauseMedia = true), removing the headset will
                automatically pause audio (by sending AVRCP Pause); donning the headset
                will resume streaming audio (by sending AVRCP Play).<br>
<b>Message Id:</b> <i>plt.msg.AUTO_PAUSE_MEDIA_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUTO_TRANSFER_CALL_SETTING">Auto-transfer call Setting</a></h3>
<b>Description:</b> Returns whether the device should switch the audio of an in-progress call based on
                wearing state.
                See the "Configure auto-transfer call" command for more details.<br>
<b>Message Id:</b> <i>plt.msg.AUTO_TRANSFER_CALL_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_AUTO_LOCK_CALL_BUTTON_SETTING">Get auto-lock call button Setting</a></h3>
<b>Description:</b> This setting returns the headset hook switch's ability to dial calls.
                If enabled, the headset's hook switch cannot initiate outgoing calls when the
                headset is not worn.
                (The purpose is to eliminate pocket dialing. If the headset is in your pocket, the
                theory goes, it is not on your head and shouldn't be making a call.)<br>
<b>Message Id:</b> <i>plt.msg.GET_AUTO_LOCK_CALL_BUTTON_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="WEARING_SENSOR_ENABLED_SETTING">Wearing sensor enabled Setting</a></h3>
<b>Description:</b> Describes whether the wearing sensor is enabled.  If the sensor is disabled,
                for example through the Morini control panel, the device will not generate "Wearing state" events.
                This setting must be implemented in all devices equipped with a wearing state sensor.<br>
<b>Message Id:</b> <i>plt.msg.WEARING_SENSOR_ENABLED_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUTO_MUTE_CALL_SETTING">Auto-Mute call Setting</a></h3>
<b>Description:</b> If enabled (autoMuteCall = true), removing the headset will
                automatically mute on of the active call; donning the headset
                will resume mute off the active call.<br>
<b>Message Id:</b> <i>plt.msg.AUTO_MUTE_CALL_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CONFIGURATION_FOR_A_CONNECTED_HEADSET_SETTING">Configuration for a Connected Headset Setting</a></h3>
<b>Description:</b> Configure how a device treats the connected headset.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURATION_FOR_A_CONNECTED_HEADSET_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_MUTE_TONE_VOLUME_SETTING">Get mute tone volume Setting</a></h3>
<b>Description:</b> Configure how the device should play a tone on mute.<br>
<b>Message Id:</b> <i>plt.msg.GET_MUTE_TONE_VOLUME_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING">Get second inbound call ring type Setting</a></h3>
<b>Description:</b> Get the second inbound call ring type.<br>
<b>Message Id:</b> <i>plt.msg.GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_MUTE_OFF_VP_SETTING">Get Mute off VP Setting</a></h3>
<b>Description:</b> Device should return Mute off VP  enable status if it support this setting . Otherwise exception should be returned.<br>
<b>Message Id:</b> <i>plt.msg.GET_MUTE_OFF_VP_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_SCO_OPEN_TONE_ENABLE_SETTING">Get SCO Open Tone Enable Setting</a></h3>
<b>Description:</b> Allow a device to be queried as to the configured state of the SCO Open Tone<br>
<b>Message Id:</b> <i>plt.msg.GET_SCO_OPEN_TONE_ENABLE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_OLI_FEATURE_ENABLE_SETTING">Get OLI feature Enable Setting</a></h3>
<b>Description:</b> Device should return the OLI feature status.<br>
<b>Message Id:</b> <i>plt.msg.GET_OLI_FEATURE_ENABLE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MUTE_ALERT_SETTING">Mute Alert Setting</a></h3>
<b>Description:</b> Return current mute alert scheme , disabled or time interval reminder or voice detect reminder<br>
<b>Message Id:</b> <i>plt.msg.MUTE_ALERT_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CURRENT_SIGNAL_STRENGTH_SETTING">Current signal strength Setting</a></h3>
<b>Description:</b> Returns the current signal strength.<br>
<b>Message Id:</b> <i>plt.msg.CURRENT_SIGNAL_STRENGTH_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionId </td><td> byte </td><td> The connection ID of the link being requested to provide the signal strength information.</td></tr>
      </table>
<h3><a id="CALLER_ANNOUNCEMENT_SETTING">Caller announcement Setting</a></h3>
<b>Description:</b> Return the current caller announcement configuration.<br>
<b>Message Id:</b> <i>plt.msg.CALLER_ANNOUNCEMENT_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SIGNAL_STRENGTH_CONFIGURATION_SETTING">Signal strength configuration Setting</a></h3>
<b>Description:</b> Reads configuration of rssi and near far.<br>
<b>Message Id:</b> <i>plt.msg.SIGNAL_STRENGTH_CONFIGURATION_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionId </td><td> byte </td><td> The connection ID of the link being used to generate the signal strength event.</td></tr>
      </table>
<h3><a id="FIND_HEADSET_LED_ALERT_STATUS_SETTING">Find Headset LED Alert Status Setting</a></h3>
<b>Description:</b> Get current Find Headset LED Alert Status .<br>
<b>Message Id:</b> <i>plt.msg.FIND_HEADSET_LED_ALERT_STATUS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TXPOWER_REPORTING_SETTING">TxPower Reporting Setting</a></h3>
<b>Description:</b> Get Transmit Output Power fro a given connection Id.<br>
<b>Message Id:</b> <i>plt.msg.TXPOWER_REPORTING_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionId </td><td> byte </td><td> The connection ID of the link being requested to provide the transmit power information.</td></tr>
      </table>
<h3><a id="VOICE_SILENT_DETECTION_SETTING">Voice silent detection Setting</a></h3>
<b>Description:</b> Get current Voice silent detection mode.<br>
<b>Message Id:</b> <i>plt.msg.VOICE_SILENT_DETECTION_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="PRODUCT_NAME_SETTING">Product name Setting</a></h3>
<b>Description:</b> Return the user-facing product name (market name).<br>
<b>Message Id:</b> <i>plt.msg.PRODUCT_NAME_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TATTOO_SERIAL_NUMBER_SETTING">Tattoo Serial Number Setting</a></h3>
<b>Description:</b> Tattoo serial number programmed in manufacturing.<br>
<b>Message Id:</b> <i>plt.msg.TATTOO_SERIAL_NUMBER_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="USB_PID_SETTING">USB PID Setting</a></h3>
<b>Description:</b> This returns the device's USB product ID, a 16-bit unsigned quantity.<br>
<b>Message Id:</b> <i>plt.msg.USB_PID_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TATTOO_BUILD_CODE_SETTING">Tattoo Build Code Setting</a></h3>
<b>Description:</b> Tattoo build code programmed in manufacturing.<br>
<b>Message Id:</b> <i>plt.msg.TATTOO_BUILD_CODE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="FIRMWARE_VERSION_SETTING">Firmware version Setting</a></h3>
<b>Description:</b> The firmware ID is a pair of numbers. The buildTarget field describes the headset
                build-target, the release field contains the release number.<br>
<b>Message Id:</b> <i>plt.msg.FIRMWARE_VERSION_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="PART_NUMBER_SETTING">Part Number Setting</a></h3>
<b>Description:</b> Part number and revision programmed in manufacturing.<br>
<b>Message Id:</b> <i>plt.msg.PART_NUMBER_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="USER_ID_SETTING">User ID Setting</a></h3>
<b>Description:</b> User ID accessed by software.<br>
<b>Message Id:</b> <i>plt.msg.USER_ID_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="FIRST_DATE_USED_SETTING">First Date Used Setting</a></h3>
<b>Description:</b> Date of the first date of device use.<br>
<b>Message Id:</b> <i>plt.msg.FIRST_DATE_USED_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LAST_DATE_USED_SETTING">Last Date Used Setting</a></h3>
<b>Description:</b> Date of the last date of device use.<br>
<b>Message Id:</b> <i>plt.msg.LAST_DATE_USED_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LAST_DATE_CONNECTED_SETTING">Last Date Connected Setting</a></h3>
<b>Description:</b> Date of the last date of device connection.<br>
<b>Message Id:</b> <i>plt.msg.LAST_DATE_CONNECTED_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TIME_USED_SETTING">Time Used Setting</a></h3>
<b>Description:</b> Total time of time used.<br>
<b>Message Id:</b> <i>plt.msg.TIME_USED_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="USER_DEFINED_STORAGE_SETTING">User Defined Storage Setting</a></h3>
<b>Description:</b> Message for user defined storage access.<br>
<b>Message Id:</b> <i>plt.msg.USER_DEFINED_STORAGE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="VR_CALL_REJECT_AND_ANSWER_SETTING">VR call reject and answer Setting</a></h3>
<b>Description:</b> Return whether the VR call reject / answer feature is enabled or not.<br>
<b>Message Id:</b> <i>plt.msg.VR_CALL_REJECT_AND_ANSWER_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="A2DP_IS_ENABLED_SETTING">A2DP is enabled Setting</a></h3>
<b>Description:</b> Is A2DP currently enabled? Return true if it is, false if not.<br>
<b>Message Id:</b> <i>plt.msg.A2DP_IS_ENABLED_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="VOCALYST_PHONE_NUMBER_SETTING">Vocalyst phone number Setting</a></h3>
<b>Description:</b> Returns the current Vocalyst telephone number.<br>
<b>Message Id:</b> <i>plt.msg.VOCALYST_PHONE_NUMBER_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="VOCALYST_INFO_NUMBER_SETTING">Vocalyst info number Setting</a></h3>
<b>Description:</b> Returns the current Vocalyst information ("411") telephone number.<br>
<b>Message Id:</b> <i>plt.msg.VOCALYST_INFO_NUMBER_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BATTERY_INFO_SETTING">Battery info Setting</a></h3>
<b>Description:</b> Implemented only in devices (typically headsets) equipped with a battery.
                The current battery state: battery level, minutes of talk time, if the talk time is
                a high estimate, and charging or not.<br>
<b>Message Id:</b> <i>plt.msg.BATTERY_INFO_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GENES_GUID_SETTING">Genes GUID Setting</a></h3>
<b>Description:</b> Return the device's Genes Globally Unique ID (GUID). If the device should contain no Genes
                GUID, it must not implement this Setting.<br>
<b>Message Id:</b> <i>plt.msg.GENES_GUID_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MUTE_REMINDER_TIMING_SETTING">Mute reminder timing Setting</a></h3>
<b>Description:</b> Return the interval between mute reminders (voice prompt or tone) in the headset.<br>
<b>Message Id:</b> <i>plt.msg.MUTE_REMINDER_TIMING_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="PAIRING_MODE_SETTING">Pairing mode Setting</a></h3>
<b>Description:</b> To be implemented only in Bluetooth devices.
                Is the device in Bluetooth pairing mode?
                Returns true if in pairing mode, false if not.<br>
<b>Message Id:</b> <i>plt.msg.PAIRING_MODE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SPOKEN_ANSWER_IGNORE_COMMAND_SETTING">Spoken answer/ignore command Setting</a></h3>
<b>Description:</b> Reports if the 'say "answer" or "ignore"' prompt and recognition feature is enabled.<br>
<b>Message Id:</b> <i>plt.msg.SPOKEN_ANSWER_IGNORE_COMMAND_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING">Lync dial tone on Call press Setting</a></h3>
<b>Description:</b> Returns whether the Lync Dialtone feature is enabled. See the command "Configure
                Lync dial tone on Call press" for more details.<br>
<b>Message Id:</b> <i>plt.msg.LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MANUFACTURER_SETTING">Manufacturer Setting</a></h3>
<b>Description:</b> This setting provides information that identifies the manufacturer of the device in
                "reverse DNS" style.  Generally, this will always be "COM.PLANTRONICS".<br>
<b>Message Id:</b> <i>plt.msg.MANUFACTURER_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TOMBSTONE_SETTING">Tombstone Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.TOMBSTONE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BLUETOOTH_ADDRESS_SETTING">Bluetooth Address Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.BLUETOOTH_ADDRESS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BLUETOOTH_CONNECTION_SETTING">Bluetooth Connection Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.BLUETOOTH_CONNECTION_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionOffset </td><td> short </td><td> Offset of required connection bluetooth settings</td></tr>
      </table>
<h3><a id="DECKARD_VERSION_SETTING">Deckard Version Setting</a></h3>
<b>Description:</b> This setting allows a device to be queried as to which version of Deckard its messages Ids and payloads
                have been built against.<br>
<b>Message Id:</b> <i>plt.msg.DECKARD_VERSION_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CONNECTION_STATUS_SETTING">Connection Status Setting</a></h3>
<b>Description:</b> Enables a Host to determine the number of ports and connection status of a device.<br>
<b>Message Id:</b> <i>plt.msg.CONNECTION_STATUS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CALL_STATUS_SETTING">Call status Setting</a></h3>
<b>Description:</b> This contains the telephone call state of the device. The device will issue
                "Call status change" events whenever the state changes.<br>
<b>Message Id:</b> <i>plt.msg.CALL_STATUS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MICROPHONE_MUTE_STATE_SETTING">Microphone Mute State Setting</a></h3>
<b>Description:</b> Microphone mute state of the device.<br>
<b>Message Id:</b> <i>plt.msg.MICROPHONE_MUTE_STATE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TRANSMIT_AUDIO_STATE_SETTING">Transmit Audio State Setting</a></h3>
<b>Description:</b> Transmit (microphone) audio state of the device.<br>
<b>Message Id:</b> <i>plt.msg.TRANSMIT_AUDIO_STATE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="RECEIVE_AUDIO_STATE_SETTING">Receive Audio State Setting</a></h3>
<b>Description:</b> Receive (speaker) audio state of the device.<br>
<b>Message Id:</b> <i>plt.msg.RECEIVE_AUDIO_STATE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LED_STATUS_GENERIC_SETTING">LED Status Generic Setting</a></h3>
<b>Description:</b> LED status of the device.<br>
<b>Message Id:</b> <i>plt.msg.LED_STATUS_GENERIC_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="HEADSET_AVAILABLE_SETTING">Headset Available Setting</a></h3>
<b>Description:</b> Availability of the headset based on connection state (wireless or wired).<br>
<b>Message Id:</b> <i>plt.msg.HEADSET_AVAILABLE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="Y_CABLE_CONNECTION_SETTING">Y Cable Connection Setting</a></h3>
<b>Description:</b> Connection state for a Y-Cable.<br>
<b>Message Id:</b> <i>plt.msg.Y_CABLE_CONNECTION_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SPEAKER_VOLUME_SETTING">Speaker Volume Setting</a></h3>
<b>Description:</b> Speaker volume of the device.<br>
<b>Message Id:</b> <i>plt.msg.SPEAKER_VOLUME_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SPOKEN_LANGUAGE_SETTING">Spoken language Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.SPOKEN_LANGUAGE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SUPPORTED_LANGUAGES_SETTING">Supported Languages Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.SUPPORTED_LANGUAGES_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_PARTITION_INFORMATION_SETTING">Get Partition Information Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.GET_PARTITION_INFORMATION_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> partition </td><td> short </td><td> The partition to obtain information about</td></tr>
      </table>
<h3><a id="AUDIO_STATUS_SETTING">Audio status Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.AUDIO_STATUS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LED_STATUS_SETTING">LED Status Setting</a></h3>
<b>Description:</b> Enables a Host to determine the current LED Indication being provided by a device.<br>
<b>Message Id:</b> <i>plt.msg.LED_STATUS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="HEADSET_CALL_STATUS_SETTING">Headset Call status Setting</a></h3>
<b>Description:</b> This contains the telephone call state of all devices connected to the device.
                The returned payload is repeated for each connected device able to make phone calls
                The device will issue "Headset Call status " event whenever any call of the connected device state changes.<br>
<b>Message Id:</b> <i>plt.msg.HEADSET_CALL_STATUS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="DEVICE_INTERFACES_SETTING">Device interfaces Setting</a></h3>
<b>Description:</b> Returns a byte array containing the interface types for every interface the device includes.<br>
<b>Message Id:</b> <i>plt.msg.DEVICE_INTERFACES_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="RINGTONES_SETTING">Ringtones Setting</a></h3>
<b>Description:</b> Return the ring tone for all three interface types.<br>
<b>Message Id:</b> <i>plt.msg.RINGTONES_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BANDWIDTHS_SETTING">Bandwidths Setting</a></h3>
<b>Description:</b> Return the bandwidth for all three interface types.<br>
<b>Message Id:</b> <i>plt.msg.BANDWIDTHS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="RINGTONE_VOLUMES_SETTING">Ringtone volumes Setting</a></h3>
<b>Description:</b> Return the volume for all three interface types.<br>
<b>Message Id:</b> <i>plt.msg.RINGTONE_VOLUMES_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="DEFAULT_OUTBOUND_INTERFACE_SETTING">Default Outbound Interface Setting</a></h3>
<b>Description:</b> Indicates the current default outbound interface.<br>
<b>Message Id:</b> <i>plt.msg.DEFAULT_OUTBOUND_INTERFACE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TONE_CONTROLS_SETTING">Tone Controls Setting</a></h3>
<b>Description:</b> Returns the tone levels for PSTN and VOIP interface types.<br>
<b>Message Id:</b> <i>plt.msg.TONE_CONTROLS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUDIO_SENSING_SETTING">Audio Sensing Setting</a></h3>
<b>Description:</b> Indicates whether or not the radio link will be automatically established without having to press the call control button.<br>
<b>Message Id:</b> <i>plt.msg.AUDIO_SENSING_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="INTELLISTAND_AUTO_ANSWER_SETTING">Intellistand Auto-Answer Setting</a></h3>
<b>Description:</b> Indicates whether incoming calls should be answered automatically when the headset is removed from the charging cradle.<br>
<b>Message Id:</b> <i>plt.msg.INTELLISTAND_AUTO_ANSWER_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUTO_CONNECT_TO_MOBILE_SETTING">Auto-Connect to Mobile Setting</a></h3>
<b>Description:</b> Indicates whether or not the base automatically establishes a Bluetooth link to the mobile phone when the headset is undocked from the base and the mobile phone is within range.<br>
<b>Message Id:</b> <i>plt.msg.AUTO_CONNECT_TO_MOBILE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="STOP_AUTO_CONNECT_ON_DOCK_SETTING">Stop Auto-Connect on Dock Setting</a></h3>
<b>Description:</b> Indicates whether or not the Bluetooth connection to the mobile phone should be dropped when the headset is docked.   Only applicable if Set Auto-Connect to Mobile is true.<br>
<b>Message Id:</b> <i>plt.msg.STOP_AUTO_CONNECT_ON_DOCK_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BLUETOOTH_ENABLED_SETTING">Bluetooth Enabled Setting</a></h3>
<b>Description:</b> Indicates whether or not Bluetooth is enabled.<br>
<b>Message Id:</b> <i>plt.msg.BLUETOOTH_ENABLED_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="OVER_THE_AIR_SUBSCRIPTION_SETTING">Over-the-Air Subscription Setting</a></h3>
<b>Description:</b> Indicates whether or not the headset can subscribe to the base if it is not docked.<br>
<b>Message Id:</b> <i>plt.msg.OVER_THE_AIR_SUBSCRIPTION_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SYSTEM_TONE_VOLUME_SETTING">System Tone Volume Setting</a></h3>
<b>Description:</b> Indicates the system tone volume.<br>
<b>Message Id:</b> <i>plt.msg.SYSTEM_TONE_VOLUME_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="POWER_LEVEL_SETTING">Power Level Setting</a></h3>
<b>Description:</b> Indicates the current power level.<br>
<b>Message Id:</b> <i>plt.msg.POWER_LEVEL_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MOBILE_VOICE_COMMANDS_SETTING">Mobile Voice Commands Setting</a></h3>
<b>Description:</b> Indicates whether or not the mobile phone can be put in voice command mode via the mobile phone button on the base.<br>
<b>Message Id:</b> <i>plt.msg.MOBILE_VOICE_COMMANDS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="VOLUME_CONTROL_ORIENTATION_SETTING">Volume Control Orientation Setting</a></h3>
<b>Description:</b> Indicates if the current volume control orientation is the right or left ear.<br>
<b>Message Id:</b> <i>plt.msg.VOLUME_CONTROL_ORIENTATION_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_ACOUSTIC_INCIDENT_REPORTING_ENABLE_SETTING">AAL Acoustic Incident Reporting Enable Setting</a></h3>
<b>Description:</b> Get AAL acoustic incident reporting to be enabled or disabled, true or false.<br>
<b>Message Id:</b> <i>plt.msg.AAL_ACOUSTIC_INCIDENT_REPORTING_ENABLE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_SETTING">AAL Acoustic Incident Reporting Thresholds Setting</a></h3>
<b>Description:</b> Get AAL acoustic incident reporting thresholds.<br>
<b>Message Id:</b> <i>plt.msg.AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_ACOUSTIC_INCIDENT_REPORT_SETTING">AAL Acoustic Incident Report Setting</a></h3>
<b>Description:</b> PLACEHOLDER: This setting ID is reserved as the setting is not supported but no other setting shall use the associated ID per policy.<br>
<b>Message Id:</b> <i>plt.msg.AAL_ACOUSTIC_INCIDENT_REPORT_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_TWA_REPORTING_ENABLE_SETTING">AAL TWA Reporting Enable Setting</a></h3>
<b>Description:</b> Get AAL TWA reporting to be enabled or disabled, true or false.<br>
<b>Message Id:</b> <i>plt.msg.AAL_TWA_REPORTING_ENABLE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_TWA_REPORTING_TIME_PERIOD_SETTING">AAL TWA Reporting Time Period Setting</a></h3>
<b>Description:</b> Get AAL TWA reporting time period frequency.<br>
<b>Message Id:</b> <i>plt.msg.AAL_TWA_REPORTING_TIME_PERIOD_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="ANTI_STARTLE_SETTING">Anti-startle Setting</a></h3>
<b>Description:</b> Return the current anti-startle value.<br>
<b>Message Id:</b> <i>plt.msg.ANTI_STARTLE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_TWA_REPORT_SETTING">AAL TWA Report Setting</a></h3>
<b>Description:</b> PLACEHOLDER: This setting ID is reserved as the setting is not supported but no other setting shall use the associated ID per policy.<br>
<b>Message Id:</b> <i>plt.msg.AAL_TWA_REPORT_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="G616_SETTING">G616 Setting</a></h3>
<b>Description:</b> Return the current G.616 value.<br>
<b>Message Id:</b> <i>plt.msg.G616_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CONVERSATION_DYNAMICS_REPORTING_ENABLE_SETTING">Conversation Dynamics Reporting Enable Setting</a></h3>
<b>Description:</b> Get conversation dynamics reporting to be enabled or disabled, true or false.<br>
<b>Message Id:</b> <i>plt.msg.CONVERSATION_DYNAMICS_REPORTING_ENABLE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TIME_WEIGHTED_AVERAGE_SETTING">Time-weighted average Setting</a></h3>
<b>Description:</b> Return the current time-weighted average value.<br>
<b>Message Id:</b> <i>plt.msg.TIME_WEIGHTED_AVERAGE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_SETTING">Conversation Dynamics Reporting Time Period Setting</a></h3>
<b>Description:</b> Get conversation dynamics reporting time period frequency.<br>
<b>Message Id:</b> <i>plt.msg.CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TIME_WEIGHTED_AVERAGE_PERIOD_SETTING">Time-weighted average period Setting</a></h3>
<b>Description:</b> Return the current time-weighted average period value.<br>
<b>Message Id:</b> <i>plt.msg.TIME_WEIGHTED_AVERAGE_PERIOD_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CONVERSATION_DYNAMICS_REPORT_SETTING">Conversation Dynamics Report Setting</a></h3>
<b>Description:</b> PLACEHOLDER: This setting ID is reserved as the setting is not supported but no other setting shall use the associated ID per policy.<br>
<b>Message Id:</b> <i>plt.msg.CONVERSATION_DYNAMICS_REPORT_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_SUPPORTED_DSP_CAPABILITIES_SETTING">Get Supported DSP capabilities Setting</a></h3>
<b>Description:</b> Returns a list of supported DSP capabilities<br>
<b>Message Id:</b> <i>plt.msg.GET_SUPPORTED_DSP_CAPABILITIES_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_DSP_PARAMETERS_SETTING">Get DSP Parameters Setting</a></h3>
<b>Description:</b> Get DSP parameters either from persistent or volatile storage.<br>
<b>Message Id:</b> <i>plt.msg.GET_DSP_PARAMETERS_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> codec </td><td> byte </td><td> </td></tr><tr><td> storeIsVolatile </td><td> boolean - true or false </td><td> this is for the DSP to say how it is stored - not the vm ---------------
                        FALSE = read from PSKEY
                        TRUE = read from  DSP RAM  --------- optional may not be able to support this may ask dsp for current value
                        returns error on true if not supported</td></tr><tr><td> ParameterIndex </td><td> short </td><td> Zero based index into KAT</td></tr>
      </table>
<h3><a id="FEATURE_LOCK_SETTING">Feature lock Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.FEATURE_LOCK_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="FEATURE_LOCK_MASK_SETTING">Feature lock Mask Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.FEATURE_LOCK_MASK_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="PASSWORD_SETTING">Password Setting</a></h3>
<b>Description:</b> Return the device's password value.<br>
<b>Message Id:</b> <i>plt.msg.PASSWORD_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="PROTECTED_STATE_SETTING">Protected state Setting</a></h3>
<b>Description:</b> Return the device's Protected state: true true if the password is equal to something other
                than the device default value, false otherwise.<br>
<b>Message Id:</b> <i>plt.msg.PROTECTED_STATE_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="HAL_CURRENT_SCENARIO_SETTING">Hal Current Scenario Setting</a></h3>
<b>Description:</b> Return the device's current scenario.<br>
<b>Message Id:</b> <i>plt.msg.HAL_CURRENT_SCENARIO_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="HAL_CURRENT_VOLUME_SETTING">Hal Current Volume Setting</a></h3>
<b>Description:</b> Return the device's current volumes for a scenario.<br>
<b>Message Id:</b> <i>plt.msg.HAL_CURRENT_VOLUME_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> scenario </td><td> short </td><td> </td></tr><tr><td> volumes </td><td> array of bytes </td><td> </td></tr>
      </table>
<h3><a id="HAL_CURRENT_EQ_SETTING">Hal Current EQ Setting</a></h3>
<b>Description:</b> Returns current volume settings for a scenario<br>
<b>Message Id:</b> <i>plt.msg.HAL_CURRENT_EQ_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> scenario </td><td> short </td><td> The scenario for the EQ query</td></tr><tr><td> EQs </td><td> array of bytes </td><td> Array containing Ids of the EQ to return values for</td></tr>
      </table>
<h3><a id="HAL_GENERIC_SETTING">Hal Generic Setting</a></h3>
<b>Description:</b> Allows a number of devices settings to be queried in a single message<br>
<b>Message Id:</b> <i>plt.msg.HAL_GENERIC_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> halGeneric </td><td> array of shorts </td><td> Array of deckard messages</td></tr>
      </table>
<h3><a id="QUERY_SERVICES_CONFIGURATION_DATA_SETTING">Query services configuration data Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.QUERY_SERVICES_CONFIGURATION_DATA_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> serviceID </td><td> short </td><td> </td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr>
      </table>
<h3><a id="QUERY_SERVICES_CALIBRATION_DATA_SETTING">Query services calibration data Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.QUERY_SERVICES_CALIBRATION_DATA_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> serviceID </td><td> short </td><td> </td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr>
      </table>
<h3><a id="QUERY_APPLICATION_CONFIGURATION_DATA_SETTING">Query application configuration data Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.QUERY_APPLICATION_CONFIGURATION_DATA_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> featureID </td><td> short </td><td> Reference "Configure applciation" command for valid feature IDs.</td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr>
      </table>
<h3><a id="QUERY_SERVICES_DATA_SETTING">Query services data Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.QUERY_SERVICES_DATA_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> ServiceID </td><td> short </td><td> </td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr>
      </table>
<h3><a id="GET_DEVICE_INFO_SETTING">Get device info Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.GET_DEVICE_INFO_SETTING</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>

 
  
  
  
  
  
 
<h3><a name="commands"></a>PLT Command Messages</h3>
<b>When do you use this message?</b><br>
Command messages are used to set properties on the device or to enable sensors and or features on the device. To receive the command response you must register a callback with the plt.addCommandSuccessListener function.
<br>
Below is an exhaustive listing of all of the get command messages that the device should support.
<br>
 
<h2>Command Messages</h2>
<h3><a id="TEST_INTERFACE_ENABLE_DISABLE_COMMAND">Test Interface Enable-Disable Command</a></h3>
<b>Description:</b> Command to enable and disable test messaging to and from a device.  The test interface enable message
                must be sent to a device before any other test messages will be received as valid.  The test interface
                is disabled by default so that production devices cannot be stimulated by test messages under normal
                operation.<br>
<b>Message Id:</b> <i>plt.msg.TEST_INTERFACE_ENABLE_DISABLE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> testInterfaceEnable </td><td> boolean - true or false </td><td> True to enable test messaging, false to disable and ignore test messaging.</td></tr>
      </table>
<h3><a id="BUTTON_SIMULATION_COMMAND">Button Simulation Command</a></h3>
<b>Description:</b> Command to request to simulate a user button action for one or more buttons simultaneously.<br>
<b>Message Id:</b> <i>plt.msg.BUTTON_SIMULATION_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> buttonAction </td><td> byte </td><td> </td></tr><tr><td> buttonIDs </td><td> array of shorts </td><td> </td></tr>
      </table>
<h3><a id="INDIRECT_EVENT_SIMULATION_COMMAND">Indirect Event Simulation Command</a></h3>
<b>Description:</b> Command to request to simulate a device indirect event, such as don/doff, battery level change, etc.<br>
<b>Message Id:</b> <i>plt.msg.INDIRECT_EVENT_SIMULATION_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> indirectEvent </td><td> short </td><td> </td></tr><tr><td> EventParameter </td><td> array of bytes </td><td> </td></tr>
      </table>
<h3><a id="RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_COMMAND">Raw ButtonTest Event Enable-Disable Command</a></h3>
<b>Description:</b> Command to enable and disable raw button messaging from a device. The test interface enable message
                must be enabled prior to this command being issued. The test interface is disabled by default so that
                production devices do not provide raw button events.<br>
<b>Message Id:</b> <i>plt.msg.RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> rawButtonEventEnable </td><td> boolean - true or false </td><td> True to enable raw button event messages, false to disable.
                        NOTE that the Test Interface must be enabled before this command is enabled ("0x1000")</td></tr>
      </table>
<h3><a id="VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_COMMAND">Voice Recognition Test Event Enable-Disable Command</a></h3>
<b>Description:</b> Command to enable and disable Voice Recognition messaging from a device. The test interface enable message
                must be enabled prior to this command being issued. The test interface is disabled by default so that
                production devices do not Voice recognition events.<br>
<b>Message Id:</b> <i>plt.msg.VOICE_RECOGNITION_TEST_EVENT_ENABLE_DISABLE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> voiceRecogntionEventEnable </td><td> boolean - true or false </td><td> True to enable Voice recognition event messages, false to disable.
                        NOTE that the Test Interface must be enabled before this command is enabled ("0x1000")</td></tr>
      </table>
<h3><a id="TEXT_TO_SPEECH_TEST_COMMAND">Text To Speech Test Command</a></h3>
<b>Description:</b> Command to verify the Text to Speech engine of a device. The test interface enable message
                must be enabled prior to this command being issued. The test interface is disabled by default so that
                production devices do not have this functionality enabled.<br>
<b>Message Id:</b> <i>plt.msg.TEXT_TO_SPEECH_TEST_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> Text </td><td> string </td><td> Text issued by Test Harness to invoke the appropriate response from the Text to Speech engine.
                        NOTE that the Test Interface must be enabled before this command is enabled ("0x1000")</td></tr>
      </table>
<h3><a id="RAW_DATA_EVENT_ENABLE_DISABLE_COMMAND">Raw Data Event Enable-Disable Command</a></h3>
<b>Description:</b> Command to enable and disable raw Data events from being issued by a device<br>
<b>Message Id:</b> <i>plt.msg.RAW_DATA_EVENT_ENABLE_DISABLE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="RAW_DATA_COMMAND">Raw Data Command Command</a></h3>
<b>Description:</b> Command to carry Raw Data to the Device<br>
<b>Message Id:</b> <i>plt.msg.RAW_DATA_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MFI_TEST_COMMAND">MFI Test Command</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.MFI_TEST_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> command </td><td> byte </td><td> Command byte value for MFI Test</td></tr>
      </table>
<h3><a id="CAPSENSE_TEST_COMMAND">Capsense Test Command</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.CAPSENSE_TEST_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> command </td><td> byte </td><td> </td></tr>
      </table>
<h3><a id="AUTO_ANSWER_ON_DON_COMMAND">Auto-answer on don Command</a></h3>
<b>Description:</b> Configure whether the device should answer incoming calls when the user dons the
                headset. If true, answer on don. If false, donning the headset during an incoming
                call will have no effect.<br>
<b>Message Id:</b> <i>plt.msg.AUTO_ANSWER_ON_DON_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> answerOnDon </td><td> boolean - true or false </td><td> True if the device should answer calls on don, false if not.</td></tr>
      </table>
<h3><a id="CONFIGURE_AUTO_PAUSE_MEDIA_COMMAND">Configure auto-pause media Command</a></h3>
<b>Description:</b> This command selects the effect of doffing and donning the headset while streaming
                audio to it. If enabled (autoPauseMedia = true), removing the headset will
                automatically pause audio (by sending AVRCP Pause); donning the headset
                will resume streaming audio (by sending AVRCP Play).<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_AUTO_PAUSE_MEDIA_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> autoPauseMedia </td><td> boolean - true or false </td><td> If true, enable auto-pause/auto-resume of streaming audio on doff/don. If
                        false,these physical events will not affect streaming audio.</td></tr>
      </table>
<h3><a id="CONFIGURE_AUTO_TRANSFER_CALL_COMMAND">Configure auto-transfer call Command</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_AUTO_TRANSFER_CALL_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> autoTransferCall </td><td> boolean - true or false </td><td> If true, the device should route audio based on headset wearing state.</td></tr>
      </table>
<h3><a id="CONFIGURE_AUTO_LOCK_CALL_BUTTON_COMMAND">Configure auto-lock call button Command</a></h3>
<b>Description:</b> This command controls the headset hook switch's ability to dial calls.
                If enabled, the headset's hook switch cannot initiate outgoing calls when the
                headset is not worn.
                (The purpose is to eliminate pocket dialing. If the headset is in your pocket, the
                theory goes, it is not on your head and shouldn't be making a call.)<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_AUTO_LOCK_CALL_BUTTON_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> autoLockCallButton </td><td> boolean - true or false </td><td> If true, the hook switch on the device cannot initiate outgoing calls when
                        the device is not worn.</td></tr>
      </table>
<h3><a id="CONFIGURE_WEARING_SENSOR_ENABLED_COMMAND">Configure wearing sensor enabled Command</a></h3>
<b>Description:</b> This command controls the headset ability to provide don-doff events.
                If enabled, the headset will provide don events when the user dons the headset, and doff events when the headset is removed.
                This must be enabled to provide auto answer, anto pause, auto lock, auto transfer functionality.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_WEARING_SENSOR_ENABLED_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> wearingStateSensorEnabled </td><td> boolean - true or false </td><td> If true, the wearing state sensor is enabled to provide Don Doff events.</td></tr>
      </table>
<h3><a id="CONFIGURE_AUTO_MUTE_CALL_COMMAND">Configure auto-mute call Command</a></h3>
<b>Description:</b> This command selects the effect of doffing and donning the headset while active
                call to it. If enabled (autoMuteCall = true), removing the headset will
                automatically mute on the active call; donning the headset
                will resume mute off of the active call.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_AUTO_MUTE_CALL_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> autoMuteCall </td><td> boolean - true or false </td><td> If true, enable auto-mute on/off of active call on doff/don. If
                        false,these physical events will not affect active call.</td></tr>
      </table>
<h3><a id="CONFIGURE_MUTE_TONE_VOLUME_COMMAND">Configure mute tone volume Command</a></h3>
<b>Description:</b> Configure how (if) the device should play a tone on mute. (Some headsets may play a
                voice prompt instead or in addition.  This setting does not affect voice prompts.)<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_MUTE_TONE_VOLUME_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> muteToneVolume </td><td> byte </td><td> </td></tr>
      </table>
<h3><a id="CONFIGURATION_FOR_A_CONNECTED_HEADSET_COMMAND">Configuration for a Connected Headset Command</a></h3>
<b>Description:</b> Configuration of how a device treats the connected headset.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURATION_FOR_A_CONNECTED_HEADSET_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> configuration </td><td> byte </td><td> Byte value to indicate the configuration to be used for the connected headset by the target device.</td></tr>
      </table>
<h3><a id="CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_COMMAND">Configure second inbound call ring type Command</a></h3>
<b>Description:</b> Configure the second inbound call ring type.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_SECOND_INBOUND_CALL_RING_TYPE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> ringType </td><td> byte </td><td> </td></tr>
      </table>
<h3><a id="CONFIGURE_MUTE_OFF_VP_COMMAND">Configure Mute off VP Command</a></h3>
<b>Description:</b> Enable/disable Mute off VP. Device should return success if it support this command .<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_MUTE_OFF_VP_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> Enable/Disable Mute off VP</td></tr>
      </table>
<h3><a id="SET_SCO_OPEN_TONE_ENABLE_COMMAND">Set SCO Open Tone Enable Command</a></h3>
<b>Description:</b> Configure device as to it should have an open sco tone.<br>
<b>Message Id:</b> <i>plt.msg.SET_SCO_OPEN_TONE_ENABLE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> Enable/Disable SCO Open Tone</td></tr>
      </table>
<h3><a id="CONFIGURE_OLI_FEATURE_COMMAND">Configure OLI Feature Command</a></h3>
<b>Description:</b> Configure device whether to enable the OLI feature or not.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_OLI_FEATURE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> OLIenable </td><td> byte </td><td> Enable/Disable OLI feature</td></tr>
      </table>
<h3><a id="CONFIGURE_MUTE_ALERT_COMMAND">Configure Mute Alert Command</a></h3>
<b>Description:</b> Configure current mute alert scheme , disabled or time interval reminder or voice detect reminder<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_MUTE_ALERT_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> mode </td><td> byte </td><td> Select between disable , time interval mute alert and voice detect mute alert.</td></tr><tr><td> parameter </td><td> byte </td><td> When mode is Voice Detect Reminder , item parameter is valid
                        Otherwise it will be ignored .
                        When mode is TimeIntervalReminder , command Configure mute reminder timing should be used to configure Time interval.</td></tr>
      </table>
<h3><a id="CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND">Configure signal strength events Command</a></h3>
<b>Description:</b> Allows configuration of rssi and near far events.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionId </td><td> byte </td><td> The connection ID of the link being used to generate the signal strength event.</td></tr><tr><td> enable </td><td> boolean - true or false </td><td> If true, this will enable the signal strength monitoring.</td></tr><tr><td> dononly </td><td> boolean - true or false </td><td> If true, report near far events only when headset is donned.</td></tr><tr><td> trend </td><td> boolean - true or false </td><td> If true don't use trend detection</td></tr><tr><td> reportRssiAudio </td><td> boolean - true or false </td><td> If true, Report rssi and trend events in headset audio</td></tr><tr><td> reportNearFarAudio </td><td> boolean - true or false </td><td> If true, report Near/Far events in headset Audio</td></tr><tr><td> reportNearFarToBase </td><td> boolean - true or false </td><td> If true, report RSSI and Near Far events</td></tr><tr><td> sensitivity </td><td> byte </td><td> This number multiplies the dead_band value (currently 5) in the headset configuration.
                        This result is added to an minimum dead-band, currently 5 to compute the total dead-band.
                        in the range 0 to 9</td></tr><tr><td> nearThreshold </td><td> byte </td><td> The near / far threshold in the range -128 to +127; larger (positive) values mean a weaker signal</td></tr><tr><td> maxTimeout </td><td> short </td><td> The number of seconds after any event before terminating sending rssi values</td></tr>
      </table>
<h3><a id="DSP_TUNING_MESSAGE_COMMAND">DSP Tuning Message Command</a></h3>
<b>Description:</b> DSP tuning messages used by a DSP tuning tool to send commands and receive
                responses using a proprietary DSP tuning message format.<br>
<b>Message Id:</b> <i>plt.msg.DSP_TUNING_MESSAGE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> data </td><td> array of bytes </td><td> The payload_in data is the DSP tuning command to the recipient
                        from the initiator.</td></tr>
      </table>
<h3><a id="PLATFORM_SPECIFIC_INSTRUMENTATION_MESSAGE_COMMAND">Platform Specific Instrumentation Message Command</a></h3>
<b>Description:</b> Platform specific instrumentation messages are intended for use with an
                instrumentation tool to send commands and receive responses using a format
                specific to a platform code base.<br>
<b>Message Id:</b> <i>plt.msg.PLATFORM_SPECIFIC_INSTRUMENTATION_MESSAGE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> data </td><td> array of bytes </td><td> The payload_in data is the instrumentation command to the recipient
                        from the initiator.</td></tr>
      </table>
<h3><a id="CONFIGURE_CALLER_ANNOUNCEMENT_COMMAND">Configure caller announcement Command</a></h3>
<b>Description:</b> Set the desired caller announcement configuration.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_CALLER_ANNOUNCEMENT_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> value </td><td> byte </td><td> </td></tr>
      </table>
<h3><a id="MANUFACTURING_TEST_MESSAGE_COMMAND">Manufacturing Test Message Command</a></h3>
<b>Description:</b> Manufacturing Test messages are intended for use with a
                manufacturing test tool to send commands and receive responses using a format
                specific to a platform code base.<br>
<b>Message Id:</b> <i>plt.msg.MANUFACTURING_TEST_MESSAGE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> data </td><td> array of bytes </td><td> The payload_in data is the manufacturing test command to the recipient
                        from the initiator.</td></tr>
      </table>
<h3><a id="CONFIGURE_FIND_HEADSET_LED_ALERT_COMMAND">Configure Find Headset LED Alert Command</a></h3>
<b>Description:</b> Enable/disable Find Headset LED Alert.
                    Device supposes enable command will be send every TIMEOUT seconds or less otherwise Find Headset LED Alert will be terminated .<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_FIND_HEADSET_LED_ALERT_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> Enable or disable Find Headset LED Alert</td></tr><tr><td> timeout </td><td> byte </td><td> If ENABLE is TRUE ,  Find Headset LED Alert should enable and timeout after TIMEOUT seconds.
                    TIMEOUT is unsigned decimal number , it could not be bigger than 255 and not equal to zero.
                    If ENABLE is FALSE , Find Headset LED Alert should be disabled right way.</td></tr>
      </table>
<h3><a id="ENABLE_TXPOWER_REPORTING_COMMAND">Enable TxPower Reporting Command</a></h3>
<b>Description:</b> Enable/disable Transmit Power Reporting.<br>
<b>Message Id:</b> <i>plt.msg.ENABLE_TXPOWER_REPORTING_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionId </td><td> byte </td><td> The connection ID of the link being requested to provide Transmit Power information.</td></tr><tr><td> enable </td><td> boolean - true or false </td><td> Enable or disable Transmit Power Reporting from a Device</td></tr>
      </table>
<h3><a id="CONFIGURE_DEVICE_POWER_STATE_COMMAND">Configure Device Power State Command</a></h3>
<b>Description:</b> Allows the device to be restarted or have it's power state changed.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_DEVICE_POWER_STATE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> DeviceState </td><td> byte </td><td> Required power state.</td></tr>
      </table>
<h3><a id="TATTOO_SERIAL_NUMBER_COMMAND">Tattoo Serial Number Command</a></h3>
<b>Description:</b> Tattoo serial number programmed in manufacturing.<br>
<b>Message Id:</b> <i>plt.msg.TATTOO_SERIAL_NUMBER_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> serialNumber </td><td> array of bytes </td><td> Array containing the nine ASCII serial number characters.</td></tr>
      </table>
<h3><a id="TATTOO_BUILD_CODE_COMMAND">Tattoo Build Code Command</a></h3>
<b>Description:</b> Tattoo build code programmed in manufacturing.<br>
<b>Message Id:</b> <i>plt.msg.TATTOO_BUILD_CODE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> buildCode </td><td> array of bytes </td><td> Array containing the nine ASCII build code characters.</td></tr>
      </table>
<h3><a id="PART_NUMBER_COMMAND">Part Number Command</a></h3>
<b>Description:</b> Part number and revision programmed in manufacturing.<br>
<b>Message Id:</b> <i>plt.msg.PART_NUMBER_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> partNumber </td><td> integer </td><td> Four byte number with the upper three bytes containing the hexadecimal value of the decimal
						part number and the low byte containing a numeric representation of the revision.</td></tr>
      </table>
<h3><a id="USER_ID_COMMAND">User ID Command</a></h3>
<b>Description:</b> User ID accessed by software.<br>
<b>Message Id:</b> <i>plt.msg.USER_ID_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> userID </td><td> array of bytes </td><td> Array of up to 32 ASCII characters used as the User ID.</td></tr>
      </table>
<h3><a id="FIRST_DATE_USED_COMMAND">First Date Used Command</a></h3>
<b>Description:</b> Date of the first date of device use.<br>
<b>Message Id:</b> <i>plt.msg.FIRST_DATE_USED_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> month </td><td> short </td><td> Two ASCII characters of month digits.</td></tr><tr><td> day </td><td> short </td><td> Two ASCII characters of day digits.</td></tr><tr><td> year </td><td> integer </td><td> Four ASCII characters of year digits.</td></tr>
      </table>
<h3><a id="CONFIGURE_VR_CALL_REJECT_AND_ANSWER_COMMAND">Configure VR call reject and answer Command</a></h3>
<b>Description:</b> Enable or disable the VR call reject / answer feature, which provides the user the
                ability to speak to the headset to answer or reject an incoming call.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_VR_CALL_REJECT_AND_ANSWER_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> If the user can speak to the handset to answer or reject a call, this will be true.
                        Otherwise it's false.</td></tr>
      </table>
<h3><a id="LAST_DATE_USED_COMMAND">Last Date Used Command</a></h3>
<b>Description:</b> Date of the last date of device use.<br>
<b>Message Id:</b> <i>plt.msg.LAST_DATE_USED_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> month </td><td> short </td><td> Two ASCII characters of month digits.</td></tr><tr><td> day </td><td> short </td><td> Two ASCII characters of day digits.</td></tr><tr><td> year </td><td> integer </td><td> Four ASCII characters of year digits.</td></tr>
      </table>
<h3><a id="LAST_DATE_CONNECTED_COMMAND">Last Date Connected Command</a></h3>
<b>Description:</b> Date of the last date of device connection.<br>
<b>Message Id:</b> <i>plt.msg.LAST_DATE_CONNECTED_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> month </td><td> short </td><td> Two ASCII characters of month digits.</td></tr><tr><td> day </td><td> short </td><td> Two ASCII characters of day digits.</td></tr><tr><td> year </td><td> integer </td><td> Four ASCII characters of year digits.</td></tr>
      </table>
<h3><a id="CONFIGURE_A2DP_COMMAND">Configure A2DP Command</a></h3>
<b>Description:</b> Turn A2DP on or off after the next device reboot.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_A2DP_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> If true, enable A2DP. If false, turn A2DP off. Change takes place on reboot.
                        (Changing this value does not cause a reboot.)</td></tr>
      </table>
<h3><a id="TIME_USED_COMMAND">Time Used Command</a></h3>
<b>Description:</b> Total time of time used.<br>
<b>Message Id:</b> <i>plt.msg.TIME_USED_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> totalTime </td><td> short </td><td> Two bytes representing total time used.</td></tr>
      </table>
<h3><a id="USER_DEFINED_STORAGE_COMMAND">User Defined Storage Command</a></h3>
<b>Description:</b> Message for user defined storage access.<br>
<b>Message Id:</b> <i>plt.msg.USER_DEFINED_STORAGE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> data </td><td> array of bytes </td><td> Array of unspecified data bytes to be stored on the device.</td></tr>
      </table>
<h3><a id="SET_VOCALYST_PHONE_NUMBER_COMMAND">Set Vocalyst phone number Command</a></h3>
<b>Description:</b> Set the current Vocalyst telephone number.<br>
<b>Message Id:</b> <i>plt.msg.SET_VOCALYST_PHONE_NUMBER_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> vocalystPhoneNumber </td><td> string </td><td> The local Vocalyst telephone number.</td></tr>
      </table>
<h3><a id="VOCALYST_INFO_NUMBER_COMMAND">Vocalyst info number Command</a></h3>
<b>Description:</b> Sets the current Vocalyst information ("411") telephone number.<br>
<b>Message Id:</b> <i>plt.msg.VOCALYST_INFO_NUMBER_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> infoPhoneNumber </td><td> string </td><td> The new telephone number for information ("411").</td></tr>
      </table>
<h3><a id="SET_GENES_GUID_COMMAND">Set Genes GUID Command</a></h3>
<b>Description:</b> Set the device's Genes Globally Unique ID (GUID). If the device is designed not to
                contain a Genes GUID, it must not implement this Command.<br>
<b>Message Id:</b> <i>plt.msg.SET_GENES_GUID_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> guid </td><td> array of bytes </td><td> The Genes GUID is an array of 16 bytes containing a unique 128-bit value. Byte 0
                        is the most significant, byte 15 is the least significant.</td></tr>
      </table>
<h3><a id="CONFIGURE_MUTE_REMINDER_TIMING_COMMAND">Configure mute reminder timing Command</a></h3>
<b>Description:</b> Change the interval between mute reminders (voice prompt or tone) in the headset.
                The device will make a best effort to play the reminders on this schedule, though
                exact timing is not guaranteed.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_MUTE_REMINDER_TIMING_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> seconds </td><td> short </td><td> The number of seconds to wait between mute prompts when the headset is
                        muted.</td></tr>
      </table>
<h3><a id="SET_PAIRING_MODE_COMMAND">Set pairing mode Command</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.SET_PAIRING_MODE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> If true, put the device into pairing mode. If false, leave
                        pairing mode.</td></tr>
      </table>
<h3><a id="CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND">Configure spoken answer/ignore command Command</a></h3>
<b>Description:</b> Enable or disable the 'say "answer" or "ignore"' prompt for incoming calls,
                and turn on or off recognition of the voice commands that allow it.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_SPOKEN_ANSWER_IGNORE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> If true, prompt the user to say "answer" or "ignore" for incoming calls, and
                        turn on
                        recognition of the voice commands that allow it. If false, do not prompt the
                        user
                        and do not try to recognize those utterances.</td></tr>
      </table>
<h3><a id="CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_COMMAND">Configure Lync dial tone on Call press Command</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_LYNC_DIAL_TONE_ON_CALL_PRESS_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> If true, pressing the call button on the device while it is in an idle state
                        will bring Microsoft Lync to the foreground and initiate a dial tone.</td></tr>
      </table>
<h3><a id="CLEAR_TOMBSTONE_COMMAND">Clear tombstone Command</a></h3>
<b>Description:</b> Clears the last panic (device crash) dump, a so-called "tombstone." It is not an
                error to call this when there is no tombstone.<br>
<b>Message Id:</b> <i>plt.msg.CLEAR_TOMBSTONE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BLUETOOTH_CONNECTION_PRIORITY_COMMAND">Bluetooth Connection Priority Command</a></h3>
<b>Description:</b> Allows devices to smart disconnect on an individual basis<br>
<b>Message Id:</b> <i>plt.msg.BLUETOOTH_CONNECTION_PRIORITY_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionOffset </td><td> short </td><td> Offset into the paired device list</td></tr><tr><td> allowSmartDisconnect </td><td> boolean - true or false </td><td> Set to true to allow smart disconnect</td></tr>
      </table>
<h3><a id="BLUETOOTH_CONNECT_DISCONNECT_COMMAND">Bluetooth Connect Disconnect Command</a></h3>
<b>Description:</b> Request a paired device to disconnect or connect<br>
<b>Message Id:</b> <i>plt.msg.BLUETOOTH_CONNECT_DISCONNECT_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionOffset </td><td> short </td><td> Offset into the paired device list</td></tr><tr><td> disconnect </td><td> boolean - true or false </td><td> Set to true to disconnect</td></tr>
      </table>
<h3><a id="BLUETOOTH_DELETE_PAIRING_COMMAND">Bluetooth Delete Pairing Command</a></h3>
<b>Description:</b> Delete the pairing information for paired device with specified connection offset<br>
<b>Message Id:</b> <i>plt.msg.BLUETOOTH_DELETE_PAIRING_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionOffset </td><td> short </td><td> Offset into the paired device list</td></tr>
      </table>
<h3><a id="BLUETOOTH_ADD_PAIRING_COMMAND">Bluetooth Add Pairing Command</a></h3>
<b>Description:</b> Define an address and link key for either a temporary or permanent bluetooth connection<br>
<b>Message Id:</b> <i>plt.msg.BLUETOOTH_ADD_PAIRING_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionOffset </td><td> short </td><td> Offset into the paired device list</td></tr><tr><td> persist </td><td> boolean - true or false </td><td> True for pairing to persist</td></tr><tr><td> nap </td><td> short </td><td> NAP of the Bluetooth address</td></tr><tr><td> uap </td><td> byte </td><td> UAP of the Bluetooth address</td></tr><tr><td> lap </td><td> integer </td><td> LAP of the Bluetooth address</td></tr><tr><td> linkKeyType </td><td> short </td><td> type of link key</td></tr><tr><td> linkKey </td><td> array of shorts </td><td> Link key to use for this connection</td></tr>
      </table>
<h3><a id="MICROPHONE_MUTE_STATE_COMMAND">Microphone Mute State Command</a></h3>
<b>Description:</b> Microphone mute state of the device.<br>
<b>Message Id:</b> <i>plt.msg.MICROPHONE_MUTE_STATE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> state </td><td> boolean - true or false </td><td> True (1) if the device is muted and false (0) if unmuted.</td></tr>
      </table>
<h3><a id="TRANSMIT_AUDIO_STATE_COMMAND">Transmit Audio State Command</a></h3>
<b>Description:</b> Transmit (microphone) audio state of the device.<br>
<b>Message Id:</b> <i>plt.msg.TRANSMIT_AUDIO_STATE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> state </td><td> boolean - true or false </td><td> True (1) if the device Tx audio path is on and false (0) if Tx audio path is off.</td></tr>
      </table>
<h3><a id="CALL_ANSWER_COMMAND">Call answer Command</a></h3>
<b>Description:</b> This command instructs the device to answer the current incoming (ringing) call.  This is intended only
                for devices (like Bluetooth headsets) with the ability to tell the audio gateway (AG) to do so.<br>
<b>Message Id:</b> <i>plt.msg.CALL_ANSWER_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="RECEIVE_AUDIO_STATE_COMMAND">Receive Audio State Command</a></h3>
<b>Description:</b> Receive (speaker) audio state of the device.<br>
<b>Message Id:</b> <i>plt.msg.RECEIVE_AUDIO_STATE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> state </td><td> boolean - true or false </td><td> True (1) if the device Rx audio path is on and false (0) if Rx audio path is off.</td></tr>
      </table>
<h3><a id="CALL_END_COMMAND">Call end Command</a></h3>
<b>Description:</b> This command instructs the device to terminate (hang up) the current call.  This is intended only
                for devices (like Bluetooth headsets) with the ability to tell the audio gateway (AG) to do so.<br>
<b>Message Id:</b> <i>plt.msg.CALL_END_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LED_STATUS_GENERIC_COMMAND">LED Status Generic Command</a></h3>
<b>Description:</b> LED status of the device.  All parameter arrays must be of a matching length or an exception will be returned.<br>
<b>Message Id:</b> <i>plt.msg.LED_STATUS_GENERIC_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> ID </td><td> array of bytes </td><td> Array of LED IDs.</td></tr><tr><td> color </td><td> array of bytes </td><td> Array of LED colors.</td></tr><tr><td> state </td><td> array of bytes </td><td> Array of LED states.</td></tr>
      </table>
<h3><a id="SET_AUDIO_TRANSMIT_GAIN_COMMAND">Set Audio Transmit Gain Command</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.SET_AUDIO_TRANSMIT_GAIN_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> gain </td><td> byte </td><td> Valid range is 0 - 0x0F
                        If zero, mute the transmit (microphone) audio.
                        All other values set the gain from 0x01 to 0x0F as required.
                        Note that Bluetooth devices implement values 0 and 0x0F.
                        Therefore, non-zero values will be handled in the device as being 0x0F.</td></tr>
      </table>
<h3><a id="HEADSET_AVAILABLE_COMMAND">Headset Available Command</a></h3>
<b>Description:</b> Availability of the headset based on connection state (wireless or wired).<br>
<b>Message Id:</b> <i>plt.msg.HEADSET_AVAILABLE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> state </td><td> boolean - true or false </td><td> True (1) if the headset is connected and false (0) if the headset is disconnected.</td></tr>
      </table>
<h3><a id="SET_SPEAKER_VOLUME_COMMAND">Set Speaker Volume Command</a></h3>
<b>Description:</b> Speaker volume of the device.<br>
<b>Message Id:</b> <i>plt.msg.SET_SPEAKER_VOLUME_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> action </td><td> byte </td><td> </td></tr><tr><td> volume </td><td> short </td><td> Varies depending on action.</td></tr>
      </table>
<h3><a id="Y_CABLE_CONNECTION_COMMAND">Y Cable Connection Command</a></h3>
<b>Description:</b> Connection state for a Y-Cable.<br>
<b>Message Id:</b> <i>plt.msg.Y_CABLE_CONNECTION_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> state </td><td> boolean - true or false </td><td> True (1) if the Y-Cable is connected and false (0) if the Y-Cable is disconnected.</td></tr>
      </table>
<h3><a id="MAKE_CALL_COMMAND">Make call Command</a></h3>
<b>Description:</b> Dial a telephone number. Whitespace (ASCII space, tab, LF, CR) is ignored.  This is intended only
                for devices (like Bluetooth headsets) with the ability to tell the audio gateway (AG) to do so.<br>
<b>Message Id:</b> <i>plt.msg.MAKE_CALL_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> digits </td><td> string </td><td> The digits to dial. Whitespace (ASCII space, tab, LF, CR) is ignored.</td></tr>
      </table>
<h3><a id="REDIAL_COMMAND">Redial Command</a></h3>
<b>Description:</b> Redial the most recently-dialed telephone number. If the device has not dialed a
                number previously, this command is ignored. This is intended only
                for devices (like Bluetooth headsets) with the ability to tell the audio gateway (AG) to redial.<br>
<b>Message Id:</b> <i>plt.msg.REDIAL_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="FLASH_CALL_COMMAND">Flash Call Command</a></h3>
<b>Description:</b> Issue a Flash command to a device.<br>
<b>Message Id:</b> <i>plt.msg.FLASH_CALL_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> value </td><td> short </td><td> Reserved for future use - set to 0.</td></tr>
      </table>
<h3><a id="CONFIGURE_CURRENT_LANGUAGE_COMMAND">Configure Current Language Command</a></h3>
<b>Description:</b> If the Language ID is valid , the success should be returned .Otherwise "Illegal value" exception should be throw.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_CURRENT_LANGUAGE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> LanguageId </td><td> short </td><td> </td></tr>
      </table>
<h3><a id="REMOVE_PARTITION_INFORMATION_COMMAND">Remove Partition Information Command</a></h3>
<b>Description:</b> This command removes information for a partition given a partition id - this would normally be a language id<br>
<b>Message Id:</b> <i>plt.msg.REMOVE_PARTITION_INFORMATION_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> partitionId </td><td> short </td><td> The partition id to remove</td></tr>
      </table>
<h3><a id="SET_RINGTONE_COMMAND">Set Ringtone Command</a></h3>
<b>Description:</b> Set the ring tone for a particular interface.<br>
<b>Message Id:</b> <i>plt.msg.SET_RINGTONE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> interfaceType </td><td> byte </td><td> </td></tr><tr><td> ringTone </td><td> byte </td><td> The ring tone to set, a value in the range [0..2] inclusive.</td></tr>
      </table>
<h3><a id="SET_AUDIO_BANDWIDTH_COMMAND">Set Audio Bandwidth Command</a></h3>
<b>Description:</b> Set the bandwidth (narrowband or wideband) for the given interface.<br>
<b>Message Id:</b> <i>plt.msg.SET_AUDIO_BANDWIDTH_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> interfaceType </td><td> byte </td><td> </td></tr><tr><td> bandwidth </td><td> byte </td><td> The bandwidth, either 1 (narrowband) or 2 (wideband).</td></tr>
      </table>
<h3><a id="SET_RINGTONE_VOLUME_COMMAND">Set Ringtone Volume Command</a></h3>
<b>Description:</b> Set the ring tone volume for the given interface.<br>
<b>Message Id:</b> <i>plt.msg.SET_RINGTONE_VOLUME_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> interfaceType </td><td> byte </td><td> </td></tr><tr><td> volume </td><td> byte </td><td> </td></tr>
      </table>
<h3><a id="SET_DEFAULT_OUTBOUND_INTERFACE_COMMAND">Set Default Outbound Interface Command</a></h3>
<b>Description:</b> Set the interface to be the default for subsequent outgoing calls.<br>
<b>Message Id:</b> <i>plt.msg.SET_DEFAULT_OUTBOUND_INTERFACE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> interfaceType </td><td> byte </td><td> </td></tr>
      </table>
<h3><a id="SET_TONE_CONTROL_COMMAND">Set Tone Control Command</a></h3>
<b>Description:</b> Sets the tone level for a particular interface (PSTN or VOIP).<br>
<b>Message Id:</b> <i>plt.msg.SET_TONE_CONTROL_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> interfaceType </td><td> byte </td><td> </td></tr><tr><td> toneLevel </td><td> byte </td><td> The tone level to set, a value in the range [0..6] inclusive.</td></tr>
      </table>
<h3><a id="SET_AUDIO_SENSING_COMMAND">Set Audio Sensing Command</a></h3>
<b>Description:</b> Configure whether the radio link should automatically be established between the base and wireless headset without
                needing to press the call control button.<br>
<b>Message Id:</b> <i>plt.msg.SET_AUDIO_SENSING_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> audioSensing </td><td> boolean - true or false </td><td> True if the radio link should automatically be established between the base and wireless headset without needing to press the call control button, false otherwise.</td></tr>
      </table>
<h3><a id="SET_INTELLISTAND_AUTO_ANSWER_COMMAND">Set Intellistand Auto-Answer Command</a></h3>
<b>Description:</b> Configure whether an incoming call should be answered automatically when the headset is removed from the charging cradle.<br>
<b>Message Id:</b> <i>plt.msg.SET_INTELLISTAND_AUTO_ANSWER_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> intellistand </td><td> boolean - true or false </td><td> True if the incoming calls should be automatically answered when the headset is removed from the charging cradle.   False if the headset call control button or base PC/desk phone talk button must be pressed to answer the incoming call.</td></tr>
      </table>
<h3><a id="SET_AUTO_CONNECT_TO_MOBILE_COMMAND">Set Auto-Connect to Mobile Command</a></h3>
<b>Description:</b> Configure whether or not a Bluetooth link to the mobile phone should automatically be established when the headset is undocked and the mobile phone is within range.<br>
<b>Message Id:</b> <i>plt.msg.SET_AUTO_CONNECT_TO_MOBILE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> autoConnect </td><td> boolean - true or false </td><td> Set to true if the base should automatically establish a Bluetooth link to the mobile phone when the headset is undocked from the base and the mobile phone is within range.   Set to false if it should not automatically establish the link.</td></tr>
      </table>
<h3><a id="SET_STOP_AUTO_CONNECT_ON_DOCK_COMMAND">Set Stop Auto-Connect on Dock Command</a></h3>
<b>Description:</b> Configures whether or not the Bluetooth connection to the mobile phone should be dropped automatically when the headset is docked (only  applicable if Set Auto-Connect to Mobile is true).<br>
<b>Message Id:</b> <i>plt.msg.SET_STOP_AUTO_CONNECT_ON_DOCK_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> stopAutoConnect </td><td> boolean - true or false </td><td> Set to true if the Bluetooth connection to the mobile phone should be dropped when the headset is docked, false if the connection should not be dropped. Only applicable if Set Auto-Connect to Mobile is true.</td></tr>
      </table>
<h3><a id="SET_BLUETOOTH_ENABLED_COMMAND">Set Bluetooth Enabled Command</a></h3>
<b>Description:</b> Configures whether or not Bluetooth is enabled.<br>
<b>Message Id:</b> <i>plt.msg.SET_BLUETOOTH_ENABLED_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> bluetoothEnabled </td><td> boolean - true or false </td><td> Set to true if  Bluetooth should be enabled, false otherwise.</td></tr>
      </table>
<h3><a id="SET_OVER_THE_AIR_SUBSCRIPTION_COMMAND">Set Over-the-Air Subscription Command</a></h3>
<b>Description:</b> Configures whether or not a headset can be subscribed to the base without docking the headset.<br>
<b>Message Id:</b> <i>plt.msg.SET_OVER_THE_AIR_SUBSCRIPTION_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> otaEnabled </td><td> boolean - true or false </td><td> Set to true if a headset can subscribe to the base without docking the headset, otherwise set to false.</td></tr>
      </table>
<h3><a id="SET_SYSTEM_TONE_VOLUME_COMMAND">Set System Tone Volume Command</a></h3>
<b>Description:</b> Sets the system tone volume.<br>
<b>Message Id:</b> <i>plt.msg.SET_SYSTEM_TONE_VOLUME_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> volume </td><td> byte </td><td> .</td></tr>
      </table>
<h3><a id="SET_POWER_LEVEL_COMMAND">Set Power Level Command</a></h3>
<b>Description:</b> Configures the power level which, if minimized, can improve user density, help with deskphone/PC buzzing, or restrict the range of a user.<br>
<b>Message Id:</b> <i>plt.msg.SET_POWER_LEVEL_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> powerLevel </td><td> byte </td><td> Sets the power level (range), a value in the range [0..2] inclusive:
                        Low - up to 50 feet
                        Medium - up to 150 feet
                        High - up to 300 feet</td></tr>
      </table>
<h3><a id="SET_MOBILE_VOICE_COMMANDS">Set Mobile Voice Commands Command</a></h3>
<b>Description:</b> Configures the ability to put a paired mobile phone in voice command mode via the mobile phone button on the base.<br>
<b>Message Id:</b> <i>plt.msg.SET_MOBILE_VOICE_COMMANDS</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> mobileVoiceCommands </td><td> boolean - true or false </td><td> Sets whether or not you can put a paired mobile phone in voice command mode by pressing the mobile phone button on the base.  If true, pressing the mobile phone button on the base will enable voice commands on the mobile phone.  If false, voice commands on the mobile phone will not be enabled when you press the base mobile phone button.</td></tr>
      </table>
<h3><a id="SET_VOLUME_CONTROL_ORIENTATION_COMMAND">Set Volume Control Orientation Command</a></h3>
<b>Description:</b> Sets the volume control orientation to the right or left ear.<br>
<b>Message Id:</b> <i>plt.msg.SET_VOLUME_CONTROL_ORIENTATION_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> orientation </td><td> byte </td><td> Numeric value to set the volume control orientation to the right ear (0) or left ear (1).</td></tr>
      </table>
<h3><a id="SET_DEFAULT_FEATURE_COMMAND">Set default feature Command</a></h3>
<b>Description:</b> sets the default values to certain features.Features that are already locked are ignored.<br>
<b>Message Id:</b> <i>plt.msg.SET_DEFAULT_FEATURE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_ACOUSTIC_INCIDENT_REPORTING_ENABLE_COMMAND">AAL Acoustic Incident Reporting Enable Command</a></h3>
<b>Description:</b> Set AAL acoustic incident reporting to be enabled or disabled, true or false.<br>
<b>Message Id:</b> <i>plt.msg.AAL_ACOUSTIC_INCIDENT_REPORTING_ENABLE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> The acoustic incident reporting enable state: true or false.</td></tr>
      </table>
<h3><a id="AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_COMMAND">AAL Acoustic Incident Reporting Thresholds Command</a></h3>
<b>Description:</b> Set AAL acoustic incident reporting thresholds.<br>
<b>Message Id:</b> <i>plt.msg.AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> gainThreshold </td><td> byte </td><td> The acoustic incident reporting threshold for gain upon which crossed for a set amount of time will result in a report being sent (0 to 12 dB in 1 dB increments).</td></tr><tr><td> timeThreshold </td><td> short </td><td> The acoustic incident reporting threshold for the amount of time of having a gain above the gain threshold will result in a report being sent (1 to 1000 ms in 1 ms increments).</td></tr>
      </table>
<h3><a id="AAL_ACOUSTIC_INCIDENT_REPORT_COMMAND">AAL Acoustic Incident Report Command</a></h3>
<b>Description:</b> PLACEHOLDER: This command ID is reserved as the command is not supported but no other command shall use the associated ID per policy.<br>
<b>Message Id:</b> <i>plt.msg.AAL_ACOUSTIC_INCIDENT_REPORT_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_TWA_REPORTING_ENABLE_COMMAND">AAL TWA Reporting Enable Command</a></h3>
<b>Description:</b> Set AAL TWA reporting to be enabled or disabled, true or false.<br>
<b>Message Id:</b> <i>plt.msg.AAL_TWA_REPORTING_ENABLE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> The TWA reporting enable state: true or false.</td></tr>
      </table>
<h3><a id="AAL_TWA_REPORTING_TIME_PERIOD_COMMAND">AAL TWA Reporting Time Period Command</a></h3>
<b>Description:</b> Set AAL TWA reporting time period frequency.<br>
<b>Message Id:</b> <i>plt.msg.AAL_TWA_REPORTING_TIME_PERIOD_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> timePeriod </td><td> integer </td><td> The time period frequency at which a TWA report is sent out (1 to 10 minutes in 60,000 ms increments).</td></tr>
      </table>
<h3><a id="SET_ANTI_STARTLE_COMMAND">Set Anti-startle Command</a></h3>
<b>Description:</b> Set the new anti-startle value, true or false.<br>
<b>Message Id:</b> <i>plt.msg.SET_ANTI_STARTLE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> The new anti-startle value: true or false.</td></tr>
      </table>
<h3><a id="AAL_TWA_REPORT_COMMAND">AAL TWA Report Command</a></h3>
<b>Description:</b> PLACEHOLDER: This command ID is reserved as the command is not supported but no other command shall use the associated ID per policy.<br>
<b>Message Id:</b> <i>plt.msg.AAL_TWA_REPORT_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SET_G616_COMMAND">Set G616 Command</a></h3>
<b>Description:</b> Set the new G.616 value, true or false.<br>
<b>Message Id:</b> <i>plt.msg.SET_G616_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> The new G.616 value, true or false.</td></tr>
      </table>
<h3><a id="CONVERSATION_DYNAMICS_REPORTING_ENABLE_COMMAND">Conversation Dynamics Reporting Enable Command</a></h3>
<b>Description:</b> Set conversation dynamics reporting to be enabled or disabled, true or false.<br>
<b>Message Id:</b> <i>plt.msg.CONVERSATION_DYNAMICS_REPORTING_ENABLE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> enable </td><td> boolean - true or false </td><td> The conversation dynamics reporting enable state: true or false.</td></tr>
      </table>
<h3><a id="SET_TIME_WEIGHTED_AVERAGE_COMMAND">Set time-weighted average Command</a></h3>
<b>Description:</b> Set the new time-weighted average value.<br>
<b>Message Id:</b> <i>plt.msg.SET_TIME_WEIGHTED_AVERAGE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> twa </td><td> byte </td><td> </td></tr>
      </table>
<h3><a id="CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_COMMAND">Conversation Dynamics Reporting Time Period Command</a></h3>
<b>Description:</b> Set conversation dynamics reporting time period frequency.<br>
<b>Message Id:</b> <i>plt.msg.CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> timePeriod </td><td> integer </td><td> The time period frequency at which a conversation dynamics report is sent out (1 to 60 seconds in 1,000 ms increments).</td></tr>
      </table>
<h3><a id="SET_TIME_WEIGHTED_AVERAGE_PERIOD_COMMAND">Set time-weighted average period Command</a></h3>
<b>Description:</b> Set the new time-weighted average period value.<br>
<b>Message Id:</b> <i>plt.msg.SET_TIME_WEIGHTED_AVERAGE_PERIOD_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> twa </td><td> byte </td><td> </td></tr>
      </table>
<h3><a id="CONVERSATION_DYNAMICS_REPORT_COMMAND">Conversation Dynamics Report Command</a></h3>
<b>Description:</b> PLACEHOLDER: This command ID is reserved as the command is not supported but no other command shall use the associated ID per policy.<br>
<b>Message Id:</b> <i>plt.msg.CONVERSATION_DYNAMICS_REPORT_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BLUETOOTH_DSP_SEND_MESSAGE_COMMAND">Bluetooth DSP Send Message Command</a></h3>
<b>Description:</b> Send a message to the DSP<br>
<b>Message Id:</b> <i>plt.msg.BLUETOOTH_DSP_SEND_MESSAGE_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> messageid </td><td> short </td><td> Message ID to send to DSP</td></tr><tr><td> parametera </td><td> short </td><td> First parameter for DSP message</td></tr><tr><td> parameterb </td><td> short </td><td> Second parameter for DSP message</td></tr><tr><td> parameterc </td><td> short </td><td> Third parameter for DSP message</td></tr><tr><td> parameterd </td><td> short </td><td> Fourth parameter for DSP message</td></tr>
      </table>
<h3><a id="BLUETOOTH_DSP_SEND_MESSAGE_LONG_COMMAND">Bluetooth DSP Send Message Long Command</a></h3>
<b>Description:</b> Send a message long to the DSP<br>
<b>Message Id:</b> <i>plt.msg.BLUETOOTH_DSP_SEND_MESSAGE_LONG_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> messageid </td><td> short </td><td> Message ID from DSP</td></tr><tr><td> parameter </td><td> array of bytes </td><td> Byte array with DSP parameters</td></tr>
      </table>
<h3><a id="BLUETOOTH_DSP_LOAD_COMMAND">Bluetooth DSP Load Command</a></h3>
<b>Description:</b> If TRUE load and start the DSP code<br>
<b>Message Id:</b> <i>plt.msg.BLUETOOTH_DSP_LOAD_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> load </td><td> boolean - true or false </td><td> TRUE to load and start the DSP code</td></tr>
      </table>
<h3><a id="SET_DSP_PARAMETERS_COMMAND">Set DSP Parameters Command</a></h3>
<b>Description:</b> Set DSP parameters, either in persistent or volatile storage.<br>
<b>Message Id:</b> <i>plt.msg.SET_DSP_PARAMETERS_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> codec </td><td> byte </td><td> </td></tr><tr><td> storeIsVolatile </td><td> boolean - true or false </td><td> this is for the DSP to say how it is stored - not the vm ---------------
                        FALSE = store in Non-Volatile storage        ---- set pskey value to payload
                        TRUE = store in Volatile storage          ------ send message to dsp</td></tr><tr><td> ParameterIndex </td><td> short </td><td> Zero based index into KAT</td></tr><tr><td> Payload </td><td> array of shorts </td><td> DSP payload data</td></tr>
      </table>
<h3><a id="DSP_UPDATE_PARAMETERS_COMMAND">DSP Update Parameters Command</a></h3>
<b>Description:</b> Update DSP for given type<br>
<b>Message Id:</b> <i>plt.msg.DSP_UPDATE_PARAMETERS_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> codec </td><td> byte </td><td> </td></tr>
      </table>
<h3><a id="SET_FEATURE_LOCK_COMMAND">Set feature lock Command</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.SET_FEATURE_LOCK_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> commands </td><td> array of shorts </td><td> </td></tr>
      </table>
<h3><a id="SET_PASSWORD_COMMAND">Set password Command</a></h3>
<b>Description:</b> Set the device's password value.
                The device is not expected to undertake any checking mechanism to validate the password.<br>
<b>Message Id:</b> <i>plt.msg.SET_PASSWORD_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> password </td><td> string </td><td> The password to associate with the device.</td></tr>
      </table>
<h3><a id="HAL_CURRENT_SCENARIO_COMMAND">Hal Current Scenario Command</a></h3>
<b>Description:</b> Allows HAL to set the current scenario<br>
<b>Message Id:</b> <i>plt.msg.HAL_CURRENT_SCENARIO_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> scenario </td><td> short </td><td> </td></tr>
      </table>
<h3><a id="HAL_CONFIGURE_VOLUME_COMMAND">Hal Configure Volume Command</a></h3>
<b>Description:</b> Allows HAL to configure devices volumes<br>
<b>Message Id:</b> <i>plt.msg.HAL_CONFIGURE_VOLUME_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> scenario </td><td> short </td><td> </td></tr><tr><td> volumes </td><td> array of bytes </td><td> </td></tr>
      </table>
<h3><a id="HAL_CONFIGURE_EQ_COMMAND">Hal Configure EQ Command</a></h3>
<b>Description:</b> Command to set one or more EQ settings within the headset.<br>
<b>Message Id:</b> <i>plt.msg.HAL_CONFIGURE_EQ_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> scenario </td><td> short </td><td> The scenario to act on for the EQ setting</td></tr><tr><td> numberOfEQs </td><td> short </td><td> The number of EQ setting specified in this message</td></tr><tr><td> EQId </td><td> byte </td><td> The EQ to control</td></tr><tr><td> EQSettings </td><td> array of bytes </td><td> Array of EQ settings.
                        Where the EQ is represented as individual sliders, the range is 0..255 to represent 0..100%</td></tr>
      </table>
<h3><a id="CONFIGURE_SERVICES_COMMAND">Configure services Command</a></h3>
<b>Description:</b> Configure one or more service characteristics.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_SERVICES_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> serviceID </td><td> short </td><td> </td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr><tr><td> configurationData </td><td> array of bytes </td><td> </td></tr>
      </table>
<h3><a id="CALIBRATE_SERVICES_COMMAND">Calibrate services Command</a></h3>
<b>Description:</b> Calibrate one or more service characteristics.<br>
<b>Message Id:</b> <i>plt.msg.CALIBRATE_SERVICES_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> serviceID </td><td> short </td><td> </td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr><tr><td> calibrationData </td><td> array of bytes </td><td> </td></tr>
      </table>
<h3><a id="CONFIGURE_APPLICATION_COMMAND">Configure application Command</a></h3>
<b>Description:</b> Configure one or more application characteristics.<br>
<b>Message Id:</b> <i>plt.msg.CONFIGURE_APPLICATION_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> featureID </td><td> short </td><td> </td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr><tr><td> configurationData </td><td> array of bytes </td><td> </td></tr>
      </table>
<h3><a id="PERFORM_APPLICATION_ACTION_COMMAND">Perform application action Command</a></h3>
<b>Description:</b> Performs an application action.<br>
<b>Message Id:</b> <i>plt.msg.PERFORM_APPLICATION_ACTION_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> ApplicationID </td><td> short </td><td> </td></tr><tr><td> action </td><td> short </td><td> </td></tr><tr><td> operatingData </td><td> array of bytes </td><td> </td></tr>
      </table>
<h3><a id="SUBSCRIBE_TO_SERVICES_COMMAND">Subscribe to services Command</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b> <i>plt.msg.SUBSCRIBE_TO_SERVICES_COMMAND</i><br>
<b>Options Object:</b>This object is optional if 'address' is the only attribute specified in the table below
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> serviceID </td><td> short </td><td> </td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr><tr><td> mode </td><td> short </td><td> </td></tr><tr><td> period </td><td> short </td><td> </td></tr>
      </table>

 
  
  
  
  
  
 
