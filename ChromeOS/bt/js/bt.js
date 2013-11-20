//PLT Labs - Bladerunner Experiment
//Author: Cary Bran
//JS Library to test bladerunner functionality

var PLT_DEVICE_NAME = 'PLT_Legend';

var BT_SOCKET_READ_INTERVAL = 20;
var PLT_RECONNECT_INTERVAL = 5000;

var BR_SEQUENCE_OFFSET = 2;


var pltDevice;
var pltSocket = null;
var pltReadIntervalId = null; 
var pltDeviceRoute = new ArrayBuffer(4);
var pltDeviceMinBRVersion = 0;
var pltDeviceMaxBRVersion = 0;
var pltDeviceSupportedCommands = null;
var pltDeviceSupportedEvents = null;
var pltDeviceSupportedGetSettings = null;

var connectIntervalId = null;

var devices = [];
var connected = false;

function log(msg) {
  var msg_str = (typeof(msg) == 'object') ? JSON.stringify(msg) : msg;
  console.log(msg_str);
  var l = document.getElementById('log');
  if (l) {
    l.innerText = msg_str + '\n' + l.innerText;
  }
}

function init(){
  $('#butDisconnect').click(disconnect);
  $('#butConnect').click(findAndConnect);
 // $('#butTI').click(sendEnableTestInterfaceCommand);
  $('#butButtonEvents').click(sendEnableButtonsCommand);
  
  
  //$('#butDisconnect').prop('disabled', true);
  
  // Add the listener to deal with our initial connection
  chrome.bluetooth.onConnection.addListener(onConnectHandler);
  //initialize the address array
  var data_view = new Uint8Array(pltDeviceRoute);
  
  log('Starting PLT Labs Chrome BT integration demo...');
  
  //findAndConnect();
}

//Responsible for the initial handshake with the Bladerunner device
//sends a 9-byte U8 array to the device after the profile has been negotiated and the 
//connection established.  The host negotiate packet is needed to start the flow of contextual data
//to and from the device
//
var hostNegotiate = function(){
  var packet = createHostNegotiateMessage();
  /*  var buffer = new ArrayBuffer(9);
    var view = new Uint8Array(buffer);
    view[0] = 0X10;
    view[1] = 0X7;
    view[5] = 0X1;
    view[6] = 0X1;
    view[7] = 0X1;
    */
  log('hostNegotiate: sending host negotiate packet');
  sendBladerunnerPacket(packet);   
}



var sendEnableButtonsCommand = function(){
  var packet = createEnableButtonsMessage({"address": pltDeviceRoute, "enabled" : true}); 
  sendBladerunnerPacket(packet);
}
var sendEnableTestInterfaceCommand = function(){
  var packet = createEnableTestInterfaceMessage({"address": pltDeviceRoute, "enabled" : true}); 
  sendBladerunnerPacket(packet);
}

var parseBladerunnerData = function(data){
  if(!data||data.byteLength < BR_HEADER_SIZE){
   return;
  }
  
  var data_view = new Uint8Array(data, 0);
  var messageType = data_view[5];
  
  switch(messageType){
    case PROTOCOL_VERSION_TYPE:
      log('Protocol Version Type Message');
      break;
     case GET_REQUEST_TYPE:
      log('Get Request Type Message');
      break;
     case GET_RESULT_SUCCESS_TYPE:
      log('Get Result Success Type Message');
      break;
     case GET_RESULT_EXCEPTION_TYPE:
      log('Get Result Exception Type Message');
      break;
     case PERFORM_COMMAND_TYPE:
      log('Perform Command Type Message');
      break;
     case PERFORM_COMMAND_RESULT_SUCCESS_TYPE:
      log('Perform Command Result Success Type Message');
      break;
     case PERFORM_COMMAND_RESULT_EXCEPTION_TYPE:
      var exceptionCode = parseException(data);
      log('Exception while performing command: id = ' + exceptionCode.toString(16));
      break; 
     case DEVICE_PROTOCOL_VERSION_TYPE:
      parseDevicePrototol(data, function(min, max){
        pltDeviceMinBRVersion = min; 
        pltDeviceMaxBRVersion = max; 
        log('Device supports Bladerunner versions from ' + pltDeviceMinBRVersion + ' to ' + pltDeviceMaxBRVersion); 
      });
      break;
     case METADATA_TYPE:
        parseMetadata(data, function(deviceMetadata){
        //metadata about the devices capabilities
        pltDeviceSupportedCommands = deviceMetadata.supportedCommands;
        pltDeviceSupportedEvents = deviceMetadata.supportedEvents;
        pltDeviceSupportedGetSettings = deviceMetadata.supportedGetSettings;
        
         
        sendEnableTestInterfaceCommand();
        
      });
      break;
     case EVENT_TYPE:
      //parse and handle the event
        parseEvent(data, function(event){
        handleEvent(event)
        log('Event recieved: ' + event.name + ' id = ' + event.id.toString(16));
        
      });
      break;
     case CLOSE_SESSION_TYPE:
      log('Close Session Type Message');
      break;
     case HOST_PROTOCOL_NEGOTIATION_REJECTION_TYPE:
      log('Host Protocol Negotiation Rejection Type Message');
      break;
    default:
      log('Unknown Message Type: ' + messageType);
      break;
   
  }

};

function handleEvent(event){
  if(!event){
    return;
  }
  switch(event.id){
    case WEARING_STATE_CHANGED_EVENT:
      log('Event: ' + event.name + ' worn = ' + event.properties['worn']);
      break;
    case CONNECTED_DEVICE_EVENT:
      log('Event: ' + event.name + ' address = ' + event.properties['address']);
      break;
    case CALL_STATUS_CHANGE_EVENT:
       log('Event: ' + event.name + ' call state = ' + event.properties['callStateName'] + 'phone number' + event.phoneNumber);
       break;
     case RAW_BUTTON_TEST_EVENT:
      log('Event: ' + event.name + ' name = ' + event.properties['buttonName']) ;
      break;
    default:
      break;
  }
}

//Attempts to send a blade runner packet, if error occurs will log it out.
function sendBladerunnerPacket(packet){
  if(!pltSocket){
    log('Packet send fail - socket is null');
    return; 
  }
  
  chrome.bluetooth.write({socket:pltSocket, data:packet},
                         function(bytes) {
                           if (chrome.runtime.lastError) {
                             log('sendBladerunnerPacket write error: ' + chrome.runtime.lastError.message);
                           }
                         });
}

//Handle the device connect event and set up the bladerunner connection and the socket read interval
var onConnectHandler = function(socket) {
  if(socket){  
    log("onConnectHandler - connected to Bladerunner socket");
    connected = true;
    stopReconnects();  
    pltSocket = socket;
    pltReadIntervalId = window.setInterval(function() {
                               chrome.bluetooth.read({socket: pltSocket}, parseBladerunnerData); }, BT_SOCKET_READ_INTERVAL);
    hostNegotiate();    
  } 
  else {
    log("onConnectHandler: failed to connect to socket");
  }
}


//kill the socket connection
var disconnect = function(){
  connected = false;
  if (pltReadIntervalId !== null) {
        clearInterval(pltReadIntervalId);
  }
  if (pltSocket) {
    log("Disconnecting Bladerunner device");
    chrome.bluetooth.disconnect({socket: pltSocket}, function() {
      log("Bladerunner socket closed.");
      pltSocket = null;
    });
  }
};

//main entry for connecting to the device
var findAndConnect = function(){
  if(!connected){
    getBladerunnerDevice(connectToDevice);
  }
};
  

//Function for fetching the bladerunner devicess
var getBladerunnerDevice = function(callback){
  if(connected){
   return; 
  }
  devices = [];
  if(!callback){
    log('No callback specified');
    return;
  }
  log('Searching for Plantronics Bladerunner devices');
  
  chrome.bluetooth.getAdapterState(function(adapterState){
    if(!adapterState.available || !adapterState.powered){
      log('Bluetooth adapter not available');
      callback();
      return;
    }
    chrome.bluetooth.getDevices(
      {deviceCallback: function(device){devices.push(device);}}, callback);
  });
 };
       
//connects to the device if it has the Bladerunner profile     
var connectToDevice = function() {
  if (chrome.runtime.lastError) {
    log('Error searching for a devices: ' + chrome.runtime.lastError.message);
    return;
  }
  if(!devices) {
    startReconnects();
    return;
  }
       
  for(var i in devices){
    var d = devices[i];
    if(d.connected && d.name == PLT_DEVICE_NAME){
        log('Plantronics Bladerunner device found: ' + d.name + ' address: ' + d.address );
        pltDevice = d;
        chrome.bluetooth.connect({device:d , profile: BR_PROFILE}, 
                                 function() {
                                   if (chrome.runtime.lastError){ 
                                     connected = false
                                     console.error("Error connecting to Bladerunner device:", chrome.runtime.lastError.message);
                                   }});
       return;
    }
  }
  
  //no devices found
  startReconnects();
       
};

function stopReconnects(){
  if (connectIntervalId) {
    clearInterval(connectIntervalId);
    connectIntervalId = null;
  }
}

function startReconnects(){
  if(connected || connectIntervalId){
    return; 
  }
  log('No devices found - retry in ' +  PLT_RECONNECT_INTERVAL + 'ms');
  connectIntervalId = window.setInterval(findAndConnect, PLT_RECONNECT_INTERVAL);
  
};

init();
