var 

function log(message){
    console.log(message);  
}

function connectToServer() {
  log('Connecting to WebRTC server');
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
  
  
  peer.on('error', function(err){log('Error connecting to server: ' + err.type);});
}

function handleDataConnection(dataConnection){
  log("got a data connection from " + dataConnection.peer + " label = " + dataConnection.label);
  if (window.existingDataConnection) {
    //close any existing calls
    window.existingDataConnection.close();
  }
  dataConnection.on("data", function(data){
    var event = '<span class="remote-data">Data from :'+ dataConnection.peer + '<br>' + data + '</span>'; 
    log(event);
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
   log('Answering incoming call from ' + call.peer);
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
  log('Calling ' + userId);
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
  log('call has ended');
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
                                    log("GUM returned successfuly");
                                    $('#local-video').prop('src', URL.createObjectURL(stream));
                                    window.localStream = stream;
                                    readyForCall = true;
                                    setButtonState(true);
                                    $('#butConnect').attr("disabled", false);
                                    },
                                    function(error){ log(error); });
      
          
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
    connectToServer();
}

function disconnect(){
   if (peer) {
    peer.destroy();
    peer = null;
   }
   resetButtonsAfterWebRTCCall();
}
