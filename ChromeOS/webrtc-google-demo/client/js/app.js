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

var peer = null;
var readyForCall = false;
var ringing = false;
var ringtone = new Audio('/media/ringtone.ogg');
ringtone.addEventListener('ended', function() {this.currentTime = 0;this.play();}); //loop for the ringtone
// Compatibility shim
navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;


function init(){
  setButtonState(false);
  readyForCall = false;
  //webrtc stuff
  $('#butCall').attr("disabled", true);
  $('#butCall').click(makeCall);
  $('#butConnectWebRTC').click(connectToServer);
  $('#txtCallerId').keyup(function() {
        if($(this).val() != '') {
           $('#butCall').attr("disabled", false);
        }
        else{
          $('#butCall').attr("disabled", true);
        }
     });
  $('#cbButton').click(enableButtonPressEvents);
  $('#cbProximity').click(enableProximity);
  
 // $('#cbLED').click(enableLED);
  jScrollPaneAPI =  $('#logHolder').jScrollPane({
            verticalDragMinHeight: 12,
            verticalDragMaxHeight: 12
        }).data('jsp');

  PLTLabsAPI.debug = true;
  
  

}

function connectToServer() {
  var handleId = $('#txtUserHandle').val();
  var server = $('#txtServer').val();
  var portNumber = $('#txtPort').val();
  peer = new Peer(handleId, {host:server, port: portNumber, debug: 3, config: {'iceServers': [{ url: 'stun:stun.l.google.com:19302' } ]}});

  peer.on('open', function(){
      $('#user-name').text(peer.id);
  });
  
  peer.on('call', ring);
  $('#video-container').show();
    
  gum();
  
}

function ring(call){
  ringing = true;
  $('#incoming-call').find('h3').text('Incoming call from ' + call.peer);
  $('#butAnswerCall').click(function(){
    answerCall(call);
  })
  $('#incoming-call').show();
  ringtone.play();
  $('html, body').animate({scrollTop: $("#incoming-call").offset().top - 40}, 500);
}


function answerCall(call){
   l('answerCall: incoming call');
   ringing = false;
   ringtone.pause();
   $('#incoming-call').hide();
   
   call.answer(window.localStream);
   if (window.existingCall) {
    //close any existing calls
    window.existingCall.close();
   }
   
   call.on('stream', function(stream){
      $('#remote-video').prop('src', URL.createObjectURL(stream));
   });
   window.existingCall = call;
   call.on('close', resetButtonsAfterWebRTCCall);
}

function makeCall() {
  if (!readyForCall) {
    return;
  }
  // Initiate a call
  var userId = $('#txtCallerId').val();
  $('#txtUserId').attr("disabled", true);
  
  var call = peer.call(userId, window.localStream);
  if (window.existingCall) {
      window.existingCall.close();
  }

  // Wait for stream on the call, then set peer video display
  call.on('stream', function(stream){
    $('#butCall').attr("value", "Hang Up");
    $('#butCall').click(hangUp);
    $('#remote-video').prop('src', URL.createObjectURL(stream));
  });

  // UI stuff
  window.existingCall = call;
  //$('#their-id').text(call.peer);
  call.on('close', resetButtonsAfterWebRTCCall);
//  $('#step1, #step2').hide();
 // $('#step3').show();
}

function hangUp(){
  window.existingCall.close();
  resetButtonsAfterWebRTCCall;
  
}

function resetButtonsAfterWebRTCCall(){
  ringing = false;
  ringtone.pause();
  $('#butCall').attr("value", "Call");
  $('#butCall').click(makeCall);
  $('#txtCallerId').attr("disabled", false);
}


function gum (initiator) {
            // Get audio/video stream
            navigator.getUserMedia({audio: true, video: true},
                                   function(stream){
                                    // Set your video displays
                                    l("setting up local video");
                                    $('#local-video').prop('src', URL.createObjectURL(stream));
                                    window.localStream = stream;
                                    readyForCall = true;
                                    },
                                    function(error){ l(error); });
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
   
   if (PLTLabsMessageHelper.BUTTON_EVENT == info.id && ringing) {
    $('#butAnswerCall').trigger("click");
   }
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
