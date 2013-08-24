//
//  CSR_Wireless_SensorViewController.m
//  CSR Wireless Sensor
//
//  Copyright Cambridge Silicon Radio Ltd 2009. All rights reserved.
//

#import "SettingsViewController_old.h"
//#import "PLTAppSettings.h"
#import "PLTContextServer.h"
#import "PLTContextServerMessage.h"
#import "InfoViewController.h"
#import "PLTHeadsetManager.h"
#import "LocationMonitor.h" 


#define BLUEMEDIA_BUTTON_MASK   (1 << 0)
#define AUX2_BUTTON_MASK        (1 << 1)
#define AUX1_BUTTON_MASK        (1 << 10)
#define BACK_BUTTON_MASK        (1 << 15)
#define FWD_BUTTON_MASK         (1 << 14)
#define PLAY_STOP_BUTTON_MASK   (1 << 13)
#define VOL_MINUS_BUTTON_MASK   (1 << 12)
#define VOL_PLUS_BUTTON_MASK    (1 << 11)
#define PWR_HOOK_BUTTON_MASK    (1 << 2)

#define MAX_BROADCAST_RATE      20.0 // Hz


@implementation SettingsViewController_old
@synthesize infoViewController;
@synthesize eventsEnabled;
@synthesize deviceID;
@synthesize thesubviews;
@synthesize locationManager;
@synthesize longitude;
@synthesize latitude;
@synthesize useLLView;
@synthesize latView;
@synthesize longView;
@synthesize server;

@synthesize broadcastDate;


@synthesize consoleTextView = _consoleTextView;

-(IBAction)connButtonPressed:(id)sender{
    
    //if([auth_status.text isEqualToString:@"Auth"])
    if(![auth_status isHidden])
        return;
    if(self.infoViewController.view.superview==nil){
        if(self.infoViewController==nil){
            InfoViewController *infoController = [[InfoViewController alloc]initWithNibName:@"InfoView" bundle:nil];
            self.infoViewController=infoController;
        }
    }
    NSMutableString * urlstring = [[NSMutableString alloc] init];
    
    
    [urlstring appendString:@"ws"];
    
    if(self.infoViewController.switchView.on)
        [urlstring appendString:@"s://"];
    else
        [urlstring appendString:@"://"];
    [urlstring appendString:self.infoViewController.serverTextView.text];
    [urlstring appendString:@":"];
    [urlstring appendString:self.infoViewController.portTextView.text];
    [urlstring appendString:@"/context-server/context-websocket"];
    
    //server = [[PLTContextServer alloc] initWithURL:urlstring username:infoViewController.userTextView.text password:infoViewController.passTextView.text];
    
    self.server = [PLTContextServer sharedContextServerWithURL:urlstring
                                                      username:self.infoViewController.userTextView.text
                                                      password:self.infoViewController.passTextView.text
                                                     protocols:@[@"plt-device"]];
        
  //  server = [[PLTContextServer alloc] initWithURL:@"wss://23.21.44.181:8443/context-server/context-websocket" username: @"dougrosener" password:@"12345"];
    //  server = [[PLTContextServer alloc] initWithURL:@"wss://pltdev01.pltbluesky.com:8443/context-server/context-websocket" username: @"dougrosener" password:@"12345"];
    //   // server = [[PLTContextServer alloc] initWithURL:@"wss://10.1.191.1:8443/context-server/context-websocket" username: @"dougrosener" password:@"12345"];
  //    server = [[PLTContextServer alloc] initWithURL:@"ws://23.23.249.221:8080/context-server/context-websocket" username: @"doug.rosener" password:@"plt123"]; //new server
    //server.delegate = self;
    [server addDelegate:self];

    // clear console and reconnect
    self.consoleTextView.text = @"";
    self.infoViewController.consoleTextView.text = @"";
    
     [self writeToDisplay:@"Connecting to server...\n"];
    [server openConnection]; 
}
-(IBAction)disconnButtonPressed:(id)sender{
    // clear console and reconnect
    infoViewController.consoleTextView.text = @"";
    [self writeToDisplay:@"Disconnecting tfromserver...\n"];
    [server closeConnection];
    server=nil;
    
    
}
- (IBAction)eventButtonPressed:(id)sender
{
    u_char buf[23]={0, 1, 2 ,3 ,4, 5, 6 ,7, 8, 9, 0, 1 ,2, 3, 4 ,5, 6, 7, 8 ,9, 0, 1,2,};
    //send "quat" message to the context server
    [self sendQuat:buf];

}
-(IBAction)regButtonPressed:(id)sender{
    // clear console and reconnect

    [self registerDeviceWithContextServer];

}

-(IBAction)switchViews:(id)sender{
    
//    if(self.infoViewController.view.superview==nil){
        if(self.infoViewController==nil){
            InfoViewController *infoController = [[InfoViewController alloc]initWithNibName:@"InfoView" bundle:nil];
            self.infoViewController=infoController;
        }
//        for (UIView *aView in thesubviews){
//            [aView removeFromSuperview];
//
//        }
//        [self.view insertSubview:infoViewController.view atIndex:0];
//        [sender setTitle:@"Display" forState:UIControlStateNormal];

        //[self.view removeFromSuperview];
        
        [self presentModalViewController:self.infoViewController animated:YES];
//    }
//    else{
////        [infoViewController.view removeFromSuperview];
////        for (UIView *aView in thesubviews){
////            [self.view insertSubview:aView atIndex:0];
////            
////        }
////        [sender setTitle:@"Settings" forState:UIControlStateNormal];
//
//        [self dismissModalViewControllerAnimated:YES];
//    }
}

// show connection status to user
// if not connected also clear the sensor data
//-(void)ShowConnected:(BOOL)connected
//{
//    if (connected == TRUE)
//    {
//        [connection_status setText:@"Connected"];
//    }
//    else
//    {
//        [connection_status setText:@"Not Connected"];
//        
//        // clear the  scales and hide the text
//        [self UpdateHeading:0];
//        [self UpdateButtonStatus:0];
//        [self UpdateRoll:0];
//        [self UpdatePitch:0];
//        [text_heading setHidden:TRUE];
//        [text_roll setHidden:TRUE];
//        [text_pitch setHidden:TRUE];
//        
//
//    }
//}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    InfoViewController *infoController=[[InfoViewController alloc] initWithNibName:@"InfoView" bundle:nil];
    self.infoViewController=infoController;
    thesubviews=[self.view subviews];
    
    [reg_status setHidden:TRUE];
    [auth_status setHidden:TRUE];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    

}

-(void)locationManager: (CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *location = [locationManager location];
    // Configure the new event with information from the location
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    longitude=coordinate.longitude;
    latitude=coordinate.latitude;
    
//    NSLog(@"dLongitude : %f",longitude);
//    NSLog(@"dLatitude : %f", latitude);


}

-(void)locationManager: (CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    //NSLog(@"heading : %f", theHeading);
    
    
}

-(void) locationManager: (CLLocationManager *)manager didFailWitherror:(NSError *)error
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    // rotate and scale the progress bar we're using for heading
//    [heading_scale setTransform:CGAffineTransformMakeRotation(M_PI / 2 + M_PI)];
//    [heading_scale setTransform:CGAffineTransformScale([heading_scale transform], 1.0, 1.5)];
//    // rotate and scale the progress bar we're using for roll
//    [roll_scale setTransform:CGAffineTransformMakeRotation(M_PI / 2 + M_PI)];
//    [roll_scale setTransform:CGAffineTransformScale([roll_scale transform], 1.0, 1.5)];
//    // rotate and scale the progress bar we're using for pitch
//    [pitch_scale setTransform:CGAffineTransformMakeRotation(M_PI / 2 + M_PI)];
//    [pitch_scale setTransform:CGAffineTransformScale([pitch_scale transform], 1.0, 1.5)];
}

-(void) registerDeviceWithContextServer {
    //CLLocation *location=[[CLLocation alloc] initWithLatitude:((CLLocationDegrees)47.56)longitude:((CLLocationDegrees)-122.40 );
    NSLog(@"[self deviceID]: %@",[self deviceID]);
    NSDictionary *subpayload =[NSDictionary dictionaryWithObjectsAndKeys:
                              [self deviceID],@"deviceId",
//                               @"junk",@"deviceId",
                               @"1151",@"vendorId",
                               @"1045",@"productId",
                               @"2116",@"versionNumber", 
                               @"Plantronics BT300",@"productName", 
                               @"Vpro1",@"internalName", 
                               @"Plantronics",@"manufacturerName", 
                               nil];

    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             subpayload,@"device" ,
                              nil];
    
    
    PLTContextServerMessage *message = [[PLTContextServerMessage alloc] initWithType:MESSAGE_TYPE_REGISTER_DEVICE messageId:REGISTER_DEVICE payload:payload];
    debugLog(@"Send message: register device");
    [self writeToDisplay:@"Send message: Register Device\n"];
    [self sendMessage:message];

}
//// Update heading scale and text to reflect incoming value
//-(void)UpdateHeading:(int16_t)heading
//{
//
//    // clip the heading to the range we want to show -180 -> 180
//    if (heading < -180) heading = (heading+360)%180;
//    if (heading > 180) heading = (heading-360)%180;
//    
//    // turn the int into a float between 0.0 and 1.0 and update the heading scale
//    float fl_head = (heading+180) / 360.0;
//    [heading_scale setProgress:fl_head];
//
//    // show the heading on the screen as a number
//    [text_heading setText:[NSString stringWithFormat:@"%d°", heading]];
//    [text_heading setHidden:FALSE];
//}
//
//// Update Roll scale and text to reflect incoming value
//-(void)UpdateRoll:(int16_t)roll
//{
//    // clip the roll to the range we want to show -180 -> 180
//    if (roll < -180) roll = (roll+360)%180;
//    if (roll > 180) roll = (roll-360)%180;
//    
//    // turn the int into a float between 0.0 and 1.0 and update the roll scale
//    float fl_roll = ((roll) +180)/ 360.0;
//    [roll_scale setProgress:fl_roll];
//    
//    // show the roll on the screen as a number
//    [text_roll setText:[NSString stringWithFormat:@"%d°", roll]];
//    [text_roll setHidden:FALSE];
//}
//// Update pitch text to reflect incoming value
//-(void)UpdatePitch:(int16_t)pitch
//{
//    // clip the pitch to the range we want to show -90 -> 90
//    if (pitch < -180) pitch = (pitch+360)%180;
//    if (pitch > 180) pitch = (pitch-360)%180;
//    
//    // turn the int into a float between 0.0 and 1.0 and update the pitch scale
//    float fl_pitch = ((pitch) +90)/ 180.0;
//    [pitch_scale setProgress:fl_pitch];
// 
//    // show the pitch on the screen as a number
//    [text_pitch setText:[NSString stringWithFormat:@"%d°", pitch]];
//    [text_pitch setHidden:FALSE];
//}

// Update pitch text to reflect incoming value
-(void)UpdateData:(uint8_t*)data
{
 //   NSString *datastr=[[NSString alloc] initWithBytes:data  length:23 encoding:NSASCIIStringEncoding];
    NSMutableString * datastr = [[NSMutableString alloc] init];

    int i;
    for (i=0; i<24; i++) {
        [datastr appendString:[NSString stringWithFormat:@"%02x",data[i]]];
    }
    // show the data on the screen in hex
    [text_data setText: datastr];
    [text_data setHidden:FALSE];
    
    if(eventsEnabled)
        [self sendQuat:data];
}
// Switch button highlights on/off to reflect state in incoming
// button state mask
-(void)UpdateButtonStatus:(uint16_t)button_state
{
    // handle PWR/HOOK button
    if (button_state & PWR_HOOK_BUTTON_MASK)
        [pwr_hook_button setHighlighted:TRUE];
    else
        [pwr_hook_button setHighlighted:FALSE];
    
    // handle VOL+ button
    if (button_state & VOL_PLUS_BUTTON_MASK)
        [vol_plus_button setHighlighted:TRUE];
    else
        [vol_plus_button setHighlighted:FALSE];

    // handle VOL- button
    if (button_state & VOL_MINUS_BUTTON_MASK)
        [vol_minus_button setHighlighted:TRUE];
    else
        [vol_minus_button setHighlighted:FALSE];

    // handle PLAY/STOP button
    if (button_state & PLAY_STOP_BUTTON_MASK)
        [play_stop_button setHighlighted:TRUE];
    else
        [play_stop_button setHighlighted:FALSE];
    
    // handle FWD button
    if (button_state & FWD_BUTTON_MASK)
        [fwd_button setHighlighted:TRUE];
    else
        [fwd_button setHighlighted:FALSE];
    
    // handle BACK button
    if (button_state & BACK_BUTTON_MASK)
        [back_button setHighlighted:TRUE];
    else
        [back_button setHighlighted:FALSE];
    
    // handle AUX1 button
    if (button_state & AUX1_BUTTON_MASK)
        [aux1_button setHighlighted:TRUE];
    else
        [aux1_button setHighlighted:FALSE];
    
    // handle AUX2 button
    if (button_state & AUX2_BUTTON_MASK)
        [aux2_button setHighlighted:TRUE];
    else
        [aux2_button setHighlighted:FALSE];
    
    // handle BLUEMEDIA button
    if (button_state & BLUEMEDIA_BUTTON_MASK)
        [bluemedia_button setHighlighted:TRUE];
    else
        [bluemedia_button setHighlighted:FALSE];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.title = @"Settings";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headsetInfoDidUpdateNotification:) name:PLTHeadsetInfoDidUpdateNotification object:nil];
    
    return self;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) ||
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


//- (void)dealloc {
//    [super dealloc];
//}


- (void) writeToDisplay:(NSString *)string
{
    // write to the scrolling text field on the iPhone's display
    // ensuring execution on the main thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.consoleTextView.text = [self.consoleTextView.text stringByAppendingString:string];
        infoViewController.consoleTextView.text = [infoViewController.consoleTextView.text stringByAppendingString:string];
        
        // scroll to the bottom
        [self.consoleTextView scrollRangeToVisible:NSMakeRange(self.consoleTextView.text.length, 0)];
        [infoViewController.consoleTextView scrollRangeToVisible:NSMakeRange(infoViewController.consoleTextView.text.length, 0)];
    }];
}


- (void) sendMessage:(PLTContextServerMessage *) message
{
    // if "Raw JSON" option is selected, write to display
//    if (settings.displayRawJson) {
//        [self writeToDisplay:[NSString stringWithFormat:@"%@\n",
//                              [message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]]];
//    }
    
    // send message to context server
    [[PLTContextServer sharedContextServer] sendMessage:message cacheIfServerIsOffline:YES];
}

// *******  PLTContextServerDelegate functions  *******

- (void)server:(PLTContextServer *)sender didReceiveMessage:(PLTContextServerMessage *)message
{
    [self writeToDisplay:@"Received Message...\n"];
    
    // if "Raw JSON" option is selected, write to display
//    if (settings.displayRawJson && !([message hasType:@"event"] && [[message messageId] isEqualToString:EVENT_HEAD_TRACKING])) {
//        [self writeToDisplay:[NSString stringWithFormat:@"%@\n",
//                              [message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]]];
//    }
    
    // parse message to decide what action to take...
    
    // registerDeviceWithContextServer
    

    if ([message hasType:@"registerDeviceWithContextServer"])
        {
        // do stuff here...
        
        [reg_status setHidden:FALSE];
        //    [self writeToDisplay:[NSString stringWithFormat:@"%@\n",
                        //          [message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]]];
        [self setEventsEnabled:true];
            
            
            // added by Morgan
            //self.server.state = PLT_CONTEXT_SERVER_REGISTERED;
            
            
    }
    
    // event
    else if ([message hasType:@"event"])
    {
        // do stuff here...
        
       // NSLog(@"[message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]: %@",[message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]);
      
        [self writeToDisplay:[NSString stringWithFormat:@"%@\n",
                              [message copyAsJSONStringWithOption:NSJSONWritingPrettyPrinted]]];
    }
    
    // setting
    else if ([message hasType:@"setting"])
    {
        // do stuff here...
    }
    
    // command
    else if ([message hasType:@"command"])
    {
        // do stuff here...
    }
    
    // exception
    else if ([message hasType:@"exception"])
    {
        NSString *alertMessage = [NSString stringWithFormat:@"id: %@\nmessage: %@", message.messageId, [message.payload objectForKey:@"message"]];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Context Server Exception" 
                              message:alertMessage 
                              delegate:nil 
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    // unknown
    else
    {
        NSString *alertMessage = [NSString stringWithFormat:@"The message type\"%@\" is not valid.", message.type];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Unknown Message Type" 
                              message:alertMessage
                              delegate:nil 
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}


- (void) serverDidOpen:(PLTContextServer *)sender
{
    [self writeToDisplay:@"Web Socket opened\n"];
    
    //only when using local server
     //    [self setEventsEnabled:true];
}


- (void)server:(PLTContextServer *)sender didAuthenticate:(BOOL)authenticationWasSuccessful
{
    if (authenticationWasSuccessful) {
        [self writeToDisplay:@"Authentication succeeded\n"];
        {
            [auth_status setHidden:FALSE];
        }
    }
    else {
        [self writeToDisplay:@"Authentication failed\n"];
    }
}


- (void)server:(PLTContextServer *)sender didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    [self writeToDisplay:[NSString stringWithFormat:@"Web Socket closed: %@\n", reason]];
    [self setEventsEnabled:(false)];
        [reg_status setHidden:TRUE];
        [auth_status setHidden:TRUE];
    
}


- (void)server:(PLTContextServer *)sender didFailWithError:(NSError *)error
{
    [self writeToDisplay:[NSString stringWithFormat:@"Web Socket failed with error: %@\n", error]];
    [self setEventsEnabled:(false)];
        [reg_status setHidden:TRUE];
        [auth_status setHidden:TRUE];
    

}


- (void) sendQuat:(u_char *)buf 
{
    NSTimeInterval gap = [[NSDate date] timeIntervalSinceDate:self.broadcastDate];
    if ( !self.broadcastDate || (gap >= (1.0/MAX_BROADCAST_RATE)) ) {
        
        //NSString *deviceId=@"12:34:56:78:90:13-00";
        CLLocation *location;
        char buff64[32];
        b64_ntop(buf, 23, buff64, 32);
        //buff64[31]=0;
        NSString *cleanbuf=[[NSString alloc] initWithBytes:buff64 length:(32) encoding:(NSASCIIStringEncoding)];
        
        
        
//        if(useLLView.on)
//            location=[[CLLocation alloc] initWithLatitude:((CLLocationDegrees)[latView.text floatValue]) longitude:((CLLocationDegrees)[longView.text floatValue])];
//        else
//            location=[[CLLocation alloc] initWithLatitude:((CLLocationDegrees)latitude) longitude:((CLLocationDegrees)longitude )];
        
        location = [LocationMonitor sharedMonitor].location;
        
        NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:
                                 cleanbuf,@"quaternion",
                                 @"true",@"isTransient",
                                 nil];
        PLTContextServerMessage *message = [[PLTContextServerMessage alloc] initWithType:MESSAGE_TYPE_EVENT messageId:EVENT_HEAD_TRACKING deviceId:[self deviceID]  payload:payload location:location];
        //debugLog(@"Send message: quaternion");
        
        [self sendMessage:message];
        
        self.broadcastDate = [NSDate date];
    }
//    else {
//        NSLog(@"Broadcast rate exceeded, waiting...");
//    }
}


- (void)headsetInfoDidUpdateNotification:(NSNotification *)note
{
    u_char packet[1024];
    NSData *packetData = note.userInfo[PLTHeadsetInfoKeyPacketData];
    [packetData getBytes:packet length:[packetData length]];
    [self UpdateData:packet];
}

@end
