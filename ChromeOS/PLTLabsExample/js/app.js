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
    $('#butConnect').attr("value", "Disconnect");
  }
  else{
    $('#butConnect').click(findPLTDevices);
    $('#butConnect').attr("value", "Connect");
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


init();
