//PLT Labs - Bladerunner Experiment
//Author: Cary Bran
//JS Library to test bladerunner functionality





//Device related variables
var connectedToDevice = false;
var connectedToSensorPort = false;
var connectingToSensorPort = false;
var deviceMetadata = null;

var sensorPortAddress = new ArrayBuffer(4);
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
  $('#btnCreateHostNegotiate').click(function(){
      $('#messageJSON').html('');
      var hs = plt.msg.createHostNegotiateMessage();
      var c = JSON.stringify(hs);
      $('#messageJSON').html("<span>" + c + "</span>");
      });
  
  $('#btnCreateCommand').click(function(){
      $('#messageJSON').html('');
      var options = {};
      var commandId = parseInt($("#selectCommand").val());
      if (commandId == plt.msg.TYPE_SERVICEID_HEADORIENTATION ||
	  commandId == plt.msg.TYPE_SERVICEID_PEDOMETER ||
	  commandId == plt.msg.TYPE_SERVICEID_FREEFALL ||
	  commandId == plt.msg.TYPE_SERVICEID_TAPS) {
	  options.address = sensorPortAddress;
	  options.serviceID = commandId;
	  options.characteristic = 0;
	  options.mode = plt.msg.TYPE_MODEONCCHANGE;
	  commandId = plt.msg.SUBSCRIBE_TO_SERVICES_COMMAND;
      }
      if (commandId == plt.msg.CONFIGURE_MUTE_TONE_VOLUME_COMMAND) {
	 options.muteToneVolume = 2;
      }
      if (commandId == plt.msg.SECOND_INBOUND_CALL_RING_TYPE_COMMAND) {
	 options.ringType = 2;
      }
      
      try{
	var command = plt.msg.createCommand(commandId, options);
	var c = JSON.stringify(command);
	$('#messageJSON').html("<span>" + c + "</span>");
      }catch(e){
	$('#messageJSON').html("exception caught " + e);
      }
  });
  $('#btnCreateSetting').click(function(){
      $('#messageJSON').html('');
      var options = {};
      var settingId = parseInt($("#selectSetting").val());
      try{
	var setting = plt.msg.createGetSetting(settingId, options);
	var c = JSON.stringify(setting);
	$('#messageJSON').html("<span>" + c + "</span>");
      }catch(e){
	$('#messageJSON').html("exception caught " + e);
      }
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
  plt.addConnectionListener(connectionListener);
  plt.addEventListener(onEvent);
  plt.addSettingsListener(onSettings);
  plt.addCommandSuccessListener(onCommandSuccess);
  PLTLabsAPI.debug = true;
  PLTLabsAPI.subscribeToEvents(onEvent);
  PLTLabsAPI.subscribeToSettings(onSettings);
  PLTLabsAPI.subscribeToDisconnect(connectionClosed);
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

function onCommandSuccess(commandSuccessMessage){
    log('onCommandSuccess: command successfully executed: ' + JSON.stringify(commandSuccessMessage));
}

//PLTLabs Functions
function findPLTDevices(){
  log("findPLTDevices: Searching for PLT Labs devices");
  try{
    plt.addDeviceListener(devicesFound);
    plt.getDevices();
  }
  catch(e){
    log(e);
  }
}

function connectionListener(connected){
  if (connected) {
    //device connected
    
  }
  else{
    connectionClosed();
  }
}

function disconnectPLT(){
 plt.disconnect();
 
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
   if (!connectedToDevice) {
    plt.connect(deviceList[0]);
  }
  
     
}

function connectionOpened(event){
  if (event.payload.address == plt.msg.SENSOR_PORT) {
    log("connectionOpened: sensor port connection is open!");
    enableWearableConceptEvents();
    connectedToSensorPort = true;
    connectingToSensorPort = false;
    setPLTCheckboxesState(false);
  }
  else if (!connectedToDevice) {
    log('connectionOpened: data connection opened to device');
    var options = new Object();
    getSettings();
    connectedToDevice = true;
    $('#chkProximity').attr("disabled",false);
  }
}

function onSettings(info){
  
    log('onSetttings: settings info ' + JSON.stringify(info));
    
     switch (info.payload.messageId){
      case plt.msg.BATTERY_INFO_SETTING:
	       var charge = info.payload.level + 0.0;
	       var levels = info.payload.numLevels + 0.0;
	       var totalCharge = (100* (charge/levels)) + "%";
	       if (info.payload.charging) {
		  totalCharge += "(charging)";
	       }
	       $('#batteryLevel').text(totalCharge);
	       break;
      case plt.msg.PRODUCT_NAME_SETTING:
	       $('#productName').text(info.payload.productName);
	       break;
      case plt.msg.FIRMWARE_VERSION_SETTING:
	       var version = info.payload.buildTarget + "." + info.payload.release;
	       $('#firmwareVersion').text(version);
	       break;
      case plt.msg.DECKARD_VERSION_SETTING:
	       var isReleaseVersion = info.payload.releaseVersion;
	       var version = info.payload.majorVersion + "." + info.payload.minorVersion + "(" + info.payload.maintenanceVersion + ')' + (isReleaseVersion ? 'Production' : 'Beta');  
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
  var packet = plt.msg.createGetSetting(plt.msg.PRODUCT_NAME_SETTING);
  log('getSettings: getting product name');
  plt.getSetting(packet);
  
  packet = plt.msg.createGetSetting(plt.msg.FIRMWARE_VERSION_SETTING);
  log('getSettings: getting firmware version');
  plt.getSetting(packet);
  
  packet = plt.msg.createGetSetting(plt.msg.DECKARD_VERSION_SETTING);
  log('getSettings: getting Plantronics M2M messaging version');
  plt.getSetting(packet);
  
  packet = plt.msg.createGetSetting(plt.msg.BATTERY_INFO_SETTING);
  log('getSettings: getting device battery information');
  plt.getSetting(packet);
  
  $('#bdAddress').text(PLTLabsAPI.device.address);
  
}

//PLT checkbox functions 
function enableHeadtracking(on) {
  var options = {"serviceId" : plt.msg.TYPE_SERVICEID_HEADORIENTATION};
  enableWC1Service(on, options);
}

function enableFreeFallDetection(on) {
  var options = {"serviceID" : plt.msg.TYPE_SERVICEID_FREEFALL};
  enableWC1Service(on, options);
}

function enableTapDetection(on) {
 var options = {"serviceID" : plt.msg.TYPE_SERVICEID_TAPS};
  enableWC1Service(on, options);
}

function enablePedometer(on) {
  var options = {"serviceID": plt.msg.TYPE_SERVICEID_PEDOMETER};
  enableWC1Service(on, options);
}

function enableWC1Service(on, options) {
  options.mode = on ? plt.msg.TYPE_MODEONCCHANGE : plt.msg.TYPE_MODEOFF;
  options.address = sensorPortAddress;
  var packet = plt.msg.createCommand(plt.msg.SUBSCRIBE_TO_SERVICES_COMMAND, options) 
  plt.sendCommand(packet)
}

function enableProximity(on){
  var options = {"enable": on ? true : false};
  options.sensitivity = 5;
  options.nearThreshold = 0x3C;
  options.maxTimeout = 0xFFFF;
  var packet = plt.msg.createCommand(plt.msg.CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND, options);
  console.log("sending command to enable proximity " + JSON.stringify(packet));
  plt.sendCommand(packet);
}


//Turns on the WC1's sensor channel - does so by sending a metadata command to port 5
function enableWearableConceptEvents(){
  /*if (!deviceMetadata) {
    log("enableWearableConceptEvents: no device metadata abondoning efforts to sensor service device features");
    return;
  }
  
  var availablePorts = deviceMetadata.payload.availablePorts;
  if (availablePorts.indexOf(plt.msg.SENSOR_PORT) < 0) {
   log("enableWearableConceptEvents: device does not support sensor service subscription");
   return;
 }
*/
// log("enableWearbleConceptEvents: sending host negotiate to enable concept device services");
 //var packet = plt.msg.createHostNegotiateMessage({"address":sensorPortAddress});
   
}

function onEvent(info){
   log('event received: ' + JSON.stringify(info));
   switch (info.payload.messageId) {

    case plt.msg.SUBSCRIBED_SERVICE_DATA_EVENT:
     switch(info.payload.serviceID) {
       case plt.msg.TYPE_SERVICEID_HEADORIENTATION:
         $('#roll').text(info.payload.roll);
	 $('#pitch').text(info.payload.pitch);
         $('#heading').text(info.payload.heading);
         var c = {"roll":info.payload.roll, "pitch": info.payload.pitch, "heading": info.payload.heading};
         sendHeadTrackingCoordinatesToPeer(c); 
         break;
       case plt.msg.TYPE_SERVICEID_TAPS:
         $('#taps').text("X = " + info.payload.x);
         break;
       case plt.msg.TYPE_SERVICEID_FREEFALL:
         $('#freefall').text(info.payload.freefall);
         break;
       case plt.msg.TYPE_SERVICEID_PEDOMETER:
         $('#steps').text(info.payload.steps);
         break;
       default:
       break;
     }
     break;
    case plt.msg.CONNECTED_DEVICE_EVENT:
	connectionOpened(info);
	break;
    case plt.msg.DISCONNECTED_DEVICE_EVENT:
	break;
   case plt.msg.WEARING_STATE_CHANGED_EVENT:
     var state = info.payload.worn ? "On" : "Off";
      $('#dondoff').text(state);
      break;
   case plt.msg.SIGNAL_STRENGTH_EVENT:
      var range = info.payload.nearFar == 1 ? "Near" : "Far"; 
      $('#rssi').text(range);
      break;
   case plt.msg.RAW_BUTTON_TEST_EVENT:
     $('#buttons').text(info.payload.buttonIdName);
     if (info.payload.buttonId == 2) {
       if(ringing){
	 $('#btnCall').trigger("click");
       }
       else if (window.existingCall) {
	   //hang up the call
	   $('#btnHangUp').trigger("click");
       }
     }
     break;
    }
  
  }

  // hook flash button
  
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
