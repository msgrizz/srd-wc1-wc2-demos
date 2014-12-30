/*
 * Plantronics bluetooth integration sample applicaiton
 * This packaged Chrome application highlights the integration between Plantronics WC1 device
 * and Google Chrome's bluetooth APIs
 * @author: Cary A. Bran
 * @version: 1.0
 * @copyright: 2014 Plantronics Inc
 */

//Device related variables
var connectedDevice = null;

//to talk to the wearable concepts sensors, you need to address the messgaes to port 5
var sensorPortAddress = new ArrayBuffer(4);
var sensorPortAddress_view = new Uint8Array(sensorPortAddress);
sensorPortAddress_view[0] = 0x50;

//FIDO stuff
//to get chunks of messages and to know what kind of
//message we are getting back from the WC2 SE we need to
//maintain state - the reason for this is the the messages
//we receive back from the WC2 are opaque to us and we are
//unable to tell what type of messages they are (yet)
var IDLE_STATE = -1;
var PINGING_STATE = 0;
var ENROLLING_STATE = 1;
var SIGNING_STATE = 2;
var TOUCHING_STATE = 3;
var CHECKING_ENROLLMENTS = 4;


var currentFidoState = IDLE_STATE;
var isEnrolled = false;
var validEnrollmentKey;
var enrollRequest;
var signRequest;

//this global is needed because sometimes APDUs come back in fragments
//from the WC2 secure element - we need to reconsitute them within the app
var currentAPDU = "";
var apduChunkCount = 0;

//this header is what you send to the WC2 secure element to ask for more chunks of the APDU
var apduGetChunkHeader;

//END FIDO stuff

function init(){
  $('#chkPLTDevice').change(function(){
    if(this.checked){
      connectDevice();
    }
    else{
      disconnectDevice();
    }
  }
  );
  $('#btnCheckEnrollment').attr("disabled", true);
    $('#btnCheckEnrollment').click(function(){
      checkForDeviceEnrollments();
    });
  $('#btnSign').attr("disabled", true);
  $('#btnSign').click(function(){
    sign();
  });
    
  $('#btnPing').attr("disabled", false);
  $('#btnPing').click(function(){
    ping();
  });
  
  $('#btnEnroll').attr("disabled", true);
  $('#btnEnroll').click(function(){
    enroll();
  });
 $('#chkTouchSecureElement').attr("disabled", true);
 $('#chkTouchSecureElement').change(function(){
    if(this.checked){
      touch();
    }
  }
  );
  log("init() - registering listeners with plt library");
  plt.addEventListener(onEvent);
  log("init() - events -> plt.addEventListener(onEvent);");
  plt.addSettingsListener(onSettings);
  log("init() - settings -> plt.addSettingsListener(onSettings);");
  plt.addCommandSuccessListener(onCommandSuccess);
  log("init() - command success -> plt.addCommandSuccessListener(onCommandSuccess);"); 
  plt.addOnConnectionListener(onConnectionOpened);
  log("init() - device socket connection opened -> plt.addOnConnectionListener(onConnectionOpened);");
  plt.addOnDisconnectListener(onDisconnect);
  log("init() - device socket disconnect -> plt.addOnDisconnectListener(onDisconnect);");
  
}

//gets the server connection information from the
//screen - will default to localhost and joe/1234 if fields are blank
function getServerConnection(){
  var result = {"url":  "http://localhost:8080",
		"username": "joe",
		"password": "1234"};
		
  
  var url = $('#serverAddress').val();
  var username = $('#username').val();
  var password = $('#password').val();
  
  if (url.trim() != "") {
    result.url = url;
  }
  if (username.trim() != "") {
    result.username  = username;
    result.password = password;
  }
  
  return result;
}

function onEvent(info){
  switch (info.payload.messageId) {
    case plt.msg.BATTERY_STATUS_CHANGED_EVENT:
      updateBatterySettings(info);
      break;
    case plt.msg.CONNECTED_DEVICE_EVENT:
      connectionOpened(info);
      break;
    case plt.msg.PASS_THROUGH_PROTOCOL_EVENT:
      info.payload.apdu = processRawAPDU(info);
      if (!info.payload.apdu) {
	//wait for more chunks to come in from the device
	//the device will chunk up large APDUs
	log('onEvent: waiting for more APDU chunks - chunk count = ' + apduChunkCount);
	return;
      }
      
      log("onEvent: Pass through event recieved");
      switch(currentFidoState){
	case IDLE_STATE:
	  throw "onEvent: fido event recieved during idle state";
	  break;
	case SIGNING_STATE:
	  log("onEvent: processing APDU signing result from device");
	  checkSignatureWithServer(info);
	  break;
	case ENROLLING_STATE:
	  log("onEvent: processing APDU enrollment result from device");
	  enrollDevice(info);
	  break;
	case TOUCHING_STATE:
	  log("onEvent: processing APDU touch result from device");
	  touchResponse(info);
	  break;
	case PINGING_STATE:
	  log("onEvent: processing APDU ping result from device");
	  validatePing(info);
	  break;
	case CHECKING_ENROLLMENTS:
	  log("onEvent: checking enrollments for device");
	  validateEnrollment(info);
      }
      currentFidoState = IDLE_STATE;
      break;
  }
}

function processRawAPDU(event){
  var apduChunk = unPackBinaryToHex(event.payload.dataBlob);
  log('processRawAPDU: chunk recieved ' + apduChunk);
  var chunkLength = apduChunk.length;
  var statusWord = apduChunk.substring(chunkLength - 4);
  if (statusWord != '9000') {
    // Handle sign check results
    // This should NEVER return a 9000....TODO: Check on this and the use of sign_check below
    if (currentFidoState == CHECKING_ENROLLMENTS){
      log("processRawAPDU: checking enrollments and statusWord = " +  statusWord);
      return (statusWord == "6985" ? "1" : "0");
    }
    
    log('processRawAPDU: error condition, state = ' + currentFidoState + ' statusWord = ' + statusWord);
    currentFidoState = IDLE_STATE;
    currentAPDU = "";
    return null;
  }
  //if the first two hex chunks are equal to "80" then we have to get more data
  var needMoreChunks = (apduChunk.substring(0, 2)  === "80");
  log('processRawAPDU: chunk length = ' + chunkLength + ' status = ' + statusWord + ' needs more APDU chunks = ' + needMoreChunks);
  //FIXUP! - we are getting back the length of the chunk here - this is coming from our firmware and
  //serves no purpose in when reconstructing the APDUs.
  //TODO - remove the size of the byte arrays from the last byte of the array
  currentAPDU += apduChunk.substring(2, chunkLength - 6);
  if (!needMoreChunks) {
    //we are done - no need to append chunks any longer
    return currentAPDU;
  }
  
  //we have a chunk of an APDU so we need to ask the device for more
  apduChunkCount++;
  var apdu = apduGetChunkHeader + "0" + apduChunkCount.toString(16);	
  log("processRawAPDU: getting more chunks, apdu = " + apdu + " chunk count = " + apduChunkCount);
  sendApduToDevice(apdu);
  return null;
  
}

//packages up a PLT pass through protocol deckard message and sends it to the device for processing
function sendApduToDevice(apdu){
  var apduByteArray = packHexToBinary(apdu);
  var options = {"protocolid": plt.msg.TYPE_PROTOCOLAPDU, "dataBlob": apduByteArray, "address": sensorPortAddress};
  var command = plt.msg.createCommand(plt.msg.PASS_THROUGH_PROTOCOL_EVENT, options);
  log("sendApduToDevice: sending pass through protocol command  (byte size) = " + command.messageBytes.byteLength)
  if (connectedDevice) {
    plt.sendMessage(connectedDevice, command);
  }
}


//creates a touch apdu and sends it to the device
function touch() {
  currentAPDU = "";
  var apdu = createTouchAPDU();
  apduChunkCount = 0;
  apduGetChunkHeader = apdu.substring(0, 8) + "01";
  currentFidoState = TOUCHING_STATE;
  sendApduToDevice(apdu);

}
//handles the callback to a touch command
function touchResponse(event){
  var touchResponse = event.payload.apdu;
  $('#touchState').text("Secure element touched: " + touchResponse);
  $('#chkTouchSecureElement').attr("disabled", true);
  $('#btnEnroll').attr("disabled", false);
}

//BEGIN CHECK FOR ENROLLMENTS - use this when fix is in place for WC2
//This function is call upon connection of the WC2
//It will ask the security server for device enrollments based
//upon the user account, a user account may have many device enrollments
//however they may not belong to this particular device
//if we do find a valid enrollment key for the this device we can use it
//to sign our requests with.
function checkForDeviceEnrollments(){
  isLastEnrollment = false;
  validEnrollmentKey = null;
  getEnrollments("joe", "1234", signTestEnrollmentKeys); 
}

function signTestEnrollmentKeys(enrollments){
  if (currentFidoState != IDLE_STATE) {
    //wait a few more seconds to get back the results from the server
    log("signTestEnrollmentKeys: waiting for idle state")
    setTimeout(function(){signTestEnrollmentKeys(enrollments); }, 2000);
  }
  
  log("signTestEnrollmentKeys: number of enrollments returned = " + enrollments.length);
  //pop off the first key in the array
  testEnrollmentKey = enrollments.shift();
  
  //create the check sign request
  signRequest = {
        type: "sign_check_keyhandle",
        signData: testEnrollmentKey
    };
  log("signTestEnrollmentKeys: creating sign APDU with " + JSON.stringify(signRequest));
  var apdu = createSignAPDU(signRequest);
  apduChunkCount = 0;
  apduGetChunkHeader = apdu.substring(0, 8) + "01";
  currentFidoState = CHECKING_ENROLLMENTS;
  sendApduToDevice(apdu);
  
  if (enrollments.length > 0) {
    log("signTestEnrollmentKeys: recursing on the remaining enrollments.")
    setTimeout(function(){signTestEnrollmentKeys(enrollments); }, 1500);
  }
  else{
    isLastEnrollment = true;
  }
}

function validateEnrollment(event){
   log("validateEnrollment: validating enrollment: APDU response " + event.payload.apdu);
  if (event.payload.apdu == "1") {
    log("validateEnrollment: valid enrollment found");
    validEnrollmentKey = testEnrollmentKey;
    $('#btnEnroll').attr("disabled", true);
  }
  
  if(isLastEnrollment){
    //enable buttons to interact with the SE
    $('#btnPing').attr("disabled", false);
    $('#chkTouchSecureElement').attr("disabled", false);
    $('#btnEnroll').attr("disabled", (validEnrollmentKey ? true : false));
    $('#btnSign').attr("disabled", (validEnrollmentKey ? false : true));
  }
}

//END CHECK FOR ENROLLMENTS


//BEGIN PING
//creates a ping APDU and sends it to the device
function ping(){
  currentAPDU = "";
  var apdu = createPingAPDU();
  apduChunkCount = 0;
  apduGetChunkHeader = apdu.substring(0, 8) + "01";
  currentFidoState = PINGING_STATE;
  sendApduToDevice(apdu);
}

//processes the ping callback and checks to see if the ping is valid
function validatePing(event){ 
 if (!event) {
    return;
  }
  log("validatePing: validating secure element ping");
  var validPingResponse = "0102030405060708090a0b0c0d0e0f10";
  
  var pingResponse = event.payload.apdu;
  log("validatePing: response from secure element :" + pingResponse);

  // Extra version string - need to find NULL terminator
  var endOfString = -1;
  var version;
  for (var i = 0; i < pingResponse.length - 4; i += 2){
    var hexVal = pingResponse.substring(i, i + 2);
    if (hexVal === "00"){
      endOfString = i;
      version = pingResponse.substring(0, i);
      break;
    }
  }
  var pingReturnString = pingResponse.substring(endOfString + 2);
  console.log("validatePing: version = " + version);
  console.log("validatePing: valid ping = " + validPingResponse);
  console.log("validatePing: response recieved = " + pingReturnString )
  // Validate ping return
  if (pingReturnString != validPingResponse){
    $('#pingResult').text("Invalid Ping: " + pingReturnString);
    return;
  }
  
  $('#pingResult').text("Ping successful!");
}
//END PING


//BEGIN SIGN
function sign(){
  currentAPDU = "";
  getEnrollments("joe", "1234", signWithEnrollment);
}

function signWithEnrollment(keyHandle){
  if (!keyHandle || keyHandle.length == 0) {
    log("signWithEnrollment: No enrollments for this account - authentication failed!");
    $('#authResultImg').attr("src", "img/fail.jpeg");
    setTimeout(function(){$('#authResultImg').attr("src", "img/vault.jpeg");}, 10000);
    return;
  }
  log("signWithEnrollment: keyHandle = " + JSON.stringify(keyHandle[0]));
  signRequest = {
        type: "sign_web_request",
        signData: keyHandle[0]
      };
  log("signWithEnrollment: creating sign APDU with " + JSON.stringify(signRequest));
  var apdu = createSignAPDU(signRequest);
  apduChunkCount = 0;
  apduGetChunkHeader = apdu.substring(0, 8) + "01";
  currentFidoState = SIGNING_STATE;
  log("signWithEnrollment: sending signing APDU to device: " + apdu);
  sendApduToDevice(apdu);
}

function checkSignatureWithServer(event){
  
  var bd = {typ:"navigator.id.getAssertion", challenge:JSON.stringify(signRequest.signData.challenge)};
  var sessionId = signRequest.signData.sessionId;
  var challenge = "challenge";
  var appId = "appId";
  var apdu = event.payload.apdu;
  log("checkSignatureWithServer: APDU returned from device " + apdu);
  var words = CryptoJS.enc.Hex.parse(apdu);
  log("checkSignatureWithServer: words = " + words);
  var base64Apdu = CryptoJS.enc.Base64.stringify(words);
  log("checkSignatureWithServer: base64Adpdu = " + base64Apdu);
  var urlSafeApdu = base64ToURLSafe(base64Apdu);
  log("checkSignatureWithServer: urlSaftApdu = " + urlSafeApdu);
  var webEncodedApdu = encodeURIComponent(urlSafeApdu);
  log("checkSignatureWithServer: webEncodedApdu = " + webEncodedApdu);
  var browserData = btoa(JSON.stringify(bd));
  
  var connInfo = getServerConnection();
  
  var url = connInfo.url + "/signFinish?sessionId="+ sessionId +"&appId=" + appId + "&browserData=" + browserData + "&challenge="+ challenge +"&signData=" + webEncodedApdu;
  log("checkSignatureWithServer: URL to server = " + url);
  $.ajax({
      url: url,
      type: 'get',
      crossDomain: true,
      success: function (result) {
	      log("checkSignatureWithServer: result from server : " + JSON.stringify(result));
	      if (result.result == "success") {
		log("checkSignatureWithServer: secure element has been authenticated with server - success!");
		$('#authResultImg').attr("src", "img/success.jpeg");
	      }
	      else{
		log("checkSignatureWithServer: secure element has FAILED authenticated with server!");
		$('#authResultImg').attr("src", "img/fail.jpeg");
	      }
	      setTimeout(function(){$('#authResultImg').attr("src", "img/vault.jpeg");}, 5000);
	    }
      }).fail( function(e) {
	log("enrollDevice: error getting data " + e)
      });
  
}

//END SIGN

//currently just going with the assumption that there is one valid enrollment
//for the device - I know this is not robust but am doing it for speed of completion
function getEnrollments(userName, password, callback){
  var connInfo = getServerConnection();
  var url = connInfo.url + "/signData.js?userName=" + connInfo.username + "&password=" + connInfo.password;
  $.ajax({
    url: url,
    type: 'get',
    crossDomain: true,
    success: function (result) {
      var signData = result;
      var numItems = signData.length;
      if (numItems == 0) {
	log("getEnrollments: no enrollments found on server");
      }
      
      callback(signData);
      //assume (bad) that the enrollment if returned is valid
      //TODO return the list of enrollments to the keycheck
     // console.log("getEnrollments: enrollment found = " + signData[0]);
     // signWithEnrollment(signData[0]);
    }
  })
  .fail( function(e) {
	  switch (e.status)
	  {
		  case 400:
			  log("getEnrollments: Bad Request");
			  break;
		  case 401:
			  log("getEnrollments: Bad Password");	
			  break;
		  case 404:
			  log("getEnrollments: Invalid User");
			  break;
		  default:
			  log("getEnrollments: Unknown / other error: " + e.status);
			  break;
		  
	  }
  
  });
}

//BEGIN ENROLLMENTS
//step 1 of the enrollement process 
function enroll(){
  currentAPDU = "";
  //onEnrollData is called when the request comes back from the server
  getEnrollDataFromServer("joe", "1234",  onEnrollData);
}
//step 2 of the enrollment process - call the server with the username and password
//of the user that you want to enroll the device with
function getEnrollDataFromServer(userName, password, callback){
  var connInfo = getServerConnection();
  var url = connInfo.url + "/enrollData.js?userName=" + connInfo.username + "&password=" + connInfo.password;
  $.ajax({
    url: url,
    type: 'get',
    crossDomain: true,
    success: function (result) {
	  callback(result);
	  }
    }).fail( function(e) {
      log("getEnrollDataFromServer: error getting data " + e)
    });
}
//step 3 of the enrollment process - onEnrollData is the callback that is passed into
//getEnrollDataFromServer - this function will generate and send the enroll request
//APDU to the device
function onEnrollData(data){
  log("onEnrollData: got back the enroll data from the server");
  log("onEnrollData: server returned JSON -> " + JSON.stringify(data));
  enrollRequest = { 
	"sessionId": data.sessionId,
        "enrollChallenge": {
              "appId": data.appId,
              "version": data.version,
	      "browserData":{
		"typ":"navigator.id.finishEnrollment",
		"challenge": data.challenge
		}
        }
  };
  log("onEnrollData: creating enroll APDU with " + JSON.stringify(enrollRequest));
  var apdu = createEnrollAPDU(enrollRequest);
  apduChunkCount = 0;
  apduGetChunkHeader = apdu.substring(0, 8) + "01";
  currentFidoState = ENROLLING_STATE;
  sendApduToDevice(apdu);
}

//step 4 of the enrollment process - this function is called when we recieve the passthrough event and
//the current state is enrolling.  This function will package up the apdu from the secure element and send it
//off to the server for enrollment.
function enrollDevice(event){
  if (!event || !enrollRequest) {
    return;
  }
  
  var apdu = event.payload.apdu;
  log("enrollDevice: APDU returned from device " + apdu);
  var words = CryptoJS.enc.Hex.parse(apdu);
  log("enrollDevice: words = " + words);
  var base64Apdu = CryptoJS.enc.Base64.stringify(words);
  log("enrollDevice: base64Adpdu = " + base64Apdu);
  var urlSafeApdu = base64ToURLSafe(base64Apdu);
  log("enrollDevice: urlSaftApdu = " + urlSafeApdu);
  var webEncodedApdu = encodeURIComponent(urlSafeApdu);
  log("enrollDevice: webEncodedApdu = " + webEncodedApdu);
  
  var browserData = btoa(JSON.stringify(enrollRequest.enrollChallenge.browserData));
  var connInfo = getServerConnection();
  var url = connInfo.url + "/enrollFinish?sessionId="+ enrollRequest.sessionId +"&browserData=" + browserData + "&challenge=challenge&enrollData=" + webEncodedApdu;
  log("enrollDevice: URL to server = " + url);
  $.ajax({
      url: url,
      type: 'get',
      crossDomain: true,
      success: function (result) {
	      log("enrollDevice: result from server : " + JSON.stringify(result));
	      //set the values up
	      var enrollmentInfo = result;
	      if (!enrollmentInfo.attestationCertificate) {
		log("enrollDevice: no attenstation certificate returned - enrollment failed");
		return;
	      }
	      $('#enrollState').text("Enrolled!");
	     $('#publicKey').text(enrollmentInfo.publicKey);
	      $('#keyHandle').text(enrollmentInfo.keyHandle);
	      $('#btnEnroll').attr("disabled", true);
	      $('#btnSign').attr("disabled", false);
  
	    }
      }).fail( function(e) {
	log("enrollDevice: error getting data " + e)
      });
  
}
//END ENROLLMENTS

function onCommandSuccess(commandSuccessMessage){
   log('onCommandSuccess: command successfully executed: ' + JSON.stringify(commandSuccessMessage));
}

//connect to the PLT Labs device
function connectDevice(){
  log("\nconnectDevice() - searching for PLT Labs devices");
  try{
    log("connectDevice() - adding device found listener -> plt.addDeviceListener(devicesFound);");
    plt.addDeviceListener(devicesFound);
    log("connectDevice() - calling plt api to get devices -> plt.getDevices();");
    plt.getDevices();
  }
  catch(e){
    log(e);
  }
}

//callback for when devices are found by the plt api
function devicesFound(deviceList){
   log("\ndevicesFound(deviceList): callback has been invoked from plt api");
   if (!connectedDevice) {
    log("devicesFound(deviceList): connecting to device -> plt.connect(deviceList[0]);");
    plt.connect(deviceList[0]);
  }  
}

//disconnect from the PLT Labs device
function disconnectDevice(){
  log("\ndisconnectDevice - calling plt api to disconnect device ->  plt.disconnect(connectedDevice);");
  if (!connectedDevice) {
    return;
  }
  plt.disconnect(connectedDevice);
}

function onDisconnect(device){
  //check to make sure this is the device we connected to
  //as this event could be from another connection
  if (device.socketId != connectedDevice.socketId) {
    return;
  }
  log("\nonDisconnect(device): device disconnect from plt api -> device: " + JSON.stringify(device))
  connectedDevice = null;
  
  clearSettings();
  sessionId = null;
  $('#chkPLTDevice').attr("checked", false);
  $('#btnPing').attr("disabled", true);
  $('#btnSign').attr("disabled", true);
  $('#btnEnroll').attr("disabled", true);
  $('#chkTouchSecureElement').attr("disabled", true);
  $('#btnCheckEnrollment').attr("disabled", true);
  var currentFidoState = IDLE_STATE;
  isEnrolled = false;
  apduChunkCount = 0;
  apduGetChunkHeader = "";
  currentAPDU = "";
}


function onConnectionOpened(device) {
  if (connectedDevice) {
    return;
  }
  connectedDevice = device;
  log("\nonConnectionOpened(device): callback has been invoked from plt api");
  log("onConnectionOpened(device): connected PLT device ->" + JSON.stringify(connectedDevice));
  getSettings();
  $('#btnPing').attr("disabled", false);
  $('#btnSign').attr("disabled", false);
  $('#btnEnroll').attr("disabled", false);
  $('#chkTouchSecureElement').attr("disabled", false);
  $('#btnCheckEnrollment').attr("disabled", false);
  
  
}

function onSettings(message){
     switch (message.payload.messageId){
      case plt.msg.BATTERY_INFO_SETTING:
	       updateBatterySettings(message);
	       break;
      case plt.msg.PRODUCT_NAME_SETTING:
	       $('#productName').text(message.payload.productName);
	       break;
      case plt.msg.FIRMWARE_VERSION_SETTING:
	       var version = "Release:" + message.payload.release;
	       $('#firmwareVersion').text(version);
	       break;
      case plt.msg.DECKARD_VERSION_SETTING:
	       var isReleaseVersion = message.payload.releaseVersion;
	       var version = message.payload.majorVersion + "." + message.payload.minorVersion + "(" + message.payload.maintenanceVersion + ')' + (isReleaseVersion ? 'Production' : 'Beta');  
	       $('#deckardVersion').text(version);
	       break;
     }   
}

//battery event update the UI
function updateBatterySettings(message){
  var charge = message.payload.level + 0.0;
  var levels = message.payload.numLevels + 0.0;
  var totalCharge = (100* (charge/levels)) + "%";
  if (message.payload.charging) {
     totalCharge += "(charging)";
  }
  $('#batteryLevel').text(totalCharge);
}

//clear out the UI 
function clearSettings(){
   $('#batteryLevel').text('');
   $('#productName').text('');
   $('#firmwareVersion').text('');
   $('#deckardVersion').text('');
   $('#bdAddress').text('');
   $('#steps').text('');  
}

function getSettings(){
  var message = plt.msg.createGetSetting(plt.msg.PRODUCT_NAME_SETTING);
  plt.sendMessage(connectedDevice, message);
  
  message = plt.msg.createGetSetting(plt.msg.FIRMWARE_VERSION_SETTING);
  plt.sendMessage(connectedDevice,message);
  
  message = plt.msg.createGetSetting(plt.msg.DECKARD_VERSION_SETTING);
  plt.sendMessage(connectedDevice,message);
  
  message = plt.msg.createGetSetting(plt.msg.BATTERY_INFO_SETTING);
  plt.sendMessage(connectedDevice,message);
  
  $('#bdAddress').text(connectedDevice.address);
  
}

function log(message){
  console.log(message);
}
 
//END PLT FUNCTIONS

init();
