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


//UI initialization via JQuery
$(function() {
  $( "#accordion" ).accordion();
});

function init(){
  setControlsState(true);
  readyForCall = false;
  //webrtc stuff
  $('#chkPLTDevice').change(function(){
    if(this.checked){
      connectDevice();
    }
    else{
      disconnectDevice();
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
  $('#chkProximity').change(function(){
    enableProximity(this.checked);
  });
  $("#btnResetPedometer").click(function(){
    resetPedometer();
  });
  $("#btnCalHeadtracking").click(function(){
    calibrateHeadtracking();
  });
  
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
  
  initWebGL();
  
}
var viewer;
function initWebGL(){
  var canvas = document.getElementById('cv');
  viewer = new JSC3D.Viewer(canvas);
  
  viewer.setParameter('SceneUrl', 'model/mother_child_statue.obj');
  viewer.setParameter('InitRotationX', 0);
  viewer.setParameter('InitRotationY', 0);
  viewer.setParameter('InitRotationZ', 0);
  viewer.setParameter('BackgroundColor1', '#060606');
  viewer.setParameter('BackgroundColor2', '#303030');
  viewer.setParameter('RenderMode', 'texture');
  viewer.init();
  viewer.enableDefaultInputHandler(false);
  viewer.update();
  
}
function calibrateHeadtracking(){
  if (!connectedDevice) {
    return;
  }
  log('\ncalibrateHeadtracking(): plt api call to connected device to calibrate head orientation  -> plt.calibrateHeadOrientation(connectedDevice);');
  plt.calibrateHeadOrientation(connectedDevice);
  viewer.resetScene();
  viewer.update();
}

function resetPedometer(){
  var options = {"serviceID": plt.msg.TYPE_SERVICEID_PEDOMETER, "address": sensorPortAddress}
  var calibrationData = new ArrayBuffer(1);
  var calibrationData_view = new Uint8Array(calibrationData);
  //set the reset flag
  calibrationData_view[0] = 1;
  options.calibrationData = calibrationData;
  log('\nresetPedometer(): creating command to resent pedometer -> var command = plt.msg.createCommand(plt.msg.CALIBRATE_SERVICES_COMMAND, options);');
  log('resetPedometer(): options -> ' + JSON.stringify(options) );
  log('resetPedometer(): sending command to connected device -> plt.sendMessage(connectedDevice, command);');
  var command = plt.msg.createCommand(plt.msg.CALIBRATE_SERVICES_COMMAND, options);
  if (connectedDevice) {
    plt.sendMessage(connectedDevice, command);
  }
  $("#steps").text("0");
  
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
   // console.log('onCommandSuccess: command successfully executed: ' + JSON.stringify(commandSuccessMessage));
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
  setControlsState(true);
}

function setControlsState(connected){
  $('#chkHT').attr("disabled", connected);
  $('#chkTap').attr("disabled", connected);
  $('#chkFF').attr("disabled", connected);
  $('#chkPedo').attr("disabled",connected); 
}





function onConnectionOpened(device) {
  if (connectedDevice) {
    return;
  }
  connectedDevice = device;
  log("\nonConnectionOpened(device): callback has been invoked from plt api");
  log("onConnectionOpened(device): connected PLT device ->" + JSON.stringify(connectedDevice));
  if (connectedDevice.isSensorPortEnabled) {
    setControlsState(false);
  }
  $('#chkProximity').attr("disabled",false);
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
   $('#freefall').text('');
   $('#roll').text('');
   $('#pitch').text('');
   $('#heading').text('');
   $('#taps').text('');
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

//PLT checkbox functions 
function enableHeadtracking(on) {
  var options = {"serviceId" : plt.msg.TYPE_SERVICEID_HEADORIENTATION};
  if (!on) {
    $('#roll').text('');
    $('#pitch').text('');
    $('#heading').text('');
  }
  enableWC1Service(on, options);
}

function enableFreeFallDetection(on) {
  var options = {"serviceID" : plt.msg.TYPE_SERVICEID_FREEFALL};
  if (!on) {
    $('#freefall').text('');
  }
  enableWC1Service(on, options);
}

function enableTapDetection(on) {
 var options = {"serviceID" : plt.msg.TYPE_SERVICEID_TAPS};
 if (!on) {
  $('#taps').text('');
 }
 enableWC1Service(on, options);
}

function enablePedometer(on) {
  var options = {"serviceID": plt.msg.TYPE_SERVICEID_PEDOMETER};
  if (!on) {
    $('#steps').text('');
  }
  enableWC1Service(on, options);
}

function enableWC1Service(on, options) {
  options.mode = on ? plt.msg.TYPE_MODEONCCHANGE : plt.msg.TYPE_MODEOFF;
  options.address = sensorPortAddress;
  log('\nenableWC1Service(on, options): creating command to send to enable/disable services on PLT concept device ->  plt.msg.createCommand(plt.msg.SUBSCRIBE_TO_SERVICES_COMMAND, options) ');
  log('enableWC1Service(on, options): options ->' + JSON.stringify(options));
  var message = plt.msg.createCommand(plt.msg.SUBSCRIBE_TO_SERVICES_COMMAND, options); 
  log('enableWC1Service(on, options): sending command to connected device -> plt.sendMessage(connectedDevice, message)');
  plt.sendMessage(connectedDevice, message);
}

function enableProximity(on){
  var options = {"enable": on ? true : false};
  options.sensitivity = 5;
  options.nearThreshold = 0x3C;
  options.maxTimeout = 0xFFFF;
  var message = plt.msg.createCommand(plt.msg.CONFIGURE_SIGNAL_STRENGTH_EVENTS_COMMAND, options);
  log('\nenableProximity(on, options): creating command to send to enable/disable services on PLT concept device ->  plt.msg.createCommand(plt.msg.SUBSCRIBE_TO_SERVICES_COMMAND, options) ');
  log('enableProximity(on, options): options ->' + JSON.stringify(options));
  log('enableProximity(on, options): sending command to connected device -> plt.sendMessage(connectedDevice, message)');
  plt.sendMessage(connectedDevice, message);
}

function log(message){
  console.log(message);
}

function onEvent(info){
 // log('\nonEvent(info): event received');
//  log('onEvent(info): event -> ' + JSON.stringify(info));
  switch (info.payload.messageId) {

    case plt.msg.SUBSCRIBED_SERVICE_DATA_EVENT:
     switch(info.payload.serviceID) {
       case plt.msg.TYPE_SERVICEID_HEADORIENTATION:
         $('#roll').text(info.payload.eulerAngles.roll);
	 $('#pitch').text(info.payload.eulerAngles.pitch);
         $('#heading').text(info.payload.eulerAngles.heading);
	 viewer.rotate(info.payload.eulerAngles.heading, info.payload.eulerAngles.roll, info.payload.eulerAngles.pitch);
	 viewer.update();
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
