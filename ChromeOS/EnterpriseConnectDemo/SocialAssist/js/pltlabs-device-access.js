//PLT Labs - Bluetooth device access library
//Author - Cary Bran - cary.bran@plantronics.com
//This library is to enable experimental device data access
//using the Google Chrome Bluetooth APIs 

var readIntervalId = null; 
var connectIntervalId = null;
var deviceRoute = new ArrayBuffer(4);
//initialize the address array to 0x0
var address = new Uint8Array(deviceRoute);

var onDeviceAddedCallback = null;
var onSocketConnectionCallback = null;
var onEventCallback = null;
var onMetaDataCallback = null;
var onSettingsCallback = null;
var subscribedEvents = [];

var PLTLabsAPI = {};



//public members
PLTLabsAPI.connected = false;
PLTLabsAPI.connectedDevices =[];
PLTLabsAPI.debug = false;
PLTLabsAPI.socket = null;
PLTLabsAPI.lastCommandSent = null;
PLTLabsAPI.testInterfaceEnabled = false;
PLTLabsAPI.buttonEventsEnabled = false;



//Once this callback is added it will kick off the searching for PLTLabs 
//devices - devices will be passed to the callback function for connecting
//callback function must have the following signature:
//function (devices) - where the devices passed into the function is an array of 
//PLTLabs devices that have been found connected to the host system
PLTLabsAPI.findDevices = function(callback){
  if(!callback || !typeof(callback) == "function"){
    throw new PLTLabsException("this method requires a callback function");
  }
  onDeviceAddedCallback = callback;
  findPLTLabsDevices();
};

//Function opens a socket connection to the device
//the callback signature is a single argument function, the argument that will be passed back
//is a port id that is used by that socket
PLTLabsAPI.openConnection = function(device, callback){
  if(!callback || !typeof(callback) == "function"){
    throw new PLTLabsException("this method requires a callback function");
  }
  if(!device){
    throw new PLTLabsException("this method requires a valid device");
  }
  log('openConnection: opening connection for device ' +  JSON.stringify(device));
  onSocketConnectionCallback = callback;
  chrome.bluetooth.connect({device:device , profile: BR_PROFILE}, function() {
    if (chrome.runtime.lastError){ 
      log("Error connecting to PLTLabs device :" + chrome.runtime.lastError.message);
    }});
};


//closes down the socket connection to the device
//the callback signature is a single argument function
PLTLabsAPI.closeConnection = function(callback){
 if(!callback || !typeof(callback) == "function"){
    throw new PLTLabsException("closeConnection: this method requires a callback function");
  }
  this.connected = false;
  onDeviceAddedCallback = null;
  onSocketConnectionCallback = null;
  onInfoUpdateCallback = null;
  subscribedEvents = null;
  //remove the socket from the list of ports
  for(index = 0; index < PLTLabsAPI.connectedDevices.length; index++){
        var s = PLTLabsAPI.connectedDevices[index];
        if (s.socketId == PLTLabsAPI.socket.id) {
          PLTLabsAPI.connectedDevicessplice(index, 1);
          break;
        }
  }
  
  if (this.socket) {
    log("closeConnection: disconnecting socket from device");
    chrome.bluetoothSocket.disconnect(this.socket.id,function(){
      log("closeConnection: socket closed.");
      callback();
      PLTLabsAPI.socket = null;
    });
  }

};

//sets up the events subscription, if the subscription already exists then 
//update the events subscription service
PLTLabsAPI.subscribeToEvents = function(options, callback){
  if(!this.connected){
    throw new PLTLabsException("subscribeToEvents: a connection must be established first before subscribing to services");
  }
  if(!callback || !typeof(callback) == "function"){
    throw new PLTLabsException("subscribeToEvents: this method requires a callback function");
  }
  
  if(!options || !options.events){
    throw new PLTLabsException("subscribeToEvents: options and options.events array must be present");
  }
  
  onEventCallback = callback;
  this.subscribedEvents = options.events;
  
  enableTestInterfaces();  
  
};

//returns device metadata when it arrive to the callback
//callback parameter must be a function with a single argument
PLTLabsAPI.subscribeToDeviceMetadata = function(callback){
  if(!callback || !typeof(callback) == "function"){
    throw new PLTLabsException("subscribeToEvents: this method requires a callback function");
  }
  onMetaDataCallback = callback;
};

PLTLabsAPI.sendCommand = function(command){
  if(!command){
    log('sendCommand: empty command ignoring'); 
  }
  
  PLTLabsAPI.lastCommandSent = command;
  
  PLTLabsAPI.sendBladerunnerPacket(command);
  //log('sendCommand: command packet has been sent to device');
};

//Attempts to send a blade runner packet over the bluetooth socket connection, if error occurs will log it out.
PLTLabsAPI.sendBladerunnerPacket = function(packet){
  if(!this.connected){
    log('sendBladerunnerPacket: PLTLabs device packet send fail - not connected');
    return; 
  }
  //this variable is required to maintain correct scoping when calling the send function
  var socketId = this.socket.id;
  chrome.bluetoothSocket.send(socketId, packet);
  log('sendBladerunnerPacket: packet sent to device');
};
  

//Function for fetching the PLTLabs devicess
var findPLTLabsDevices = function(){
  //if we already have a connection then do not try and find
  //more devices - this assumes a 1 device connection at a time paradigm
  if(PLTLabsAPI.connected){
    return; 
  }
  
  log('findPLTLabsDevices: searching for PLTLabs devices');
  
  // Add the listener to deal with our initial connection
  chrome.bluetooth.onDeviceAdded.addListener(function(device){
      if (onDeviceAddedCallback) {
          onDeviceAddedCallback([devices]);  
      }    
  });
  
  chrome.bluetooth.onConnection.addListener(onConnectDeviceHandler);
  chrome.bluetoothSocket.onReceive.addListener(onReceiveHandler);
  chrome.bluetoothSocket.onReceiveError.addListener(function(info){log('error on socket receive: socket id = ' + info.socketId + ' message = ' + info.errorMessage + ' error = ' + info.error);});
  chrome.bluetoothSocket.onAccept.addListener(function (info){log('onAccept  server socket id = ' + info.socketId + ' clientSocket = ' + info.clientSocketId);});
  
  log('findPLTLabsDevices: added connection listeners');
  
  chrome.bluetooth.getAdapterState(function(adapterState){
    if(!adapterState.available || !adapterState.powered){
      log('findPLTLabsDevices: bluetooth adapter not available');
      return;
    }
    log('getAdaptorState: getting devices');
    chrome.bluetooth.getDevices(returnDeviceList);
  });
  
  log('findPLTLabsDevices: exit function');
  
};

//Handle the device connect event and set up the device connection
//and the socket read interval
var onConnectDeviceHandler = function(_socket){
   if(_socket){  
      log("onConnectDeviceHandler: socket id " + _socket.id + " for device obtained, setting up socket communications");
      chrome.bluetoothSocket.setPaused(_socket.id , false);
      PLTLabsAPI.connected = true;
      PLTLabsAPI.socket = _socket;
      hostNegotiate();    
   } 
   else {
      log("onConnectDeviceHandler: failed to connect to socket");
   }
   
};

var onReceiveHandler = function(info) {
  //log('socket has recieved ' + info.data.byteLength + ' bytes of data');
  parseBladerunnerData(info);
}

 
//This function enables the test interface for the PLTLabs device
//the test interface is a prerequisite for receiving events from buttons and other features.
var enableTestInterfaces = function(){
  if(!PLTLabsAPI.connected){
    log('enableTestInterfaces: cannot subscribe to events PLTLabs API disconnected');
    return; 
  }
  if(!PLTLabsAPI.subscribedEvents){
    log('enableTestInterfaces: cannot subscribe to events PLTLabs API subscribed events array is empty');
    return;
  }
  //simple test right now - test for the presence of either the test interface events, or the button events, if 
  //either exist then enable the test interface
  var enableButtonEvents = (PLTLabsAPI.subscribedEvents.indexOf(PLTLabsMessageHelper.BUTTON_EVENT) > -1);
  //todo - this test will grow over time - so revisit in the future for optimizations
  if(enableButtonEvents && !PLTLabsAPI.testInterfaceEnabled){
    //disable/enable the interface so the states match 
    var command = {"address": deviceRoute, "enabled" : enableButtonEvents};
    var packet = PLTLabsMessageHelper.createEnableTestInterfaceCommand(command); 
    log('enableTestInterfaces: sending command '  + JSON.stringify(command));
    PLTLabsAPI.sendCommand(packet);
   }
};


//enables the buttons functionality
var enableButtons = function(){
  var enableButtonEvents = (PLTLabsAPI.subscribedEvents.indexOf(PLTLabsMessageHelper.BUTTON_EVENT) > -1);
  if(!PLTLabsAPI.testInterfaceEnabled && enableButtonEvents){
    log('enableButtons: enabling the test interface to enable button events');
    enableTestInterfaces();
  }
  
    window.setTimeout(function(){
  
    var command = {"address": deviceRoute, "enabled" : enableButtonEvents};
    var packet = PLTLabsMessageHelper.createEnableButtonEventsCommand(command); 
    log('enableButtons: sending command ' + JSON.stringify(command));
    PLTLabsAPI.sendCommand(packet)}, 100)
};
  
var returnDeviceList = function(devices) {
  if (chrome.runtime.lastError) {
    log('returnDeviceList: error searching for a devices: ' + chrome.runtime.lastError.message);
    return;
  }
  
  //if we have some devices hand them back to the caller to decide what to do with them
  if(devices.length > 0){
    log('returnDeviceList: sending back found device array - size = ' + devices.length);
    onDeviceAddedCallback(devices);
  }
};
 
var log = function(msg) {
  if(PLTLabsAPI.debug != true){
    return;
  }
  var msg_str = (typeof(msg) == 'object') ? JSON.stringify(msg) : msg;
  console.log(msg_str);
}; 
  
//Responsible for the initial handshake with the Bladerunner device
//sends a 9-byte U8 array to the device after the profile has been negotiated and the 
//connection established.  The host negotiate packet is needed to start the flow of contextual data
//to and from the device
var hostNegotiate = function(){
  //this is the default address of 000000
  var address = new ArrayBuffer(PLTLabsMessageHelper.BR_ADDRESS_SIZE);
  var address_view = new Uint8Array(address);
  var packet = PLTLabsMessageHelper.createHostNegotiateMessage(address);
  log('hostNegotiate: sending host negotiate packet');
  
  PLTLabsAPI.sendBladerunnerPacket(packet);   
};
  
//enables the test interface for recieving test interface events - such as button presses
var sendEnableTestInterfaceCommand = function(enabled){
  var packet = PLTLabsMessageHelper.createEnableTestInterfaceMessage({"address": deviceRoute, "enabled" : enabled}); 
  log('sendEnableTestInterfaceCommand: going to ' + (enabled ? 'enable' : 'disable') + ' the test interface');
  PLTLabsAPI.sendBladerunnerPacket(packet);
};

//function determines what, if any steps should happen
//next after a command successfully completes
var onCommandSuccess = function(commandId){
    
    var data_view = new Uint8Array(PLTLabsAPI.lastCommandSent, PLTLabsMessageHelper.BR_HEADER_SIZE);
    var lastCommandId = PLTLabsMessageHelper.parseShortArray(0, data_view, 2);
  
    if(lastCommandId[0] != commandId){
      log('onCommandSuccess: last command id and current command id do not match');
      return;
    }
  
    switch(commandId){
      case PLTLabsMessageHelper.CREATE_ENABLE_TEST_INTERFACE_MESSAGE_ID:
        //get the value of the byte:
        var enabled = PLTLabsMessageHelper.parseByteArray(2, data_view, 3);
        PLTLabsAPI.testInterfaceEnabled = (enabled == 1);
        log('onCommandSuccess: test interface enabled = ' +  PLTLabsAPI.testInterfaceEnabled);
        var enableButtonEvents = (PLTLabsAPI.subscribedEvents.indexOf(PLTLabsMessageHelper.BUTTON_EVENT) > -1);
        if(enableButtonEvents != PLTLabsAPI.buttonEventsEnabled){
            enableButtons(); 
        }  
        break;
      case PLTLabsMessageHelper.RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_MESSAGE_ID:
        log('onCommandSuccess: enable button events command successfully executed - 0x' + commandId.toString(16));
        break;
      case PLTLabsMessageHelper.SUBSCRIBE_TO_SERVICES:
        log('onCommandSuccess: subscribe to WC1 service command successfully executed - 0x' + commandId.toString(16));
        break;
      default:
        log('onCommandSuccess: unknown command successfully executed - 0x' + commandId.toString(16));
    }
}

  
//Parses the bladerunner packet response - depending on 
//the type of the message additional functionality may be executed
var parseBladerunnerData = function(info){
  var data = info.data;
  
  if(!data||data.byteLength < PLTLabsMessageHelper.BR_HEADER_SIZE){
   return;
  }
  
  var data_view = new Uint8Array(data, 0);

  //The message type always in the 6th byte, per the bladerunner/deckard spec
  var messageType = data_view[5];
  //log('parseBladerunnerData: message type = ' + messageType );
  
  switch(messageType){
    case PLTLabsMessageHelper.PROTOCOL_VERSION_TYPE:
    //  log('parseBladerunnerData: Protocol Version Type Message');
      break;
     case PLTLabsMessageHelper.GET_REQUEST_TYPE:
    //  log('Get Request Type Message');
      break;
     case PLTLabsMessageHelper.GET_RESULT_SUCCESS_TYPE:
    //  log('Get Result Success Type Message');
      break;
     case PLTLabsMessageHelper.GET_RESULT_EXCEPTION_TYPE:
        //log('parseBladerunnerData: Exception Type Message');
      break;
     case PLTLabsMessageHelper.PERFORM_COMMAND_TYPE:
     // log('Perform Command Type Message');
      break;
     case PLTLabsMessageHelper.PERFORM_COMMAND_RESULT_SUCCESS_TYPE:
      //log('Perform Command Result Success Type Message');
      var commandSuccessId = PLTLabsMessageHelper.parseResult(data);
      //log('parseBladerunnerData: command successful: id = 0x' + commandSuccessId.toString(16));
      onCommandSuccess(commandSuccessId);
      break;
     case PLTLabsMessageHelper.PERFORM_COMMAND_RESULT_EXCEPTION_TYPE:
      var exceptionCode = PLTLabsMessageHelper.parseResult(data);
       log('Exception while performing command: id = 0x' + exceptionCode.toString(16));
      break; 
     case PLTLabsMessageHelper.DEVICE_PROTOCOL_VERSION_TYPE:
      /*parseDevicePrototol(data, function(min, max){
        pltDeviceMinBRVersion = min; 
        pltDeviceMaxBRVersion = max; 
        log('Device supports Bladerunner versions from ' + pltDeviceMinBRVersion + ' to ' + pltDeviceMaxBRVersion); 
      });*/
      break;
     case PLTLabsMessageHelper.METADATA_TYPE:
      //log('parseBladerunnerData: metadata');
        if (onMetaDataCallback) { 
          onMetaDataCallback(PLTLabsMessageHelper.parseMetadata(data));
        }
      break;
     case PLTLabsMessageHelper.EVENT_TYPE:
      //parse and handle the event
      var event = PLTLabsMessageHelper.parseEvent(info);
      //log('parseBladerunnerData: event recieved: ' + JSON.stringify(event));
      if(PLTLabsMessageHelper.CONNECTED_DEVICE_EVENT == event.id ||
         PLTLabsMessageHelper.DISCONNECTED_DEVICE_EVENT == event.id){
         connectedEvent(event);
      }
      if(PLTLabsAPI.subscribedEvents.indexOf(event.id) > -1){
        //log('parseBladerunnerData: sending event to callback');
        onEventCallback(event);
      }
      
      break;
     case PLTLabsMessageHelper.CLOSE_SESSION_TYPE:
      //log('Close Session Type Message');
      break;
     case PLTLabsMessageHelper.HOST_PROTOCOL_NEGOTIATION_REJECTION_TYPE:
      //log('Host Protocol Negotiation Rejection Type Message');
      break;
    default:
      log('Unknown Message Type: ' + messageType);
      break;
   
  }

};

function inverseQuaternion(q){
  return { "w": -q.w, "x": -q.x, "y": -q.y, "z": -q.z}
}

function multiplyQuaternions(q, p){
   var quaternianMatrix =[[p.w, -p.x, -p.y, -p.z],
                          [ p.x, p.w, -p.z, p.y ],
                          [ p.y, p.z, p.w, -p.x ],
                          [p.z, -p.y, p.x, p.w ]];
   var multipliedQuaternion = { "w": 0, "x": 0, "y": 0, "z": 0}
   
  for (i = 0; i < 4; i++) {
        for (j = 0; j < 4; j++) {
            switch(j){
              case 0:
                multipliedQuaternion.w += quaternianMatrix[i][j] * q.w;
                break;
              case 1:
                multipliedQuaternion.x += quaternianMatrix[i][j] * q.x;
                break;
              case 2:
                multipliedQuaternion.y += quaternianMatrix[i][j] * q.y;
                break;
              case 3:
                multipliedQuaternion.z += quaternianMatrix[i][j] * q. z;
                break;
            }
        }
    }
    
return multipliedQuaternion;
  
}

//manages the connection state for the PLTLabs api
var connectedEvent = function(event){
  var port = event.properties['address'];
  var socketId = event.socketId;
  var socketConnection = {"socketId": socketId, "ports":[port]};
  var connectEvent = PLTLabsMessageHelper.CONNECTED_DEVICE_EVENT == event.id;
  
  log('connectedEvent: port ' + port + ' socketId ' + socketId + ' event type ' +  (connectEvent ? 'connected' : 'disconnected'));
  if(onSocketConnectionCallback && connectEvent){
    onSocketConnectionCallback(port);
  }
  for(index = 0; index < PLTLabsAPI.connectedDevices.length; index++){
    var socket = PLTLabsAPI.connectedDevices[index];
    if (socket.socketId == socketId) {
      var position = socket.ports.indexOf(port);
      //not found and disconnect - just return
      if (position == -1 && connectEvent) {
        //add the port to the list
        socket.ports.push(port);
      }
      else if (position > -1 && ! connectEvent) {
        //port in array needs to be removed on disconnect
        socket.ports.splice(position, 1);
      }
      return;
    }
  }
  //if we get here then assume the socet needs to be added
  if (PLTLabsAPI.connectedDevices.length == 0 && connectEvent) {
    PLTLabsAPI.connectedDevices.push(socketConnection); 
  }

};
  

//PLTLabs Message Helper - does the bit manipulation and parsing
//functions for messages sent to and from the PLTLabs device
PLTLabsMessageHelper = {};

  //message types
PLTLabsMessageHelper.PROTOCOL_VERSION_TYPE = 0x01;
PLTLabsMessageHelper.GET_REQUEST_TYPE = 0x02;
PLTLabsMessageHelper.GET_RESULT_SUCCESS_TYPE = 0x03;
PLTLabsMessageHelper.GET_RESULT_EXCEPTION_TYPE = 0x04;
PLTLabsMessageHelper.PERFORM_COMMAND_TYPE = 0x05;
PLTLabsMessageHelper.PERFORM_COMMAND_RESULT_SUCCESS_TYPE = 0x06;
PLTLabsMessageHelper.PERFORM_COMMAND_RESULT_EXCEPTION_TYPE =  0x07;
PLTLabsMessageHelper.DEVICE_PROTOCOL_VERSION_TYPE = 0x08;
PLTLabsMessageHelper.METADATA_TYPE = 0x09;
PLTLabsMessageHelper.EVENT_TYPE = 0x0A;
PLTLabsMessageHelper.CLOSE_SESSION_TYPE = 0x0B;
PLTLabsMessageHelper.HOST_PROTOCOL_NEGOTIATION_REJECTION_TYPE = 0x0C;

//byte sizes for the various parts of a PLTLabs device message
PLTLabsMessageHelper.BR_HEADER_SIZE = 6;
PLTLabsMessageHelper.BR_ADDRESS_SIZE = 4;
PLTLabsMessageHelper.BR_MESSAGE_ID_SIZE = 2;
PLTLabsMessageHelper.BR_MESSAGE_TYPE_SIZE = 2
PLTLabsMessageHelper.BR_MESSAGE_BOOL_SIZE = 1;

//WC1 and Bangle sensor port
PLTLabsMessageHelper.SENSOR_PORT = 5;

//device events
PLTLabsMessageHelper.TEST_INTERFACE_ENABLE_DISABLE_EVENT = 0x1000;
PLTLabsMessageHelper.RAW_BUTTON_TEST_ENABLE_DISABLE_EVENT = 0x1007;
PLTLabsMessageHelper.BUTTON_EVENT = 0x1008;
PLTLabsMessageHelper.WEARING_STATE_CHANGED_EVENT = 0x0200;
PLTLabsMessageHelper.AUTO_ANSWER_ON_DON_CHANGED_EVENT = 0x0207;
PLTLabsMessageHelper.WEARING_SENSOR_ENABLE_DISABLE_EVENT = 0x0216;
PLTLabsMessageHelper.CONFIGURE_SIGNAL_STRENGTH_EVENT = 0x0800;
PLTLabsMessageHelper.SIGNAL_STRENGTH_EVENT = 0x0806;
PLTLabsMessageHelper.LED_ALERT_STATUS_CHANGED = 0x0808;
PLTLabsMessageHelper.PAIRING_MODE = 0x0A24;
PLTLabsMessageHelper.BATTERY_STATUS_CHANGED_EVENT = 0x0A1C;
PLTLabsMessageHelper.PAIRING_MODE_EVENT = 0x0A24;
PLTLabsMessageHelper.LOW_BATTERY_VOICE_PROMPT_EVENT = 0x0A28;
PLTLabsMessageHelper.CONNECTED_DEVICE_EVENT = 0x0C00;
PLTLabsMessageHelper.DISCONNECTED_DEVICE_EVENT = 0x0C02;
PLTLabsMessageHelper.CALL_STATUS_CHANGE_EVENT = 0x0E00;
PLTLabsMessageHelper.AUDIO_STATUS_EVENT = 0x0E1E;
//Wearable concept 1 Events
PLTLabsMessageHelper.SUBSCRIBED_SERVICE_DATA_CHANGE_EVENT = 0x0FF1A;
PLTLabsMessageHelper.SUBSCRIBED_SERVICE_CONFIG_CHANGE_EVENT = 0x0FF1B;
PLTLabsMessageHelper.SERVICE_CALIBRATION_CHANGE_EVENT = 0x0FF1C;


//commands
PLTLabsMessageHelper.CREATE_ENABLE_TEST_INTERFACE_MESSAGE_ID = 0x1000;
PLTLabsMessageHelper.RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_MESSAGE_ID = 0x1007;
PLTLabsMessageHelper.CONFIGURE_SIGNAL_STRENGTH_EVENTS = 0x0800;
PLTLabsMessageHelper.CONFIGURE_LED_ALERT = 0x0808;

//Wearable concept 1 Commands
PLTLabsMessageHelper.CALIBRATE_SERVICES = 0xFF01;
PLTLabsMessageHelper.SUBSCRIBE_TO_SERVICES = 0xFF0A;

//Modes for commands for wearable concepts
PLTLabsMessageHelper.MODE_OFF = 0;
PLTLabsMessageHelper.MODE_ON_CHANGE = 1;
PLTLabsMessageHelper.MODE_PERIODIC = 2;

//Service IDs for wearable concepts
PLTLabsMessageHelper.HEAD_ORIENTATION_SERVICE_ID = 0x00;
PLTLabsMessageHelper.PEDOMETER_SERVICE_ID = 0x02;
PLTLabsMessageHelper.FREE_FALL_SERVICE_ID = 0x03;
PLTLabsMessageHelper.TAPS_SERVICE_ID = 0x04;
PLTLabsMessageHelper.MAGNETOMETER_CAL_STATUS_SERVICE_ID = 0x05;
PLTLabsMessageHelper.GYROSCOPE_CAL_STATUS_SERVICE_ID = 0x06;
PLTLabsMessageHelper.VERSIONS_SERVICE_ID = 0x07;

//creates the message needed to kick off the sending and receiving of 
//PLT device events, settings and commands  
PLTLabsMessageHelper.createHostNegotiateMessage = function(address){
  var options = new Object();
  options.messageType = this.PROTOCOL_VERSION_TYPE;
  var address_view = new Uint8Array(address);
  options.address = address;
  var data = new ArrayBuffer(3);
  var data_view = new Uint8Array(data);
  data_view[0] = 0X1;
  data_view[1] = 0X1; 
  options.messageData = data;  
  return this.createMessage(options);
}  

//command that will enable or disable the LED alert on the device
//the options is an object with two parameters
//enabled - (required) true if to enable the LED
//address - optional
//timeout - if enabled is true then the timeout must be specified in seconds - 1-255 -range
PLTLabsMessageHelper.createEnableLEDCommand = function(options){
  if(!options.address || options.address.byteLength != this.BR_ADDRESS_SIZE){
    options.address = deviceRoute;
  }
  if (options.timeout < 1 || options.timeout > 254) {
    throw new PLTLabsException('options requires field timeout  that must be between 1-255');
  }
  options.messageType = this.PERFORM_COMMAND_TYPE;
  options.messageId = this.CONFIGURE_LED_ALERT;
  
  var data = new ArrayBuffer(2);
  var data_view = new Uint8Array(data);
  data_view[0] = this.boolToByte(options.enabled);
  data_view[1] = options.timeout;
  options.messageData = data;  
  return this.createMessage(options);  
  
}


//creates the command message needed to enable/disable the 
//test interface features - which are a prerequisite for 
//features like button press events
PLTLabsMessageHelper.createEnableTestInterfaceCommand = function(options){
  if(!options.address || options.address.byteLength != this.BR_ADDRESS_SIZE){
    console.log('createEnableTestInterfaceCommand: options requires byte[4] field: address');
    return null;
  }
  
  options.messageType = this.PERFORM_COMMAND_TYPE;
  options.messageId = this.CREATE_ENABLE_TEST_INTERFACE_MESSAGE_ID;
  var data = new ArrayBuffer(this.BR_MESSAGE_BOOL_SIZE);
  var data_view = new Uint8Array(data);
  data_view[0] = this.boolToByte(options.enabled);
  options.messageData = data;  
  return this.createMessage(options);  
}

//Enables/disabled proximity
/*
Argument is options - which has one manditory field
enabled - must be true or false - If true, this will enable the signal strength monitoring.

//TODO - fix logic in value assignment below - currently hard coded below

	command.setEnable(enabled);
	command.setConnectionId(connectionID);
	command.setDononly(false);
	command.setReportNearFarAudio(false);
	command.setReportNearFarToBase(false);
	command.setReportRssiAudio(false);
	command.setTrend(false);
	command.setSensitivity(1);
	command.setNearThreshold(71);
	command.setMaxTimeout(10);


other optional settings and thier defaults
connectionId - 0 -  - The connection ID of the link being used to generate the signal strength event.
reportOnDonnedOnly - false - If true, report near far events only when headset is donned.
trendDetection - false - If true, Report rssi and trend events in headset audio
audioRSSIReport - false - If true, report Near/Far events in headset Audio 
audioReportNearFar -false - If true, report SignalStrength and Near Far events to base �
reportNearFarToBase - true - This number multiplies the dead_band value (currently 5 dB) in the headset configuration.
sensitivity - 5 - This result is added to an minimum dead-band, currently 5 dB to compute the total deadband - in the range 0 to 9
nearThreshold - 50 - The near / far threshold in dB �in the range -99 to +99; larger values mean a weaker signal 
*/
PLTLabsMessageHelper.createEnableProximityCommand = function(options){
  if(!options.address || options.address.byteLength != this.BR_ADDRESS_SIZE){
    options.address = deviceRoute;
  }
  options.messageType = this.PERFORM_COMMAND_TYPE;
  options.messageId = this.CONFIGURE_SIGNAL_STRENGTH_EVENT;
  //the array size is nine bytes + one short (2-bytes)
  var data = new ArrayBuffer(11);
  var data_view = new Uint8Array(data);
  
  //"connectionId" type="BYTE"

  data_view[0] = 0;//options.connectionId ? options.connectionId : 0x0;   
  //"enabled" type="BOOLEAN"
  data_view[1] = 1;//this.boolToByte(options.enabled);
  //"reportOnDonnedOnly" type="BOOLEAN"
  data_view[2] = 0; //options.reportOnDonnedOnly ? this.boolToByte(options.reportOnDonnedOnly) : 0x0;
  //"trendDetection" type="BOOLEAN"
  data_view[3] = 0;//options.trendDetection ? this.boolToByte(options.trendDetection) : 0x0;
  //"audioRSSIReport" type="BOOLEAN"
  data_view[4] = 0;//options.audioRSSIReport ? this.boolToByte(options.audioRSSIReport) : 0x0;
  //"audioReportNearFar" type="BOOLEAN"
  data_view[5] = 0;//options.audioReportNearFar ? this.boolToByte(options.audioReportNearFar) : 0x0;
  //"reportNearFarToBase" type="BOOLEAN"
  data_view[6] = 0;//options.reportNearFarToBase ? this.boolToByte(options.reportNearFarToBase) : 0x1;
  //"sensitivity" type="BYTE"
  data_view[7] = 1;//options.sensitivity ? options.sensitivity : 0x5;
  //"nearThreshold" type="BYTE"
  data_view[8] = 71;//data_view[7] = options.nearThreshold ? options.nearThreshold : 0x28;
 
  //"max timeout" type="SHORT"
  data_view[9] = 0;
  data_view[10] = 10; //default to 60 seconds - TODO - do we need to add this to the options?
  
  options.messageData = data;  
  return this.createMessage(options);  
  
  
};

//Enables button press events - note the create enable test inteface command must be sent fir
PLTLabsMessageHelper.createEnableButtonEventsCommand = function(options){
  if(!options.enabled){
    throw new PLTLabsException('options requires boolean field: enabled');
  }
  if(!options.address || options.address.byteLength != this.BR_ADDRESS_SIZE){
    throw new PLTLabsException('options requires byte[4] field: address');
  }
  options.messageType = this.PERFORM_COMMAND_TYPE;
  options.messageId = this.RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_MESSAGE_ID;
  var data = new ArrayBuffer(this.BR_MESSAGE_BOOL_SIZE);
  var data_view = new Uint8Array(data);
  data_view[0] = this.boolToByte(options.enabled);
  options.messageData = data;  
  return this.createMessage(options);  
}
  
//Wearble Concept 1 Device Commands
/*
-SERVICE IDs
Head orientation                   0x0000
Pedometer                          0x0002
Free Fall                          0x0003
Taps                               0x0004
Magnetometer Calibration Status    0x0005
Gyroscope Calibration Status       0x0006
Versions                           0x0007
Humidity                           0x0008
Light                              0x0009
Optical proximity                  0x0010
Ambient Temp 1                     0x0011
Ambient Temp 2                     0x0012
Skin Temp                          0x0013
Skin Conductivity                  0x0014
Ambient Pressure                   0x0015
Heart Rate                         0x0016
UI                                 0x00A0

Modes:
The update mode for the service.
0 = off,
1 = on-change,
2 = periodic
*/
//Enable head tracking
PLTLabsMessageHelper.createHeadTrackingOnChangeCommand = function(options){
  options.serviceId = this.HEAD_ORIENTATION_SERVICE_ID; // head tracking
  return this.createWC1Command(options); 
}

PLTLabsMessageHelper.createPedometerOnChangeCommand = function(options){
  options.serviceId = this.PEDOMETER_SERVICE_ID; //pedometer
  return this.createWC1Command(options); 
}

PLTLabsMessageHelper.createTapOnChangeCommand = function(options){
  options.serviceId = this.TAPS_SERVICE_ID; //taps
  return this.createWC1Command(options); 
}

PLTLabsMessageHelper.createFreeFallOnChangeCommand = function(options){
  options.serviceId = this.FREE_FALL_SERVICE_ID; //pedometer
  return this.createWC1Command(options); 
}

PLTLabsMessageHelper.createWC1Command = function(options){
  options.messageType = this.PERFORM_COMMAND_TYPE;
  options.messageId = this.SUBSCRIBE_TO_SERVICES;
  
  //this message has 4 unsigned shorts so 8-bytes
  var data = new ArrayBuffer(8);
  var data_view = new Uint8Array(data);
  //service ID - bytes 1 and 2 are 0x0000
  data_view[1] = options.serviceId;//
  //characteristic bytes 3 and 4 are 0x0000
  //mode
  data_view[4] = 0;
  var mode = this.MODE_OFF;
  if (options.mode == this.MODE_ON_CHANGE) {
    data_view[5] = 0x1;
  }
  else if (options.mode == this.MODE_PERIODIC) {
    data_view[5] = 0x2;
  }
  
  //add a frequency of packets - going for 50ms
  data_view[7] = 0x00;
  options.messageData = data;
  return this.createMessage(options);
  
}

PLTLabsMessageHelper.createCalibrateCommand = function(options){
  options.messageType = this.PERFORM_COMMAND_TYPE;
  options.messageType = this.CALIBRATE_SERVICES;
  
  var data;
  var data_view;
  //service Id = 2 bytes
  //characteristic = 2 bytes
  switch(options.serviceId){
    case PLTLabsMessageHelper.HEAD_ORIENTATION_SERVICE_ID:
      //quaternions = 8 bytes + 2 bytes for the size of the array
      //TODO - write transformation routine to calibrate the quaternions
      var q = options.quaternion;
      var inverseQ = inverseQuaternion(q);
      var calQ = multiplyQuaternions(q, inverseQ);
      data = new ArrayBuffer(14);
      data_view = new Uint8Array(data);
      data_view[1] = options.serviceId;
      data_view[5] = 0x10; // size of the array
      data_view[6] = calQ.w >> 8; //high-bit part of the quaternion
      data_view[7] = calQ.w & 0xFF; //low bit
      data_view[8] = calQ.x >> 8; //high-bit part of the quaternion
      data_view[9] = calQ.x & 0xFF; //low bit
      data_view[10] = calQ.y >> 8; //high-bit part of the quaternion
      data_view[11] = calQ.y & 0xFF; //low bit
      data_view[12] = calQ.z >> 8; //high-bit part of the quaternion
      data_view[13] = calQ.z & 0xFF; //low bit
      break;
    case PLTLabsMessageHelper.PEDOMETER_SERVICE_ID:
    case PLTLabsMessageHelper.FREE_FALL_SERVICE_ID:
    case PLTLabsMessageHelper.TAPS_SERVICE_ID:
      //one byte array - alloccate  3 bytes - 2 for the array length descriptor, one for the value to send
      data = new ArrayBuffer(7);
      data_view = new Uint8Array(data);
      data_view[1] = options.serviceId;
      data_view[5] = 0x1; // size of the array
      data_view[6] = 0x1; // reset bit
      break;
  }
  
  if (data) {
    options.messageData = data;
    return this.createMessage(options);
  }
}

//build and returns a message
PLTLabsMessageHelper.createMessage = function(options){
  if(!options.messageType){
    console.log('createMessage: options requires int field: messageType');
    return null;
  }
  if(!options.address || options.address.byteLength != this.BR_ADDRESS_SIZE){
    console.log('createMessage: options requires byte[4] field: address');
    return null;
  }
  
  var length = this.BR_ADDRESS_SIZE + (options.messageId ? this.BR_MESSAGE_ID_SIZE : 0) 
               + (options.messageData ? options.messageData.byteLength : 0);
  var message = new ArrayBuffer(this.BR_MESSAGE_TYPE_SIZE + length);
  var message_view = new Uint8Array(message);
  
  //header type - 4 bits
  message_view[0] = this.PROTOCOL_VERSION_TYPE << 4;
  
  //message length - 12 bits
  message_view[0] |= ((length & 0x0F00) >> 8);
  message_view[1] = (length & 0x00FF);
  
  var address_view = new Uint8Array(options.address);
  //address - 17 bits
  message_view[2] = address_view[0];
  message_view[3] = address_view[1];
  message_view[4] = address_view[2];
  message_view[5] = address_view[3]; //the 2-high bits are part of the address, the 2 low bits part of the message type
  
  //message type - 4 bits + preserve any addressing
  message_view[5] |= (options.messageType & 0x00FF);
  
  if(options.messageId){
   //message id - split into two bytes
    message_view[6] = ((options.messageId & 0xFF00) >> 8);
    message_view[7] = (options.messageId & 0x00FF);
  }
  
  if(options.messageData){
    //if there is a message id, shift the start of the data writing by 2 bytes
    var index = options.messageId ? (this.BR_HEADER_SIZE + this.BR_MESSAGE_ID_SIZE) : this.BR_HEADER_SIZE;
    var data_view = new Uint8Array(options.messageData);
    for(i=0; i < options.messageData.byteLength; i++){
      message_view[index++] = data_view[i];
    }
  }
  
  return message;

};

//expects byte array as parameter
PLTLabsMessageHelper.parseResult = function(message){
  if(!message){
    return null;
  }
  var data_view = new Uint8Array(message, this.BR_HEADER_SIZE);
  var commandId = this.parseShortArray(0, data_view, 2);
  return commandId[0];
}

//parse the metadata and return it in an object that can be used later
PLTLabsMessageHelper.parseMetadata = function(message){ 
  log('parseMetadata: parsing message');
  var meta = {"supportedCommands" : [],
              "supportedGetSettings" : [],
              "supportedEvents" : [],
              "availablePorts" : []};
   
   
   var data_view = new Uint8Array(message, this.BR_HEADER_SIZE);
   var index = 0;
   var bounds = 2;
   var arrayLength = this.parseShortArray(index, data_view, bounds);
   
   //adjust the index to point to the start of the array
   index += 2;
  
   //Set the bounds to the upper limit of the array  
   //bounds is multipled by 2 because the array sent back from the device
   //are 16 bit short integers - which map over to message ids
   bounds = index + (2 * arrayLength[0]);
   meta.supportedCommands = this.parseShortArray(index, data_view, bounds);
   
   index = bounds;
   bounds = index + 2;
   arrayLength = this.parseShortArray(index, data_view, bounds);
   index += 2;
   bounds = index +  (2 * arrayLength[0]);
   meta.supportedGetSettings = this.parseShortArray(index, data_view, bounds);
   
   index = bounds;
   bounds = index + 2;
   arrayLength = this.parseShortArray(index, data_view, bounds);
   index += 2;
   bounds = index +  (2 * arrayLength[0]);
   meta.supportedEvents = this.parseShortArray(index, data_view, bounds);
 
   index = bounds;
   bounds = index + 2;
   arrayLength = this.parseShortArray(index, data_view, bounds);
   index += 2;
   bounds = index + arrayLength[0] //bytes instead 16 bit integers
   //for available ports - this array is stored as single bits
   meta.availablePorts = this.parseByteArray(index, data_view, bounds)
  
  return meta;
   
} 


//function responsible for converting PLTLabs byte array messages
//into event objects - expects info object as parameter
PLTLabsMessageHelper.parseEvent = function(info){
  var message = info.data;
  var data_view = new Uint8Array(message, this.BR_HEADER_SIZE);
  var eventId = this.parseShortArray(0, data_view, 2);
  //todo -fix array/json insert of property
  var event = new Object();
  event.id = eventId[0];
  event.socketId = info.socketId;
  event.properties = {};
  switch(event.id){
    case this.WEARING_STATE_CHANGED_EVENT:
      event.name = "Wear State Changed";
      event.properties['worn'] = this.byteToBool(data_view[2]);
      break;
    case this.CONNECTED_DEVICE_EVENT:
      event.name = "Connected Device";
      event.properties['address'] = data_view[2];
      break;
    case this.DISCONNECTED_DEVICE_EVENT:
      event.name = "Disconnected Device";
      event.properties['address'] = data_view[2];
      break;
    case this.TEST_INTERFACE_ENABLE_DISABLE_EVENT:
      event.name = "Test Interface Enabled/Disabled";
      event.properties['enabled'] = this.byteToBool(data_view[2]);
      break;
    case this.BUTTON_EVENT:
      event.name = "Button Press";
      event.properties['pressType'] = data_view[2];
      event.properties['buttonId'] = data_view[3];
      event.properties['buttonName'] = this.getButtonName(event.properties['buttonId']);
      break;
    case this.CALL_STATUS_CHANGE_EVENT:
      event.name = "Call Status Change";
      event.properties["callStateName"] = this.callStateStringLookup(data_view[2]);
      event.properties["state"] = data_view[2];
      var phoneNumberLength = this.parseShortArray(3, data_view, (3 + this.BR_MESSAGE_ID_SIZE));
      var phoneNumber = this.parseCharArray((3 + this.BR_MESSAGE_ID_SIZE), data_view,(3 + this.BR_MESSAGE_ID_SIZE + phoneNumberLength));
      event.properties["phoneNumber"] = phoneNumber.join("");
      break;
    case this.AUDIO_STATUS_EVENT:
      event.name = "Audio Status";
      event.properties["codec"] = data_view[2];
      event.properties["codecName"] = this.getCodecName(data_view[2]);
      event.properties["direction"] = data_view[3];
      event.properties["directionName"] = this.getDirection(data_view[3]);
      event.properties["speakerGain"] = data_view[4];
      event.properties["micGain"] = data_view[5];
      break;
    case this.BATTERY_STATUS_CHANGED_EVENT:
      event.name = "Battery Status Changed";
      event.properties["level"] = data_view[2];
      event.properties["numberOfLevels"] = data_view[3];
      event.properties["minutesOfTalkTime"] = this.parseShortArray(4, data_view, 6);
      event.properties["talkTimeIsHighEstimate"] = this.byteToBool(data_view[6]);
      break;
    case this.SIGNAL_STRENGTH_EVENT:
      event.name = "Signal Strength";
      event.properties["connectionId"] = data_view[2];
      event.properties["rssi"] = data_view[3];
      event.properties["nearFar"] = data_view[4];
      event.properties["proximity"] = this.proximityStringLookup(data_view[4]);
      break;
    case this.RAW_BUTTON_TEST_ENABLE_DISABLE_EVENT:
      event.name = "Button Events Enabled/Disabled"
      event.properties["enabled"] = this.byteToBool(data_view[2]);
      break;
    case this.LED_ALERT_STATUS_CHANGED:
      event.name = "LED Alert Status Shanged";
      event.properties["enabled"] = this.byteToBool(data_view[2]);
      event.properties["timeout"] = data_view[3];
      break;
    case this.PAIRING_MODE:
      event.name = "Pairing Mode";
      event.properties["enabled"] = this.byteToBool(data_view[2]);
      break;
    case this.LOW_BATTERY_VOICE_PROMPT_EVENT:
      event.name = "Low Battery";
      event.properties["urgency"] = data_view[2];
      event.properties["urgencyName"] = this.getUrgency(data_view[2]);
      break;
    case this.SUBSCRIBED_SERVICE_DATA_CHANGE_EVENT:
      event.name  = "Sensor Data Change Event";
      var serviceId = this.parseShortArray(2, data_view, 4);
      event.properties["serviceId"] = serviceId[0];  
      var characteristic = this.parseShortArray(4, data_view, 6);
      event.properties["characteristic"] = characteristic[0];
      var serviceDataLength = this.parseShortArray(6, data_view, 8);
      var serviceData = this.parseShortArray(8, data_view,(8 + serviceDataLength[0]));
      switch(serviceId[0]){
        case this.HEAD_ORIENTATION_SERVICE_ID:
          //convert quaternians to eular angles - w, x, y, z
          event.properties["quaternion"] = this.convertToQuaternion(serviceData);
          break;
        case this.PEDOMETER_SERVICE_ID:
          event.properties["steps"] = serviceData[0];
          break;
        case this.TAPS_SERVICE_ID:
          event.properties["x"] = serviceData[0];
          break;
        case this.FREE_FALL_SERVICE_ID:
          event.properties["freefall"] = serviceData[0] == 1;
          break;
        }
      break;
    default:
      event.name = "unknown";
  }
  return event;
}

PLTLabsMessageHelper.convertToQuaternion = function(serviceData){
  var w = serviceData[0];
  var x = serviceData[1];
  var y = serviceData[2];
  var z = serviceData[3];

  if (w > 32767) w -= 65536;
  if (x > 32767) x -= 65536;
  if (y > 32767) y -= 65536;
  if (z > 32767) z -= 65536;
  
  var x1 = x/16384.0;
  var y1 = y/16384.0;
  var z1 = z/16384.0;
  var w1 = w/16384.0;
  
  return {"w": w1, "x": x1, "y": y1, "z": z1}
  
}

PLTLabsMessageHelper.getDirection = function(direction){
  return direction == 0 ? "Initiator" : "Another Device"; 
}

PLTLabsMessageHelper.getUrgency = function(urgencyId){
  return urgencyId == 1 ? "Critically Low" : "Low";
}
PLTLabsMessageHelper.getCodecName = function(codecId){
  switch(codecId){
    case 0:
      return "None";
    case 1:
      return "CVSD";
    case 2: 
      return "G726";                            
    case 3: 
      return "G722";
    case 4: 
      return "MSBC";
    case 5: 
      return "A2DP Sink";
    default:
      return "Unknown";
  }
}

PLTLabsMessageHelper.getButtonName = function(buttonId){
   switch(buttonId){
    case 1:
      return "Power";
    case 2: 
      return "Hook";                            
    case 3: 
      return "Talk";
    case 4: 
      return "Volume Up";
    case 5: 
      return "Volume Down";
    case 6: 
      return "Mute";
    default:
      return "Unknown";
   }
}
  
PLTLabsMessageHelper.callStateStringLookup = function(callStateCode){
  switch(callStateCode){
    case 0:
      return "Idle";
    case 1: 
      return "Active";                            
    case 2: 
      return "Ringing";
    case 3: 
      return "Dialing";
    default:
      return "Unknown";
  }
}

PLTLabsMessageHelper.proximityStringLookup = function(proximityCode){
  switch(proximityCode){
    case 0:
      return "Far";
    case 1:
      return "Near";
    default:
      return "Unknown";
  }
}

PLTLabsMessageHelper.parseCharArray = function(index, buffer, bounds){
   var result = new Array();
   for(index; index < bounds; index++){
    var val = buffer[index]
    result.push(String.fromCharCode(val));
  }
  return result;
}
PLTLabsMessageHelper.parseByteArray = function(index, buffer, bounds){
   var result = new Array();
   for(index; index < bounds; index++){
    var val = buffer[index]
    result.push(val);
  }
  return result;
}
PLTLabsMessageHelper.byteToBool = function(byte){
  return byte == 0x1;
}

PLTLabsMessageHelper.boolToByte = function(bool){
  return bool ? 0x1 : 0x0;
}
PLTLabsMessageHelper.parseShortArray = function(index, buffer, bounds){
   var result = new Array();
   for(index; index < bounds; index+=2){
    var val = buffer[index] << 8;
    val += (buffer[index+1] & 0xFF);
    result.push(val);
  }
  return result;
}

function PLTLabsException(message){
  this.message = message;
  this.toString = function(){
    return "PLTLabsException:" + message;
  }
}
