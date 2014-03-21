//WebRTC Web Page Application 
function log(message){
    console.log(message);  
}

function connectToServer(server) {
  log('Connecting to WebRTC server:' + server);
  peer = new Peer(handleId, {host:server, port: port, debug: 3, config: {'iceServers': [{ url: 'stun:stun.l.google.com:19302' } ]}});

  peer.on('open', function(){
      $('#user-name').text("Connected as " + peer.id);
      $('#btnCall').attr("disabled", false);
      gum();
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
  // Initiate a call
  log('Calling ' + calleeId);
  var call = peer.call(calleeId, window.localStream);
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


function disconnect(){
   if (peer) {
    peer.destroy();
    peer = null;
   }
   resetButtonsAfterWebRTCCall();
}
