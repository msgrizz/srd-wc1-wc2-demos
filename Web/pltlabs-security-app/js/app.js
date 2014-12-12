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

//End U2F

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

function ping(){
  var apdu = createPingAPDU();
  var options = {"protocolid": plt.msg.TYPE_PROTOCOLAPDU, "dataBlob": apdu, "address": sensorPortAddress};
  var command = plt.msg.createCommand(plt.msg.PASS_THROUGH_PROTOCOL_EVENT, options);
  if (connectedDevice) {
    plt.sendMessage(connectedDevice, command);
  }
}

var serverURL = "http://localhost:8080";
function enroll(){
  getEnrollDataFromServer("joe", "1234",  onEnrollData);
}

function onEnrollData(data){
  log("onEnrollData: got back the enroll data from the server");
  log("onEnrollData: JSON -> " + JSON.stringify(data));
  log("onEnrollData: creating enroll APDU");
  var apdu = createEnrollAPDU(data);
  //todo create the enroll APDU
  //send the APDU to the SE
  //send the results back to the server
  
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

function touch() {
  var apdu = createTouchAPDU();
  var options = {"protocolid": plt.msg.TYPE_PROTOCOLAPDU, "dataBlob": apdu, "address": sensorPortAddress};
  var command = plt.msg.createCommand(plt.msg.PASS_THROUGH_PROTOCOL_EVENT, options);
  if (connectedDevice) {
    plt.sendMessage(connectedDevice, command);
  }

}

function touchBack(obj){
  log("touchBack called: ")
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
  log("\nonSettings(message): setting callback from plt api");
  log("onSettings(message): setting ->" + JSON.stringify(message));
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
  log('\ngetSettings(): getting product name by creating a message to send to plt api -> var message = plt.msg.createGetSetting(plt.msg.PRODUCT_NAME_SETTING);');
  log('getSettings(): sending message to get product name -> plt.sendMessage(connectedDevice, message);');
  plt.sendMessage(connectedDevice, message);
  
  message = plt.msg.createGetSetting(plt.msg.FIRMWARE_VERSION_SETTING);
  log('\ngetSettings(): getting firmware version by creating a message to send to plt api -> var message = plt.msg.createGetSetting(plt.msg.FIRMWARE_VERSION_SETTING);');
  log('getSettings(): sending message to get firmware version -> plt.sendMessage(connectedDevice, message);');
  plt.sendMessage(connectedDevice,message);
  
  message = plt.msg.createGetSetting(plt.msg.DECKARD_VERSION_SETTING);
  log('\ngetSettings(): getting m2m version by creating a message to send to plt api -> var message = plt.msg.createGetSetting(plt.msg.DECKARD_VERSION_SETTING);');
  log('getSettings(): sending message to get m2m version -> plt.sendMessage(connectedDevice, message);');
  plt.sendMessage(connectedDevice,message);
  
  message = plt.msg.createGetSetting(plt.msg.BATTERY_INFO_SETTING);
  log('\ngetSettings(): getting device battery status by creating a message to send to plt api -> var message = plt.msg.createGetSetting(plt.msg.BATTERY_INFO_SETTING);');
  log('getSettings(): sending message to get device battery status version -> plt.sendMessage(connectedDevice, message);');
  plt.sendMessage(connectedDevice,message);
  
  log('\ngetSettings() device bluetooth address accessed from connected device -> connectedDevice.address')
  $('#bdAddress').text(connectedDevice.address);
  
}

function log(message){
  console.log(message);
}


function onEvent(info){
 // log('\nonEvent(info): event received');
  log('onEvent(info): event -> ' + JSON.stringify(info));
  switch (info.payload.messageId) {

    case plt.msg.SUBSCRIBED_SERVICE_DATA_EVENT:
     break;
    case plt.msg.BATTERY_STATUS_CHANGED_EVENT:
      updateBatterySettings(info);
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
     break;
    }
  
};  
//END PLT FUNCTIONS

init();
