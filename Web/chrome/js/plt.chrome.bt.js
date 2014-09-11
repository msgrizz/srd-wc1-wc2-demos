//PLT Labs - Bluetooth device access library
//Author - Cary Bran - cary.bran@plantronics.com
//This library is to enable experimental device data access
//using the Google Chrome Bluetooth APIs 
var plt = (function(my){
  var deviceListener = null;
  var connectionListener = null;
  var eventListener = null;
  var settingListener = null;
  var commandSuccessListener = null;
  var errorListener = null;
  
  var isSensorPortEnabled = false;
  
  var PLT_PROFILE = {
    uuid: '82972387-294e-4d62-97b5-2668aa35f618'
  };
  //default device address is 00 00 00 00 which maps to the device connected to the host
  var defaultAddress = new ArrayBuffer(4);
  
  //default sensor port address is 50 00 00 00 which maps to the connected device's sensor services
  var sensorAddress = new ArrayBuffer(4);
  var sensorAddress_view = new Uint8Array(sensorAddress);
  sensorAddress_view[0] = 0x50;
  
  var socketConnections = [];
  
  if(chrome.bluetooth){
    //device related listeners
    chrome.bluetooth.onDeviceAdded.addListener(function(device){
      if (deviceListener) {
        deviceListener(device);  
      }
    });
    
    chrome.bluetooth.onDeviceRemoved.addListener(onDeviceRemoved);
    
    // Add the listener to deal with the socket connection  
 //function(info){
   // log('error on socket receive: socket id = ' + info.socketId + ' message = ' + info.errorMessage + ' error = ' + info.error);
    // PLTLabsAPI.closeConnection(onDeviceDisconnectCallback);
  //});
//  chrome.bluetoothSocket.onAccept.addListener(function (info){log('onAccept  server socket id = ' + info.socketId + ' clientSocket = ' + info.clientSocketId);});
  
    
    
  }
  
  var onReceiveHandler = function(eventData){
    var message = plt.msg.parse(eventData.data);
    
    //console.log("onReceiveHandler: " + JSON.stringify(message));
    switch(message.messageType){
      case plt.msg.PROTOCOL_VERSION_TYPE:
        break;
       case plt.msg.GET_RESULT_SUCCESS_TYPE:
        if (settingListener) {
          settingListener(message);
        }
        break;
       case plt.msg.GET_RESULT_EXCEPTION_TYPE:
        break;
       case plt.msg.COMMAND_RESULT_SUCCESS_TYPE:
        if(commandSuccessListener){
          commandSuccessListener(message);
        }
        break;
       case plt.msg.COMMAND_RESULT_EXCEPTION_TYPE:
        console.log("command exception: " + JSON.stringify(message));
        break; 
       case plt.msg.DEVICE_PROTOCOL_VERSION_TYPE:
        break;
       case plt.msg.METADATA_TYPE:
        if (!isSensorPortEnabled) {
          var availablePorts = message.payload.availablePorts;
          if (!availablePorts.indexOf(my.SENSOR_PORT) >= 0) {
           console.log("enable sensor service subscription");
           sendMessageToSocket(plt.msg.createHostNegotiateMessage({"address":sensorPortAddress}).messageBytes);
           isSensorPortEnabled = true;
          }
        }
        break;
       case plt.msg.EVENT_TYPE:
        switch (message.payload.messageId) {
          case plt.msg.CONNECTED_DEVICE_EVENT:
            if(connectionListener){
              connectionListener(true);
            }
            break;
          case plt.msg.DISCONNECTED_DEVICE_EVENT:
            if(connectionListener){
              connectionListener(false);
            }
            break;
        }
        if(eventListener){
          eventListener(message);
        }
        break;
       case plt.msg.CLOSE_SESSION_TYPE:
          console.log('close session: ' + JSON.stringify(message));
        break;
       case plt.msg.HOST_PROTOCOL_NEGOTIATION_REJECTION_TYPE:
          console.log('host protocol negotiation rejection: ' + JSON.stringify(message));
        break;
      default:
        console.log('Unknown Message Type: ' + JSON.stringify(message));
        break;   
    }
  };

  
  var onReceiveErrorHandler = function(eventData){
    console.log("onReceiveErrorHandler: socket error: " + JSON.stringify(eventData));
    if (connectionListener) {
      connectionListener(false);
    }
    
  };

  var onDeviceRemoved = function(device){
    for(var i = 0; i < socketConnections.length; i++){
       var socket = socketConnections[i];
       if(socket.address == device.address){
         socketConnections.splice(i, 1);
         if(deviceListener){
           deviceListner(false);
         }
         break;
       }
     }
  }
  
  my.getDevices = function(){
    
    try{
    
     // Add the listener to deal with the socket connection
    chrome.bluetoothSocket.onReceive.addListener(onReceiveHandler);
    chrome.bluetoothSocket.onReceiveError.addListener(onReceiveErrorHandler);
    chrome.bluetooth.getAdapterState(function(adapterState){
      if(!adapterState.available || !adapterState.powered){
        log('findPLTLabsDevices: bluetooth adapter not available');
        return;
      }
      chrome.bluetooth.getDevices(function(devices){
        if(chrome.runtime.lastError) {
          console.log('getDevices: error searching for a devices ' + chrome.runtime.lastError.message);
          return;
        }
        var pltDevices = [];
        //filter on PLT devices that are connected to the host
        for(i = 0; i < devices.length; i++){
         if(devices[i].connected == true && devices[i].name.indexOf("PLT_") != -1) {
            pltDevices.push(devices[i]);
          }
        }
        //send notification if 
        if (pltDevices.length > 0 && deviceListener) {
           deviceListener(pltDevices);
        }
    });
      });
    }
    catch(e){
      console.log("exception " + e);
    }
  
  };
  
  my.connect = function(device){
    if(!device){
      throw 'connect: requires a device';
    }
    //open socket for data
    chrome.bluetoothSocket.create(function(createInfo) {
      chrome.bluetoothSocket.connect(createInfo.socketId, device.address, BR_PROFILE.uuid, function(){
        if (chrome.runtime.lastError) {
          throw 'connect: connection failed: ' + chrome.runtime.lastError.message; 
        }
        chrome.bluetoothSocket.setPaused(createInfo.socketId, false);
        chrome.bluetoothSocket.getInfo(createInfo.socketId, function(socketInfo){
          socketConnections.push(socketInfo);
          sendMessageToSocket(plt.msg.createHostNegotiateMessage().messageBytes, createInfo.socketId);   
          });
        })
      });
  };
  
  //message is byte array
  //socket id is optional - if set, then it will use the specified socketId
  var sendMessageToSocket = function(message, socketId){  
    if(socketConnections.length == 0){
      throw "no active connections";
      return; 
    }
    if (!socketId) {
      //if there is no socket id passed grab the first connection out of the sockets array
      socketId = socketConnections[0].socketId;
    }
    //this variable is required to maintain correct scoping when calling the send function
    chrome.bluetoothSocket.send(socketId, message);
  };
  
  
  my.disconnect = function(socketId){
    if (socketConnections.length == 0) {
      return;
    }
    if (!socketId) {
      socketId = socketConnections[0].socketId
    }

    for(var i = 0; i < socketConnections.length; i++){
       var socket = socketConnections[i];
       if(socket.socketId == socketId){
         socketConnections.splice(i, 1);
         break;
       }
    }
    log("disconnect: disconnecting socket from device");
    chrome.bluetoothSocket.disconnect(socketId,function(){
        log("closeConnection: socket closed.");
        if (connectionListener) {
           connectionListener(false);
         }
    });
  };
  
  my.sendCommand = function(command, socketId){
    console.log('sendCommad called');
    sendMessageToSocket(command.messageBytes, socketId);
  };
  
  //setting - a setting message
  //socketId - optional
  my.getSetting = function(setting, socketId){
    console.log("getSetting: sending "  + JSON.stringify(setting));
    sendMessageToSocket(setting.messageBytes, socketId);
  }
  
  //registration functions for device callbacks
  my.addDeviceListener = function(callback){
    deviceListener = callback;
  }
  my.addConnectionListener = function(callback){
    connectionListener = callback;
  };
  my.addEventListener = function(callback){
    eventListener = callback;
  };
  my.addSettingsListener = function(callback){
    settingListener = callback;
  };
  my.addCommandSuccessListener = function(callback){
    commandSuccessListener = callback;
  };
   
  return my;  
})(plt || {});

/*

var deviceRoute = new ArrayBuffer(4);
//initialize the address array to 0x0
var address = new Uint8Array(deviceRoute);

var onDeviceAddedCallback = null;
var onSocketConnectionCallback = null;
var onEventCallback = null;
var onMetaDataCallback = null;
var onSettingsCallback = null;
var onDeviceDisconnectCallback = null;


var PLTLabsAPI = {};



//public members
PLTLabsAPI.connected = false;
PLTLabsAPI.connectedDevices =[];
PLTLabsAPI.debug = false;
PLTLabsAPI.socketId = null;
PLTLabsAPI.device = null;
PLTLabsAPI.testInterfaceEnabled = false;
PLTLabsAPI.buttonEventsEnabled = false;

var BR_PROFILE = {
  uuid: '82972387-294e-4d62-97b5-2668aa35f618'
};



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
  
  chrome.bluetoothSocket.create(function(createInfo) {
    log('openConnection: socket created connecting to device ' + device.address + ' with socketId ' + createInfo.socketId);
    PLTLabsAPI.socketId = createInfo.socketId;
    PLTLabsAPI.device = device;
    chrome.bluetoothSocket.connect(createInfo.socketId, device.address, BR_PROFILE.uuid, onConnectDeviceHandler);
    
  });
  
};

PLTLabsAPI.subscribeToDisconnect = function(callback){
  if(!callback || !typeof(callback) == "function"){
    throw new PLTLabsException("closeConnection: this method requires a callback function");
  } 
  onDeviceDisconnectCallback = callback;
  
}


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
  //remove the socket from the list of ports
  for(index = 0; index < PLTLabsAPI.connectedDevices.length; index++){
        var s = PLTLabsAPI.connectedDevices[index];
        if (s.socketId == PLTLabsAPI.socketId) {
        //TODO - see if we need to maintain this array now
          PLTLabsAPI.connectedDevices.splice(index, 1);
          break;
        }
  }
  
  log("closeConnection: disconnecting socket from device");
  if(PLTLabsAPI.socketId){
    chrome.bluetoothSocket.disconnect(PLTLabsAPI.socketId,function(){
        log("closeConnection: socket closed.");
        callback();
        PLTLabsAPI.socketId = null;    
    });
  }
  
  PLTLabsAPI.device = null;
  onDeviceDisconnectCallback = null;
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
  chrome.bluetooth.onDeviceAdded.addListener(function(devices){
      if (onDeviceAddedCallback) {
          onDeviceAddedCallback(devices);  
      }    
  });
  
  chrome.bluetooth.onDeviceRemoved.addListener(function(device){
    if(PLTLabsAPI.device && (PLTLabsAPI.device.address == device.address)){
      PLTLabsAPI.closeConnection(onDeviceDisconnectCallback);
    }
  });
  chrome.bluetoothSocket.onReceive.addListener(onReceiveHandler);
  chrome.bluetoothSocket.onReceiveError.addListener(function(info){
    log('error on socket receive: socket id = ' + info.socketId + ' message = ' + info.errorMessage + ' error = ' + info.error);
    PLTLabsAPI.closeConnection(onDeviceDisconnectCallback);
  });
  chrome.bluetoothSocket.onAccept.addListener(function (info){log('onAccept  server socket id = ' + info.socketId + ' clientSocket = ' + info.clientSocketId);});
  
  //log('findPLTLabsDevices: added connection listeners');
  
  chrome.bluetooth.getAdapterState(function(adapterState){
    if(!adapterState.available || !adapterState.powered){
      log('findPLTLabsDevices: bluetooth adapter not available');
      return;
    }
    //log('getAdaptorState: getting devices');
    chrome.bluetooth.getDevices(returnDeviceList);
  });
  
  //log('findPLTLabsDevices: exit function');
  
};

//Handle the device connect event and set up the device connection
//and the socket read interval
var onConnectDeviceHandler = function(){
  if (chrome.runtime.lastError) {
    log("onConnectionDeviceHandler: Connection failed: " + chrome.runtime.lastError.message);
    closeConnection();
    return;
  }
  
  log("onConnectDeviceHandler: socket communications established");
  chrome.bluetoothSocket.setPaused(PLTLabsAPI.socketId , false);
  PLTLabsAPI.connected = true;
  hostNegotiate();    
   
};

var onReceiveHandler = function(info) {
 parseBladerunnerData(info);
}

//sets up the events subscription, if the subscription already exists then 
//update the events subscription service
PLTLabsAPI.subscribeToEvents = function(callback){
  if(!callback || !typeof(callback) == "function"){
    throw new PLTLabsException("subscribeToEvents: this method requires a callback function");
  } 
  onEventCallback = callback; 
};

PLTLabsAPI.subscribeToSettings = function(callback){
  if(!callback || !typeof(callback) == "function"){
    throw new PLTLabsException("subscribeToSettings: this method requires a callback function");
  }
  
  onSettingsCallback = callback;

}



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
  PLTLabsAPI.sendBladerunnerPacket(command);
};

PLTLabsAPI.sendSetting = function(setting){
  if(!setting){
    log('sendSetting: empty setting ignoring'); 
  }
  PLTLabsAPI.sendBladerunnerPacket(setting);
};

//Attempts to send a blade runner packet over the bluetooth socket connection, if error occurs will log it out.
PLTLabsAPI.sendBladerunnerPacket = function(packet){
  if(!this.connected){
    log('sendBladerunnerPacket: PLTLabs device packet send fail - not connected');
    return; 
  }
  //this variable is required to maintain correct scoping when calling the send function
  chrome.bluetoothSocket.send(PLTLabsAPI.socketId, packet.messageBytes ? packet.messageBytes : packet);
};
  


 
//This function enables the test interface for the PLTLabs device
//the test interface is a prerequisite for receiving events from buttons and other features.
var enableTestInterfaces = function(){
  if(!PLTLabsAPI.connected){
    log('enableTestInterfaces: cannot subscribe to events PLTLabs API disconnected');
    return; 
  }
  if(!PLTLabsAPI.testInterfaceEnabled){
    //disable/enable the interface so the states match 
    var options = {"address": deviceRoute, "enable" : true};
    var packet = plt.msg.createCommand(plt.msg.TEST_INTERFACE_ENABLE_DISABLE_COMMAND , options); 
    log('enableTestInterfaces: enabling test interface ' + JSON.stringify(packet));
    PLTLabsAPI.sendCommand(packet);
   }
};


//enables the buttons functionality
var enableButtons = function(enableButtonEvents){
  if(!PLTLabsAPI.testInterfaceEnabled){
    log('enableButtons: enabling the test interface to enable button events');
    enableTestInterfaces();
  }
  var options = {"address": deviceRoute, "enable" : enableButtonEvents};
  var packet = plt.msg.createCommand(plt.msg.RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_COMMAND , options);
  log('enableButtons: sending command ' + JSON.stringify(packet));
  PLTLabsAPI.sendCommand(packet);//}, 100)
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
  var packet = plt.msg.createHostNegotiateMessage();
  log('hostNegotiate: sending host negotiate packet'); 
  PLTLabsAPI.sendBladerunnerPacket(packet);   
};
  
//called when we receive a command success message
var onCommandSuccess = function(commandSuccessMessage){
    switch(commandSuccessMessage.payload.messageId){
      case plt.msg.TEST_INTERFACE_ENABLE_DISABLE_COMMAND:
        if(!PLTLabsAPI.buttonEventsEnabled){
            enableButtons(true); 
        }  
        break;
      case plt.msg.RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_COMMAND:
         PLTLabsAPI.buttonEventsEnabled =! PLTLabsAPI.buttonEventsEnabled;
        break;
      default:
        log('onCommandSuccess: command successfully executed: ' + JSON.stringify(command));
    }
}

  
//Parses the bladerunner packet response - depending on 
//the type of the message additional functionality may be executed
var parseBladerunnerData = function(rawData){
  var message = plt.msg.parse(rawData.data);
  log('parseBladerunnerData: message ' + JSON.stringify(message));
  switch(message.messageType){
    case plt.msg.PROTOCOL_VERSION_TYPE:
      log('parseBladerunnerData: protocol version: ' + JSON.stringify(message));
      break;
     case plt.msg.GET_RESULT_SUCCESS_TYPE:
      log('parseBladerunnerData: get setting success: ' + JSON.stringify(message));
      onSettingsCallback(message);
      break;
     case plt.msg.GET_RESULT_EXCEPTION_TYPE:
       log('parseBladerunnerData: get setting exception: ' + JSON.stringify(message));
      break;
     case plt.msg.COMMAND_RESULT_SUCCESS_TYPE:
      onCommandSuccess(message);
      break;
     case plt.msg.COMMAND_RESULT_EXCEPTION_TYPE:
       log('parseBladerunnerData: command exception: ' + JSON.stringify(message));
      break; 
     case plt.msg.DEVICE_PROTOCOL_VERSION_TYPE:
        log('parseBladerunnerData: protocol version message recieved: ' + JSON.stringify(message));
      break;
     case plt.msg.METADATA_TYPE:
        if (onMetaDataCallback) { 
          onMetaDataCallback(message);
        }
      break;
     case plt.msg.EVENT_TYPE:
      log('parseBladerunnerData: event recieved: ' + JSON.stringify(message));
      switch (message.payload.messageId) {
        case plt.msg.CONNECTED_DEVICE_EVENT:
        case plt.msg.DISCONNECTED_DEVICE_EVENT:
          connectedEvent(message);
          break;
      }
      onEventCallback(message);
      break;
     case plt.msg.CLOSE_SESSION_TYPE:
        log('parseBladerunnerData: close session: ' + JSON.stringify(message));
      break;
     case plt.msg.HOST_PROTOCOL_NEGOTIATION_REJECTION_TYPE:
        log('parseBladerunnerData: host protocol negotiation rejection: ' + JSON.stringify(message));
      break;
    default:
      log('Unknown Message Type: ' + JSON.stringify(message));
      break;
   
  }

};


//manages the connection state for the PLTLabs api
var connectedEvent = function(event){
  var port = event.payload.address;
  var socketId = event.socketId;
  var socketConnection = {"socketId": socketId, "ports":[port]};
  var connectEvent = plt.msg.CONNECTED_DEVICE_EVENT == event.payload.messageId;
  
  //log('connectedEvent: port ' + port + ' socketId ' + socketId + ' event type ' +  (connectEvent ? 'connected' : 'disconnected'));
  if(onSocketConnectionCallback && connectEvent){
    onSocketConnectionCallback(event);
  }
  for(index = 0; index < PLTLabsAPI.connectedDevices.length; index++){
    var socket = PLTLabsAPI.connectedDevices[index];
    if (socket.socketId == socketId) {
      var position = socket.ports.indexOf(port);
      //not found and disconnect - just return
      if (position == -1 && connectEvent) {
        //add the port to the list
        socket.ports.push(port);
        enableTestInterfaces();
      }
      else if (position > -1 && ! connectEvent) {
        //port in array needs to be removed on disconnect
        socket.ports.splice(position, 1);
      }
      return;
    }
  }
  //if we get here then assume the socket needs to be added
  if (PLTLabsAPI.connectedDevices.length == 0 && connectEvent) {
    PLTLabsAPI.connectedDevices.push(socketConnection); 
  }

};
  
function PLTLabsException(message){
  this.message = message;
  this.toString = function(){
    return "PLTLabsException:" + message;
  }
}
*/