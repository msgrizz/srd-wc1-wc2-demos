//
//  BRCommand.mm
//  BRPlayground
//
//  Created by Davis, Morgan on 12/6/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "BRCommand.h"


using namespace std;


@interface BRCommand()

- (id)initWithDevice:(BladeRunnerDevice *)device
             command:(int16_t)commandID
           arguments:(NSArray *)arguments
            delegate:(id <BRCommandDelegate>)delegate;
- (void)didRun:(NSError *)error;
- (void)timeout:(NSTimer *)theTime;

@property(nonatomic, weak)      id <BRCommandDelegate>      delegate;
@property(nonatomic, assign)    BladeRunnerDevice           *device;
@property(nonatomic, strong)    NSTimer                     *timeoutTimer;
@property(nonatomic, assign)    int16_t                     commandID;
@property(nonatomic, strong)    NSArray                     *arguments;
@property(nonatomic, strong)    NSThread                    *thread;

@end


@implementation BRCommand

#pragma mark - Public

+ (BRCommand *)runWithDevice:(BladeRunnerDevice *)device
                     command:(short)commandID
                   arguments:(NSArray *)arguments
                    delegate:(id <BRCommandDelegate>)delegate
{
    BRCommand *command = [[BRCommand alloc] initWithDevice:device command:commandID arguments:arguments delegate:delegate];
    [command run];
    return command;
}

- (id)initWithDevice:(BladeRunnerDevice *)device
             command:(short)commandID
           arguments:(NSArray *)arguments
            delegate:(id <BRCommandDelegate>)delegate
{
    if (self = [super init]) {
        self.device = device;
        self.commandID = commandID;
        self.arguments = arguments;
        self.delegate = delegate;
    }
    return self;
}

- (void)run
{
    if (self.device != NULL && self.device->isOpen()) {
        
        DeviceCommandType *commandType = new DeviceCommandType(self.commandID);
        BRError error = self.device->getCommandType(self.commandID, *commandType);
        if (error != BRError_Success ) {
            NSLog(@"Error getting command type: %d", error);
            return;
        }
        DeviceCommand *command = new DeviceCommand(self.device, *commandType);
        delete commandType;
        
        if (command) {
            vector<BRProtocolElement> els;
            //BRProtocolElement el1 = BRProtocolElement(gain);
            //els.push_back(el1);
            //error = command->perform(els);
            
            NSArray *args = @[[NSValue valueWithPointer:command], [NSValue valueWithPointer:&els]];
            self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(_run:) object:args];
            [self.thread start];
        }
        else {
            NSLog(@"Invalid command.");
        }
    }
    else {
        NSLog(@"Device not open.");
    }
}

- (void)cancel
{
    
}

#pragma mark - Private

- (void)_run:(NSArray *)args;
{
    DeviceCommand *command = (DeviceCommand *)[args[0] pointerValue];
    vector<BRProtocolElement> payload = *(vector<BRProtocolElement> *)[args[1] pointerValue];
    BRError error = command->perform(payload);
    NSLog(@"Error: %d", error);
    
    if (error == BRError_PerformCommandFailure) {
        if (command->isSuccess() == PerformCommandSuccess_Failure) {
            int16_t exceptionId;
            vector<BRProtocolElement> data;
            error = command->getExceptionData(exceptionId, data);
            delete command;
            
            if (error == BRError_Success) {
#warning TODO - get exception data.
                NSLog(@"Exception.");
            }
            else {
                NSLog(@"Error getting exception data: %d", error);
            }
        }
        else {
            NSLog(@"Command executed (2).");
        }
    }
    else {
        NSLog(@"Command executed (1).");
    }
}

- (void)didRun:(NSError *)error
{
    if (!error) {
        [self.delegate BRCommandDidFinish:self];
    }
    else {
        [self.delegate BRCommandDidFail:self withError:error];
    }
}

- (void)timeout:(NSTimer *)theTime
{
    [self.delegate BRCommandDidTimeout:self];
}

@end
