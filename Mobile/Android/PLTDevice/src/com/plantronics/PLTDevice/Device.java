package com.plantronics.PLTDevice;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import com.plantronics.PLTDevice.calibration.Calibration;
import com.plantronics.PLTDevice.configuration.Configuration;
import com.plantronics.PLTDevice.info.EulerAngles;
import com.plantronics.PLTDevice.info.Info;
import com.plantronics.PLTDevice.info.OrientationTrackingInfo;
import com.plantronics.PLTDevice.info.Quaternion;
import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.bladerunner.communicator.BladeRunnerCommunicator;
import com.plantronics.bladerunner.model.device.BladeRunnerDevice;
import com.plantronics.bladerunner.model.device.BladeRunnerDeviceManager;
import com.plantronics.bladerunner.protocol.Event;
import com.plantronics.bladerunner.protocol.EventListener;
import com.plantronics.bladerunner.protocol.event.SignalStrengthEvent;
import com.plantronics.bladerunner.protocol.event.SubscribedServiceDataEvent;
import com.plantronics.bladerunner.protocol.event.WearingStateChangedEvent;

import java.util.HashSet;
import java.util.Set;

/**
 * Created by mdavis on 1/15/14.
 */


public class Device
{
	private static final String TAG = "com.plantronics.PLTDevice";

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

	public ConnectionListener 				_connectionListener;

	private boolean 						_isConnectionOpen;

	private Context					 		_context;
	private Communicator					_communicator; // from appcore
	private BladeRunnerCommunicator			_bladeRunnerCommunicator;
	private EventListener					_eventListener;
	private BladeRunnerDevice 				_device;
	private BladeRunnerDevice 				_sensorsDevice;

	/* ****************************************************************************************************
			Public
	*******************************************************************************************************/

	public Device(Context context) {
		_context = context;

		_eventListener = new com.plantronics.bladerunner.protocol.EventListener() {
			@Override
			public void onEventReceived(Event event) {
				eventReceived(event);
			}
		};

		_bladeRunnerCommunicator = BladeRunnerCommunicator.getInstance(_context);
		_bladeRunnerCommunicator.registerEventListener(_eventListener);
	}

	public void onResume() {
		Log.i(FN(), "onResume()");

		if (_communicator != null) _communicator.onResume();
		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.onResume();
		//_nativeBluetoothCommunicatorHandler.getConnectedDeviceRequest(); // TEMPORARILY DISABLED
		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.registerEventListener(_eventListener);
	}

	public void onPause() {
		Log.i(FN(), "onPause()");

		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.unregisterEventListener(_eventListener);
		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.onPause();
		if (_communicator != null) _communicator.onPause();
	}

	public void setConnectionListener(ConnectionListener listener) {
		_connectionListener = listener;
	}

	public static void getAvailableDevices(Context context, final AvailableDevicesCallback callback) {
		Log.i(FN(), "getAvailableDevices()");

		BladeRunnerCommunicator bladeRunnerCommunicator = BladeRunnerCommunicator.getInstance(context);
		bladeRunnerCommunicator.onResume();
		bladeRunnerCommunicator.getBladerunnerCapableDevices(new BladeRunnerCommunicator.CapableDevicesCallback() {
			@Override
			public void onCapableDevicesReceived(Set<BluetoothDevice> bladeRunnerCapableDevices) {
				Set<BladeRunnerDevice> brDevices = new HashSet<BladeRunnerDevice>();
				for (BluetoothDevice d : bladeRunnerCapableDevices) {
	BladeRunnerDevice br = BladeRunnerDeviceManager.getInstance().getBladeRunnerDevice(d);
					brDevices.add(br);
				}
				if (callback != null) {
					callback.onAvailableDevices(brDevices);
				}
			}

			@Override
			public void failure() {
				if (callback != null) {
					callback.failure();
				}
			}
		});
	}

	public boolean getIsConnectionOpen() {
		return _isConnectionOpen;
	}

	public void openConnection() {
		Log.i(FN(), "openConnection()");

		_bladeRunnerCommunicator.getBladerunnerCapableDevices(new BladeRunnerCommunicator.CapableDevicesCallback() {
			@Override
			public void onCapableDevicesReceived(Set<BluetoothDevice> bladeRunnerCapableDevices) {

				if (!bladeRunnerCapableDevices.isEmpty()) {
					Log.i(FN(), "bladeRunnerCapableDevices: " + bladeRunnerCapableDevices);
					_device = BladeRunnerDeviceManager.getInstance().getBladeRunnerDevice(bladeRunnerCapableDevices.iterator().next());
					Log.i(FN(), "Local device: " + _device);

					_bladeRunnerCommunicator.initialize(_device, new BladeRunnerCommunicator.InitializationCallback() {
						@Override
						public void onInitializationComplete(BladeRunnerDevice device) {
							Log.i(FN(), "Local device connected!");
						}

						@Override
						public void onDeviceDisconnected(BladeRunnerDevice device) {
							Log.i(FN(), "Local device disconnected!");

							_device = null;
							_sensorsDevice = null;
							_isConnectionOpen = false;
						}

						@Override
						public void onRemoteDeviceDiscovered(BladeRunnerDevice remoteDevice) {
							Log.i(FN(), "Remote device at route " + remoteDevice.getRouteToDevice() + " connected");

							int port = remoteDevice.getRouteToDevice().getPort(0);
							if (port == 5) {
								_bladeRunnerCommunicator.initialize(remoteDevice, new BladeRunnerCommunicator.InitializationCallback() {
									@Override
									public void onInitializationComplete(BladeRunnerDevice device) {
										Log.i(FN(), "Remote device connected!");

										_sensorsDevice = device;
										_isConnectionOpen = true;

										onConnectionOpen();
									}

									@Override
									public void onDeviceDisconnected(BladeRunnerDevice device) {} // handled in _device's onRemoteDeviceDisconnected()

									@Override
									public void onRemoteDeviceDiscovered(BladeRunnerDevice remoteDevice) {}

									@Override
									public void onRemoteDeviceDisconnected(BladeRunnerDevice remoteDevice) {}
								});
							}
						}

						@Override
						public void onRemoteDeviceDisconnected(BladeRunnerDevice remoteDevice) {
							Log.i(FN(), "Remote device disconnected!");

							if (remoteDevice == null) {
								Log.i(FN(), "********************* This is happening because of an error in service, will be fixed, for now, restart headset. *********************");
								return;
							}
							if (remoteDevice.getRouteToDevice().getPort(0) == 5) {
								_sensorsDevice = null;
								_isConnectionOpen = false;
							}
						}
					});
				}
				else {
					Log.i(FN(), "No Bladerunner devices found!");
				}
			}

			@Override
			public void failure() {
				//To change body of implemented methods use File | Settings | File Templates.
			}
		});
	}

	public void closeConnection() {

	}

	public void setConfiguration(Configuration config, int service) {

	}

	public Configuration getConfiguration(int service) {
		return null;
	}

	public void setCalibration(Calibration cal, int service) {

	}

	public Calibration getCalibration(int service) {
		return null;
	}

	public void subscribe(InfoListener subscriber, int service, int mode, int minPeriod) {

	}

	public void unsubscribe(InfoListener subscriber, int service) {

	}

	public void unsubscribe(InfoListener subscriber) {

	}

	public Info cachedInfo(int service) {
		return null;
	}

	public void queryInfo(InfoListener subscriber, int service) {

	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void onConnectionOpen() {
		Log.i(FN(), "************ CONNECTION OPEN! ************");

		_connectionListener.onConnectionOpen(this);
	}

	private void eventReceived(Event event) {
		Log.i(FN(), "eventReceived(): " + event);

		if (event instanceof SubscribedServiceDataEvent) {
			SubscribedServiceDataEvent serviceData = (SubscribedServiceDataEvent)event;
			//int[] data = serviceData.getServiceData();
			int serviceID = serviceData.getServiceID();

			switch (serviceID) {
				case 0x0000: // head orientation
					break;
				case 0x0003: // free fall
					break;
				case 0x0004: // taps
					break;
				case 0x0002: // pedometer
					break;
				case 0x0006: // gyro cal status
					break;
				case 0x0007: // mag cal status
					break;
			}
		}
		else if (event instanceof WearingStateChangedEvent) {
			final WearingStateChangedEvent e = (WearingStateChangedEvent)event;
			Log.i(FN(), "********* Wearing state event: " + (e.getWorn() ? "Donned" : "Doffed") + " *********");
		}
		else if (event instanceof SignalStrengthEvent) {
			final SignalStrengthEvent e = (SignalStrengthEvent)event;
			Log.i(FN(), "********* Signal strength event: Near/far: " + e.getNearFar() + ", Strength: " + e.getStrength() + " *********");
		}
	}

	/* ****************************************************************************************************
			Static
	*******************************************************************************************************/

	public static String FN() {
		StackTraceElement[] trace = Thread.currentThread().getStackTrace();
		if (trace.length >= 3) {
			String methodName = trace[3].getMethodName();
			return String.format("%s.%s", TAG, methodName);
		}
		else {
			return "STACK TRACE TOO SHALLOW";
		}
	}

	/* ****************************************************************************************************
			Classes
	*******************************************************************************************************/

	public static abstract class AvailableDevicesCallback {
		public abstract void onAvailableDevices(Set<BladeRunnerDevice>devices);
		public abstract void failure();
	}
}
