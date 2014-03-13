//PLT Labs - Bladerunner Experiment
//Author: Cary Bran
//JS Library to test bladerunner functionality


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
  PLTLabsMessageHelper.AUDIO_STATUS_EVENT,
  PLTLabsMessageHelper.SUBSCRIBED_SERVICE_DATA_CHANGE_EVENT,
  PLTLabsMessageHelper.SERVICE_CALIBRATION_CHANGE_EVENT,
  PLTLabsMessageHelper.SUBSCRIBED_SERVICE_CONFIG_CHANGE_EVENT];

//Device related variables
var connectedToDevice = false;
var connectedToSensorPort = false;
var connectingToSensorPort = false;
var deviceMetadata = null;
var calibrtionQuaternion = {"w": 1, "x": 0, "y": 0, "z": 0};
var sensorPortAddress = new ArrayBuffer(PLTLabsMessageHelper.BR_ADDRESS_SIZE);
var sensorPortAddress_view = new Uint8Array(sensorPortAddress);
sensorPortAddress_view[0] = 0x50;


//WebRTC variables
var handleId = "Cary";
var calleeId = "Joe";
var server = "10.0.1.51";
var port = "9000";


var peer = null;
var readyForCall = false;
var ringing = false;
var ringtone = new Audio('/media/ringtone.ogg');
ringtone.addEventListener('ended', function() {this.currentTime = 0;if(ringing){this.play();}}); //loop for the ringtone
// Compatibility shim
navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

function init(){
  setPLTCheckboxesState(true);
  readyForCall = false;
  //webrtc stuff
  $('#chkPLTDevice').change(function(){
      if(this.checked){
        findPLTDevices();
      }
      else{
        disconnectPLT();
      }
    }
  );
  $('#chkHT').change(function(){
      enableHeadtracking(this.checked);
  });
  $('#chkTap').change(function(){
      enableTapDetection(this.checked);
  });
  $('#chkFF').change(function(){
      enableFreeFallDetection(this.checked);
  });
  $('#chkPedo').change(function(){
      enablePedometer(this.checked);
  });
  $('#btnCalHeadtracking').click(calHeadset);
  $('#btnResetPedometer').click(resetPedometer);
  $('#butCall').attr("disabled", true);
  $('#btnConnect').click(prepareForWebRTCCall);
  $('#btnCall').click(makeCall);
  $('#btnCall').attr("disabled", false);
  PLTLabsAPI.debug = true;
  PLTLabsAPI.subscribeToDeviceMetadata(onMetadata);
}

//PLTLabs Functions
function findPLTDevices(){
   PLTLabsAPI.findDevices(devicesFound);
   log("findPLTDevices: Searching for PLT Labs devices");
}

function disconnectPLT(){
   PLTLabsAPI.closeConnection(connectionClosed);
   deviceMetadata = null;
   calibrtionQuaternion = {"w": 1, "x": 0, "y": 0, "z": 0};
   connectedToSensorPort = false;
   connectedToDevice = false;
}

function connectionClosed(){
  setPLTCheckboxesState(true);
  log('connectionClosed: PLTLabs device connection closed');
}

function setPLTCheckboxesState(connected){
  
  $('#chkHT').attr("disabled", connected);
  $('#chkTap').attr("disabled", connected);
  $('#chkFF').attr("disabled", connected);
  $('#chkPedo').attr("disabled",connected);
}



function devicesFound(deviceList){
  devices = JSON.parse(JSON.stringify(deviceList));
  var d = deviceList[0];
  PLTLabsAPI.openConnection(d, connectionOpened) 
}

function onMetadata(metadata){
  //l("metadata recieved " + JSON.stringify(metadata));
  deviceMetadata = metadata;
  if (!connectingToSensorPort && !connectedToSensorPort) {
        connectingToSensorPort = true;
        log("onMetadata: connecting to sensor port");
        enableWearableConceptEvents(); 
  }
 // 
}


function connectionOpened(address){
  
  if (address == PLTLabsMessageHelper.SENSOR_PORT) {
    log("connectionOpened: sensor port connection is open!");
     enableWearableConceptEvents();
     connectedToSensorPort = true;
     connectingToSensorPort = false;
     setPLTCheckboxesState(false);
  }
  else if (!connectedToDevice) {
    log('connectionOpened: data connection opened to device');
    var options = new Object();
    options.events = eventSubscriptions;
    PLTLabsAPI.subscribeToEvents(options, onEvent);
    enableButtonPressEvents();
    connectedToDevice = true;
  }
  
  //TODO - UNCOMMENT ME 
  //connectToServer();
}

//PLT checkbox functions 
function enableHeadtracking(on) {
  var mode = on ? PLTLabsMessageHelper.MODE_ON_CHANGE : PLTLabsMessageHelper.MODE_OFF;
  var options = {"mode" : mode, "address" : sensorPortAddress};
  var packet = PLTLabsMessageHelper.createHeadTrackingOnChangeCommand(options);
  log("enableHeadtracking: sending command to " + (on ? " enable " : " disable ") + " headtracking" );
  PLTLabsAPI.sendCommand(packet);
}

function enableFreeFallDetection(on) {
  var mode = on ? PLTLabsMessageHelper.MODE_ON_CHANGE : PLTLabsMessageHelper.MODE_OFF;
  var options = {"mode" : mode, "address": sensorPortAddress}; 
  var packet = PLTLabsMessageHelper.createFreeFallOnChangeCommand(options);
  log("enableFreeFallDetection: sending command to " + (on ? " enable " : " disable ") + " free fall" );
  PLTLabsAPI.sendCommand(packet);
}

function enableTapDetection(on) {
  var mode = on ? PLTLabsMessageHelper.MODE_ON_CHANGE : PLTLabsMessageHelper.MODE_OFF;
  var options = {"mode" : mode, "address": sensorPortAddress}; 
  var packet = PLTLabsMessageHelper.createTapOnChangeCommand(options);
  log("enableTapDetection: sending command to " + (on ? " enable " : " disable ") + " tap detection" );
  PLTLabsAPI.sendCommand(packet);
}

function enablePedometer(on) {
  var mode = on ? PLTLabsMessageHelper.MODE_ON_CHANGE : PLTLabsMessageHelper.MODE_OFF;
  var options = {"mode" : mode, "address": sensorPortAddress}; 
  var packet = PLTLabsMessageHelper.createPedometerOnChangeCommand(options);
  log("enablePedometer: sending command to " + (on ? " enable " : " disable ") + " pedometer" );
  PLTLabsAPI.sendCommand(packet);
}

function resetPedometer(){
  var options = {"serviceId": PLTLabsMessageHelper.PEDOMETER_SERVICE_ID, "address": sensorPortAddress};
  var packet = PLTLabsMessageHelper.createCalibrateCommand(options);
  log("resetPedometer: sending command to reset the pedometer cound" );
  PLTLabsAPI.sendCommand(packet);
}

function calHeadset(){
  var options = {"serviceId": PLTLabsMessageHelper.HEAD_ORIENTATION_SERVICE_ID, "address": sensorPortAddress, "quaternion": calibrtionQuaternion};
  var packet = PLTLabsMessageHelper.createCalibrateCommand(options);
  log("calHeadset: sending packet to headset to calibrate headtracking");
  PLTLabsAPI.sendCommand(packet);
}

//Turns on the WC1's sensor channel - does so by sending a metadata command to port 5
function enableWearableConceptEvents(){
  if (!deviceMetadata) {
    log("enableWearableConceptEvents: no device metadata abondoning efforts to sensor service device features");
    return;
  }
  
  var availablePorts = deviceMetadata.availablePorts;
  if (availablePorts.indexOf(PLTLabsMessageHelper.SENSOR_PORT) < 0) {
     log("enableWearableConceptEvents: device does not support sensor service subscription");
     return;
  }
  
  log("enableWearbleConceptEvents: sending host negotiate to enable concept device services");
  var packet = PLTLabsMessageHelper.createHostNegotiateMessage(sensorPortAddress);
  PLTLabsAPI.sendBladerunnerPacket(packet);  
}

function onEvent(info){
    
   //log("onEvent received: " + info);
   if (info.id == PLTLabsMessageHelper.SUBSCRIBED_SERVICE_DATA_CHANGE_EVENT) {
      switch(info.properties["serviceId"]) {
        case PLTLabsMessageHelper.HEAD_ORIENTATION_SERVICE_ID:
          var q = info.properties["quaternion"];
          var c = convertQuaternianToCoordinates(q); 
          $('#roll').text(c.psi);
          $('#pitch').text(c.theta);
          $('#yaw').text(c.phi);
          calibrtionQuaternion = q;
          break;
        case PLTLabsMessageHelper.TAPS_SERVICE_ID:
          $('#taps').text("X = " + info.properties["x"] + ",Y = " + info.properties["y"]);
          break;
        case PLTLabsMessageHelper.FREE_FALL_SERVICE_ID:
          $('#freefall').text(info.properties["freefall"]);
          break;
        case PLTLabsMessageHelper.PEDOMETER_SERVICE_ID:
          $('#steps').text(info.properties["steps"]);
          break;
        default:
          break;
      }
   }
    
  // if (window.existingDataConnection) {
    //  window.existingDataConnection.send(event);
  // }
   //hook flash button
   if (PLTLabsMessageHelper.BUTTON_EVENT == info.id && info.properties['buttonId'] == 2) {
      if(ringing){
        $('#butAnswerCall').trigger("click");
      }
      else if (window.existingCall) {
        //hang up the call
        $('#btnCall').trigger("click");
      }
   }
}

//converts a quaternion into a set of Euler angles 
function convertQuaternianToCoordinates(q){
  var m22 = (2 * q.w^2) + (2 * q.y^2) - 1;
  var m21 = (2 * q.x * q.y) - (2 * q.w * q.z);
  var m13 = (2 * q.x * q.z) - (2 * q.w * q.y);
  var m23 = (2 * q.y * q.z) + (2 * q.w * q.x);
  var m33 = (2 * q.w^2) + (2 * q.z^2) - 1;
  var r2d = 180 / Math.PI;   // radians to degrees 
  var psi = -r2d * Math.atan2(m21,m22);
  var theta = r2d * Math.asin(m23);
  var phi = -r2d * Math.atan2(m13, m33);
  return {"psi" : Math.round(psi), "theta" : Math.round(theta), "phi" : Math.round(phi)};
}




function enableButtonPressEvents(){
  eventSubscriptions.push(PLTLabsMessageHelper.BUTTON_EVENT);
  var options = new Object();
  options.events = eventSubscriptions;
  PLTLabsAPI.subscribeToEvents(options, onEvent);
  
}
//END PLT FUNCTIONS

///WEBRTC Functions

function prepareForWebRTCCall(){
   $('#btnConnect').attr("value", "Connecting");
   $('#btnConnect').attr("disabled", true);
   
   connectToServer();
  
}

//disconnect from webrtc server
function disconnectWebRTC() {
  if (peer) {
    peer.destroy();
    peer = null;
   }
}

function connectToServer() {
  log('connectToServer: Connecting to WebRTC server');
  //var handleId = $('#txtUserHandle').val();
  //var server = $('#txtServer').val();
  //var portNumber = $('#txtPort').val();
  peer = new Peer(handleId, {"host":server, "port": port, "debug": 3, "config": {'iceServers': [{ url: 'stun:stun.l.google.com:19302' } ]}});

  peer.on('open', function(){
      $('#user-name').text("Connected as " + peer.id);
      $('#btnCall').attr("disabled", false);
      gum();
  });
  
  peer.on('connection', handleDataConnection);
  peer.on('call', ring);
  $('#video-container').show();
  
  peer.on('error', function(err){log('Error connecting to server: ' + err.type);});
}

function handleDataConnection(dataConnection){
  log("handleDataConnection: got a data connection from " + dataConnection.peer + " label = " + dataConnection.label);
  if (window.existingDataConnection) {
    //close any existing calls
    window.existingDataConnection.close();
  }
  dataConnection.on("data", function(data){
   // var event = '<span class="remote-data">Data from :'+ dataConnection.peer + '<br>' + data + '</span>'; 
    //TODO - add logic here for sending/handling webrtc data
    log("onData: from " + dataConnection.peer + " data: " + data);
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
   log('answerCall: answering incoming call from ' + call.peer);
   ringing = false;
   $('#incoming-call').hide();
   
   call.answer(window.localStream);
   if (window.existingCall) {
    //close any existing calls
    window.existingCall.close();
   }
   
   call.on('stream', function(stream){
      $('#btnCall').attr("value", "Hang Up");
      $('#btnCall').click(hangUp);
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
  log('makeCall: calling ' + calleeId);
  var call = peer.call(calleeId, window.localStream);
  if (window.existingCall) {
      window.existingCall.close();
  }

  // Wait for stream on the call, then set peer video display
  call.on('stream', function(stream){
    $('#btnCall').attr("value", "Hang Up");
    $('#btnCall').click(hangUp);
    $('#remote-video').prop('src', URL.createObjectURL(stream));
    //set up the data channel
    var dataConnection = peer.connect(call.peer, { label: 'device-events' });
    dataConnection.on('open', function() {
        handleDataConnection(dataConnection);
      });
    dataConnection.on('error', function(err) { log(err); });
  });

  // UI stuff
  window.existingCall = call;
  call.on('close', resetButtonsAfterWebRTCCall);

}

function hangUp(){
  window.existingCall.close();
  resetButtonsAfterWebRTCCall();
  
}

function gum (initiator) {
            // Get audio/video stream
            navigator.getUserMedia({audio: true, video: true},
                                   function(stream){
                                    // Set your video displays
                                    log("gum: GUM returned successfuly");
                                    $('#local-video').prop('src', URL.createObjectURL(stream));
                                    window.localStream = stream;
                                    readyForCall = true;
                                    //setButtonState(true);
                                    $('#btnConnect').attr("value", "Disconnect");
                                    $('#btnConnect').attr("disabled", false);
                                    $('#btnConnect').click(disconnectWebRTC);
                                     
                                    },
                                    function(error){ log(error); });
            
}

function resetButtonsAfterWebRTCCall(){
  log('resetButtonsAfterWebRTCCall: call has ended');
  ringing = false;
  $('#btnCall').attr("value", "Call");
  $('#btnCall').attr("disabled", true);
  $('#btnCall').click(makeCall);
  $('#remote-video').prop('src', "");
}
//END WEBRTC FUNCTIONS

init();
