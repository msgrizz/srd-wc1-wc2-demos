//
//  BRCommand.h
//  BRPlayground
//
//  Created by Davis, Morgan on 12/6/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <bladerunner_ios_sdk/BladeRunnerDeviceManager.h>


using namespace bladerunner;

@protocol BRCommandDelegate;


@interface BRCommand : NSObject

+ (BRCommand *)runWithDevice:(BladeRunnerDevice *)device
                     command:(int16_t)commandID
                   arguments:(NSArray *)arguments
                    delegate:(id <BRCommandDelegate>)delegate;
- (void)cancel;

@end


@protocol BRCommandDelegate

- (void)BRCommandDidFinish:(BRCommand *)command;
- (void)BRCommandDidTimeout:(BRCommand *)command;
- (void)BRCommandDidFail:(BRCommand *)command withError:(NSError *)error;

@end

