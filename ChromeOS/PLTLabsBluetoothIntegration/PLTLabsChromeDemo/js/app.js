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
PLTLabsMessageHelper.SUBSCRIBED_SERVICE_CONFIG_CHANGE_EVENT,
PLTLabsMessageHelper.SIGNAL_STRENGTH_EVENT,
PLTLabsMessageHelper.CONFIGURE_SIGNAL_STRENGTH_EVENT];

//Device related variables
var connectedToDevice = false;
var connectedToSensorPort = false;
var connectingToSensorPort = false;
var deviceMetadata = null;

var sensorPortAddress = new ArrayBuffer(PLTLabsMessageHelper.BR_ADDRESS_SIZE);
var sensorPortAddress_view = new Uint8Array(sensorPortAddress);
sensorPortAddress_view[0] = 0x50;


//WebRTC variables
var handleId;
var serverIPAddress;
var port = "8080";
var connectionKey = "peerjs";

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

$(function() {
  $( "#accordion" ).accordion();
});



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
  $('#chkProximity').change(function(){
    enableProximity(this.checked);
  });
  $('#btnDisconnect').click(disconnectWebRTC);
  $('#btnCall').attr("disabled", true);
  $('#btnCall').click(makeCall);
  $('#btnHangUp').attr("disabled", true);
  $('#btnHangUp').click(hangUp);
  $('#btnHangUp').hide();
  $('#userHandle').change(enableConnectToServerButton);
  $('#userServerIPAddress').change(enableConnectToServerButton);
  $("input[name='server']").click(enableConnectToServerButton);
  $('#btnConnect').click(function(){
		//
		$('#userHandle').attr("disabled", true);
                $('#userServerIPAddress').attr("disabled", true);
		$("input[name='server']").attr("disabled", true);
		connectToServer();
		this.disabled = true;
		});
  $("#select-result").change(function(){
      $('#btnCall').attr("disabled", (this.innerText == ""));
  });
  $( "#selectable" ).selectable({
      stop: function() {
        var result = $( "#select-result" ).empty();
        $( ".ui-selected", this ).each(function() {
          var index = $( "#selectable li" ).index( this );
          result.append(this.innerText);
	  result.change();
        });
      }
    });
  $(".trWebRTCContacts").hide();
  PLTLabsAPI.debug = true;
  PLTLabsAPI.subscribeToDeviceMetadata(onMetadata);
}

function enableConnectToServerButton(){
  handleId = $('#userHandle').val();
  var serverType = $("input[name='server']:checked").val();
  var ec2 = $('#ec2ServerIPAddress').val();
  var userDefined =  $('#userServerIPAddress').val()
  serverIPAddress = (serverType == "ec2" ?  ec2 : userDefined);
  var disabled = true;
  if (handleId && handleId != "") {
    if (serverIPAddress && serverIPAddress != "") {
      disabled = false;
    }
    
  }
  $('#btnConnect').attr("disabled", disabled);
}

//PLTLabs Functions
function findPLTDevices(){
  log("findPLTDevices: Searching for PLT Labs devices");
  PLTLabsAPI.findDevices(devicesFound);

}

function disconnectPLT(){
 PLTLabsAPI.closeConnection(connectionClosed);
 
}

function connectionClosed(){
  deviceMetadata = null;
  connectedToSensorPort = false;
  connectedToDevice = false;
  clearSettings();
  $('#chkPLTDevice').attr("checked", false);
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
  log('devices have been found!' + deviceList);
  for(i = 0; i < deviceList.length; i++){
    var d = deviceList[i];
    log('Device ' + i + ' + : ' + d.name);
    if(d.connected == true && d.name.indexOf("PLT_") != -1) {
      log('using: ' + d.name);
      PLTLabsAPI.openConnection(d, connectionOpened);
      break;
    }
  }
}

function onMetadata(metadata){
  log("metadata recieved " + JSON.stringify(metadata));
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
    PLTLabsAPI.subscribeToSettings(onSettings);
    PLTLabsAPI.subscribeToDisconnect(connectionClosed);
    enableButtonPressEvents();
    getSettings();
    connectedToDevice = true;
    $('#chkProximity').attr("disabled",false);
  }
}

function onSettings(info){
  
    log('onSetttings: settings info ' + JSON.stringify(info));
    
     switch (info.id){
      case PLTLabsMessageHelper.BATTERY_LEVEL_INFO_SETTING:
	       var charge = info.properties["chargeLevel"] + 0.0;
	       var levels = info.properties["numberOfChargeLevels"] + 0.0;
	       var totalCharge = (100* (charge/levels)) + "%";
	       $('#batteryLevel').text(totalCharge);
	       break;
      case PLTLabsMessageHelper.PRODUCT_NAME_SETTING:
	       $('#productName').text(info.properties["name"]);
	       break;
      case PLTLabsMessageHelper.FIRMWARE_VERSION_SETTING:
	       var version = info.properties["buildTarget"] + "." + info.properties["releaseNumber"];
	       $('#firmwareVersion').text(version);
	       break;
      case PLTLabsMessageHelper.DECKARD_VERSION_SETTING:
	       var isReleaseVersion = info.properties["releaseVersion"];
	       var version = info.properties["majorVersion"] + "." + info.properties["minorVersion"] + "(" + info.properties['maintenanceVersion'] + ')' + (isReleaseVersion ? 'Production' : 'Beta');  
	       $('#deckardVersion').text(version);
	       break;
     }
    
}

function clearSettings(){
   $('#batteryLevel').text('');
   $('#productName').text('');
   $('#firmwareVersion').text('');
   $('#deckardVersion').text('');
   $('#bdAddress').text('');
}

function getSettings(){
  var packet = PLTLabsMessageHelper.createGetProductNameSetting();
  //log('getSettings: getting product name');
  PLTLabsAPI.sendSetting(packet);
  
  packet = PLTLabsMessageHelper.createGetFirmwareVersionSetting();
  //log('getSettings: getting firmware version');
  PLTLabsAPI.sendSetting(packet);
  
  packet = PLTLabsMessageHelper.createGetDeckardVersionSetting();
  //log('getSettings: getting Plantronics M2M messaging version');
  PLTLabsAPI.sendSetting(packet);
  
  packet = PLTLabsMessageHelper.createGetBatteryInfoSetting();
  //log('getSettings: getting device battery information');
  PLTLabsAPI.sendSetting(packet);
  
  $('#bdAddress').text(PLTLabsAPI.device.address);
  
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

function enableProximity(on){
  var options = {"enabled": on ? true : false};
  var packet = PLTLabsMessageHelper.createEnableProximityCommand(options);
  log("enableProximity: sending command to " +  (on ? " enable " : " disable ") + " proximity" );
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
   //log('event received: ' + JSON.stringify(info));
   if (info.id == PLTLabsMessageHelper.SUBSCRIBED_SERVICE_DATA_CHANGE_EVENT) {
    switch(info.properties["serviceId"]) {
      case PLTLabsMessageHelper.HEAD_ORIENTATION_SERVICE_ID:

      var q = info.properties["quaternion"];
      var c = PLTLabsMessageHelper.convertQuaternianToCoordinates(q); 
      $('#roll').text(c.roll);
      $('#pitch').text(c.pitch);
      $('#heading').text(c.heading);
      sendHeadTrackingCoordinatesToPeer(c); 
        //log('onEvent: headtracking: ' + JSON.stringify(info));
      break;
      case PLTLabsMessageHelper.TAPS_SERVICE_ID:
      $('#taps').text("X = " + info.properties["x"]);
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
  if(info.id == PLTLabsMessageHelper.SIGNAL_STRENGTH_EVENT){
     $('#rssi').text(info.properties['proximity']);
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
  clearPeerList();
  if (peer) {
    peer.disconnect();
    peer.destroy();
    peer = null;  
  }
}



function checkForUsers(){
  if (!serverIPAddress) {
    return;
  }
  var http = new XMLHttpRequest();
  var url = 'http://' + serverIPAddress + ':' + port + '/' + connectionKey + '/whoison';
  http.open('get', url, true);
  http.onerror = function(e) {
    log('Error retrieving peers connected to server', e);
  }
  
  http.onreadystatechange = function() {
    if (http.readyState !== 4) {
      return;
    }
    if (http.status !== 200) {
      http.onerror();
      return;
    }
    var message = JSON.parse(http.responseText);
    log('checkForUsers: found ' + message.userIds.length);
    populatePeerList(message.userIds);
  };
  http.send(null);

}

function populatePeerList(users){
  for(i = 0; i < users.length; i++){
    var u = users[i];
    if (u.name == handleId) {
      //don't list yourself
      continue;
    }
    $('#selectable').append('<li class="ui-widget-content">' + u.name + '</li>');
  }
}

function clearPeerList(){
  $('#selectable li').remove();
  var result = $("#select-result").empty();
}

function connectToServer() {
  log('connectToServer: Connecting to WebRTC server');
  peer = new Peer(handleId, {"host":serverIPAddress, "port": port, "debug": 3, "config": {'iceServers': [{ url: 'stun:stun.l.google.com:19302' } ]}});

  peer.on('open', function(){
    $('#user-name').text("Connected as " + peer.id);
    $('.trWebRTCConnection').hide();
    $(".trWebRTCContacts").show();
    gum();
    checkForUsers();
  });
  
  peer.on('peerremoved', function(id){
    log('peer ' + id + ' has disconnected');
    $('#selectable li:contains('+ id + ')').remove();
    var callee = $("#select-result").text();
    if (callee == id) {
      $("#select-result").empty();
      $("#select-result").change();
    }
  });
  
  peer.on('peeradded', function(id){
    log('peer ' + id + ' has connected');
     $('#selectable').append('<li class="ui-widget-content">' + id + '</li>');
  });
  
  peer.on('close', function(){
    $('#user-name').text("");
    $('#userHandle').attr("disabled", false);
    $('#userServerIPAddress').attr("disabled", false);
    $("input[name='server']").attr("disabled", false);	
    enableConnectToServerButton();
    $('.trWebRTCConnection').show();
    $(".trWebRTCContacts").hide();
    window.localStream = null;
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
  $('#peer-information').html('Incoming call from ' + call.peer);
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
  
  var callee = $("#select-result").text();
  // Initiate a call
  log('makeCall: calling ' + callee);
  var call = peer.call(callee, window.localStream);
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
