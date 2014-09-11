#PLT Labs Javascript Library
=============
[PltLabs](http://pltlabs.com) - Javascript library for creating and parsing PLT Labs device messages  

This project provides a javascript library for PLT Labs device message parsing and creation.  Also included is an example application that uses chrome's
dev channel's bluetooth APIs.

* Twitter: [@pltlabs](http://twitter.com/pltlabs)
* Author: [@carybran](http://twitter.com/carybran)


Whats Inside
----------
code-generator
* This is the code generator project for generating the plt.msg javascript library - see the code generation section to see how this works
chrome
* sample application that uses the plt.msg.js library in conjunction with the Chrome Bluetooth APIs

###Using plt.msg
The plt.msg library is generated from the PLT M2M xml model and has the following features
* Enumerations for all of the PLT M2M types: commands, settings, events and exceptions
* Parsing of all raw PLT messages (comes in from the device as a byte array) into JSON objects
* Creation of raw PLT messages for the following types: commands, settings

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
###Generating the plt.msg library
The plt.msg library is generated from the Plantronics M2M xml model.

The project layout is as follows:
* gen.sh - shell script to launch the generator - in production, I assume the paths to the xml model will change
* models/ - folder that contins the Plantronics M2M xml message model
* templates/ - folder that contains the master template for the plt.msg library
* includes/ - template fragments that are included in the master template to generate code
* target/ - folder for the outputs of the code generation

To generate the code make sure you have java in your path, simply make the gen.sh executible (chmod +x gen.sh) and then at the command prompt type:
```
./gen.sh

```

The output "plt.msg.js" will be in the target directory along with an error and info log from the code generation.
Under the covers gen.sh just calls java and uses the jeseance library to generate teh code
```
java -jar ./jseance-2.0-beta-2-SNAPSHOT-jar-with-dependencies.jar -errorLogFile "./target/jseance-errors.log" -infoLogFile "./target/jseance-info.log" -sourcesDir "./" -targetDir "./target" pltmsg.jseance

```
