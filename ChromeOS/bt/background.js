var BR_PROFILE = {
  uuid: '82972387-294e-4d62-97b5-2668aa35f618'
};

chrome.app.runtime.onLaunched.addListener(function () {
	chrome.app.window.create("window.html", {
		"id" : "mainWindow",
		"bounds" : {
			"width" : 400,
			"height" : 500
        }},
       function(win) {
    // Add the profile to the list of profiles we support
    chrome.bluetooth.addProfile(BR_PROFILE, function(r) {
      console.log("Bladerunner profile added");
    });

    // Make the profile available in the main content window.
    win.contentWindow.BR_PROFILE = BR_PROFILE;
       })});

function removeProfile() {
  console.log("Removing Bladerunner profile");
  chrome.bluetooth.removeProfile(BR_PROFILE, function(r) {
    console.log("Profile removed");
  });
}
