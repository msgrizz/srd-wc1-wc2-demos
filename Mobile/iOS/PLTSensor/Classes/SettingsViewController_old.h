//
//  CSR_Wireless_SensorViewController.h
//  CSR Wireless Sensor
//
//  Copyright Cambridge Silicon Radio Ltd 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PLTAppSettings.h"
#import "PLTContextServer.h"
#import "PLTContextServerMessage.h"
#import "base64.h"

#define DEBUG_PRINT_ENABLED 1

@class InfoViewController;

@interface SettingsViewController_old : UIViewController <PLTContextServerDelegate ,CLLocationManagerDelegate> {
    
    InfoViewController *infoViewController;
    //PLTAppSettings *settings;
    PLTContextServer *server;
    NSArray *thesubviews;
    
   
    
    // Connected/Not Connected status display
    IBOutlet UILabel *connection_status;
    IBOutlet UILabel *auth_status;
    IBOutlet UILabel *reg_status;
    
    // Heading,roll,pitch display
    IBOutlet UILabel *text_heading;
    IBOutlet UIProgressView *heading_scale;  
    IBOutlet UILabel *text_roll;
    IBOutlet UIProgressView *roll_scale;
    IBOutlet UIProgressView *pitch_scale;
    IBOutlet UILabel *text_pitch;
    IBOutlet UILabel *text_data;
    
    ///IBOutlet UIButton *thetest;
    //IBOutlet UIButton *theevent;
    
    // Button (PIO) display
    IBOutlet UIButton *bluemedia_button;
    IBOutlet UIButton *aux2_button;
    IBOutlet UIButton *aux1_button;
    IBOutlet UIButton *back_button;
    IBOutlet UIButton *fwd_button; 
    IBOutlet UIButton *play_stop_button;
    IBOutlet UIButton *vol_minus_button;
    IBOutlet UIButton *vol_plus_button;
    IBOutlet UIButton *pwr_hook_button;
    
    NSDate *broadcastDate;
}
@property bool eventsEnabled;
@property (readwrite, retain) NSString* deviceID;
@property (retain,nonatomic)InfoViewController *infoViewController;
@property (retain,nonatomic)NSArray *thesubviews;
@property (retain,nonatomic)CLLocationManager *locationManager;
@property (assign,nonatomic) float longitude;
@property (assign,nonatomic) float latitude;
@property (retain,nonatomic) PLTContextServer *server;

@property(nonatomic,strong) IBOutlet UISwitch *useLLView;
@property(nonatomic,strong) IBOutlet UITextField *latView;
@property(nonatomic,strong) IBOutlet UITextField *longView;

@property(nonatomic,strong) NSDate *broadcastDate;


@property(nonatomic,strong) IBOutlet UITextView *consoleTextView;
-(IBAction)connButtonPressed:(id)sender;
-(IBAction)eventButtonPressed:(id)sender;
-(IBAction)regButtonPressed:(id)sender;
-(IBAction)disconnButtonPressed:(id)sender;
-(IBAction)switchViews:(id)sender;

- (void) writeToDisplay:(NSString *)string;



//-(void)ShowConnected:(BOOL)connected;
//-(void)UpdateHeading:(int16_t)heading;
//-(void)UpdateRoll:(int16_t)roll;
//-(void)UpdatePitch:(int16_t)pitch;
-(void)UpdateData:(uint8_t*)data;
-(void)UpdateButtonStatus:(uint16_t)button_state;

-(void) registerDeviceWithContextServer;
-(void) sendQuat:(u_char *)buf;
- (void) sendMessage:(PLTContextServerMessage *) message;

@end

