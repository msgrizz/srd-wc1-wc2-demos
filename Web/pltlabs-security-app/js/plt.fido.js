// JavaScript Document


var APDU_PASSTHROUGH = true;

var U2F_ENROLL = "02";
var U2F_SIGN = "04"
var U2F_ECHO_PHYSICAL_PRESENCE = "0c"
var XAPDU_XMIT_BIT = "40";

var returnLargeAPDUHex = "";	// For consolidating chunks of returned APDU's.
var moreCommandHeader = "";	// Remember command header to chain return commands together
var largeAPDUReturnChunk;	// Keeping track of chunks returned


  function base64ToURLSafe(text)
  {
  	var returnString = "";

  	for (var i = 0; i < text.length; i++)
  	{
  		var ch = text.charAt(i);
  		switch (ch)
  		{
  			case '+':
  				returnString += '-';
  				break;
  			case '/':
  				returnString += '_';
  				break;
  			case '=':
 				returnString += '*';
  				break;

  			default:
 				returnString += ch;
  				break;
 
  		}

  	}

  	return returnString;


  }

  // TODO: This is not very efficient - need to find routines to properly handle URL safe base64
  function base64FromURLSafe(text)
  {
  	var returnString = "";

  	for (var i = 0; i < text.length; i++)
  	{
  		var ch = text.charAt(i);
  		switch (ch)
  		{
  			case '-':
  				returnString += '+';
  				break;
  			case '_':
  				returnString += '/';
  				break;
  			case '*':
 				returnString += '=';
  				break;

  			default:
 				returnString += ch;
  				break;
 
  		}

  	}

  	return returnString;
  }


  function sendAPDUCommand(apdu, callback, browserData, command, sessionID)
  {
  	//console.log("*************** SENDING APDU *******************");
  	//console.log("Browser data:");
  	//console.log(browserData);

	var url = "http://localhost:4107/apdu";

	$.ajax({
		url: url,
		type: 'post',
		data: apdu,
		crossDomain: true,
		success: function (result) 
				{
					handleRawAPDUReturn(result, callback, browserData, command, sessionID);						
			
				},
		})
		.done( function(e) 

		{
			console.log("sucess");
				
		}).fail( function(e) {
			console.log("Fail");
			console.log(e);		

		});

  }

  function handleRawAPDUReturn(result, callback, browserData, command, sessionID)
  {
 /*
  	console.log("===================HANDLE APDU======================");
  	console.log("Callback:");
  	console.log(callback);
  	console.log("Brower Data:");
  	console.log(browserData);

	console.log("APDU results");
	console.log(result);
*/

	// Decode the escape sequences
	resultDecodedURLSafe = decodeURIComponent(result);
	//console.log("Decoded:");
	//console.log(resultDecoded);
	var resultDecoded = base64FromURLSafe(resultDecodedURLSafe);


	// Convert to hex

	var words = CryptoJS.enc.Base64.parse(resultDecoded);
	var resultsHex = CryptoJS.enc.Hex.stringify(words);
	//console.log("Hex: " + resultsHex);
	//console.log("Hex length: " + resultsHex.length);

	////////////////////////////// HANDLE STATUS BACK ///////////////////////
	// Validate last 2 characters are good status 9000
	var resultLength = resultsHex.length;
	var statusWord = resultsHex.substring(resultLength - 4);
	//console.log("Status Word: " + statusWord);
	if (statusWord != "9000")
	{
		// Handle sign check results
		// This should NEVER return a 9000....TODO: Check on this and the use of sign_check below
		if (command === "sign_check")
		{
			if ( (statusWord === "6a80") || (statusWord === "6984") )
			{
				callback(0);
				return;

			}

			else if (statusWord == "6985")
			{
				callback(1);
				return;
			}

		}

		else if (command === "sign")
		{
			if (statusWord === "6a80")
			{
				alert("Key handle error - APP ID mismatches");
				return;
			}
			else if (statusWord == "6985")
			{
				alert("Physical presence not asserted");
				return;
			}

		}

		else if (command === "enroll")
		{
			if (statusWord == "6985")
			{
				alert("Physical presence not asserted");
				return;
			}
		}

		alert("Bad APDU return status: " + statusWord);
		return;
	}

	//////////////////////////////////////////////////////////////////////////

	//console.log("Status OK");

	// Add to ongoing return large apdu
	// Remove beginning byte and status word
	returnLargeAPDUHex += resultsHex.substring(2, resultLength - 4);
	//console.log("Large APDU:");
	//console.log(returnLargeAPDUHex);


	// Look at more byte
	var more = (resultsHex.substring(0, 2)  === "80");
	//console.log("More flag: " + more);

	/////////////// Next step ////////////////
	if (more)
	{
			// Build up APDU
			largeAPDUReturnChunk++;
			var APDUHex = moreCommandHeader + "0" + largeAPDUReturnChunk.toString(16);	// Won't be more than 5 chunks
			//console.log("More APDU: " + APDUHex);

			// Convert to base 64
			var words = CryptoJS.enc.Hex.parse(APDUHex);
			var APDUbase64 = CryptoJS.enc.Base64.stringify(words);
			var APDUbase64URLSafe = base64ToURLSafe(APDUbase64);
			//console.log("Base64 APDU: " + APDUbase64URLSafe);

			// Send APDU command recursively
			sendAPDUCommand(APDUbase64URLSafe, callback, browserData, command);

			return;


	}
	else
	{
		//console.log("About to process large apdu:");
		//console.log(returnLargeAPDUHex);


		// Base 64 encode the data 
		var words = CryptoJS.enc.Hex.parse(returnLargeAPDUHex);
		var APDUbase64 = CryptoJS.enc.Base64.stringify(words);
		var APDUbase64URLSafe = base64ToURLSafe(APDUbase64);
		//console.log("Base64 APDU: " + APDUbase64URLSafe);

		// Web encode it
		var webEncodedReturnData = encodeURIComponent(APDUbase64URLSafe);
		//console.log("Encoded: " + webEncodedReturnData);

		//console.log("Browser data");
		//console.log(browserData);

		// Generate callback data
		var callbackData;
		if (command === "enroll")
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
		else if ( (command === "sign") || (command === "sign_check") )	// TODO: Might not need the sign_check
		{
			callbackData = {
				responseData:
		 		{
			 	 	browserData:btoa(JSON.stringify(browserData)), 
					challenge: "challenge",	// This is not being used
					signData:webEncodedReturnData,
					appId:"appId",	// Check if this is being used
					sessionId:sessionID
					
		 		}
			};


		}
		else if (command === "checkTouch")
		{
			if (resultsHex.substring(0, 2) === "01")
			{
				callback();
			}

			return;
		}

		else
		{
			alert("Bad command in callback");
			return;
		}

		//console.log("Callback data:");
		//console.log(callbackData);
		callback(callbackData);


	}




  }

  function fauxSendEnrollRequest(jsonData, callback)
  {
	  
	  // Test objects
/*
	     var testResult = {code:"Fake Error"};
 
 	     var testResult = {responseData:
		 	{
			 	browserData:"browserData", 
				challenge: "challenge",
				enrollData:"enrollData"
				
		 	}
		};
		 

	  callback(testResult);
*/
	  
	  
	  
	//	alert(JSON.stringify(jsonData));  
		// Add the browser data to the JSON object
		// I.e. Embed the challenge from the JSON object into the new JSON item
		var browserData = {typ:"navigator.id.finishEnrollment", challenge:JSON.stringify(jsonData.enrollChallenges[0].challenge)};
		jsonData.enrollChallenges[0].browserData = browserData;
		
		logit('Sending Request to server:');
		logit(JSON.stringify(jsonData));


		///////////////////////////// Raw APDU variation ////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////
		if (APDU_PASSTHROUGH)
		{
			// Hash browser data
			var browserDataString = JSON.stringify(browserData);
			//console.log("Browser data: " + browserDataString);
			//console.log("Hash: ");
			var hashBrowserData = CryptoJS.SHA256(browserDataString);
			var hashBrowserDataHex = hashBrowserData.toString(CryptoJS.enc.Hex);
			//console.log(hashBrowserDataHex);

			// Hash app id
			var AppIDString = jsonData.enrollChallenges[0].appId
			//console.log("AppID: " + AppIDString);
			//console.log("Hash: ");
			var hashAppID = CryptoJS.SHA256(AppIDString);
			var hashAppIDHex = hashAppID.toString(CryptoJS.enc.Hex);
			//console.log(hashAppIDHex);

			// Build up APDU
			var len = hashBrowserDataHex.length / 2 + hashAppIDHex.length / 2 + 1;
			//console.log("Length is: " + len);
			var lenHex = len.toString(16);
			//console.log("Hex length is: " + lenHex);
			var APDUHex = "00" + U2F_ENROLL + "0000" + lenHex + XAPDU_XMIT_BIT + hashBrowserDataHex + hashAppIDHex;
			//console.log("APDU HEX: " + APDUHex);

			// Remember header to get more return data when needed
			// Leave out the 1 byte of data as this will be added
			moreCommandHeader = APDUHex.substring(0, 8) + "01";
			//console.log("Repeat header: " + moreCommandHeader);
			largeAPDUReturnChunk = 0;	// Reset this to 0 as we track the chunks


			// Convert to base 64
			var words = CryptoJS.enc.Hex.parse(APDUHex);
			var APDUbase64 = CryptoJS.enc.Base64.stringify(words);
			var APDUbase64URLSafe = base64ToURLSafe(APDUbase64);
			//console.log("Base64 APDU: " + APDUbase64URLSafe);

			// Convert it back (to test)
			//words = CryptoJS.enc.Base64.parse(APDUbase64);
			//var convertedHex = CryptoJS.enc.Hex.stringify(words);
			//console.log("Converted back: " + convertedHex);

			// Prepare for large APDU return
			returnLargeAPDUHex = "";

			// Send APDU command recursively
			sendAPDUCommand(APDUbase64URLSafe, callback, browserData, "enroll", null);
			

			return;


		}


		////////////////////////////////////////// Original Variation /////////////////////////

		
//		alert(JSON.stringify(jsonData.enrollChallenges[0].challenge));
		
	var url = "http://localhost:4107/fido";
//	var url = "http://127.0.0.1:4107/index10.html";
	$.ajax({
		url: url,
		type: 'post',
//		data: jsonData,
		data: JSON.stringify(jsonData),
		crossDomain: true,
		success: function (result) 
			{
				
				  var callbackData = {
					  responseData:
		 			  {
			 		 	browserData:btoa(JSON.stringify(browserData)), 
						challenge: "challenge",	// This is not being used
						enrollData:result
				
		 			 }
				};
				callback(callbackData);
	
			},
	})
	.done( function(e) 

	{//sucess
//		alert('sucess');
		
	}).fail( function(e) {
		console.log(e);		

// To check all object properties
/*		
		for(var propt in e){
    logit(propt + ': ' + e[propt]);
}
*/
		
		switch (e.status)
		{
			case 506:	// Physical presence - Converted from APDU status of 0x6985
				alert("Error: " + e.statusText);
				break;
			case 500: // Undefined
				alert("Error (Undefined):" + e.statusText);	
				break;
			default:
				alert("Unknown / other error: " + e.status + "[" + e.statusText + "]");
				break;
			
		}

	});
	
		
	  
  }

  function fauxSendSignRequest(jsonData, callback)
  {
		logit(JSON.stringify(jsonData));
		logit('Sending Request to server:');
  
		 var url = "http://localhost:4107/fido";	// General FIDO command
		 
		 // Isolate variables to send back on callback
		 var sessionIDExtracted = jsonData.signData.sessionId;
		 
		var browserData = {typ:"navigator.id.getAssertion", challenge:JSON.stringify(jsonData.signData.challenge)};	

		// Determine if this is a check key handle
		var checkOnly = jsonData.type.localeCompare("sign_check_keyhandle") ? 0 : 1;


//		jsonData.signData.appId = "badappid";		// Corrupt appID - for testing	

		//////////////////////  CHECK THE ORIGIN & ADD TO BROWSER DATA //////////////////////
/*
		// Check the origin
		var serverOrigin = jsonData.signData.appId.replace('http://', '');	// Hard coded in server
		var browserOrigin = document.location.host;	// From browser URL
		if (serverOrigin.localeCompare(browserOrigin) != 0)
		{
			alert("ERROR: Browser origin doesn't match the server");
			return;
		}

		// Add it to the browser data
		browserData.origin = "http://" + document.location.host;
//		browserData.origin = "http://" + "crap";	// To test a bad origin

*/
		/////////////////////////////////////////////////////////////////

		///////////////////////////// Raw APDU variation ////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////
		if (APDU_PASSTHROUGH)
		{
			//console.log("JSON Data:");
			//console.log(jsonData);


			//return;

			// Command - Check only vs. sign
			var typeCommand = undefined;
			var commandString = undefined;
			if (checkOnly)
			{
				typeCommand = "07";
				commandString = "sign_check";
			}
			else
			{
				typeCommand = "03";
				commandString = "sign";
			}

			// Hash browser data
			var browserDataString = JSON.stringify(browserData);
			//console.log("Browser data: " + browserDataString);
			//console.log("Hash: ");
			var hashBrowserData = CryptoJS.SHA256(browserDataString);
			var hashBrowserDataHex = hashBrowserData.toString(CryptoJS.enc.Hex);
			//console.log(hashBrowserDataHex);

			// Hash app id
			var AppIDString = jsonData.signData.appId;
			//console.log("AppID: " + AppIDString);
			//console.log("Hash: ");
			var hashAppID = CryptoJS.SHA256(AppIDString);
			var hashAppIDHex = hashAppID.toString(CryptoJS.enc.Hex);
			//console.log(hashAppIDHex);

			// Key Handle
			var keyHandleBase64UrlSafe = jsonData.signData.keyHandle;
			var keyHandleBase64 = base64FromURLSafe(keyHandleBase64UrlSafe);

			//console.log("Key handle URL Safe base64:");
			//console.log(keyHandleBase64UrlSafe);
			//console.log("Key handle base64:");
			//console.log(keyHandleBase64);
			var words = CryptoJS.enc.Base64.parse(keyHandleBase64);
			var keyHandleHex = CryptoJS.enc.Hex.stringify(words);

			//console.log("Key Handle hex:");
			//console.log(keyHandleHex);


			// Build up APDU
			var len = hashBrowserDataHex.length / 2 + hashAppIDHex.length / 2 + keyHandleHex.length / 2 + 2;
			//console.log("Length is: " + len);
			var lenHex = len.toString(16);
			//console.log("Hex length is: " + lenHex);
			var APDUHex = "00" + U2F_SIGN + "0000" + lenHex + XAPDU_XMIT_BIT + typeCommand + hashBrowserDataHex + hashAppIDHex + keyHandleHex;
			//console.log("APDU HEX: " + APDUHex);

			// Remember header to get more return data when needed
			// Leave out the 1 byte of data as this will be added
			moreCommandHeader = APDUHex.substring(0, 8) + "01";
			//console.log("Repeat header: " + moreCommandHeader);
			largeAPDUReturnChunk = 0;	// Reset this to 0 as we track the chunks


			// Convert to base 64
			var words = CryptoJS.enc.Hex.parse(APDUHex);
			var APDUbase64 = CryptoJS.enc.Base64.stringify(words);
			var APDUbase64URLSafe = base64ToURLSafe(APDUbase64);
			//console.log("Base64 APDU: " + APDUbase64URLSafe);

			// Convert it back (to test)
			//words = CryptoJS.enc.Base64.parse(APDUbase64);
			//var convertedHex = CryptoJS.enc.Hex.stringify(words);
			//console.log("Converted back: " + convertedHex);

			// Prepare for large APDU return
			returnLargeAPDUHex = "";

			// Send APDU command recursively
			sendAPDUCommand(APDUbase64URLSafe, callback, browserData, commandString, sessionIDExtracted);
			

			return;


		}


		////////////////////////////////////////// Original Variation /////////////////////////
		
  		// Add the browser data to the JSON object
		// I.e. Embed the challenge from the JSON object into the new JSON item
		jsonData.signData.browserData = browserData;

		
	$.ajax({
		url: url,
		type: 'post',
//		data: jsonData,
		data: JSON.stringify(jsonData),
		crossDomain: true,
		success: function (result) 
			{

				  var callbackData = {
					  responseData:
		 			  {
			 		 	browserData:btoa(JSON.stringify(browserData)), 
						challenge: "challenge",	// This is not being used
						signData:result,
						appId:"appId",	// Check if this is being used
						sessionId:sessionIDExtracted
						
				
		 			 }
				};
								
				
				callback(callbackData);
	
			},
	})
	.done( function(e) 

	{//sucess
//		alert('sucess');
		
	}).fail( function(e) {
		console.log(e);		
		/////////////////////////// HANDLING KEY HANDLE CHECK /////////////////////
		if (checkOnly == 1)
		{
			switch (e.status)
			{
				case 506:	// Physical presence - this means it's VALID - Translated from ISO error 0x6985
					callback(1);
					break;
				// These next 2 means it's an invalid key, but that's not an error
				case 507:	// Invalid APP ID unwrapped - Translated from ISO error 0x6a80
				case 508:	// Invalid key handle - Translated from ISO error 0x6984
					callback(0);
					break;

				// These are errors
				case 510:	// Bad data sent to token
					alert("Error: " + e.statusText + " (Bad data sent to token");
					break;
				case 500:	// Undefined
					alert("Error (Undefined):" + e.statusText);	
					break;
				default:
					alert("Unknown / other error: " + e.status + "[" + e.statusText + "]");
					break;
				
			}

		}
		/////////////////////////// HANDLING SIGNATURE /////////////////////
		else
		{
			switch (e.status)
			{
				case 506:	// Physical presence
					alert("Error: " + e.statusText);
					break;
				case 507:	// Invalid APP ID unwrapped - mapped to 0x6a80
					alert("Error: " + e.statusText + " (APP ID mismatches)");
					break;
				case 508:	// Invalid key handle
					alert("Error: " + e.statusText + " (Key handle not valid)");
					break;
				case 510:	// Bad data sent to token
					alert("Error: " + e.statusText + " (Bad data sent to token");
					break;
				case 500:	// Undefined
					alert("Error (Undefined):" + e.statusText);	
					break;
				default:
					alert("Unknown / other error: " + e.status + "[" + e.statusText + "]");
					break;
				
			}
	}
	});
  }


  //takes a hex string and for each character this
  //method will parse the integer value and packs it into a uint8 byte array 
  function packHexToBinary(hexString){
      if (!hexString || hexString == "") {
            throw "Error parsing hexidecimal string to binary array";
      }
      var buffer = new ArrayBuffer(hexString.length/2);
      var data_view = new Uint8Array(buffer);
      var index = 0;
      for (var i = 0; i < hexString.length; i+=2) {
          var sub = hexString.charAt(i) + hexString.charAt(i+1);
          var b = parseInt(sub, 16);
          data_view[index++] = b;
      }
      return buffer;
  }
  
  //this function unpacks the byte array into a series of hex values
  function unPackBinaryToHex(byteArray){
      if (!byteArray) {
            throw "invalid byte array passed";
      }
      var data_view = new Uint8Array(byteArray);
      var hexString = "";
      for(var i = 0; i < data_view.length; i++){
            hexString += data_view[i].toString(16);
      }
      return hexString;
  }


  function createTouchAPDU(){	
      // Build up APDU
      var APDUHex = "00" + U2F_ECHO_PHYSICAL_PRESENCE + "0000" + "00";
      console.log("checkTouchPLTDevice: APDU hex: " + APDUHex);
      
      return packHexToBinary(APDUHex);
  }
  
  function createPingAPDU(){
      var FIDO_INS_VERSION = "06";
      var pingStringHex = "000102030405060708090a0b0c0d0e0f";

      var len = pingStringHex.length / 2;
      var lenHex = len.toString(16);
      var APDUHex = "00" + FIDO_INS_VERSION + "0000" + lenHex + pingStringHex;
      console.log("createPingAPDU - length of APDU = " + APDUHex);
      return packHexToBinary(APDUHex);
  }
  
  function creareEnrollAPDU(jsonData){
	  
      var browserData = {typ:"navigator.id.finishEnrollment", challenge:JSON.stringify(jsonData.enrollChallenges[0].challenge)};
      
      jsonData.enrollChallenges[0].browserData = browserData;
            
      // Hash browser data
      var browserDataString = JSON.stringify(browserData);
      //console.log("Browser data: " + browserDataString);
      //console.log("Hash: ");
      var hashBrowserData = CryptoJS.SHA256(browserDataString);
      var hashBrowserDataHex = hashBrowserData.toString(CryptoJS.enc.Hex);
      //console.log(hashBrowserDataHex);

      // Hash app id
      var AppIDString = jsonData.enrollChallenges[0].appId
      //console.log("AppID: " + AppIDString);
      //console.log("Hash: ");
      var hashAppID = CryptoJS.SHA256(AppIDString);
      var hashAppIDHex = hashAppID.toString(CryptoJS.enc.Hex);
      //console.log(hashAppIDHex);

      // Build up APDU
      var len = hashBrowserDataHex.length / 2 + hashAppIDHex.length / 2 + 1;
      //console.log("Length is: " + len);
      var lenHex = len.toString(16);
      //console.log("Hex length is: " + lenHex);
      var APDUHex = "00" + U2F_ENROLL + "0000" + lenHex + XAPDU_XMIT_BIT + hashBrowserDataHex + hashAppIDHex;
      console.log("createEnrollAPDU: APDU = " + APDUHex);
      return packHexToBinary(APDUHex);
      // Remember header to get more return data when needed
      // Leave out the 1 byte of data as this will be added
      //moreCommandHeader = APDUHex.substring(0, 8) + "01";
      //console.log("Repeat header: " + moreCommandHeader);
      //largeAPDUReturnChunk = 0;	// Reset this to 0 as we track the chunks


      // Convert to base 64
    //  var words = CryptoJS.enc.Hex.parse(APDUHex);
      //var APDUbase64 = CryptoJS.enc.Base64.stringify(words);
      //var APDUbase64URLSafe = base64ToURLSafe(APDUbase64);
      //console.log("Base64 APDU: " + APDUbase64URLSafe);

      // Convert it back (to test)
      //words = CryptoJS.enc.Base64.parse(APDUbase64);
      //var convertedHex = CryptoJS.enc.Hex.stringify(words);
      //console.log("Converted back: " + convertedHex);

      // Prepare for large APDU return
      //returnLargeAPDUHex = "";

      // Send APDU command recursively
      //sendAPDUCommand(APDUbase64URLSafe, callback, browserData, "enroll", null);
      
	  
  }

  
	
