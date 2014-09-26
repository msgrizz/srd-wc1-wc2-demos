#PLT Labs Javascript Library - Message Creation API reference
=============
[PltLabs](http://pltlabs.com) -
An exaustive listing of how to create PLT API messages to be sent to the device
* Twitter: [@pltlabs](http://twitter.com/pltlabs)
* Author: [@carybran](http://twitter.com/carybran)


Message Creation in a nutshell
----------
The plt.msg library is used to create and parse messages that are sent to or origniate from PLT devices
that have M2M capabilities - for example the WC1, Voyager Edge

```javascript
//accessing the id's of message types
var commandId = plt.msg.CONFIGURE_MUTE_TONE_VOLUME_COMMAND; //value is 0x0400
var settingId = plt.msg.DEVICE_STATUS_SETTING; //value is 0x1006

//parsing a raw message regardless of type returns a JSON object representation of the raw message
var parsedMessage = plt.msg.parse(rawMessage);

//JSON format of parsed message
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
   
   
//creating a command to send to the PLT device - this example shows enabling proximity
var options = {}
options.enable =  true;
options.sensitivity = 5;
options.nearThreshold = 0x3C;
options.maxTimeout = 0xFFFF;
var command = plt.msg.createCommand(plt.msg.CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND, options);

//command.messageBytes - member has the PLT raw message byte array that would be sent to device

//creating a get setting request = this example shows how to get battery level status
var setting = plt.msg.createGetSetting(plt.msg.BATTERY_INFO_SETTING);

//how to create a command to enable headtracking sensor data output
var sensorPortAddress = new ArrayBuffer(4);
var sensorPortAddress_view = new Uint8Array(sensorPortAddress);
sensorPortAddress_view[0] = 0x50;
var options = {};
options.address = sensorPortAddress;
options.serviceID = plt.msg.TYPE_SERVICEID_HEADORIENTATION;
options.mode = plt.msg.TYPE_MODEONCCHANGE;
var command = plt.msg.createCommand(plt.msg.SUBSCRIBE_TO_SERVICES_COMMAND, options);
```
###Host Negotiate Messages
When do you use this message?

How do you use it?

###PLT Setting Messages
When do you use this message?

 
<h2>Settings Messages</h2>
       <a href="BUTTON_SIMULATION_CAPABILITIES_SETTING">Button Simulation Capabilities Setting</a><br>
       <a href="INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING">Indirect Event Simulation Capabilities Setting</a><br>
       <a href="DEVICE_STATUS_CAPABILITIES_SETTING">Device Status Capabilities Setting</a><br>
       <a href="DEVICE_STATUS_SETTING">Device Status Setting</a><br>
       <a href="CUSTOM_DEVICE_STATUS_SETTING">Custom Device Status Setting</a><br>
       <a href="SINGLE_NVRAM_CONFIGURATION_READ_SETTING">Single NVRAM Configuration Read Setting</a><br>
       <a href="SUPPORTED_TEST_INTERFACE_MESSAGE_IDS_SETTING">Supported Test Interface Message IDs Setting</a><br>
       <a href="SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING">Single NVRAM Configuration Read With Address Echo Setting</a><br>
  
  
<h3><a id="BUTTON_SIMULATION_CAPABILITIES_SETTING">Button Simulation Capabilities Setting</a></h3>
<b>Description:</b> Query for the IDs specifying the buttons that are supported to be simulated.<br>
<b>Message Id:</b><i>plt.msg.BUTTON_SIMULATION_CAPABILITIES_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING">Indirect Event Simulation Capabilities Setting</a></h3>
<b>Description:</b> Query for the IDs specifying the indirect events that are supported to be simulated.<br>
<b>Message Id:</b><i>plt.msg.INDIRECT_EVENT_SIMULATION_CAPABILITIES_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="DEVICE_STATUS_CAPABILITIES_SETTING">Device Status Capabilities Setting</a></h3>
<b>Description:</b> Query for the IDs specifying the device status data that will be provided upon a device status query.<br>
<b>Message Id:</b><i>plt.msg.DEVICE_STATUS_CAPABILITIES_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="DEVICE_STATUS_SETTING">Device Status Setting</a></h3>
<b>Description:</b> Query for the internal device status of a device under test.<br>
<b>Message Id:</b><i>plt.msg.DEVICE_STATUS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CUSTOM_DEVICE_STATUS_SETTING">Custom Device Status Setting</a></h3>
<b>Description:</b> Query for the internal device specific custom status of a device under test with engineering defined formatting for the specific device.<br>
<b>Message Id:</b><i>plt.msg.CUSTOM_DEVICE_STATUS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SINGLE_NVRAM_CONFIGURATION_READ_SETTING">Single NVRAM Configuration Read Setting</a></h3>
<b>Description:</b> Query for the configuration item specified in the Setting request.<br>
<b>Message Id:</b><i>plt.msg.SINGLE_NVRAM_CONFIGURATION_READ_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> configurationItemAddress </td><td> long </td><td> The address of the NVRAM Storage to be read.</td></tr>
      </table>
<h3><a id="SUPPORTED_TEST_INTERFACE_MESSAGE_IDS_SETTING">Supported Test Interface Message IDs Setting</a></h3>
<b>Description:</b> Query for the set of supported Test Interface Deckard Message IDs for the device.<br>
<b>Message Id:</b><i>plt.msg.SUPPORTED_TEST_INTERFACE_MESSAGE_IDS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING">Single NVRAM Configuration Read With Address Echo Setting</a></h3>
<b>Description:</b> Query for the configuration item specified in the Setting request.<br>
<b>Message Id:</b><i>plt.msg.SINGLE_NVRAM_CONFIGURATION_READ_WITH_ADDRESS_ECHO_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> configurationItemAddress </td><td> long </td><td> The address of the NVRAM Storage to be read.</td></tr>
      </table>
       <a href="WEARING_STATE_SETTING">Wearing state Setting</a><br>
       <a href="AUTO_ANSWER_ON_DON_SETTING">Auto-answer on don Setting</a><br>
       <a href="AUTO_PAUSE_MEDIA_SETTING">Auto-pause media Setting</a><br>
       <a href="AUTO_TRANSFER_CALL_SETTING">Auto-transfer call Setting</a><br>
       <a href="GET_AUTO_LOCK_CALL_BUTTON_SETTING">Get auto-lock call button Setting</a><br>
       <a href="WEARING_SENSOR_ENABLED_SETTING">Wearing sensor enabled Setting</a><br>
       <a href="AUTO_MUTE_CALL_SETTING">Auto-Mute call Setting</a><br>
  
  
<h3><a id="WEARING_STATE_SETTING">Wearing state Setting</a></h3>
<b>Description:</b> The wearing state (donned/doffed). True = donned/worn.<br>
<b>Message Id:</b><i>plt.msg.WEARING_STATE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUTO_ANSWER_ON_DON_SETTING">Auto-answer on don Setting</a></h3>
<b>Description:</b> Whether the device should answer incoming calls when the user dons the headset.
                If true, answer on don. If false, donning the headset during an incoming call
                will have no effect.<br>
<b>Message Id:</b><i>plt.msg.AUTO_ANSWER_ON_DON_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUTO_PAUSE_MEDIA_SETTING">Auto-pause media Setting</a></h3>
<b>Description:</b> If enabled (autoPauseMedia = true), removing the headset will
                automatically pause audio (by sending AVRCP Pause); donning the headset
                will resume streaming audio (by sending AVRCP Play).<br>
<b>Message Id:</b><i>plt.msg.AUTO_PAUSE_MEDIA_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUTO_TRANSFER_CALL_SETTING">Auto-transfer call Setting</a></h3>
<b>Description:</b> Returns whether the device should switch the audio of an in-progress call based on
                wearing state.
                See the "Configure auto-transfer call" command for more details.<br>
<b>Message Id:</b><i>plt.msg.AUTO_TRANSFER_CALL_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
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
<b>Message Id:</b><i>plt.msg.GET_AUTO_LOCK_CALL_BUTTON_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="WEARING_SENSOR_ENABLED_SETTING">Wearing sensor enabled Setting</a></h3>
<b>Description:</b> Describes whether the wearing sensor is enabled.  If the sensor is disabled,
                for example through the Morini control panel, the device will not generate "Wearing state" events.
                This setting must be implemented in all devices equipped with a wearing state sensor.<br>
<b>Message Id:</b><i>plt.msg.WEARING_SENSOR_ENABLED_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUTO_MUTE_CALL_SETTING">Auto-Mute call Setting</a></h3>
<b>Description:</b> If enabled (autoMuteCall = true), removing the headset will
                automatically mute on of the active call; donning the headset
                will resume mute off the active call.<br>
<b>Message Id:</b><i>plt.msg.AUTO_MUTE_CALL_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
       <a href="CONFIGURATION_FOR_A_CONNECTED_HEADSET_SETTING">Configuration for a Connected Headset Setting</a><br>
       <a href="GET_MUTE_TONE_VOLUME_SETTING">Get mute tone volume Setting</a><br>
       <a href="GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING">Get second inbound call ring type Setting</a><br>
       <a href="GET_MUTE_OFF_VP_SETTING">Get Mute off VP Setting</a><br>
       <a href="GET_SCO_OPEN_TONE_ENABLE_SETTING">Get SCO Open Tone Enable Setting</a><br>
       <a href="GET_OLI_FEATURE_ENABLE_SETTING">Get OLI feature Enable Setting</a><br>
       <a href="MUTE_ALERT_SETTING">Mute Alert Setting</a><br>
  
  
<h3><a id="CONFIGURATION_FOR_A_CONNECTED_HEADSET_SETTING">Configuration for a Connected Headset Setting</a></h3>
<b>Description:</b> Configure how a device treats the connected headset.<br>
<b>Message Id:</b><i>plt.msg.CONFIGURATION_FOR_A_CONNECTED_HEADSET_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_MUTE_TONE_VOLUME_SETTING">Get mute tone volume Setting</a></h3>
<b>Description:</b> Configure how the device should play a tone on mute.<br>
<b>Message Id:</b><i>plt.msg.GET_MUTE_TONE_VOLUME_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING">Get second inbound call ring type Setting</a></h3>
<b>Description:</b> Get the second inbound call ring type.<br>
<b>Message Id:</b><i>plt.msg.GET_SECOND_INBOUND_CALL_RING_TYPE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_MUTE_OFF_VP_SETTING">Get Mute off VP Setting</a></h3>
<b>Description:</b> Device should return Mute off VP  enable status if it support this setting . Otherwise exception should be returned.<br>
<b>Message Id:</b><i>plt.msg.GET_MUTE_OFF_VP_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_SCO_OPEN_TONE_ENABLE_SETTING">Get SCO Open Tone Enable Setting</a></h3>
<b>Description:</b> Allow a device to be queried as to the configured state of the SCO Open Tone<br>
<b>Message Id:</b><i>plt.msg.GET_SCO_OPEN_TONE_ENABLE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_OLI_FEATURE_ENABLE_SETTING">Get OLI feature Enable Setting</a></h3>
<b>Description:</b> Device should return the OLI feature status.<br>
<b>Message Id:</b><i>plt.msg.GET_OLI_FEATURE_ENABLE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MUTE_ALERT_SETTING">Mute Alert Setting</a></h3>
<b>Description:</b> Return current mute alert scheme , disabled or time interval reminder or voice detect reminder<br>
<b>Message Id:</b><i>plt.msg.MUTE_ALERT_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
       <a href="CURRENT_SIGNAL_STRENGTH_SETTING">Current signal strength Setting</a><br>
       <a href="CALLER_ANNOUNCEMENT_SETTING">Caller announcement Setting</a><br>
       <a href="SIGNAL_STRENGTH_CONFIGURATION_SETTING">Signal strength configuration Setting</a><br>
       <a href="FIND_HEADSET_LED_ALERT_STATUS_SETTING">Find Headset LED Alert Status Setting</a><br>
       <a href="TXPOWER_REPORTING_SETTING">TxPower Reporting Setting</a><br>
       <a href="VOICE_SILENT_DETECTION_SETTING">Voice silent detection Setting</a><br>
  
  
<h3><a id="CURRENT_SIGNAL_STRENGTH_SETTING">Current signal strength Setting</a></h3>
<b>Description:</b> Returns the current signal strength.<br>
<b>Message Id:</b><i>plt.msg.CURRENT_SIGNAL_STRENGTH_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionId </td><td> byte </td><td> The connection ID of the link being requested to provide the signal strength information.</td></tr>
      </table>
<h3><a id="CALLER_ANNOUNCEMENT_SETTING">Caller announcement Setting</a></h3>
<b>Description:</b> Return the current caller announcement configuration.<br>
<b>Message Id:</b><i>plt.msg.CALLER_ANNOUNCEMENT_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SIGNAL_STRENGTH_CONFIGURATION_SETTING">Signal strength configuration Setting</a></h3>
<b>Description:</b> Reads configuration of rssi and near far.<br>
<b>Message Id:</b><i>plt.msg.SIGNAL_STRENGTH_CONFIGURATION_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionId </td><td> byte </td><td> The connection ID of the link being used to generate the signal strength event.</td></tr>
      </table>
<h3><a id="FIND_HEADSET_LED_ALERT_STATUS_SETTING">Find Headset LED Alert Status Setting</a></h3>
<b>Description:</b> Get current Find Headset LED Alert Status .<br>
<b>Message Id:</b><i>plt.msg.FIND_HEADSET_LED_ALERT_STATUS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TXPOWER_REPORTING_SETTING">TxPower Reporting Setting</a></h3>
<b>Description:</b> Get Transmit Output Power fro a given connection Id.<br>
<b>Message Id:</b><i>plt.msg.TXPOWER_REPORTING_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionId </td><td> byte </td><td> The connection ID of the link being requested to provide the transmit power information.</td></tr>
      </table>
<h3><a id="VOICE_SILENT_DETECTION_SETTING">Voice silent detection Setting</a></h3>
<b>Description:</b> Get current Voice silent detection mode.<br>
<b>Message Id:</b><i>plt.msg.VOICE_SILENT_DETECTION_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
       <a href="PRODUCT_NAME_SETTING">Product name Setting</a><br>
       <a href="TATTOO_SERIAL_NUMBER_SETTING">Tattoo Serial Number Setting</a><br>
       <a href="USB_PID_SETTING">USB PID Setting</a><br>
       <a href="TATTOO_BUILD_CODE_SETTING">Tattoo Build Code Setting</a><br>
       <a href="FIRMWARE_VERSION_SETTING">Firmware version Setting</a><br>
       <a href="PART_NUMBER_SETTING">Part Number Setting</a><br>
       <a href="USER_ID_SETTING">User ID Setting</a><br>
       <a href="FIRST_DATE_USED_SETTING">First Date Used Setting</a><br>
       <a href="LAST_DATE_USED_SETTING">Last Date Used Setting</a><br>
       <a href="LAST_DATE_CONNECTED_SETTING">Last Date Connected Setting</a><br>
       <a href="TIME_USED_SETTING">Time Used Setting</a><br>
       <a href="USER_DEFINED_STORAGE_SETTING">User Defined Storage Setting</a><br>
       <a href="VR_CALL_REJECT_AND_ANSWER_SETTING">VR call reject and answer Setting</a><br>
       <a href="A2DP_IS_ENABLED_SETTING">A2DP is enabled Setting</a><br>
       <a href="VOCALYST_PHONE_NUMBER_SETTING">Vocalyst phone number Setting</a><br>
       <a href="VOCALYST_INFO_NUMBER_SETTING">Vocalyst info number Setting</a><br>
       <a href="BATTERY_INFO_SETTING">Battery info Setting</a><br>
       <a href="GENES_GUID_SETTING">Genes GUID Setting</a><br>
       <a href="MUTE_REMINDER_TIMING_SETTING">Mute reminder timing Setting</a><br>
       <a href="PAIRING_MODE_SETTING">Pairing mode Setting</a><br>
       <a href="SPOKEN_ANSWER_IGNORE_COMMAND_SETTING">Spoken answer/ignore command Setting</a><br>
       <a href="LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING">Lync dial tone on Call press Setting</a><br>
       <a href="MANUFACTURER_SETTING">Manufacturer Setting</a><br>
       <a href="TOMBSTONE_SETTING">Tombstone Setting</a><br>
       <a href="BLUETOOTH_ADDRESS_SETTING">Bluetooth Address Setting</a><br>
       <a href="BLUETOOTH_CONNECTION_SETTING">Bluetooth Connection Setting</a><br>
       <a href="DECKARD_VERSION_SETTING">Deckard Version Setting</a><br>
  
  
<h3><a id="PRODUCT_NAME_SETTING">Product name Setting</a></h3>
<b>Description:</b> Return the user-facing product name (market name).<br>
<b>Message Id:</b><i>plt.msg.PRODUCT_NAME_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TATTOO_SERIAL_NUMBER_SETTING">Tattoo Serial Number Setting</a></h3>
<b>Description:</b> Tattoo serial number programmed in manufacturing.<br>
<b>Message Id:</b><i>plt.msg.TATTOO_SERIAL_NUMBER_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="USB_PID_SETTING">USB PID Setting</a></h3>
<b>Description:</b> This returns the device's USB product ID, a 16-bit unsigned quantity.<br>
<b>Message Id:</b><i>plt.msg.USB_PID_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TATTOO_BUILD_CODE_SETTING">Tattoo Build Code Setting</a></h3>
<b>Description:</b> Tattoo build code programmed in manufacturing.<br>
<b>Message Id:</b><i>plt.msg.TATTOO_BUILD_CODE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="FIRMWARE_VERSION_SETTING">Firmware version Setting</a></h3>
<b>Description:</b> The firmware ID is a pair of numbers. The buildTarget field describes the headset
                build-target, the release field contains the release number.<br>
<b>Message Id:</b><i>plt.msg.FIRMWARE_VERSION_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="PART_NUMBER_SETTING">Part Number Setting</a></h3>
<b>Description:</b> Part number and revision programmed in manufacturing.<br>
<b>Message Id:</b><i>plt.msg.PART_NUMBER_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="USER_ID_SETTING">User ID Setting</a></h3>
<b>Description:</b> User ID accessed by software.<br>
<b>Message Id:</b><i>plt.msg.USER_ID_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="FIRST_DATE_USED_SETTING">First Date Used Setting</a></h3>
<b>Description:</b> Date of the first date of device use.<br>
<b>Message Id:</b><i>plt.msg.FIRST_DATE_USED_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LAST_DATE_USED_SETTING">Last Date Used Setting</a></h3>
<b>Description:</b> Date of the last date of device use.<br>
<b>Message Id:</b><i>plt.msg.LAST_DATE_USED_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LAST_DATE_CONNECTED_SETTING">Last Date Connected Setting</a></h3>
<b>Description:</b> Date of the last date of device connection.<br>
<b>Message Id:</b><i>plt.msg.LAST_DATE_CONNECTED_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TIME_USED_SETTING">Time Used Setting</a></h3>
<b>Description:</b> Total time of time used.<br>
<b>Message Id:</b><i>plt.msg.TIME_USED_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="USER_DEFINED_STORAGE_SETTING">User Defined Storage Setting</a></h3>
<b>Description:</b> Message for user defined storage access.<br>
<b>Message Id:</b><i>plt.msg.USER_DEFINED_STORAGE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="VR_CALL_REJECT_AND_ANSWER_SETTING">VR call reject and answer Setting</a></h3>
<b>Description:</b> Return whether the VR call reject / answer feature is enabled or not.<br>
<b>Message Id:</b><i>plt.msg.VR_CALL_REJECT_AND_ANSWER_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="A2DP_IS_ENABLED_SETTING">A2DP is enabled Setting</a></h3>
<b>Description:</b> Is A2DP currently enabled? Return true if it is, false if not.<br>
<b>Message Id:</b><i>plt.msg.A2DP_IS_ENABLED_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="VOCALYST_PHONE_NUMBER_SETTING">Vocalyst phone number Setting</a></h3>
<b>Description:</b> Returns the current Vocalyst telephone number.<br>
<b>Message Id:</b><i>plt.msg.VOCALYST_PHONE_NUMBER_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="VOCALYST_INFO_NUMBER_SETTING">Vocalyst info number Setting</a></h3>
<b>Description:</b> Returns the current Vocalyst information ("411") telephone number.<br>
<b>Message Id:</b><i>plt.msg.VOCALYST_INFO_NUMBER_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BATTERY_INFO_SETTING">Battery info Setting</a></h3>
<b>Description:</b> Implemented only in devices (typically headsets) equipped with a battery.
                The current battery state: battery level, minutes of talk time, if the talk time is
                a high estimate, and charging or not.<br>
<b>Message Id:</b><i>plt.msg.BATTERY_INFO_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GENES_GUID_SETTING">Genes GUID Setting</a></h3>
<b>Description:</b> Return the device's Genes Globally Unique ID (GUID). If the device should contain no Genes
                GUID, it must not implement this Setting.<br>
<b>Message Id:</b><i>plt.msg.GENES_GUID_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MUTE_REMINDER_TIMING_SETTING">Mute reminder timing Setting</a></h3>
<b>Description:</b> Return the interval between mute reminders (voice prompt or tone) in the headset.<br>
<b>Message Id:</b><i>plt.msg.MUTE_REMINDER_TIMING_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="PAIRING_MODE_SETTING">Pairing mode Setting</a></h3>
<b>Description:</b> To be implemented only in Bluetooth devices.
                Is the device in Bluetooth pairing mode?
                Returns true if in pairing mode, false if not.<br>
<b>Message Id:</b><i>plt.msg.PAIRING_MODE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SPOKEN_ANSWER_IGNORE_COMMAND_SETTING">Spoken answer/ignore command Setting</a></h3>
<b>Description:</b> Reports if the 'say "answer" or "ignore"' prompt and recognition feature is enabled.<br>
<b>Message Id:</b><i>plt.msg.SPOKEN_ANSWER_IGNORE_COMMAND_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING">Lync dial tone on Call press Setting</a></h3>
<b>Description:</b> Returns whether the Lync Dialtone feature is enabled. See the command "Configure
                Lync dial tone on Call press" for more details.<br>
<b>Message Id:</b><i>plt.msg.LYNC_DIAL_TONE_ON_CALL_PRESS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MANUFACTURER_SETTING">Manufacturer Setting</a></h3>
<b>Description:</b> This setting provides information that identifies the manufacturer of the device in
                "reverse DNS" style.  Generally, this will always be "COM.PLANTRONICS".<br>
<b>Message Id:</b><i>plt.msg.MANUFACTURER_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TOMBSTONE_SETTING">Tombstone Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.TOMBSTONE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BLUETOOTH_ADDRESS_SETTING">Bluetooth Address Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.BLUETOOTH_ADDRESS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BLUETOOTH_CONNECTION_SETTING">Bluetooth Connection Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.BLUETOOTH_CONNECTION_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> connectionOffset </td><td> short </td><td> Offset of required connection bluetooth settings</td></tr>
      </table>
<h3><a id="DECKARD_VERSION_SETTING">Deckard Version Setting</a></h3>
<b>Description:</b> This setting allows a device to be queried as to which version of Deckard its messages Ids and payloads
                have been built against.<br>
<b>Message Id:</b><i>plt.msg.DECKARD_VERSION_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
       <a href="CONNECTION_STATUS_SETTING">Connection Status Setting</a><br>
  
  
<h3><a id="CONNECTION_STATUS_SETTING">Connection Status Setting</a></h3>
<b>Description:</b> Enables a Host to determine the number of ports and connection status of a device.<br>
<b>Message Id:</b><i>plt.msg.CONNECTION_STATUS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
       <a href="CALL_STATUS_SETTING">Call status Setting</a><br>
       <a href="MICROPHONE_MUTE_STATE_SETTING">Microphone Mute State Setting</a><br>
       <a href="TRANSMIT_AUDIO_STATE_SETTING">Transmit Audio State Setting</a><br>
       <a href="RECEIVE_AUDIO_STATE_SETTING">Receive Audio State Setting</a><br>
       <a href="LED_STATUS_GENERIC_SETTING">LED Status Generic Setting</a><br>
       <a href="HEADSET_AVAILABLE_SETTING">Headset Available Setting</a><br>
       <a href="Y_CABLE_CONNECTION_SETTING">Y Cable Connection Setting</a><br>
       <a href="SPEAKER_VOLUME_SETTING">Speaker Volume Setting</a><br>
       <a href="SPOKEN_LANGUAGE_SETTING">Spoken language Setting</a><br>
       <a href="SUPPORTED_LANGUAGES_SETTING">Supported Languages Setting</a><br>
       <a href="GET_PARTITION_INFORMATION_SETTING">Get Partition Information Setting</a><br>
       <a href="AUDIO_STATUS_SETTING">Audio status Setting</a><br>
       <a href="LED_STATUS_SETTING">LED Status Setting</a><br>
       <a href="HEADSET_CALL_STATUS_SETTING">Headset Call status Setting</a><br>
  
  
<h3><a id="CALL_STATUS_SETTING">Call status Setting</a></h3>
<b>Description:</b> This contains the telephone call state of the device. The device will issue
                "Call status change" events whenever the state changes.<br>
<b>Message Id:</b><i>plt.msg.CALL_STATUS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MICROPHONE_MUTE_STATE_SETTING">Microphone Mute State Setting</a></h3>
<b>Description:</b> Microphone mute state of the device.<br>
<b>Message Id:</b><i>plt.msg.MICROPHONE_MUTE_STATE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TRANSMIT_AUDIO_STATE_SETTING">Transmit Audio State Setting</a></h3>
<b>Description:</b> Transmit (microphone) audio state of the device.<br>
<b>Message Id:</b><i>plt.msg.TRANSMIT_AUDIO_STATE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="RECEIVE_AUDIO_STATE_SETTING">Receive Audio State Setting</a></h3>
<b>Description:</b> Receive (speaker) audio state of the device.<br>
<b>Message Id:</b><i>plt.msg.RECEIVE_AUDIO_STATE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LED_STATUS_GENERIC_SETTING">LED Status Generic Setting</a></h3>
<b>Description:</b> LED status of the device.<br>
<b>Message Id:</b><i>plt.msg.LED_STATUS_GENERIC_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="HEADSET_AVAILABLE_SETTING">Headset Available Setting</a></h3>
<b>Description:</b> Availability of the headset based on connection state (wireless or wired).<br>
<b>Message Id:</b><i>plt.msg.HEADSET_AVAILABLE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="Y_CABLE_CONNECTION_SETTING">Y Cable Connection Setting</a></h3>
<b>Description:</b> Connection state for a Y-Cable.<br>
<b>Message Id:</b><i>plt.msg.Y_CABLE_CONNECTION_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SPEAKER_VOLUME_SETTING">Speaker Volume Setting</a></h3>
<b>Description:</b> Speaker volume of the device.<br>
<b>Message Id:</b><i>plt.msg.SPEAKER_VOLUME_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SPOKEN_LANGUAGE_SETTING">Spoken language Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.SPOKEN_LANGUAGE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SUPPORTED_LANGUAGES_SETTING">Supported Languages Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.SUPPORTED_LANGUAGES_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_PARTITION_INFORMATION_SETTING">Get Partition Information Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.GET_PARTITION_INFORMATION_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> partition </td><td> short </td><td> The partition to obtain information about</td></tr>
      </table>
<h3><a id="AUDIO_STATUS_SETTING">Audio status Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.AUDIO_STATUS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="LED_STATUS_SETTING">LED Status Setting</a></h3>
<b>Description:</b> Enables a Host to determine the current LED Indication being provided by a device.<br>
<b>Message Id:</b><i>plt.msg.LED_STATUS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="HEADSET_CALL_STATUS_SETTING">Headset Call status Setting</a></h3>
<b>Description:</b> This contains the telephone call state of all devices connected to the device.
                The returned payload is repeated for each connected device able to make phone calls
                The device will issue "Headset Call status " event whenever any call of the connected device state changes.<br>
<b>Message Id:</b><i>plt.msg.HEADSET_CALL_STATUS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
       <a href="DEVICE_INTERFACES_SETTING">Device interfaces Setting</a><br>
       <a href="RINGTONES_SETTING">Ringtones Setting</a><br>
       <a href="BANDWIDTHS_SETTING">Bandwidths Setting</a><br>
       <a href="RINGTONE_VOLUMES_SETTING">Ringtone volumes Setting</a><br>
       <a href="DEFAULT_OUTBOUND_INTERFACE_SETTING">Default Outbound Interface Setting</a><br>
       <a href="TONE_CONTROLS_SETTING">Tone Controls Setting</a><br>
       <a href="AUDIO_SENSING_SETTING">Audio Sensing Setting</a><br>
       <a href="INTELLISTAND_AUTO_ANSWER_SETTING">Intellistand Auto-Answer Setting</a><br>
       <a href="AUTO_CONNECT_TO_MOBILE_SETTING">Auto-Connect to Mobile Setting</a><br>
       <a href="STOP_AUTO_CONNECT_ON_DOCK_SETTING">Stop Auto-Connect on Dock Setting</a><br>
       <a href="BLUETOOTH_ENABLED_SETTING">Bluetooth Enabled Setting</a><br>
       <a href="OVER_THE_AIR_SUBSCRIPTION_SETTING">Over-the-Air Subscription Setting</a><br>
       <a href="SYSTEM_TONE_VOLUME_SETTING">System Tone Volume Setting</a><br>
       <a href="POWER_LEVEL_SETTING">Power Level Setting</a><br>
       <a href="MOBILE_VOICE_COMMANDS_SETTING">Mobile Voice Commands Setting</a><br>
       <a href="VOLUME_CONTROL_ORIENTATION_SETTING">Volume Control Orientation Setting</a><br>
  
  
<h3><a id="DEVICE_INTERFACES_SETTING">Device interfaces Setting</a></h3>
<b>Description:</b> Returns a byte array containing the interface types for every interface the device includes.<br>
<b>Message Id:</b><i>plt.msg.DEVICE_INTERFACES_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="RINGTONES_SETTING">Ringtones Setting</a></h3>
<b>Description:</b> Return the ring tone for all three interface types.<br>
<b>Message Id:</b><i>plt.msg.RINGTONES_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BANDWIDTHS_SETTING">Bandwidths Setting</a></h3>
<b>Description:</b> Return the bandwidth for all three interface types.<br>
<b>Message Id:</b><i>plt.msg.BANDWIDTHS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="RINGTONE_VOLUMES_SETTING">Ringtone volumes Setting</a></h3>
<b>Description:</b> Return the volume for all three interface types.<br>
<b>Message Id:</b><i>plt.msg.RINGTONE_VOLUMES_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="DEFAULT_OUTBOUND_INTERFACE_SETTING">Default Outbound Interface Setting</a></h3>
<b>Description:</b> Indicates the current default outbound interface.<br>
<b>Message Id:</b><i>plt.msg.DEFAULT_OUTBOUND_INTERFACE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TONE_CONTROLS_SETTING">Tone Controls Setting</a></h3>
<b>Description:</b> Returns the tone levels for PSTN and VOIP interface types.<br>
<b>Message Id:</b><i>plt.msg.TONE_CONTROLS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUDIO_SENSING_SETTING">Audio Sensing Setting</a></h3>
<b>Description:</b> Indicates whether or not the radio link will be automatically established without having to press the call control button.<br>
<b>Message Id:</b><i>plt.msg.AUDIO_SENSING_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="INTELLISTAND_AUTO_ANSWER_SETTING">Intellistand Auto-Answer Setting</a></h3>
<b>Description:</b> Indicates whether incoming calls should be answered automatically when the headset is removed from the charging cradle.<br>
<b>Message Id:</b><i>plt.msg.INTELLISTAND_AUTO_ANSWER_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AUTO_CONNECT_TO_MOBILE_SETTING">Auto-Connect to Mobile Setting</a></h3>
<b>Description:</b> Indicates whether or not the base automatically establishes a Bluetooth link to the mobile phone when the headset is undocked from the base and the mobile phone is within range.<br>
<b>Message Id:</b><i>plt.msg.AUTO_CONNECT_TO_MOBILE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="STOP_AUTO_CONNECT_ON_DOCK_SETTING">Stop Auto-Connect on Dock Setting</a></h3>
<b>Description:</b> Indicates whether or not the Bluetooth connection to the mobile phone should be dropped when the headset is docked.   Only applicable if Set Auto-Connect to Mobile is true.<br>
<b>Message Id:</b><i>plt.msg.STOP_AUTO_CONNECT_ON_DOCK_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="BLUETOOTH_ENABLED_SETTING">Bluetooth Enabled Setting</a></h3>
<b>Description:</b> Indicates whether or not Bluetooth is enabled.<br>
<b>Message Id:</b><i>plt.msg.BLUETOOTH_ENABLED_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="OVER_THE_AIR_SUBSCRIPTION_SETTING">Over-the-Air Subscription Setting</a></h3>
<b>Description:</b> Indicates whether or not the headset can subscribe to the base if it is not docked.<br>
<b>Message Id:</b><i>plt.msg.OVER_THE_AIR_SUBSCRIPTION_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="SYSTEM_TONE_VOLUME_SETTING">System Tone Volume Setting</a></h3>
<b>Description:</b> Indicates the system tone volume.<br>
<b>Message Id:</b><i>plt.msg.SYSTEM_TONE_VOLUME_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="POWER_LEVEL_SETTING">Power Level Setting</a></h3>
<b>Description:</b> Indicates the current power level.<br>
<b>Message Id:</b><i>plt.msg.POWER_LEVEL_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="MOBILE_VOICE_COMMANDS_SETTING">Mobile Voice Commands Setting</a></h3>
<b>Description:</b> Indicates whether or not the mobile phone can be put in voice command mode via the mobile phone button on the base.<br>
<b>Message Id:</b><i>plt.msg.MOBILE_VOICE_COMMANDS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="VOLUME_CONTROL_ORIENTATION_SETTING">Volume Control Orientation Setting</a></h3>
<b>Description:</b> Indicates if the current volume control orientation is the right or left ear.<br>
<b>Message Id:</b><i>plt.msg.VOLUME_CONTROL_ORIENTATION_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
       <a href="AAL_ACOUSTIC_INCIDENT_REPORTING_ENABLE_SETTING">AAL Acoustic Incident Reporting Enable Setting</a><br>
       <a href="AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_SETTING">AAL Acoustic Incident Reporting Thresholds Setting</a><br>
       <a href="AAL_ACOUSTIC_INCIDENT_REPORT_SETTING">AAL Acoustic Incident Report Setting</a><br>
       <a href="AAL_TWA_REPORTING_ENABLE_SETTING">AAL TWA Reporting Enable Setting</a><br>
       <a href="AAL_TWA_REPORTING_TIME_PERIOD_SETTING">AAL TWA Reporting Time Period Setting</a><br>
       <a href="ANTI_STARTLE_SETTING">Anti-startle Setting</a><br>
       <a href="AAL_TWA_REPORT_SETTING">AAL TWA Report Setting</a><br>
       <a href="G616_SETTING">G616 Setting</a><br>
       <a href="CONVERSATION_DYNAMICS_REPORTING_ENABLE_SETTING">Conversation Dynamics Reporting Enable Setting</a><br>
       <a href="TIME_WEIGHTED_AVERAGE_SETTING">Time-weighted average Setting</a><br>
       <a href="CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_SETTING">Conversation Dynamics Reporting Time Period Setting</a><br>
       <a href="TIME_WEIGHTED_AVERAGE_PERIOD_SETTING">Time-weighted average period Setting</a><br>
       <a href="CONVERSATION_DYNAMICS_REPORT_SETTING">Conversation Dynamics Report Setting</a><br>
       <a href="GET_SUPPORTED_DSP_CAPABILITIES_SETTING">Get Supported DSP capabilities Setting</a><br>
       <a href="GET_DSP_PARAMETERS_SETTING">Get DSP Parameters Setting</a><br>
  
  
<h3><a id="AAL_ACOUSTIC_INCIDENT_REPORTING_ENABLE_SETTING">AAL Acoustic Incident Reporting Enable Setting</a></h3>
<b>Description:</b> Get AAL acoustic incident reporting to be enabled or disabled, true or false.<br>
<b>Message Id:</b><i>plt.msg.AAL_ACOUSTIC_INCIDENT_REPORTING_ENABLE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_SETTING">AAL Acoustic Incident Reporting Thresholds Setting</a></h3>
<b>Description:</b> Get AAL acoustic incident reporting thresholds.<br>
<b>Message Id:</b><i>plt.msg.AAL_ACOUSTIC_INCIDENT_REPORTING_THRESHOLDS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_ACOUSTIC_INCIDENT_REPORT_SETTING">AAL Acoustic Incident Report Setting</a></h3>
<b>Description:</b> PLACEHOLDER: This setting ID is reserved as the setting is not supported but no other setting shall use the associated ID per policy.<br>
<b>Message Id:</b><i>plt.msg.AAL_ACOUSTIC_INCIDENT_REPORT_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_TWA_REPORTING_ENABLE_SETTING">AAL TWA Reporting Enable Setting</a></h3>
<b>Description:</b> Get AAL TWA reporting to be enabled or disabled, true or false.<br>
<b>Message Id:</b><i>plt.msg.AAL_TWA_REPORTING_ENABLE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_TWA_REPORTING_TIME_PERIOD_SETTING">AAL TWA Reporting Time Period Setting</a></h3>
<b>Description:</b> Get AAL TWA reporting time period frequency.<br>
<b>Message Id:</b><i>plt.msg.AAL_TWA_REPORTING_TIME_PERIOD_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="ANTI_STARTLE_SETTING">Anti-startle Setting</a></h3>
<b>Description:</b> Return the current anti-startle value.<br>
<b>Message Id:</b><i>plt.msg.ANTI_STARTLE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="AAL_TWA_REPORT_SETTING">AAL TWA Report Setting</a></h3>
<b>Description:</b> PLACEHOLDER: This setting ID is reserved as the setting is not supported but no other setting shall use the associated ID per policy.<br>
<b>Message Id:</b><i>plt.msg.AAL_TWA_REPORT_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="G616_SETTING">G616 Setting</a></h3>
<b>Description:</b> Return the current G.616 value.<br>
<b>Message Id:</b><i>plt.msg.G616_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CONVERSATION_DYNAMICS_REPORTING_ENABLE_SETTING">Conversation Dynamics Reporting Enable Setting</a></h3>
<b>Description:</b> Get conversation dynamics reporting to be enabled or disabled, true or false.<br>
<b>Message Id:</b><i>plt.msg.CONVERSATION_DYNAMICS_REPORTING_ENABLE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TIME_WEIGHTED_AVERAGE_SETTING">Time-weighted average Setting</a></h3>
<b>Description:</b> Return the current time-weighted average value.<br>
<b>Message Id:</b><i>plt.msg.TIME_WEIGHTED_AVERAGE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_SETTING">Conversation Dynamics Reporting Time Period Setting</a></h3>
<b>Description:</b> Get conversation dynamics reporting time period frequency.<br>
<b>Message Id:</b><i>plt.msg.CONVERSATION_DYNAMICS_REPORTING_TIME_PERIOD_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="TIME_WEIGHTED_AVERAGE_PERIOD_SETTING">Time-weighted average period Setting</a></h3>
<b>Description:</b> Return the current time-weighted average period value.<br>
<b>Message Id:</b><i>plt.msg.TIME_WEIGHTED_AVERAGE_PERIOD_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="CONVERSATION_DYNAMICS_REPORT_SETTING">Conversation Dynamics Report Setting</a></h3>
<b>Description:</b> PLACEHOLDER: This setting ID is reserved as the setting is not supported but no other setting shall use the associated ID per policy.<br>
<b>Message Id:</b><i>plt.msg.CONVERSATION_DYNAMICS_REPORT_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_SUPPORTED_DSP_CAPABILITIES_SETTING">Get Supported DSP capabilities Setting</a></h3>
<b>Description:</b> Returns a list of supported DSP capabilities<br>
<b>Message Id:</b><i>plt.msg.GET_SUPPORTED_DSP_CAPABILITIES_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="GET_DSP_PARAMETERS_SETTING">Get DSP Parameters Setting</a></h3>
<b>Description:</b> Get DSP parameters either from persistent or volatile storage.<br>
<b>Message Id:</b><i>plt.msg.GET_DSP_PARAMETERS_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> codec </td><td> byte </td><td> </td></tr><tr><td> storeIsVolatile </td><td> boolean - true or false </td><td> this is for the DSP to say how it is stored - not the vm ---------------
                        FALSE = read from PSKEY
                        TRUE = read from  DSP RAM  --------- optional may not be able to support this may ask dsp for current value
                        returns error on true if not supported</td></tr><tr><td> ParameterIndex </td><td> short </td><td> Zero based index into KAT</td></tr>
      </table>
       <a href="FEATURE_LOCK_SETTING">Feature lock Setting</a><br>
       <a href="FEATURE_LOCK_MASK_SETTING">Feature lock Mask Setting</a><br>
       <a href="PASSWORD_SETTING">Password Setting</a><br>
       <a href="PROTECTED_STATE_SETTING">Protected state Setting</a><br>
  
  
<h3><a id="FEATURE_LOCK_SETTING">Feature lock Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.FEATURE_LOCK_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="FEATURE_LOCK_MASK_SETTING">Feature lock Mask Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.FEATURE_LOCK_MASK_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="PASSWORD_SETTING">Password Setting</a></h3>
<b>Description:</b> Return the device's password value.<br>
<b>Message Id:</b><i>plt.msg.PASSWORD_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="PROTECTED_STATE_SETTING">Protected state Setting</a></h3>
<b>Description:</b> Return the device's Protected state: true true if the password is equal to something other
                than the device default value, false otherwise.<br>
<b>Message Id:</b><i>plt.msg.PROTECTED_STATE_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
       <a href="HAL_CURRENT_SCENARIO_SETTING">Hal Current Scenario Setting</a><br>
       <a href="HAL_CURRENT_VOLUME_SETTING">Hal Current Volume Setting</a><br>
       <a href="HAL_CURRENT_EQ_SETTING">Hal Current EQ Setting</a><br>
       <a href="HAL_GENERIC_SETTING">Hal Generic Setting</a><br>
  
  
<h3><a id="HAL_CURRENT_SCENARIO_SETTING">Hal Current Scenario Setting</a></h3>
<b>Description:</b> Return the device's current scenario.<br>
<b>Message Id:</b><i>plt.msg.HAL_CURRENT_SCENARIO_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>
<h3><a id="HAL_CURRENT_VOLUME_SETTING">Hal Current Volume Setting</a></h3>
<b>Description:</b> Return the device's current volumes for a scenario.<br>
<b>Message Id:</b><i>plt.msg.HAL_CURRENT_VOLUME_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> scenario </td><td> short </td><td> </td></tr><tr><td> volumes </td><td> array of bytes </td><td> </td></tr>
      </table>
<h3><a id="HAL_CURRENT_EQ_SETTING">Hal Current EQ Setting</a></h3>
<b>Description:</b> Returns current volume settings for a scenario<br>
<b>Message Id:</b><i>plt.msg.HAL_CURRENT_EQ_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> scenario </td><td> short </td><td> The scenario for the EQ query</td></tr><tr><td> EQs </td><td> array of bytes </td><td> Array containing Ids of the EQ to return values for</td></tr>
      </table>
<h3><a id="HAL_GENERIC_SETTING">Hal Generic Setting</a></h3>
<b>Description:</b> Allows a number of devices settings to be queried in a single message<br>
<b>Message Id:</b><i>plt.msg.HAL_GENERIC_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> halGeneric </td><td> array of shorts </td><td> Array of deckard messages</td></tr>
      </table>
  
  
  
  
       <a href="QUERY_SERVICES_CONFIGURATION_DATA_SETTING">Query services configuration data Setting</a><br>
       <a href="QUERY_SERVICES_CALIBRATION_DATA_SETTING">Query services calibration data Setting</a><br>
       <a href="QUERY_APPLICATION_CONFIGURATION_DATA_SETTING">Query application configuration data Setting</a><br>
       <a href="QUERY_SERVICES_DATA_SETTING">Query services data Setting</a><br>
       <a href="GET_DEVICE_INFO_SETTING">Get device info Setting</a><br>
  
  
<h3><a id="QUERY_SERVICES_CONFIGURATION_DATA_SETTING">Query services configuration data Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.QUERY_SERVICES_CONFIGURATION_DATA_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> serviceID </td><td> short </td><td> </td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr>
      </table>
<h3><a id="QUERY_SERVICES_CALIBRATION_DATA_SETTING">Query services calibration data Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.QUERY_SERVICES_CALIBRATION_DATA_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> serviceID </td><td> short </td><td> </td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr>
      </table>
<h3><a id="QUERY_APPLICATION_CONFIGURATION_DATA_SETTING">Query application configuration data Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.QUERY_APPLICATION_CONFIGURATION_DATA_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> featureID </td><td> short </td><td> Reference "Configure applciation" command for valid feature IDs.</td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr>
      </table>
<h3><a id="QUERY_SERVICES_DATA_SETTING">Query services data Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.QUERY_SERVICES_DATA_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 

     <tr><td> ServiceID </td><td> short </td><td> </td></tr><tr><td> characteristic </td><td> short </td><td> </td></tr>
      </table>
<h3><a id="GET_DEVICE_INFO_SETTING">Get device info Setting</a></h3>
<b>Description:</b> <br>
<b>Message Id:</b><i>plt.msg.GET_DEVICE_INFO_SETTING</i><br>
<b>Options</b>: JSON object, optional to pass into creation if only address property specified below 
<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>address</td><td>byte array</td><td>Optional - an array of 4 bytes, used to route the message, default address is [0,0,0,0]</td></tr> 
     
      </table>

 
  
  
  
  
  
 

###PLT Command Messages
When do you use this message?

####Command Messages 

