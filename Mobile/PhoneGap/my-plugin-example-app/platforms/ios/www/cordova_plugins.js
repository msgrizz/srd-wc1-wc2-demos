cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/de.websector.myplugin/www/MyPlugin.js",
        "id": "de.websector.myplugin.MyPlugin",
        "clobbers": [
            "myPlugin"
        ]
    }
]
});