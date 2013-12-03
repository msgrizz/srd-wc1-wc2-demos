//PLT Labs - Bladerunner Experiment
//Author: Cary Bran
//JS Library to test bladerunner functionality

function l(msg) {
  var msg_str = (typeof(msg) == 'object') ? JSON.stringify(msg) : msg;
  console.log(msg_str);
  var l = document.getElementById('log');
  if (l) {
    l.innerText = msg_str + '\n' + l.innerText;
  }
}

function init(){
  setButtonState(false);
 // $('#butTI').click(sendEnableTestInterfaceCommand);
//  $('#butButtonEvents').click(sendEnableButtonsCommand);
  
  
  PLTLabsAPI.debug = true;
}

function findPLTDevices(){
   PLTLabsAPI.findDevices(devicesFound);
}

function disconnect(){
   PLTLabsAPI.closeConnection(connectionClosed); 
}

function connectionClosed(){
  setButtonState(false);
  l('connection closed');
}

function setButtonState(connected){
  if (connected) {
    $('#butConnect').click(disconnect);
    $('#butDisconnect').attr("value", "Disconnect");
  }
  else{
     $('#butConnect').click(findPLTDevices);
    $('#butDisconnect').attr("value", "Connect");
  }
}

function devicesFound(deviceList){
  l('devices found: ' + deviceList.length); 
  if(deviceList.length == 0){
    return;
  }
  
  devices = JSON.parse(JSON.stringify(deviceList));
  for(i = 0; i < devices.length; i ++ ){
    l('PLTLabs device found ' + JSON.stringify(devices[i]));
  } 
  
  var d = deviceList[0];
  l('opening connection to device ' +  JSON.stringify(d));
 
  PLTLabsAPI.openConnection(d, connectionOpened) 
}

function connectionOpened(address){
 
  setButtonState(true);
  
  l('got a connected callback, api connected =  ' + PLTLabsAPI.connected + ' address = ' + address);
  
  l('subscribing to PLT Labs services');
  var events = [PLTLabsMessageHelper.BUTTON_EVENT];
  var options = new Object();
  options.events = events;
  
  
  PLTLabsAPI.subscribeToEvents(options, onEvent);
  
}
    
function onEvent(info){
    l('event happened - info = ' + JSON.stringify(info));
}

/*

//Responsible for the initial handshake with the Bladerunner device
//sends a 9-byte U8 array to the device after the profile has been negotiated and the 
//connection established.  The host negotiate packet is needed to start the flow of contextual data
//to and from the device
//
var hostNegotiate = function(){
  var packet = createHostNegotiateMessage();
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

};*/

/*
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
*/





init();
