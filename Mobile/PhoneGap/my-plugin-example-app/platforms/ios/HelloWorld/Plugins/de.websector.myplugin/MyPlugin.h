#import <Cordova/CDV.h>

@interface MyPlugin : CDVPlugin

- (void)connect:(CDVInvokedUrlCommand*)command;
- (void)sayHello:(CDVInvokedUrlCommand*)command;

@end