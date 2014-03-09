var BR_PROFILE = {
  uuid: '82972387-294e-4d62-97b5-2668aa35f618'
};


//var googleAPIKey = "AIzaSyBbpISTCVPo6Bpf5qEoXY_cVQveRB1YN9g";
//var mapWindow;

chrome.app.runtime.onLaunched.addListener(
	function () {
	  chrome.app.window.create("window.html",
		{
		"id" : "mainWindow",
		"bounds" : {
			"width" : 750,
			"height" : 975 }
		},
		function(win) {
	       // Add the profile to the list of profiles we support
	       chrome.bluetooth.addProfile(BR_PROFILE, function(r) {
		console.log("PLTLabs profile added");
		//win.fullscreen();
	       });
    
	      // Make the profile available in the main content window.
	      win.contentWindow.BR_PROFILE = BR_PROFILE;
	      //win.contentWindow.launchStreetView = launchStreetView;
	      //win.contentWindow.mapWindow = mapWindow;
	      });
	    
	
	});
/*
function launchStreetView(){
   chrome.app.window.create('map.html', {
    'bounds': {
      'width': 400,
      'height': 400,
      'left': 400,
      'top': 0
    }},
    function(win) {
      mapWindow = win; }
    );
  
}
*/

function removeProfile() {
  console.log("Removing Bladerunner profile");
  chrome.bluetooth.removeProfile(BR_PROFILE, function(r) {
    console.log("Profile removed");
  });
}


