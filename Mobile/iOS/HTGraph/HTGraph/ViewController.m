//
//  ViewController.m
//  HTGraph
//
//  Created by Davis, Morgan on 11/1/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLTDevice.h"


@interface ViewController () <CPTPlotDataSource, PLTDeviceConnectionDelegate, PLTDeviceInfoObserver>
    
- (void)setupGraph;
- (void)computeNewXRange;
- (void)newDeviceAvailableNotification:(NSNotification *)notification;
    
@property(nonatomic, retain) CPTXYGraph         *graph;
//@property(nonatomic, retain) NSArray            *plotData;
@property(nonatomic, strong) PLTDevice          *device;
@property(nonatomic, strong) NSMutableArray     *headingPints;
@property(nonatomic, strong) NSMutableArray     *pitchPints;
@property(nonatomic, strong) NSMutableArray     *rollPints;
@property(nonatomic, strong) NSDate             *referenceData;
@property(nonatomic, assign) NSRange            baseXRange;

@end


@implementation ViewController
    
#pragma mark - Private
    
- (void)setupGraph
{
    // connect graph
    self.graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [self.graph applyTheme:theme];
    self.hostGraphView.hostedGraph = self.graph;
    
    
    // setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    self.baseXRange = NSMakeRange(0.0, 10.0);
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.baseXRange.location) length:CPTDecimalFromFloat(self.baseXRange.length)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-185.0) length:CPTDecimalFromFloat(185.0 * 2 + 15.0)];
    
    
    // x axes
    CPTXYAxis *x = ((CPTXYAxisSet *)self.graph.axisSet).xAxis;
    x.majorIntervalLength = CPTDecimalFromFloat(1.0);
    x.minorTicksPerInterval = 3;
    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0);
    
    
    // y axis
    CPTXYAxis *y = ((CPTXYAxisSet *)self.graph.axisSet).yAxis;
    y.majorIntervalLength = CPTDecimalFromFloat(10.0);
    y.minorTicksPerInterval = 9;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0);
    
    
    // create the heading plot
    CPTScatterPlot *headingLinePlot = [[CPTScatterPlot alloc] init];
    headingLinePlot.identifier = @"headingPlot";
    CPTMutableLineStyle *lineStyle = [headingLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor redColor];
    headingLinePlot.dataLineStyle = lineStyle;
    headingLinePlot.dataSource = self;
    [self.graph addPlot:headingLinePlot];
    
    // create the pitch plot
    CPTScatterPlot *pitchLinePlot = [[CPTScatterPlot alloc] init];
    pitchLinePlot.identifier = @"pitchPlot";
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor blueColor];
    pitchLinePlot.dataLineStyle = lineStyle;
    pitchLinePlot.dataSource = self;
    [self.graph addPlot:pitchLinePlot];
    
    // create the roll plot
    CPTScatterPlot *rollLinePlot = [[CPTScatterPlot alloc] init];
    rollLinePlot.identifier = @"rollPlot";
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor greenColor];
    rollLinePlot.dataLineStyle = lineStyle;
    rollLinePlot.dataSource = self;
    [self.graph addPlot:rollLinePlot];
}

- (void)computeNewXRange
{
    // find the largest x point
    // if it's > self.baseXRange.location + self.baseXRange.length, adjust the graph's x range out farther
    
    CGFloat greatestX = 0;
    for (int i = 0; i<self.headingPints.count ; i++) {
        NSDictionary *point = self.headingPints[i];
        CGFloat x = [point[@(CPTScatterPlotFieldX)] floatValue];
        if (x > greatestX) {
            greatestX = x;
        }
    }
    
    NSLog(@"greatestX: %.2f", greatestX);
    
    //CGFloat offset = greatestX - (self.baseXRange.location + self.baseXRange.length);
    const CGFloat headingPadding = 1.0;
    if (greatestX > self.baseXRange.length - headingPadding) {
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.baseXRange.location + (greatestX - self.baseXRange.length) + headingPadding)
                                                        length:CPTDecimalFromFloat(self.baseXRange.length)];
    }
    
//    CGFloat offset = greatestX - (self.baseXRange.location + self.baseXRange.length);
//    if (greatestX > 0) {
//        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
//        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.baseXRange.location + offset)
//                                                        length:CPTDecimalFromFloat(self.baseXRange.length)];
//    }
}

- (void)newDeviceAvailableNotification:(NSNotification *)notification
{
	NSLog(@"newDeviceAvailableNotification: %@", notification);
	
	if (!self.device) {
		self.device = notification.userInfo[PLTDeviceNewDeviceNotificationKey];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
}
    
#pragma mark CPTPlotDataSource
    
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.headingPints.count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ([(NSString *)plot.identifier isEqualToString:@"headingPlot"]) {
        return [self.headingPints objectAtIndex:index][@(fieldEnum)];
    }
    else if ([(NSString *)plot.identifier isEqualToString:@"pitchPlot"]) {
        return [self.pitchPints objectAtIndex:index][@(fieldEnum)];
    }
    return [self.rollPints objectAtIndex:index][@(fieldEnum)];
}

#pragma mark - PLTDeviceConnectionDelegate

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
	
	NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
	if (err) NSLog(@"Error: %@", err);
    
    self.referenceData = [NSDate date];
}

- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error
{
	NSLog(@"PLTDevice: %@ didFailToOpenConnection: %@", aDevice, error);
	self.device = nil;
}

- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidCloseConnection: %@", aDevice);
	self.device = nil;
}

#pragma mark - PLTDeviceInfoObserver

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
        NSDictionary *headingPoint = @{
                                       @(CPTScatterPlotFieldX) : @([[NSDate date] timeIntervalSinceDate:self.referenceData]),
                                       @(CPTScatterPlotFieldY) : @(eulerAngles.x)};
        NSDictionary *pitchPoint = @{
                                     @(CPTScatterPlotFieldX) : @([[NSDate date] timeIntervalSinceDate:self.referenceData]),
                                     @(CPTScatterPlotFieldY) : @(eulerAngles.y)};
        NSDictionary *rollPoint = @{
                                    @(CPTScatterPlotFieldX) : @([[NSDate date] timeIntervalSinceDate:self.referenceData]),
                                    @(CPTScatterPlotFieldY) : @(eulerAngles.z)};
        [self.headingPints addObject:headingPoint];
        [self.pitchPints addObject:pitchPoint];
        [self.rollPints addObject:rollPoint];
        //[self computeNewXRange];
        [self.graph reloadData];
    }
}
    
#pragma mark - UIViewController
    
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ViewController" bundle:nil];
    self.navigationItem.title = @"HTGraph";
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupGraph];
    self.headingPints = [NSMutableArray array];
    self.pitchPints = [NSMutableArray array];
    self.rollPints = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
	else {
		NSLog(@"No available devices.");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceAvailableNotification:) name:PLTDeviceNewDeviceAvailableNotification object:nil];
}

@end
