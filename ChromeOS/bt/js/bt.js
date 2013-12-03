//PLT Labs - Bladerunner Experiment
//Author: Cary Bran
//JS Library to test bladerunner functionality

var PLT_DEVICE_NAME = 'PLT_Legend';

var BT_SOCKET_READ_INTERVAL = 10;
var BR_MIN_PACKET_SIZE = 4;
var BR_SEQUENCE_OFFSET = 2;


var pltDevice;
var pltSocket = null;
var pltReadIntervalId = null; 
var devices = [];
var isConnected = false;

function log(msg) {
  var msg_str = (typeof(msg) == 'object') ? JSON.stringify(msg) : msg;
  console.log(msg_str);
  var l = document.getElementById('log');
  if (l) {
    l.innerText += msg_str + '\n';
  }
}

function init(){
  $('#butDisconnect').click(disconnect);
  $('#butConnect').click(findAndConnect);
  
  //$('#butDisconnect').prop('disabled', true);
  
  // Add the listener to deal with our initial connection
  chrome.bluetooth.onConnection.addListener(onConnectHandler);
  
  log('Starting PLTLabs demo...');
  
  findAndConnect();
}

//Responsible for the initial handshake with the Bladerunner device
//sends a 9-byte U8 array to the device after the profile has been negotiated and the 
//connection established.  The host negotiate packet is needed to start the flow of contextual data
//to and from the device
//
//The packet looks like this in byte array form:
//-0X10
//-0X07
//-0X00
//-0X00
//-0X00
//-0X01
//-0X01
//-0X01
//-0X00
var hostNegotiate = function(){
    var buffer = new ArrayBuffer(9);
    var view = new Uint8Array(buffer);
    view[0] = 0X10;
    view[1] = 0X7;
    view[5] = 0X1;
    view[6] = 0X1;
    view[7] = 0X1;
    log('sending host negotiate');
    sendBladerunnerPacket(buffer);   
}

var parseBladerunnerData = function(data){
  if(!data||data.byteLength < BR_MIN_PACKET_SIZE){
   return;
  }
  
  var data_view = new Uint8Array(data, 0);
  var packetType = data_view[0] >>4;
  var messageType = data_view[5];
  var length = data_view[1];
  //todo document magic numbers
 // var bladerunnerMessageLength = ((data_view[2] & 0x0f) << 8) + data_view[3] + 2;
  var buffer = new ArrayBuffer(length);
  var bladerunnerMessage = new Uint8Array(buffer);
  
   
  //more magic numbers here
  //for(var count = 0; count < (63 - BR_SEQUENCE_OFFSET) && count < length; count++){
  //  bladerunnerMessage[count] = data_view[count +  BR_SEQUENCE_OFFSET];
 // }
  
  log("Bladerunner data: packetType = " + packetType + ", length = " + length + " message type = " + messageType);
 
};


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
  log("Disconnecting");
  if (pltReadIntervalId !== null) {
        clearInterval(pltReadIntervalId);
  }
  if (pltSocket) {
        log("Disconnecting Bladerunner socket");
    chrome.bluetooth.disconnect({socket: pltSocket}, function() {
        log("Socket closed.");
        pltSocket = null;
    });
  }
};

var findAndConnect = function(){
  getBladerunnerDevice(connectToDevice);
};

//Function for fetching the bladerunner devicess
var getBladerunnerDevice = function(callback){
    devices = [];
    if(!callback){
        log('No callback specified');
        return;
    }
    log('Searching for Bladeurnner Devices');
     
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
    log('Error searching for a device to connect to.');
    return;
  }
  if (!devices) {
    log('No devices found to connect to.');
    return;
  }
       
  for(var i in devices){
    var d = devices[i];
    if(d.connected && d.name == PLT_DEVICE_NAME){
        log(' device found: ' + d.name + ' address: ' + d.address );
        pltDevice = d;
        chrome.bluetooth.connect({device:d , profile: BR_PROFILE}, 
                                function() {
                                if (chrome.runtime.lastError) {
                                    console.error("Error on connection.", chrome.runtime.lastError.message);
                                }
    });
       return;
    }
  }   
       
};

init();
