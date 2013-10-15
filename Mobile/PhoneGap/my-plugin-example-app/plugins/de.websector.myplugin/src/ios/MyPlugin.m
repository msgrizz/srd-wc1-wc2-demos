#import "MyPlugin.h"
#import <Cordova/CDV.h>

@implementation MyPlugin

- (void)sayHello:(CDVInvokedUrlCommand*)command
{
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Gerbles"];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end