//PLT Labs - Bladerunner Experiment
//Author: Cary Bran
//JS Library to test bladerunner functionality


var jScrollPaneAPI = null;
function init(){
  setButtonState(false);
  jScrollPaneAPI =  $('#logHolder').jScrollPane({
            verticalDragMinHeight: 12,
            verticalDragMaxHeight: 12
        }).data('jsp');

  PLTLabsAPI.debug = true;
}

function l(msg) {
  var msg_str = (typeof(msg) == 'object') ? JSON.stringify(msg) : msg;
  var logEntry = '<div class="logEntry"><span>' + msg_str + '</span></div>';
  jScrollPaneAPI.getContentPane().append(logEntry);
  jScrollPaneAPI.reinitialise();
  jScrollPaneAPI.scrollToBottom(true);
}

function findPLTDevices(){
   PLTLabsAPI.findDevices(devicesFound);
}

function disconnect(){
   PLTLabsAPI.closeConnection(connectionClosed); 
}

function connectionClosed(){
  setButtonState(false);
  l('PLTLabs device connection closed');
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
  
  devices = JSON.parse(JSON.stringify(deviceList));
  for(i = 0; i < devices.length; i ++ ){
    l('PLTLabs device found ' + JSON.stringify(devices[i]));
  } 
  
  var d = deviceList[0];
  l('Opening connection to device ' +  JSON.stringify(d));
 
  PLTLabsAPI.openConnection(d, connectionOpened) 
}

function connectionOpened(address){
 
  setButtonState(true);
  
  var events = [PLTLabsMessageHelper.BUTTON_EVENT];
  var options = new Object();
  options.events = events;
  
  
  PLTLabsAPI.subscribeToEvents(options, onEvent);
  
}
    
function onEvent(info){
   var event = 'Event: 0x'+info.id.toString(16);
   l(event); 
}


init();
