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
var IDLE_STATE = -1;
var PINGING_STATE = 0;
var ENROLLING_STATE = 1;
var SIGNING_STATE = 2;
var TOUCHING_STATE = 3;

var currentFidoState = IDLE_STATE;
var isEnrolled = false;
var sessionId;



//UI initialization via JQuery
$(function() {
  $( "#accordion" ).accordion();
});

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
  
  $('#btnPing').attr("disabled", true);
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



var serverURL = "http://localhost:8080";
function enroll(){
  getEnrollDataFromServer("joe", "1234",  onEnrollData);
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
      
      log("onEvent: Pass through event recieved");
      switch(currentFidoState){
	case IDLE_STATE:
	  throw "onEvent: fido event recieved during idle state";
	  break;
	case SIGNING_STATE:
	  log("onEvent: processing APDU signing result from device");
	  break;
	case ENROLLING_STATE:
	  log("onEvent: processing APDU enrollment result from device");
	  break;
	case TOUCHING_STATE:
	  log("onEvent: processing APDU touch result from device");
	  touchResponse(info);
	  break;
	case PINGING_STATE:
	  log("onEvent: processing APDU ping result from device");
	  validatePing(info);
	  break;
      }
      //resent the state
      currentFidoState = IDLE_STATE;
      break;
  }
}

function touchResponse(event){
  var touchResponse = unPackBinaryToHex(event.payload.dataBlob);
  $('#touchState').text("Secure element touched: " + touchResponse);
  $('#chkTouchSecureElement').attr("disabled", true);
  $('#btnEnroll').attr("disabled", false);
}

function validatePing(event){
  var pingReturnStringHex = "0102030405060708090a0b0c0d0e0f10199000";	// Includes return status
  var pingSuccessStatus = "9000";

  if (!event) {
    return;
  }
  log("validatePing: validating secure element ping");
  var validPingResponse = "0102030405060708090a0b0c0d0e0f109000";
  var binaryArray = event.payload.dataBlob;
  var pingResponse = unPackBinaryToHex(binaryArray);
  log("validatePing: response from secure element :" + pingResponse);

  // Validate status code which is the last 4 characters of the response
  var status = pingResponse.substring(pingResponse.length - 4);
  console.log("validatePing: status = " + status);
  if (status != pingSuccessStatus){
    $('#pingResult').text("validatePing: Bad APDU return status: " + status);
    return;
  }

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
  console.log("validatePing: version = " + version);
  // Validate ping return
  var pingReturnString = pingResponse.substring(endOfString + 2);
  if (pingReturnString != pingReturnStringHex){
    $('#pingResult').text("Invalid Ping: " + pingReturnString);
    return;
  }
  
  $('#pingResult').text("Ping successful!");
}

function onEnrollData(data){
  log("onEnrollData: got back the enroll data from the server");
  log("onEnrollData: JSON -> " + JSON.stringify(data));
  sessionId = data.sessionId;
  var enrollRequest = {
        type: "enroll_web_request",
        enrollChallenges: [
            {
              "appId": data.appId,
              "challenge": data.challenge,
              "version": data.version
            }
        ]
    };
  var apdu = createEnrollAPDU(enrollRequest);
  log("onEnrollData: enroll apdu is " + apdu.byteLength + " bytes")
  var options = {"protocolid": plt.msg.TYPE_PROTOCOLAPDU, "dataBlob": apdu, "address": sensorPortAddress};
  var command = plt.msg.createCommand(plt.msg.PASS_THROUGH_PROTOCOL_EVENT, options);
  if (connectedDevice) {
    currentFidoState = ENROLLING_STATE;
    log("onEnrollData: sending ADPU enroll command to device");
    plt.sendMessage(connectedDevice, command);
  }  
}

function enrollDevice(event){
  if (!event) {
    return;
  }
  log("enrollDevice: sending device enrollment back to server");
  var apdu = unPackBinaryToHex(event.payload.dataBlob);
  var words = CryptoJS.enc.Hex.parse(apdu);
  var base64Apdu = CryptoJS.enc.Base64.stringify(words);
  var urlSafeApdu = base64ToURLSafe(base64Apdu);
  
  
  //var url = serverURL + "/enrollFinish?browserData=" + userName + "&password=" + password;
  /*
   *
   *if (command === "enroll")
		{
			callbackData = {
				responseData:
				{
			 		browserData:btoa(JSON.stringify(browserData)), 
					challenge: "challenge",	// This is not being used
					enrollData:webEncodedReturnData
				
				}
			};
			
			
		}
		
		
			  // Return OK results with data in a structure
      var responseData = extensionResult.responseData;
      callback({
        browserData: responseData.browserData,
        challenge: responseData.challenge,
        enrollData: responseData.enrollData,
        sessionId: sessionId
      });
   document.location = "/enrollFinish"
		            + "?browserData=" + result.browserData
		            + "&challenge=" + result.challenge
		            + "&enrollData=" + result.enrollData
		            + "&sessionId=" + result.sessionId;
   */
  
}

function getEnrollDataFromServer(userName, password, callback){
  var url = serverURL + "/enrollData.js?userName=" + userName + "&password=" + password;
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

function ping(){
  var apdu = createPingAPDU();
  var options = {"protocolid": plt.msg.TYPE_PROTOCOLAPDU, "dataBlob": apdu, "address": sensorPortAddress};
  var command = plt.msg.createCommand(plt.msg.PASS_THROUGH_PROTOCOL_EVENT, options);
  if (connectedDevice) {
    currentFidoState = PINGING_STATE;
    plt.sendMessage(connectedDevice, command);
  }
}

function touch() {
  var apdu = createTouchAPDU();
  var options = {"protocolid": plt.msg.TYPE_PROTOCOLAPDU, "dataBlob": apdu, "address": sensorPortAddress};
  var command = plt.msg.createCommand(plt.msg.PASS_THROUGH_PROTOCOL_EVENT, options);
  if (connectedDevice) {
    currentFidoState = TOUCHING_STATE;
    plt.sendMessage(connectedDevice, command);
  }

}

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
  $('#chkTouchSecureElement').attr("disabled", true);
}


function onConnectionOpened(device) {
  if (connectedDevice) {
    return;
  }
  connectedDevice = device;
  log("\nonConnectionOpened(device): callback has been invoked from plt api");
  log("onConnectionOpened(device): connected PLT device ->" + JSON.stringify(connectedDevice));
  $('#chkProximity').attr("disabled",false);
  $('#chkTouchSecureElement').attr("disabled", false);
  $('#btnPing').attr("disabled", false);
  getSettings();
  
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
