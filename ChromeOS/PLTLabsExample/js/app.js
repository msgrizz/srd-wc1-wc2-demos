//PLT Labs - Bladerunner Experiment
//Author: Cary Bran
//JS Library to test bladerunner functionality


var jScrollPaneAPI = null;
var eventSubscriptions = [
  PLTLabsMessageHelper.TEST_INTERFACE_ENABLE_DISABLE_EVENT,
  PLTLabsMessageHelper.RAW_BUTTON_TEST_ENABLE_DISABLE_EVENT,
  PLTLabsMessageHelper.WEARING_STATE_CHANGED_EVENT,
  PLTLabsMessageHelper.AUTO_ANSWER_ON_DON_CHANGED_EVENT,
  PLTLabsMessageHelper.WEARING_SENSOR_ENABLE_DISABLE_EVENT,
  PLTLabsMessageHelper.CONFIGURE_SIGNAL_STRENGTH_EVENT,
  PLTLabsMessageHelper.SIGNAL_STRENGTH_EVENT,
  PLTLabsMessageHelper.BATTERY_STATUS_CHANGED_EVENT,
  PLTLabsMessageHelper.PAIRING_MODE_EVENT,
  PLTLabsMessageHelper.LED_ALERT_STATUS_CHANGED,
  PLTLabsMessageHelper.LOW_BATTERY_VOICE_PROMPT_EVENT,
  PLTLabsMessageHelper.CONNECTED_DEVICE_EVENT,
  PLTLabsMessageHelper.DISCONNECTED_DEVICE_EVENT,
  PLTLabsMessageHelper.CALL_STATUS_CHANGE_EVENT,
  PLTLabsMessageHelper.AUDIO_STATUS_EVENT];


function init(){
  setButtonState(false);
  $('#cbButton').click(enableButtonPressEvents);
  $('#cbProximity').click(enableProximity);
 // $('#cbLED').click(enableLED);
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
   $('#butConnect').attr("value", "Connecting");
   $('#butConnect').attr("disabled", true);
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
  $('#butConnect').attr("disabled", false);
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
  var options = new Object();
  options.events = eventSubscriptions;
  PLTLabsAPI.subscribeToEvents(options, onEvent);
  
}
    
function onEvent(info){
   var event = '<span>Event: 0x'+info.id.toString(16) + ' - ' + info.name + '</span>';
    event += '<ul>';
    for(prop in info.properties){
     event += '<li>' + prop + ' = ' + info.properties[prop] + '</li>';
    }
    event += '</ul>';
   l(event); 
}

function enableButtonPressEvents(){
  if (this.checked) {
    eventSubscriptions.push(PLTLabsMessageHelper.BUTTON_EVENT);
  }
  else{
    eventSubscriptions.pop(PLTLabsMessageHelper.BUTTON_EVENT);
  }
  var options = new Object();
  options.events = eventSubscriptions;
  PLTLabsAPI.subscribeToEvents(options, onEvent);
  
}

function enableLED(){
  var options = new Object();
  options.timeout = 1;
  options.enabled = this.checked;
  var packet = PLTLabsMessageHelper.createEnableLEDCommand(options);
  PLTLabsAPI.sendCommand(packet);
}

function enableProximity(){
  var options = new Object();
  if(this.checked){
     options.enabled = true;
  }
  else{
    options.enabled = false;
  }
  for(i = 0; i < PLTLabsAPI.connectedDevices.byteLength; i++){
    if (PLTLabsAPI.connectedDevices[i] == 0x0) {
      continue;
    }
    options.connectionId = PLTLabsAPI.connectedDevices[i];
    var packet = PLTLabsMessageHelper.createEnableProximityCommand(options);
    PLTLabsAPI.sendCommand(packet);
  }
}

init();
