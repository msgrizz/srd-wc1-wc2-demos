//WebRTC Web Page Application 
function log(message){
    console.log(message);  
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
    $('#webRTCConnection').hide();
    $("#webRTCContacts").show();
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
    $('#webRTCConnection').show();
    $("#webRTCContacts").hide();
    window.localStream = null;
  });
  
  
  peer.on('connection', handleDataConnection);
  peer.on('call', ring);
  
  
  peer.on('error', function(err){log('Error connecting to server: ' + err.type);});
}

function handleDataConnection(dataConnection){
  log("got a data connection from " + dataConnection.peer + " label = " + dataConnection.label);
  if (window.existingDataConnection) {
    //close any existing calls
    window.existingDataConnection.close();
  }
  dataConnection.on("data", function(data){
    var msg = JSON.parse(data);
    if (msg.id == "gps") {
        log("onData: GPS message receieved for location " + msg.description);
        initializeStreetView(msg);
    }
    else if (msg.id == "ht") {
        updateStreetView(msg.h, msg.p);
    }
  });
   
  window.existingDataConnection = dataConnection;
}

function sendGPSSetMessageToPeer(){
    sendMessageToPeer({"id":"gpsSet"});
}

function sendMessageToPeer(msg) {
    if (window.existingDataConnection) {
        log("sending data message to peer");
        window.existingDataConnection.send(JSON.stringify(msg))
    }
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
   log('Answering incoming call from ' + call.peer);
   ringing = false;
   $('#incoming-call').hide();
   $('#video-container').show();
   
   call.answer(window.localStream);
   if (window.existingCall) {
    //close any existing calls
    window.existingCall.close();
   }
   
   call.on('stream', onStream);    
   window.existingCall = call;
   call.on('close', resetButtonsAfterWebRTCCall);
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

//when a stream comes in
function onStream(stream){
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

function resetButtonsAfterWebRTCCall(){
  log('resetButtonsAfterWebRTCCall: call has ended');
  ringing = false;
  $('#btnHangUp').attr("disabled", true);
  $('#btnHangUp').hide();
  $('#btnCall').show();
  $('#btnCall').attr("disabled", false);
  $('#remote-video').prop('src', "");
  $('#video-container').hide();
  $('#map-canvas').empty();
  $('#map-canvas').hide();
  map = null;
  
  $('#pano').empty();
  $('#pano').hide();
  panorama = null;
  
  $('#content-filler').show();
  
  
}


function gum (initiator) {
            // Get audio/video stream
            navigator.getUserMedia({audio: true, video: true},
                                   function(stream){
                                    // Set your video displays
                                    log("GUM returned successfuly");
                                    //$('#local-video').prop('src', URL.createObjectURL(stream));
                                    window.localStream = stream;
                                    readyForCall = true;
                                    $('#butConnect').attr("disabled", false);
                                    },
                                    function(error){ log(error); });
      
          
}


function disconnectWebRTC(){
  log('disconnectWebRTC: disconnecting');
  clearPeerList();
  if (peer) {
    peer.disconnect();
    peer.destroy();
    peer = null;  
  }
}
