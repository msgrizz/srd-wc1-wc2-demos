package com.plantronics.PLTDevice;

/**
 * Created by mdavis on 1/15/14.
 */


public class Device
{
	public static final int SERVICE_PROXIMITY =			 		0x00;
	public static final int SERVICE_WEARING_STATE = 			0x01;
	public static final int SERVICE_ORIENTATION_TRACKING = 		0x02;
	public static final int SERVICE_PEDOMETER = 				0x03;
	public static final int SERVICE_FREE_FALL = 				0x04;
	public static final int SERVICE_TAPS = 						0x05;
	public static final int SERVICE_MAGNETOMETER_CAL_STATUS = 	0x06;
	public static final int SERVICE_GYROSCOPE_CAL_STATUS =		0x07;

	public static final int SUBSCRIPTION_MODE_ON_CHANGE = 		0;
	public static final int SUBSCRIPTION_MODE_PERIODIC = 		1;


	public static Device[] getAvailableDevices()
	{
		return null;
	}

	public void openConnection()
	{

	}

	public void closeConnection()
	{

	}

	public void setConfiguration(Configuration config, int service)
	{

	}

	public Configuration getConfiguration(int service)
	{
		return null;
	}

	public void setCalibration(com.plantronics.PLTDevice.Calibration cal, int service)
	{

	}

	public com.plantronics.PLTDevice.Calibration getCalibration(int service)
	{
		return null;
	}

	public void subscribe(InfoSubscriber subscriber, int service, int mode, int minPeriod)
	{

	}

	public void unsubscribe(InfoSubscriber subscriber, int service)
	{

	}

	public void unsubscribe(InfoSubscriber subscriber)
	{

	}

	public Info cachedInfo(int service)
	{
		return null;
	}

	public void queryInfo(InfoSubscriber subscriber, int service)
	{

	}
}






//- (void)openConnection;
//		- (void)closeConnection;
//		- (void)setConfiguration:(PLTConfiguration *)aConfiguration forService:(PLTService)theService;
//		- (PLTConfiguration *)configurationForService:(PLTService)theService;

//		- (void)setCalibration:(PLTCalibration *)aCalibration forService:(PLTService)theService;
//		- (PLTCalibration *)calibrationForService:(PLTService)theService;

//		- (NSError *)subscribe:(id <PLTDeviceInfoObserver>)subscriber toService:(PLTService)service withMode:(PLTSubscriptionMode)mode minPeriod:(NSUInteger)minPeriod;
//		- (void)unsubscribe:(id <PLTDeviceInfoObserver>)subscriber fromService:(PLTService)service;
//		- (void)unsubscribeFromAll:(id <PLTDeviceInfoObserver>)subscriber;

//		- (NSArray *)subscriptions; // not implemented
//		- (PLTInfo *)cachedInfoForService:(PLTService)aService;
//		- (void)queryInfo:(id <PLTDeviceInfoObserver>)subscriber forService:(PLTService)aService;