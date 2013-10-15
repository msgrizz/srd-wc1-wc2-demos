cordova.define("de.websector.myplugin.MyPlugin", function(require, exports, module) {var exec = require('cordova/exec');
/**
 * Constructor
 */
function MyPlugin() {}

MyPlugin.prototype.connect = function(success) {
  exec(function(result){
      // result handler
      //alert(result);
	   success();
    },
    function(error){
      // error handler
      alert("Error" + error);
    }, 
    "MyPlugin", 
    "connect",
    []
  );
}
			   
MyPlugin.prototype.getIsConnected = function() {
exec(function(result){
	// result handler
	alert(result);
	},
	function(error){
	// error handler
	alert("Error" + error);
	},
	"MyPlugin",
	"getIsConnected",
	[]
	);
}

MyPlugin.prototype.calibrate = function() {
exec(function(result){
	// result handler
	//alert(result);
	},
	function(error){
	// error handler
	alert("Error" + error);
	},
	"MyPlugin",
	"calibrate",
	[]
	);
}
			   
MyPlugin.prototype.getEulerAngles = function(success) {
exec(function(result){
	// result handler
	//alert(result);
	 success(result);
	},
	function(error){
	// error handler
	alert("Error" + error);
	},
	"MyPlugin",
	"getEulerAngles",
	[]
	);
}
			   
MyPlugin.prototype.getLatestInfo = function(success) {
exec(function(result){
	// result handler
	//alert(result);
	success(result);
	},
	function(error){
	// error handler
	alert("Error" + error);
	},
	"MyPlugin",
	"getLatestInfo",
	[]
	);
}

var myPlugin = new MyPlugin();
module.exports = myPlugin});
