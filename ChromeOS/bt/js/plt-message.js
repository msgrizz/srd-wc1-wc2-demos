// PLT Labs experiment - Deckard JS
// Author: Cary Bran
// Message format for PLT Messages

var PROTOCOL_VERSION_TYPE = 0x01;
var GET_REQUEST_TYPE = 0x02;
var GET_RESULT_SUCCESS_TYPE = 0x03;
var GET_RESULT_EXCEPTION_TYPE = 0x04;
var PERFORM_COMMAND_TYPE = 0x05;
var PERFORM_COMMAND_RESULT_SUCCESS_TYPE = 0x06;
var PERFORM_COMMAND_RESULT_EXCEPTION_TYPE =  0x07;
var DEVICE_PROTOCOL_VERSION_TYPE = 0x08;
var METADATA_TYPE = 0x09;
var EVENT_TYPE = 0x0A;
var CLOSE_SESSION_TYPE = 0x0B;
var HOST_PROTOCOL_NEGOTIATION_REJECTION_TYPE = 0x0C;

var BR_HEADER_SIZE = 6;
var BR_ADDRESS_SIZE = 4;
var BR_MESSAGE_ID_SIZE = 2;
var BR_MESSAGE_TYPE_SIZE = 2
var BR_MESSAGE_BOOL_SIZE = 1;

var CONNECTED_DEVICE_EVENT = 0x0C00;
var WEARING_STATE_CHANGED_EVENT = 0x0200;
var CALL_STATUS_CHANGE_EVENT = 0x0E00;
var TEST_INTERFACE_ENABLE_DISABLE_EVENT = 0x1000;
var RAW_BUTTON_TEST_EVENT = 0x1008;

var CREATE_ENABLE_TEST_INTERFACE_MESSAGE_ID = 0x1000;
var RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_MESSAGE_ID = 0x1007;


// Create a message - TOOODO test
var createMessage = function(options){
  if(!options.messageType){
    console.log('createMessage: options requires int field: messageType');
    return null;
  }
  if(!options.address || options.address.byteLength != BR_ADDRESS_SIZE){
    console.log('createMessage: options requires byte[4] field: address');
    return null;
  }
  
  var length = BR_ADDRESS_SIZE + (options.messageId ? BR_MESSAGE_ID_SIZE : 0) + (options.messageData ? options.messageData.byteLength : 0);
  var message = new ArrayBuffer(BR_MESSAGE_TYPE_SIZE + length);
  var message_view = new Uint8Array(message);
  
  //header type - 4 bits
  message_view[0] = PROTOCOL_VERSION_TYPE << 4;
  
  //message length - 12 bits
  message_view[0] |= ((length & 0x0F00) >> 8);
  message_view[1] = (length & 0x00FF);
  
  //address - 17 bits
  message_view[2] = options.address[0];
  message_view[3] = options.address[1];
  message_view[4] = options.address[2];
  message_view[5] = options.address[3]; //the 2-high bits are part of the address, the 2 low bits part of the message type
  
  //message type - 4 bits + preserve any addressing
  message_view[5] |= (options.messageType & 0x00FF);
  
  if(options.messageId){
   //message id - split into two bytes
    message_view[6] = ((options.messageId & 0xFF00) >> 8);
    message_view[7] = (options.messageId & 0x00FF);
  }
  
  if(options.messageData){
    //if there is a message id, shift the start of the data writing by 2 bytes
    var index = options.messageId ? (BR_HEADER_SIZE + BR_MESSAGE_ID_SIZE) : BR_HEADER_SIZE;
    var data_view = new Uint8Array(options.messageData);
    for(i=0; i < options.messageData.byteLength; i++){
      message_view[index++] = data_view[i];
    }
  }
  
  return message;

};

//The packet looks like this in byte array form:
//-0X10
//-0X7
//-0X0
//-0X0
//-0X0
//-0X1
//-0X1
//-0X1
//-0X0
var createHostNegotiateMessage = function(){
  var options = new Object();
  options.messageType = PROTOCOL_VERSION_TYPE;
  var address = new ArrayBuffer(BR_ADDRESS_SIZE);
  var address_view = new Uint8Array(address);
  options.address = address;
  var data = new ArrayBuffer(3);
  var data_view = new Uint8Array(data);
  data_view[0] = 0X1;
  data_view[1] = 0X1; 
  options.messageData = data;  
  return createMessage(options);
  
}

//Enables button press events - note the create enable test inteface command must be sent fir
var createEnableButtonsMessage = function(options){
  if(!options.enabled){
    console.log('options requires boolean field: enabled');
    return null;
  }
  if(!options.address || options.address.byteLength != BR_ADDRESS_SIZE){
    console.log('options requires byte[4] field: address');
    return null;
  }
  options.messageType = PERFORM_COMMAND_TYPE;
  options.messageId = RAW_BUTTONTEST_EVENT_ENABLE_DISABLE_MESSAGE_ID;
  var data = new ArrayBuffer(BR_MESSAGE_BOOL_SIZE);
  var data_view = new Uint8Array(data);
  data_view[0] = options.enabled ? 0x1 : 0x0;
  options.messageData = data;  
  return createMessage(options);  
}

//creates the command message needed to enable/disable the 
//test interface features - which are a prerequisite for 
//features like button press events
var createEnableTestInterfaceMessage = function(options){
  if(!options.enabled){
    console.log('options requires boolean field: enabled');
    return null;
  }
  if(!options.address || options.address.byteLength != BR_ADDRESS_SIZE){
    console.log('options requires byte[4] field: address');
    return null;
  }
  
  options.messageType = PERFORM_COMMAND_TYPE;
  options.messageId = CREATE_ENABLE_TEST_INTERFACE_MESSAGE_ID;
  var data = new ArrayBuffer(BR_MESSAGE_BOOL_SIZE);
  var data_view = new Uint8Array(data);
  data_view[0] = options.enabled ? 0x1 : 0x0;
  options.messageData = data;  
  return createMessage(options);  
}



//expects byte array as parameter
var parseDevicePrototol = function(message, callback){
  if(!message || !callback){
    return;
  }
  var data_view = new Uint8Array(message, BR_HEADER_SIZE);
  callback(data_view[0], data_view[1]);
}


//expects byte array as parameter
var parseException = function(message){
  if(!message){
    return null;
  }
  var data_view = new Uint8Array(message, BR_HEADER_SIZE);
  var exceptionId = parseShortArray(0, data_view, 2);
  return exceptionId[0];
}

//expects byte array as parameter
var parseEvent = function(message, callback){
  var data_view = new Uint8Array(message, BR_HEADER_SIZE);
  var eventId = parseShortArray(0, data_view, 2);
  //todo -fix array/json insert of property
  var event = new Object();
  event.id = eventId[0];
  event.properties = {};
  switch(event.id){
    case WEARING_STATE_CHANGED_EVENT:
      event.name = "wearstatechanged";
      event.properties['worn'] = data_view[2] == 0x1 ? true : false;
      break;
    case CONNECTED_DEVICE_EVENT:
      event.name = "connecteddevice";
      event.properties['address'] = data_view[2];
      break;
    case TEST_INTERFACE_ENABLE_DISABLE_EVENT:
      event.name = "testinterfaceenabledisable";
      event.properties['enabled'] = data_view[2] == 0x1 ? true : false;
      break;
    case RAW_BUTTON_TEST_EVENT:
      event.name = "button";
      event.properties['pressType'] = data_view[2];
      event.properties['buttonId'] = data_view[3];
      event.properties['buttonName'] = getButtonName(event.properties['buttonId']);
      break;
    case CALL_STATUS_CHANGE_EVENT:
      event.name = "callstatuschange";
      event.callStateName = callStateStringLookup(data_view[2]);
      event.state = data_view[2];
      var phoneNumberLength = parseShortArray(3, data_view, (3 + BR_MESSAGE_ID_SIZE));
      var phoneNumber = parseCharArray((3 + BR_MESSAGE_ID_SIZE), data_view,(3 + BR_MESSAGE_ID_SIZE + phoneNumberLength));
      event.phoneNumber = phoneNumber.join("");
      //todo parse buffer
      break;
  }
 
  callback(event);
  
}

//expects byte array as parameter
var parseMetadata = function(message, callback){
  
  if(!message){
    console.log("parseMetadata: no message to parse");
    return;
  }
  
  //allocate the array and skip the header information
  var data_view = new Uint8Array(message, BR_HEADER_SIZE);
  
  var index = 0;
  var bounds = 2;
  
  //calculate the array length using the first two bytes of the data view - first byte is the high byte, second is the low
  var arrayLength = parseShortArray(index, data_view, bounds);
  
  //adjust the index to point to the start of the array
  index += 2;
  
  //Set the bounds to the upper limit of the array  
  //bounds is multipled by 2 because the array sent back from the device
  //are 16 bit short integers - which map over to message ids
  bounds = index + (2 * arrayLength[0]);
  var commands = parseShortArray(index, data_view, bounds);
  console.log("parseMetadata: Commands size = " + commands.length + "\n\tlist:" + commands.toString());
  
  index = bounds;
  bounds = index + 2;
  arrayLength = parseShortArray(index, data_view, bounds);
  index += 2;
  bounds = index +  (2 * arrayLength[0]);
  var getters = parseShortArray(index, data_view, bounds);
  console.log("parseMetadata: Getters size = " + getters.length + "\n\tlist:" + getters.toString());
  
  index = bounds;
  bounds = index + 2;
  arrayLength = parseShortArray(index, data_view, bounds);
  index += 2;
  bounds = index +  (2 * arrayLength[0]);
  var events = parseShortArray(index, data_view, bounds);
  console.log("parseMetadata: Events size = " + events.length + "\n\tlist:" + events.toString());
  
 
  index = bounds;
  bounds = index + 2;
  arrayLength = parseShortArray(index, data_view, bounds);
  index += 2;
  bounds = index + arrayLength[0] //bytes instead 16 bit integers
  //for available ports - this array is stored as single bits
  var availablePorts = parseByteArray(index, data_view, bounds)
  console.log("parseMetadata: Available ports size = " + availablePorts.length + "\n\tlist:" + availablePorts.toString());
  var deviceMetadata = {"supportedCommands" : commands,
                        "supportedGetSettings" : getters,
                        "supportedEvents" : events,
                        "availablePorts" : availablePorts};
  callback(deviceMetadata);
  
};
function getButtonName(buttonId){
   switch(buttonId){
    case 1:
      return "Power";
    case 2: 
      return "Hook";                            
    case 3: 
      return "Talk";
    case 4: 
      return "Volume Up";
    case 5: 
      return "Volume Down";
    case 6: 
      return "Mute";
    default:
      return "Unknown";
   }
}
  
function callStateStringLookup(callStateCode){
  switch(callStateCode){
    case 0:
      return "Idle";
    case 1: 
      return "Active";                            
    case 2: 
      return "Ringing";
    case 3: 
      return "Dialing";
    default:
      return "Unknown";
  }
}

function parseCharArray(index, buffer, bounds){
   var result = new Array();
   for(index; index < bounds; index++){
    var val = buffer[index]
    result.push(String.fromCharCode(val));
  }
  return result;
}
function parseByteArray(index, buffer, bounds){
   var result = new Array();
   for(index; index < bounds; index++){
    var val = buffer[index]
    result.push(val);
  }
  return result;
}
function parseShortArray(index, buffer, bounds){
   var result = new Array();
   for(index; index < bounds; index+=2){
    var val = buffer[index] << 8;
    val += (buffer[index+1] & 0xFF);
    result.push(val);
  }
  return result;
}