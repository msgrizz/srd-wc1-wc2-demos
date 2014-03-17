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
//var calibrtionQuaternion = {"w": 1, "x": 0, "y": 0, "z": 0};
var lastQuaternion = [1, 0, 0, 0]
var calibrtionQuaternion = [1, 0, 0, 0];
var sensorPortAddress = new ArrayBuffer(PLTLabsMessageHelper.BR_ADDRESS_SIZE);
var sensorPortAddress_view = new Uint8Array(sensorPortAddress);
sensorPortAddress_view[0] = 0x50;


//WebRTC variables
var handleId = "Cary";
var calleeId = "Joe";
var port = "9000";

//Street view GPS coordinates
var locationMatrix = [[47.608589,-122.340437, "Pike Place Market"],
[33.799242,-78.737483, "Alligator Adventure"],
[40.758911,-73.984853, "Times Square"]];


var peer = null;
var readyForCall = false;
var ringing = false;
var ringtone = new Audio('/media/ringtone.ogg');
ringtone.addEventListener('ended', function() {this.currentTime = 0;if(ringing){this.play();}}); //loop for the ringtone

var sendHeadtrackingData = false;
var currentGPSIndex = null;

// Compatibility shim
navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;




function multipliedQuaternions(q, p) {

  var mulQuat = [0, 0, 0, 0];
  var m = [p[0], p[1], p[2], p[3]];
    
    var quatmat = 
    [ [ p[0], -p[1], -p[2], -p[3] ],
      [ p[1], p[0], -p[3], p[2] ],
      [ p[2], p[3], p[0], -p[1] ],
      [ p[3], -p[2], p[1], p[0] ]
    ];
    
    for (var i = 0; i < 4; i++) {
        for (var j = 0; j < 4; j++) {
            //double *qq = (double *)&q;
            mulQuat[i] += quatmat[i][j] * q[j];
        }
    }
    
    return [ mulQuat[0], mulQuat[1], mulQuat[2], mulQuat[3] ];
}

function inverseQuaternion(q) {

  return [q[0], -q[1], -q[2], -q[3]];
}




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
  $('#chkSendCoordinates').attr("disabled", true);
  $('#chkSendCoordinates').change(function(){
    sendGPSToPeer(this.checked);
  });
  $('#coordinates').attr("disabled", true);
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
  $('#btnCall').attr("disabled", true);
  $('#btnCall').click(makeCall);
  $('#btnHangUp').attr("disabled", true);
  $('#btnHangUp').click(hangUp);
  $('#btnHangUp').hide();
  
 $("input[name='server']").click(function(){
		connectToServer(this.value);
		this.disabled = true;
		});
  PLTLabsAPI.debug = true;
  PLTLabsAPI.subscribeToDeviceMetadata(onMetadata);
}

//PLTLabs Functions
function findPLTDevices(){
  log("findPLTDevices: Searching for PLT Labs devices");
  PLTLabsAPI.findDevices(devicesFound);

}

function disconnectPLT(){
 PLTLabsAPI.closeConnection(connectionClosed);
 deviceMetadata = null;
 lastQuaternion = [1, 0, 0, 0];
 calibrtionQuaternion = [1, 0, 0, 0];
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
  log('devices have been found!');
  devices = JSON.parse(JSON.stringify(deviceList));
  for(i = 0; i < deviceList.length; i++){
    var d = deviceList[i];
    log('Device ' + i + ' + : ' + d.name);
    //if(d.connected == true && d.name == "PLT_WC1"){
    if(d.connected == true && d.name.indexOf("PLT_WC1") != -1) {
      log('using: ' + d.name);
      PLTLabsAPI.openConnection(d, connectionOpened);
      break;
    }
  }
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


  calibrtionQuaternion = lastQuaternion;
  // var options = {"serviceId": PLTLabsMessageHelper.HEAD_ORIENTATION_SERVICE_ID, "address": sensorPortAddress, "quaternion": calibrtionQuaternion};
  // var packet = PLTLabsMessageHelper.createCalibrateCommand(options);
  // log("calHeadset: sending packet to headset to calibrate headtracking");
  // PLTLabsAPI.sendCommand(packet);
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
   if (info.id == PLTLabsMessageHelper.SUBSCRIBED_SERVICE_DATA_CHANGE_EVENT) {
    switch(info.properties["serviceId"]) {
      case PLTLabsMessageHelper.HEAD_ORIENTATION_SERVICE_ID:

      var q = info.properties["quaternion"];
      lastQuaternion = [q['w'], q['x'], q['y'], q['z']];

      var c = convertQuaternianToCoordinates(q); 
      $('#roll').text(c.roll);
      $('#pitch').text(c.pitch);
      $('#heading').text(c.heading);
      sendHeadTrackingCoordinatesToPeer(c);   
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
  if(info.id == PLTLabsMessageHelper.WEARING_STATE_CHANGED_EVENT){
    var state = info.properties['worn'] ? "On" : "Off";
     $('#dondoff').text(state);
  }
  if(info.id == PLTLabsMessageHelper.BUTTON_EVENT){
    $('#buttons').text(info.properties['buttonName']);
  }

  // hook flash button
  if (PLTLabsMessageHelper.BUTTON_EVENT == info.id && info.properties['buttonId'] == 2) {
    if(ringing){
      $('#btnCall').trigger("click");
    }
    else if (window.existingCall) {
        //hang up the call
        $('#btnHangUp').trigger("click");
      }
    }
  }


// Pass the obj.quaternion that you want to convert here:
//*********************************************************
function quatToEuler (q1) {
  var pitchYawRoll = {"x":0, "y":0, "z":0};
     sqw = q1.w*q1.w;
     sqx = q1.x*q1.x;
     sqy = q1.y*q1.y;
     sqz = q1.z*q1.z;
     unit = sqx + sqy + sqz + sqw; // if normalised is one, otherwise is correction factor
     test = q1.x*q1.y + q1.z*q1.w;
    if (test > 0.499*unit) { // singularity at north pole
        heading = 2 * Math.atan2(q1.x,q1.w);
        attitude = Math.PI/2;
        bank = 0;
        //return;
    }
    if (test < -0.499*unit) { // singularity at south pole
        heading = -2 * Math.atan2(q1.x,q1.w);
        attitude = -Math.PI/2;
        bank = 0;
        //return;
    }
    else {
        heading = Math.atan2(2*q1.y*q1.w-2*q1.x*q1.z , sqx - sqy - sqz + sqw);
        attitude = Math.asin(2*test/unit);
        bank = Math.atan2(2*q1.x*q1.w-2*q1.y*q1.z , -sqx + sqy - sqz + sqw)
    }
    pitchYawRoll.z = Math.floor(attitude * 1000) / 1000;
    pitchYawRoll.y = Math.floor(heading * 1000) / 1000;
    pitchYawRoll.x = Math.floor(bank * 1000) / 1000;

    return pitchYawRoll;
}        

// Then, if I want the specific yaw (rotation around y), I pass the results of
// pitchYawRoll.y into the following to get back the angle in radians which is
// what can be set to the object's rotation.

//*********************************************************
function eulerToAngle(rot) {
    var ca = 0;
    if (rot > 0)
        { ca = (Math.PI*2) - rot; } 
    else 
        { ca = -rot }

    return Math.round((ca / ((Math.PI*2)/360)));  // camera angle radians converted to degrees
}


//converts a quaternion into a set of Euler angles 
function convertQuaternianToCoordinates(q){
  
  var p = quatToEuler(q);
  log("q2e -> " + JSON.stringify(p));
  //var pitch = eulerToAngle(p.x);
  pitch = convertToPitch(q);
  return {"pitch" :pitch, "roll" :eulerToAngle(p.z), "heading" : eulerToAngle(p.y)};
}

//I am sure there is a more elegant way to do this - but hack it is
function convertToPitch(q){
  var p = (2 * q.y * q.z) + (2 * q.w * q.x);
  var r2d = 180 / Math.PI;   // radians to degrees 
  var pitch = r2d * Math.asin(p);
  return Math.round(pitch);//{"psi" : Math.round(psi), "theta" : Math.round(theta), "phi" : Math.round(phi)};
  
}

function enableButtonPressEvents(){
  eventSubscriptions.push(PLTLabsMessageHelper.BUTTON_EVENT);
  var options = new Object();
  options.events = eventSubscriptions;
  PLTLabsAPI.subscribeToEvents(options, onEvent);
  
}
//END PLT FUNCTIONS



//disconnect from webrtc server
function disconnectWebRTC() {
  log('disconnectWebRTC: disconnecting');
  
  if (peer) {
    peer.disconnect();
    peer = null;
    
  }
}

function connectToServer(server) {
  log('connectToServer: Connecting to WebRTC server');
  peer = new Peer(handleId, {"host":server, "port": port, "debug": 3, "config": {'iceServers': [{ url: 'stun:stun.l.google.com:19302' } ]}});

  peer.on('open', function(){
    $('#user-name').text("Connected as " + peer.id);
    $('#btnCall').attr("disabled", false);
    gum();
  });
  
  peer.on('connection', handleDataConnection);
  peer.on('call', ring);
  
  peer.on('error', function(err){log('Error connecting to server: ' + err.type);});
}

//sends headtracking coordinates
function sendHeadTrackingCoordinatesToPeer(eularAngles){
  if(!sendHeadtrackingData || !window.existingDataConnection){
    return;
  }
  var ht = {'id': "ht" ,'p':eularAngles.pitch,'h':eularAngles.heading};
  window.existingDataConnection.send(JSON.stringify(ht));
}

//Sends the GPS coodrinages 
function sendGPSToPeer(sendData){
  if (!window.existingDataConnection) {
    sendHeadtrackingData = false;
    log("sendGPSToPeer: no data connection to send GPS to - returning");
    return;
  }
  if(!sendData){
    //send command to disable streaming of data if the data channel is open
    sendHeadtrackingData;
    currentGPSIndex = null;
  }
  else{
    var gpsIndex = $("#coordinates option:selected").val();
    if(currentGPSIndex == gpsIndex){
        //nothing to do so return
        return;
      }
      currentGPSIndex = gpsIndex;
      var location = locationMatrix[currentGPSIndex];
      var gpsMessage = {"id":"gps","lat":location[0], "long": location[1], "description": location[2]};
      log('sendGPSToPeer: sending GPS for ' + gpsMessage.description + ' to peer');

      window.existingDataConnection.send(JSON.stringify(gpsMessage));
    }

  }

  function handleDataConnection(dataConnection){
    log("handleDataConnection: got a data connection from " + dataConnection.peer + " label = " + dataConnection.label);
    if (window.existingDataConnection) {
    //close any existing calls
    window.existingDataConnection.close();
  }
  dataConnection.on("data", function(data){
    var msg = JSON.parse(data);
    if(msg.id == "gpsSet"){
      sendHeadtrackingData = true;
    }
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
  call.on('stream', onStream);
  
  call.on('close', resetButtonsAfterWebRTCCall);
  
  window.existingCall = call;
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
    onStream(stream);
    //set up the data channel
    log("setting up data connection for " + call.peer);
    var dataConnection = peer.connect(call.peer);
    dataConnection.on('open', function() {
      log("data connection has been opened");
      handleDataConnection(dataConnection);
    });
    dataConnection.on('error', function(err) { log(err); });
  });

  call.on('close', resetButtonsAfterWebRTCCall);
  // UI stuff
  window.existingCall = call;

}

//when a stream comes in
function onStream(stream){
  $('#chkSendCoordinates').attr("disabled", false);
    $('#coordinates').attr("disabled", false);
    $('#btnCall').attr("disabled",true);
    $('#btnCall').hide();
    $('#btnHangUp').show();
    $('#btnHangUp').attr("disabled", false);
    $('#remote-video').prop('src', URL.createObjectURL(stream));
    $('#video-container').show();
}

function hangUp(){
  window.existingCall.close();
}

function gum (initiator) {
            // Get audio/video stream
            navigator.getUserMedia({audio: true, video: true},
             function(stream){
                                    // Set your video displays
                                    log("gum: GUM returned successfuly");
                                    window.localStream = stream;
                                    readyForCall = true;
                                  },
                                  function(error){
                                    log(error);
                                  });
}

function resetButtonsAfterWebRTCCall(){
  log('resetButtonsAfterWebRTCCall: call has ended');
  ringing = false;
  $('#btnHangUp').attr("disabled", true);
  $('#btnHangUp').hide();
  $('#btnCall').show();
  $('#btnCall').attr("disabled", false);
  $('#chkSendCoordinates').attr("disabled", true);
  $('#coordinates').attr("disabled", true);
  $('#remote-video').prop('src', "");
  $('#video-container').hide();
}
//END WEBRTC FUNCTIONS

init();
