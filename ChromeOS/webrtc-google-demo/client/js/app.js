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

var connectedToPlantronics = false;

var peer = null;
var readyForCall = false;
var ringing = false;
var ringtone = new Audio('/media/ringtone.ogg');
ringtone.addEventListener('ended', function() {this.currentTime = 0;if(ringing){this.play();}}); //loop for the ringtone
// Compatibility shim
navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

function init(){
  setButtonState(false);
  readyForCall = false;
  //webrtc stuff
  $('#butCall').attr("disabled", true);
  $('#butConnect').attr("disabled", true);
  $('#butCall').click(makeCall);
  $('#txtCallerId').keyup(function() {
        if($(this).val() != '') {
           $('#butCall').attr("disabled", false);
        }
        else{
          $('#butCall').attr("disabled", true);
        }
     });
  $('#txtUserHandle').keyup(function() {
        var server = $('#txtServer').val();
        var port = $('#txtPort').val();
        if($(this).val() != '' && server != '' && port != '') {
           $('#butConnect').attr("disabled", false);
        }
        else{
          $('#butConnect').attr("disabled", true);
        }
     });
  
   $('#txtServer').keyup(function() {
        var userHandle = $('#txtUserHandle').val();
        var port = $('#txtPort').val();
        if($(this).val() != '' && userHandle != '' && port != '') {
           $('#butConnect').attr("disabled", false);
        }
        else{
          $('#butConnect').attr("disabled", true);
        }
     });
   
    $('#txtPort').keyup(function() {
        var server =  $('#txtServer').val();
        var userHandle = $('#txtUserHandle').val();
        if($(this).val() != '' && server != '' && userHandle != '') {
           $('#butConnect').attr("disabled", false);
        }
        else{
          $('#butConnect').attr("disabled", true);
        }
     });
 
  jScrollPaneAPI =  $('#logHolder').jScrollPane({
            verticalDragMinHeight: 12,
            verticalDragMaxHeight: 12
        }).data('jsp');

  PLTLabsAPI.debug = true;
  
  

}

function connectToServer() {
  l('Connecting to WebRTC server');
  var handleId = $('#txtUserHandle').val();
  var server = $('#txtServer').val();
  var portNumber = $('#txtPort').val();
  peer = new Peer(handleId, {host:server, port: portNumber, debug: 3, config: {'iceServers': [{ url: 'stun:stun.l.google.com:19302' } ]}});

  peer.on('open', function(){
      $('#user-name').text("Connected as " + peer.id);
      gum();
  });
  
  peer.on('connection', handleDataConnection);
  peer.on('call', ring);
  $('#video-container').show();
  
  
  peer.on('error', function(err){l('Error connecting to server: ' + err.type);});
}

function handleDataConnection(dataConnection){
  l("got a data connection from " + dataConnection.peer + " label = " + dataConnection.label);
  if (window.existingDataConnection) {
    //close any existing calls
    window.existingDataConnection.close();
  }
  dataConnection.on("data", function(data){
    var event = '<span class="remote-data">Data from :'+ dataConnection.peer + '<br>' + data + '</span>'; 
    l(event);
  });
   
  window.existingDataConnection = dataConnection;
}


function ring(call){
  ringing = true;
  $('#incoming-call').find('h3').text('Incoming call from ' + call.peer);
  $('#butAnswerCall').click(function(){
    answerCall(call);
    $('#incoming-call').hide();
  })
  $('#incoming-call').show();
  ringtone.play();
  $('html, body').animate({scrollTop: $("#incoming-call").offset().top - 40}, 500);
}


function answerCall(call){
   l('Answering incoming call from ' + call.peer);
   ringing = false;
   $('#incoming-call').hide();
   
   call.answer(window.localStream);
   if (window.existingCall) {
    //close any existing calls
    window.existingCall.close();
   }
   
   call.on('stream', function(stream){
      $('#butCall').attr("value", "Hang Up");
      $('#butCall').click(hangUp);
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
  l('Calling ' + userId);
  var call = peer.call(userId, window.localStream);
  if (window.existingCall) {
      window.existingCall.close();
  }

  // Wait for stream on the call, then set peer video display
  call.on('stream', function(stream){
    $('#butCall').attr("value", "Hang Up");
    $('#butCall').click(hangUp);
    $('#remote-video').prop('src', URL.createObjectURL(stream));
    //set up the data channel
    var dataConnection = peer.connect(call.peer, { label: 'device-events' });
    dataConnection.on('open', function() {
        handleDataConnection(dataConnection);
      });
    dataConnection.on('error', function(err) { l(err); });
  });

  // UI stuff
  window.existingCall = call;
  call.on('close', resetButtonsAfterWebRTCCall);

}

function hangUp(){
  window.existingCall.close();
  resetButtonsAfterWebRTCCall;
  
}

function resetButtonsAfterWebRTCCall(){
  l('call has ended');
  ringing = false;
  $('#butCall').attr("value", "Call");
  $('#butCall').click(makeCall);
  $('#txtCallerId').attr("disabled", false);
  $('#remote-video').prop('src', "");
}


function gum (initiator) {
            // Get audio/video stream
            navigator.getUserMedia({audio: true, video: true},
                                   function(stream){
                                    // Set your video displays
                                    l("GUM returned successfuly");
                                    $('#local-video').prop('src', URL.createObjectURL(stream));
                                    window.localStream = stream;
                                    readyForCall = true;
                                    setButtonState(true);
                                    $('#butConnect').attr("disabled", false);
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
   PLTLabsAPI.findDevices(devicesFound);
   l("Searching for PLT Labs devices");
}

function disconnect(){
   PLTLabsAPI.closeConnection(connectionClosed);
   if (peer) {
    peer.destroy();
    peer = null;
   }
   resetButtonsAfterWebRTCCall();
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
    $('#butConnect').click(prepareForWebRTCCall);
    $('#butConnect').attr("value", "Connect");
  }
}

function prepareForWebRTCCall(){
   $('#butConnect').attr("value", "Connecting");
   $('#butConnect').attr("disabled", true);
   
  if ($("#chkPLTDevice").prop("checked")) {
      findPLTDevices();
  }
  else{
    connectToServer();
  }
  
}

function devicesFound(deviceList){
  devices = JSON.parse(JSON.stringify(deviceList));
  var d = deviceList[0];
  PLTLabsAPI.openConnection(d, connectionOpened) 
}

function connectionOpened(address){
  l('Data connection opened to PLTLabs device');
  var options = new Object();
  options.events = eventSubscriptions;
  PLTLabsAPI.subscribeToEvents(options, onEvent);
  enableButtonPressEvents();
 // enableProximity();
  connectToServer();
}
    
function onEvent(info){
   var event = '<span>Event: 0x'+info.id.toString(16) + ' - ' + info.name + '</span>';
    event += '<ul>';
    for(prop in info.properties){
     event += '<li>' + prop + ' = ' + info.properties[prop] + '</li>';
    }
    event += '</ul>';
    
   l(event);
   if (window.existingDataConnection) {
    window.existingDataConnection.send(event);
   }
   
   //hook flash button
   if (PLTLabsMessageHelper.BUTTON_EVENT == info.id && info.properties['buttonId'] == 2) {
      if(ringing){
        $('#butAnswerCall').trigger("click");
      }
      else if (window.existingCall) {
        //hang up the call
        $('#butCall').trigger("click");
      }
   }
}

function enableButtonPressEvents(){
  eventSubscriptions.push(PLTLabsMessageHelper.BUTTON_EVENT);
  var options = new Object();
  options.events = eventSubscriptions;
  PLTLabsAPI.subscribeToEvents(options, onEvent);
  
}

function enableProximity(){
  var options = new Object();
  options.enabled = true;
  
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
