/*
 * Plantronics Google Chrome bluetooth integration library
 * This library provides an web applicaiton integration with the PLT device and Google Chrome's bluetooth APIs
 * @author: Cary A. Bran
 * @version: 1.0
 * @copyright: 2014 Plantronics Inc
 */
var plt = (function(my){
  var deviceListener = null;
  var onConnectionListener = null;
  var onDisconnectListener = null;
  var eventListener = null;
  var settingListener = null;
  var commandSuccessListener = null;
  var errorListener = null;
 
  var PLT_PROFILE = {
    uuid: '82972387-294e-4d62-97b5-2668aa35f618'
  };
  //default device address is 00 00 00 00 which maps to the device connected to the host
  var defaultAddress = new ArrayBuffer(4);
  
  //default sensor port address is 50 00 00 00 which maps to the connected device's sensor services
  var sensorAddress = new ArrayBuffer(4);
  var sensorAddress_view = new Uint8Array(sensorAddress);
  sensorAddress_view[0] = 0x50;
  var isSensorPortEnabled = false;
  
  //maintain the current active socket connections
  var deviceConnections = {};
  if(chrome.bluetooth){
    chrome.bluetooth.onDeviceRemoved.addListener(onDeviceRemoved);
    
    chrome.bluetooth.onDeviceAdded.addListener(function(device){
        var pltDevices = [];
        console.log('device added sending to deivce listener!');
        if(device.connected == true && device.name.indexOf("PLT_") != -1) {
          pltDevices.push(device);
          if (deviceListener) {
            deviceListener(pltDevices);
          }
        }
      });
    
    chrome.bluetooth.onDeviceChanged.addListener(function(device){
        console.log('device changed sending to deivce listener!');
    });
  }
  
  /* This funtion searches for Plantronics devices, will only returned devices that are
   * connected to the host system.  It will return devices by sending notification to
   * the device listener that has been registered using addDeviceListener.
   */
  my.getDevices = function(){
     // Add the listener to deal with the socket connection
    chrome.bluetoothSocket.onReceive.addListener(onReceiveHandler);
    chrome.bluetoothSocket.onReceiveError.addListener(onReceiveErrorHandler);
    chrome.bluetooth.getAdapterState(function(adapterState){
      if(!adapterState.available || !adapterState.powered){
        console.log('findPLTLabsDevices: bluetooth adapter not available');
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
        //send notification of the found devices
        if (pltDevices.length > 0 && deviceListener) {
           deviceListener(pltDevices);
        }
      });
    });
  };
  
  my.connect = function(device){
    if(!device){
      throw 'connect: requires a device';
    }
    //open socket for data
    chrome.bluetoothSocket.create(function(createInfo) {
      chrome.bluetoothSocket.connect(createInfo.socketId, device.address, PLT_PROFILE.uuid, function(){
        if (chrome.runtime.lastError) {
          throw 'connect: connection failed: ' + chrome.runtime.lastError.message; 
        }
        chrome.bluetoothSocket.setPaused(createInfo.socketId, false);
        chrome.bluetoothSocket.getInfo(createInfo.socketId, function(socketInfo){
          device.socketId = socketInfo.socketId;
          device.isSensorPortEnabled = false;
          device.buttonsEnabled = false;
          deviceConnections[device.socketId] = device;
          my.sendMessage(device, plt.msg.createHostNegotiateMessage());   
          });
        })
      });
  };
  
  /* Disconnects the device socket
   * @param socketId - optional, the socket id to disconnect, if no id is passed then the first active connection will be disconnected
   */
  my.disconnect = function(device){
    if (!device || !deviceConnections[device.socketId]){
      return;
    }
    //remove the device association with the socket id
    delete deviceConnections[device.socketId];
    console.log("disconnect: disconnecting socket from device");
    chrome.bluetoothSocket.disconnect(device.socketId, function(){
        console.log("disconnect: socket closed.");
        if (onDisconnectListener) {
           onDisconnectListener(device);
         }
    });
  };
  
  //registration functions for device callbacks
  my.addDeviceListener = function(callback){
    deviceListener = callback;
  }
  my.addEventListener = function(callback){
    eventListener = callback;
  };
  my.addSettingsListener = function(callback){
    settingListener = callback;
  };
  my.addCommandSuccessListener = function(callback){
    commandSuccessListener = callback;
  };
  
  /* Add a callback for the on connect event that occurs after a socket to the device has been created
   * @param callback - required, a function - function callback(device), where 'device' is the connected device
   * the device is passed back to this API to send a message
   */
  my.addOnConnectionListener = function(callback){
    onConnectionListener = callback;
    
  }
  
  /* Add a callback for the on connect event that occurs after a socket to the device has been disconnected
   * @param callback - required, a function - function callback(device), where 'device' is the previously connected device
   */
  my.addOnDisconnectListener = function(callback){
    onDisconnectListener = callback;
  }
  
  /* Sends a deckard message over the bluetooth socket
   * @param device - required - the device to send the message too
   * @param message - a message created by the plt.msg class
   */
  my.sendMessage = function(device, message){  
    if (!device || !message) {
      throw "device and message parameters are required"
    }
    //this variable is required to maintain correct scoping when calling the send function
    chrome.bluetoothSocket.send(device.socketId, message.messageBytes);
  };
  
  my.calibrateHeadOrientation = function(device){
    if (!device || !deviceConnections[device.socketId]) {
      return;
    }
    deviceConnections[device.socketId].calibrateQuaternionFlag = true;
  }
  
  
  
  var onReceiveHandler = function(eventData){
    var device = deviceConnections[eventData.socketId];
    var message = plt.msg.parse(eventData.data);
    //console.log("onReceiveHandler: " + JSON.stringify(message));
    switch(message.messageType){
      case plt.msg.PROTOCOL_VERSION_TYPE:
        break;
       case plt.msg.GET_RESULT_SUCCESS_TYPE:
        if (settingListener) {
          settingListener(message);
        }
        switch (message.payload.messageId) {
          case plt.msg.GENES_GUID_SETTING:
            console.log("device guid set");
            deviceConnections[device.socketId].guid = message.payload.guid;
            //once the guid has been set - all of the initial device configuration
            //is complete - so send the connection event
            if (onConnectionListener) {
              //send the connected event
              onConnectionListener(deviceConnections[device.socketId]);
            }
            break;
        }
        break;
       case plt.msg.GET_RESULT_EXCEPTION_TYPE:
        console.log("get exception " + JSON.stringify(message));
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
        if (!device.isSensorPortEnabled && message.payload.availablePorts.indexOf(5) >= 0) {
           console.log("enabling sensor service subscription");
           my.sendMessage(device, plt.msg.createHostNegotiateMessage({"address":sensorPortAddress}));
           deviceConnections[device.socketId].isSensorPortEnabled = true;
        }
        if (!device.buttonsEnabled) {
          enableButtonEvents(device);
        }
        if (!device.guid && (message.payload.supportedGetSettings.indexOf(plt.msg.GENES_GUID_SETTING) >= 0)) {
          //get the device guid
          console.log("fetching the device guid");
          my.sendMessage(device, plt.msg.createGetSetting(plt.msg.GENES_GUID_SETTING));
        }
        break;
       case plt.msg.EVENT_TYPE:
        switch(message.payload.messageId){
          case plt.msg.SUBSCRIBED_SERVICE_DATA_EVENT:
            if (device.calibrateQuaternionFlag) {
              device.calibrationQuaternion = message.payload.quaternion;
              device.calibrateQuaternionFlag = false;
              console.log("calibration quaternion stored for device" + JSON.stringify(device.calibrationQuaternion));
            }
            if (device.calibrationQuaternion && message.payload.serviceID == plt.msg.TYPE_SERVICEID_HEADORIENTATION){
              //inverse the calibration quaterion
               var iQ = inverseQuaternion(device.calibrationQuaternion);
               var calQ = multiplyQuaternions(iQ, message.payload.quaternion);
               message.payload.calibratedQuaternion = calQ;
               var c = convertQuaternianToCoordinates(calQ);
               message.payload.roll = c.roll;
               message.payload.pitch = c.pitch;
               message.payload.heading = c.heading;
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
  
  
  var inverseQuaternion = function(q){
    return {"w": q.w, "x": -q.x , "y": -q.y, "z": -q.z};
  };
  
  var multiplyQuaternions = function(p, q){
    var qArray = [q.w, q.x, q.y, q.z];
    var matrix = [[p.w, -p.x, -p.y, -p.z],
                  [p.x,  p.w, -p.z,  p.y],
                  [p.y,  p.z,  p.w, -p.x],
                  [p.z, -p.y,  p.x,  p.w]];
    var newQuatArray = [0.0, 0.0, 0.0, 0.0];
    for(var i = 0; i < 4; i++) {
        for(var j = 0; j < 4; j++) {
            newQuatArray[i] += (matrix[i][j] * qArray[j]);
        }
    }
    return {"w": newQuatArray[0], "x": newQuatArray[1] , "y": newQuatArray[2], "z": newQuatArray[3]}; 
  }
  
  var quaternianToEuler = function(q1) {
    var pitchYawRoll = {"x":0, "y":0, "z":0};
    var sqw = q1.w*q1.w;
    var sqx = q1.x*q1.x;
    var sqy = q1.y*q1.y;
    var sqz = q1.z*q1.z;
    var unit = sqx + sqy + sqz + sqw; // if normalised is one, otherwise is correction factor
    var test = q1.x*q1.y + q1.z*q1.w;
    var heading = 0;
    var attitude = 0;
    var bank = 0;
    
    if (test > 0.499*unit) { // singularity at north pole
        heading = 2 * Math.atan2(q1.x,q1.w);
        attitude = Math.PI/2;
    }
    if (test < -0.499*unit) { // singularity at south pole
        heading = -2 * Math.atan2(q1.x,q1.w);
        attitude = -Math.PI/2;
    }
    else {
        heading = Math.atan2(2*q1.y*q1.w-2*q1.x*q1.z , sqx - sqy - sqz + sqw);
        attitude = Math.asin(2*test/unit);
        bank = Math.atan2(2*q1.x*q1.w-2*q1.y*q1.z , -sqx + sqy - sqz + sqw)
    }
    pitchYawRoll.z = Math.floor(attitude * 1000) / 1000;
    pitchYawRoll.y = Math.floor(heading * 1000) / 1000;
    pitchYawRoll.x = Math.floor(bank * 1000) / 1000;

    return pitchYawRoll;
  }        

  var eulerToAngle = function(r) {
      var c = 0;
      if (r > 0){
        c = (Math.PI*2) - r;
      } 
      else {
        c = -r
      }
      return Math.round((c / ((Math.PI*2)/360)));  // camera angle radians converted to degrees
  }

  //converts a quaternion into a set of Euler angles 
  var convertQuaternianToCoordinates = function(q){
    var e = quaternianToEuler(q);
   
    p = convertToPitch(q);
    return {"pitch" :p, "roll" :eulerToAngle(e.z), "heading" : eulerToAngle(e.y)};
  
  }
  
  var convertToPitch = function(q){
    var p = (2 * q.y * q.z) + (2 * q.w * q.x);
    var pitch = (180 / Math.PI) * Math.asin(p);
    return Math.round(pitch);
  };


  var messageCameFromSensorPort = function(message){
    if (!message || !message.address) {
      return false;
    }
    //address will be formated as 0, 5, 0, 0, 0, 0, 0 if it has come back from
    //the sensor port 
    return message.address[1] == 5;
  }
  //enables the button event functionality
  var enableButtonEvents = function(device){
    var options = {"address": defaultAddress, "enable" : true};
    var message = plt.msg.createCommand(plt.msg.TEST_INTERFACE_ENABLE_DISABLE_COMMAND , options); 
    
    console.log('enabling test interface');
    my.sendMessage(device, message);
    
    message = plt.msg.createCommand(plt.msg.RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_COMMAND , options);
    console.log('enabling button press events');
    
    my.sendMessage(device, message);
    deviceConnections[device.socketId].buttonsEnabled = true;
  };
  
  
  var onReceiveErrorHandler = function(eventData){
    console.log("onReceiveErrorHandler: socket error: " + JSON.stringify(eventData));
    my.disconnect(deviceConnections[eventData.socketId]);
    
  };
  
  //handles device removed events from the chrome api
  var onDeviceRemoved = function(device){
    for(var i = 0; i < deviceConnections.length; i++){
       var d = deviceConnections[i];
       if(d.address == device.address){
         d.splice(i, 1);
         if(onDeviceDisconnectCallback){
           onDeviceDisconnectCallback(device);
         }
         break;
       }
     }
  }
   
  return my;  
})(plt || {});
