//PLT Labs - Bladerunner Experiment
//Author: Cary Bran
//JS Library to test bladerunner functionality

var PLT_DEVICE_NAME = 'PLT_Legend';

var BT_SOCKET_READ_INTERVAL = 10;


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


var hostNegotiate = function(){
  if(!pltSocket){
    return; 
  }
   /*Host Negotiate Command - 0X10
                             -0X07
                             -0X00
                             -0X00
                             -0X00
                             -0X01
                             -0X01
                             -0X01
                             -0X00
                             
                             */
    var buffer = new ArrayBuffer(9);
    buffer[0] = 0X10;
    buffer[1] = 0X07;
    buffer[2] = 0X00;
    buffer[3] = 0X00;
    buffer[4] = 0X00;
    buffer[5] = 0X01;
    buffer[6] = 0X01;
    buffer[7] = 0X00;
    buffer[8] = 0X00;
  
  
    chrome.bluetooth.write({socket:pltSocket, data:buffer},
        function(bytes) {
          if (chrome.runtime.lastError) {
            log('Write error: ' + chrome.runtime.lastError.message);
          } else {
            log('wrote ' + bytes + ' bytes');
             chrome.bluetooth.read({socket: pltSocket}, parseBladerunnerData);
          }
        });};

//Handle the device connect
var onConnectHandler = function(socket) {
  log("onConnectHandler - socket = " + socket);
   //if we get a socket then set up the read function to check for data every 500 milliseconds 
  if (socket) {
        pltSocket = socket;
       hostNegotiate();
       
        
  } else {
        log("Failed to connect to socket");
  }
}

var parseBladerunnerData = function(data){
  if(!data){
    return; 
  }
      log("gonna parse me some bladerunner data: " + data.byteLength);
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
    log('Searching for BladeRunner Devices');
     
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
    log(' device found: ' + d.name + ' address: ' + d.address + ' connected: ' + d.connected );
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
