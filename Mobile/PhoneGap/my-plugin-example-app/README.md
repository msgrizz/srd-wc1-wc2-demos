my-plugin-example-app
=========

This is a crude hacking-together of a PhoneGap plugin example found at http://www.websector.de/blog/2013/07/25/example-of-a-native-ios-plugin-for-using-phonegap-3/

Install PhoneGap (Cordova) from http://phonegap.com and follow the instructions linked above to get an overview of how this project works.

In my trials, I found that modifying the contents of the 'Plugin' and 'www' directories, and then building (to product an Xcode project) was not reliable. The work-around I found was to build once, then modify the copied versions of the 'Plugin' and 'www' directories under platforms/ios/.

Contact morgan.davis@plantronics.com with questions.

Morgan
