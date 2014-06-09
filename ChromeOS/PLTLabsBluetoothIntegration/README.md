# [PltLabs](http://pltlabs.com)

PLTLabs - Chrome Bluetooth API Integration 

This project is to test the Google Chrome Bluetooth API integration capabilities PLT device APIs.

* Source: [https://github.com/plantronics-innovation/core-team/tree/master/ChromeOS/PLTLabsBluetoothIntegration](https://github.com/plantronics-innovation/core-team/tree/master/ChromeOS/PLTLabsBluetoothIntegration)
* Twitter: [@pltlabs](http://twitter.com/pltlabs)
* Author: [@carybran](http://twitter.com/carybran)


## Demo Setup

### Setting up Chrome/Chrome OS 
Grab the dev channel version of Google Chrome or set your Chrome OS device to the dev channel - if you need instructions for this just google it

### Getting the PLTLabs Source code
* Download our chrome demo source code from Github
* The folder breakdown is as follows:  
  * PLTLabsChromeDemo - this is the Chrome packaged app that has the PLTLabs Javascript library for Bladerunner device access
  * PLTLabsDemoWebSite - web application for showing functionality that cannot be implemented in a packaged app - e.g. google maps, hangouts, etc. This web site can be hosted on webserver of your choice.
  * peerjs-server - this folder contains the [peerjs](http://peerjs.com/) WebRTC server - see site for prerequisites for installing peerjs

### Setting up the Chrome packaged app
You can set up the Chrome app by navigating to the extensions manager in Chrome [chrome://extensions/](chrome://extensions/).
Once you are in the extensions managment view perform the following steps:
* Enable developer mode by checking the "Developer mode" checkbox
* Click on the "Load unpackaged extension" button
* Navigate to the directory where you have the PLTLabsChromeDemo and select the directory (note - in ChromeOS I usually copy the PLTLabsChromeDemo directory to the "downloads" folder - either via USB stick or download from Google Drive)
* The application should install and you should see the extension loaded as "PLTLabs Javascript Bluetooth API Demo 1.0"

### Setting up the WC1 or any device that speaks Bladerunner over Bluetooth
* Pair the device with the ChromeBook or Host - make sure it is connected

### Gotcha's if you are using Chrome browser
To use a development packaged application in Chrome browser without downloading it from the Google Play store, you must sign into the Chrome browser with your Gmail account.
If you do not sign in, the app will not launch and you will be redirected to the Google Play store.

### Setting up the WebRTC functionality
The PLTLabsChromeDemo will function out of the box with the Bladerunner headset.  You will be able to get all of the contextual data listed on the various pages.
If you want to demonstrate the WebRTC functionality the following additional items must be set up and configured.

#### Setting up the WebRTC server
* Install nodejs
* Follow the instructions here (https://github.com/peers/peerjs-server) - or just use the instance of the server in the peerjs-server folder

The WebRTC demo is written to work with either EC2 or a local instance of the peerjs server I am assuming that if you are reading this that you want to run your own instance.
The demo is not robust, IP addresses, ports and user names are hardcoded you are free to change the configuration in the code or configure your wifi access point to assign your server machine an IP address of: 10.0.1.51.
The demo as downloaded will look for a server running on port 8080 with either the EC2 IP address of 23.23.249.221 or the intranet address of 10.0.1.51.  If you want pointers as to where to change the code please let me know.
To start the WebRTC server using port 8080 from the peerjs-server folder run the following command:
`./peerjs --port 8080 --key peerjs`
The server should launch and be ready for managing the PeerConnection between the Chrome packaged app and the PLTLabs demo website.

#### Setting up the PLTLabs demo web site
Host the contents of the PLTLabsDemoWebSite folder on the web server of your choice

#### Notes that are required for the WebRTC/Street View demo
* Internet connection is required for the system that is accessing the PLTLabsDemoWebSite - the Google Maps Javascript library is loaded dynamically from google.com thus it requires a live internet connection in order to render streetview.
* The Chrome packaged app with the WC1 connected drives the streetview experience - the GPS and head orientation coordinates are streamed from the Chrome packaged app over the WebRTC data channel to the user logged on to the PLTLabs demo website
* When you connect to the WebRTC server from the Chrome packaged app you will be logged in as user "Cary", when you connect via the web site you will be logged in as user "Joe"
* If you get a user handle error from the server, you have somebody trying to log in with the same account from another browser, simply restart the peerjs server and you will be good to go
* The WebRTC demo website uses WebRTC code that can run on either Firefox or Chrome
* Pressing the hookflash button on the headset when on a WebRTC call will terminate the call (just like it does when you are on a mobile or desktop phone)