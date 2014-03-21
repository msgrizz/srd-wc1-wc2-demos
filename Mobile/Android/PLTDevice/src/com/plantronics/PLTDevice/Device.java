package com.plantronics.PLTDevice;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.util.Log;
import com.plantronics.PLTDevice.calibration.Calibration;
import com.plantronics.PLTDevice.calibration.OrientationTrackingCalibration;
import com.plantronics.PLTDevice.configuration.Configuration;
import com.plantronics.PLTDevice.info.*;
import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.bladerunner.communicator.BladeRunnerCommunicator;
import com.plantronics.bladerunner.model.device.BladeRunnerDevice;
import com.plantronics.bladerunner.model.device.BladeRunnerDeviceManager;
import com.plantronics.bladerunner.protocol.*;
import com.plantronics.bladerunner.protocol.EventListener;
import com.plantronics.bladerunner.protocol.command.SubscribeToServicesCommand;
import com.plantronics.bladerunner.protocol.event.SignalStrengthEvent;
import com.plantronics.bladerunner.protocol.event.SubscribedServiceDataEvent;
import com.plantronics.bladerunner.protocol.event.WearingStateChangedEvent;

import java.util.*;

/**
 * Created by mdavis on 1/15/14.
 */


public class Device
{
	private static final String TAG = "com.plantronics.PLTDevice";

	public static final int SERVICE_PROXIMITY =			 		0x1000;
	public static final int SERVICE_WEARING_STATE = 			0x1001;
	public static final int SERVICE_ORIENTATION_TRACKING = 		0x0000;
	public static final int SERVICE_PEDOMETER = 				0x0002;
	public static final int SERVICE_FREE_FALL = 				0x0003;
	public static final int SERVICE_TAPS = 						0x0004;
	public static final int SERVICE_MAGNETOMETER_CAL_STATUS = 	0x0006;
	public static final int SERVICE_GYROSCOPE_CAL_STATUS =		0x0005;

	public static final int SUBSCRIPTION_MODE_ON_CHANGE = 		1;
	public static final int SUBSCRIPTION_MODE_PERIODIC = 		2;

	public static final int INFO_REQUEST_TYPE_SUBSCRIPTION =	0;
	public static final int INFO_REQUEST_TYPE_QUERY =			1;

	private ArrayList<ConnectionListener> 			_connectionListeners;
	private HashMap<Integer, InternalSubscription>	_subscriptions;

	private HashMap<Integer, Info>					_cachedInfo;

	private boolean 								_isConnectionOpen;

	private Context					 				_context;
	private Communicator							_communicator; // from appcore
	private BladeRunnerCommunicator					_bladeRunnerCommunicator;
	private EventListener							_eventListener;
	private BladeRunnerDevice 						_device;
	private BladeRunnerDevice 						_sensorsDevice;

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

	public void addConnectionListener(ConnectionListener listener) {
		if (_connectionListeners==null) {
			_connectionListeners = new ArrayList<ConnectionListener>();
		}
		_connectionListeners.add(listener);
	}

	public void removeConnectionListener(ConnectionListener listener) {
		if (_connectionListeners!=null) {
			_connectionListeners.remove(listener);
		}
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

	public void subscribe(InfoListener listener, int service, int mode, int period) {
		Log.i(FN(), "subscribe(): listener=" + listener + ", service=" + service + ", mode=" + mode + ", period=" + period);

		if (listener!=null) {
			switch (service) {
				case SERVICE_ORIENTATION_TRACKING:
				case SERVICE_PEDOMETER:
				case SERVICE_FREE_FALL:
				case SERVICE_TAPS:
				case SERVICE_MAGNETOMETER_CAL_STATUS:
				case SERVICE_GYROSCOPE_CAL_STATUS:
					// cool.
					break;
				case SERVICE_PROXIMITY:
				case SERVICE_WEARING_STATE:
					// TODO: handle this!
					break;
				default:
					Log.e(FN(), "Invalid service: " + service);
					// TODO: Raise exception.
					return;
			}

			if (_subscriptions==null) {
				_subscriptions = new HashMap<Integer, InternalSubscription>();
			}

			// get the subscription with the matching serviceID.
			// 1. if doesnt exist, create it. add listener. add subscription. notify subscribers. execute BR command.
			// 2. if exists and the mode is different, change to new mode. remove and re-add listener. update subscription. notify all listeners. execute BR command.
			// 3. if exists and mode is onchange for both, remove and re-add listener. update subscription. dont notify subscribers. dont execute BR command.
			// 4. if exists and mode is periodic for both and both periods are the same, remove and re-add listener. update subscription. dont notify subscribers. dont execute BR command.
			// 5. if exists and mode is periodic for both and both periods are not the same, remove and re-add listener. update subscription. notify all subscribers. execute BR command.

			ArrayList<InfoListener> listenersToNotify = new ArrayList<InfoListener>();
			InternalSubscription oldInternalSubscription;
			InternalSubscription newInternalSubscription = new InternalSubscription(service, mode, period, listener);

			InternalSubscription sub = _subscriptions.get(service);
			// 1.
			if (sub==null) {
				_subscriptions.put(service, newInternalSubscription);
				listenersToNotify.add(listener);
				oldInternalSubscription = null;
			}
			else {
				oldInternalSubscription = sub;

				// 2.
				if (mode!=sub.getMode()) {
					listenersToNotify.addAll(sub.getListeners());
					sub.addListener(listener); // removes and re-adds
					_subscriptions.put(service, newInternalSubscription);
				}
				// 3.
				else if (mode==SUBSCRIPTION_MODE_ON_CHANGE && sub.getMode()==SUBSCRIPTION_MODE_ON_CHANGE) {
					sub.addListener(listener); // removes and re-adds
					_subscriptions.put(service, newInternalSubscription);
				}
				else if (mode==SUBSCRIPTION_MODE_PERIODIC && sub.getMode()==SUBSCRIPTION_MODE_PERIODIC) {
					// 4.
					if (period==sub.getPeriod()) {
						sub.addListener(listener); // removes and re-adds
						_subscriptions.put(service, newInternalSubscription);
					}
					// 5.
					else {
						sub.addListener(listener); // removes and re-adds
						_subscriptions.put(service, newInternalSubscription);
						listenersToNotify.addAll(sub.getListeners());
					}
				}
			}

			if (!listenersToNotify.isEmpty()) {

				Iterator i = listenersToNotify.iterator();
				while (i.hasNext()) {
					Subscription oldSubscription = null;
					if (oldInternalSubscription!=null) {
						oldSubscription = new Subscription(oldInternalSubscription.getServiceID(), oldInternalSubscription.getMode(), oldInternalSubscription.getPeriod());
					}
					Subscription newSubscription = new Subscription(newInternalSubscription.getServiceID(), newInternalSubscription.getMode(), newInternalSubscription.getPeriod());
					((InfoListener)i.next()).onSubscriptionChanged(oldSubscription, newSubscription);
				}

				SubscribeToServicesCommand command = new SubscribeToServicesCommand();
				command.setServiceID(service);
				command.setCharacteristic(0);
				if (mode==SUBSCRIPTION_MODE_ON_CHANGE) {
					command.setMode(SubscribeToServicesCommand.Mode.ModeOnCchange.getValue());
				}
				else {
					command.setMode(SubscribeToServicesCommand.Mode.ModePeriodic.getValue());
				}
				command.setPeriod(period);

				Log.i(FN(), "Subscribing... (" + service + ")");
				_bladeRunnerCommunicator.executeWithStreaming(command, _sensorsDevice, new MessageCallback() {
							@Override
							public void onSuccess(IncomingMessage message) {
								Log.i(FN(), "********* Subscribe success: " + message + " *********");
							}

							@Override
							public void onFailure(BladerunnerException exception) {
								Log.e(FN(), "********* Subscribe exception: " + exception + " *********");
							}
						}, new BladeRunnerCommunicator.FastEventListener() {
							@Override
							public void onEventReceived(Event event) {
								//Log.i(FN(), "\"********* Streaming: " + event.toString() + "*********");
								eventReceived(event);
							}
						});
			}
		}
		else {
			Log.e(FN(), "Listener is null!");
			// TODO: Raise exception.
		}
	}

	public void unsubscribe(InfoListener listener, int service) {
		if (listener!=null) {

			switch (service) {
				case SERVICE_ORIENTATION_TRACKING:
				case SERVICE_PEDOMETER:
				case SERVICE_FREE_FALL:
				case SERVICE_TAPS:
				case SERVICE_MAGNETOMETER_CAL_STATUS:
				case SERVICE_GYROSCOPE_CAL_STATUS:
					// cool.
					break;
				case SERVICE_PROXIMITY:
				case SERVICE_WEARING_STATE:
					// TODO: handle this!
					break;
				default:
					Log.e(FN(), "Invalid service: " + service);
					// TODO: Raise exception.
					return;
			}

			ArrayList<InfoListener> listenersToNotify = new ArrayList<InfoListener>();
			InternalSubscription oldInternalSubscription = null;
			boolean execCommand = false;

			if (_subscriptions==null) {
				// great, done!
			}
			else {
				InternalSubscription sub = _subscriptions.get(service);
				// 1.
				if (sub==null) {
					// done!
				}
				else {
					if (!sub.getListeners().contains(listener)) {
						// done!
					}
					else {
						oldInternalSubscription = sub;
						listenersToNotify.add(listener);

						if (sub.getListeners().size() > 1) {
							// after removing listener there will still be other listeners
							sub.removeListener(listener);
						}
						else {
							// listener is the last listener
							_subscriptions.remove(service);
							execCommand = true;
						}
					}
				}
			}

			if (execCommand) {
				SubscribeToServicesCommand command = new SubscribeToServicesCommand();
				command.setServiceID(service);
				command.setCharacteristic(0);
				command.setMode(SubscribeToServicesCommand.Mode.ModeOff.getValue());
				command.setPeriod(0);

				Log.i(FN(), "Unsubscribing...");
				_bladeRunnerCommunicator.execute(command, _sensorsDevice, new MessageCallback() {
					@Override
					public void onSuccess(IncomingMessage message) {
						Log.i(FN(), "********* Unsubscribe success: " + message + " *********");
					}

					@Override
					public void onFailure(BladerunnerException exception) {
						Log.e(FN(), "********* Unsubscribe exception: " + exception + " *********");
					}
				});
			}

			Iterator i = listenersToNotify.iterator();
			while (i.hasNext()) {
				Subscription oldSubscription = new Subscription(oldInternalSubscription.getServiceID(), oldInternalSubscription.getMode(), oldInternalSubscription.getPeriod());
				((InfoListener)i.next()).onSubscriptionChanged(oldSubscription, null);
			}
		}
		else {
			Log.e(FN(), "Listener is null!");
			// TODO: Raise exception.
		}
	}

	public void unsubscribe(InfoListener listener) {
		unsubscribe(listener, SERVICE_PROXIMITY);
		unsubscribe(listener, SERVICE_WEARING_STATE);
		unsubscribe(listener, SERVICE_ORIENTATION_TRACKING);
		unsubscribe(listener, SERVICE_PEDOMETER);
		unsubscribe(listener, SERVICE_FREE_FALL);
		unsubscribe(listener, SERVICE_TAPS);
		unsubscribe(listener, SERVICE_MAGNETOMETER_CAL_STATUS);
		unsubscribe(listener, SERVICE_GYROSCOPE_CAL_STATUS);
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

		Iterator i =  _connectionListeners.iterator();
		while (i.hasNext()) {
			((ConnectionListener)i.next()).onConnectionOpen(this);
		}
	}

	private void eventReceived(Event event) {
		Log.i(FN(), "eventReceived(): " + event);

		int requestType = INFO_REQUEST_TYPE_SUBSCRIPTION;
		Date timestamp = new Date();
		Info info = null;
		ArrayList<InfoListener> listeners = null;

		if (event instanceof SubscribedServiceDataEvent) {
			SubscribedServiceDataEvent serviceEvent = (SubscribedServiceDataEvent)event;
			int service = serviceEvent.getServiceID();

			InternalSubscription internalSubscription = _subscriptions.get(service);
			if (internalSubscription !=null) {
				int[] data = serviceEvent.getServiceData();
				listeners = internalSubscription.getListeners();

				switch (service) {
					case SERVICE_ORIENTATION_TRACKING:
						Log.i(FN(), "SERVICE_ORIENTATION_TRACKING");
						Quaternion q = quaternionFromData(data);
						OrientationTrackingCalibration cal = new OrientationTrackingCalibration(new Quaternion(1, 0, 0, 0));
						info = new OrientationTrackingInfo(requestType, timestamp, cal, q);
						break;
					case SERVICE_PEDOMETER:
						Log.i(FN(), "SERVICE_PEDOMETER");
						info = new PedometerInfo(requestType, timestamp, null, getPedometerCountFromData(data));
						break;
					case SERVICE_FREE_FALL:
						Log.i(FN(), "SERVICE_FREE_FALL");
						info = new FreeFallInfo(requestType, timestamp, null, getInFreeFallFromData(data));
						break;
					case SERVICE_TAPS:
						Log.i(FN(), "SERVICE_TAPS");
						info = new TapsInfo(requestType, timestamp, null, getTapCountFromData(data), getTapDirectionFromData(data));
						break;
					case SERVICE_MAGNETOMETER_CAL_STATUS:
						Log.i(FN(), "SERVICE_MAGNETOMETER_CAL_STATUS");
						info = new MagnetometerCalInfo(requestType, timestamp, null, getMagIsCaldFromData(data));
						break;
					case SERVICE_GYROSCOPE_CAL_STATUS:
						Log.i(FN(), "SERVICE_GYROSCOPE_CAL_STATUS");
						info = new GyroscopeCalInfo(requestType, timestamp, null, getGyroIsCaldFromData(data));
						break;
					default:
						Log.e(FN(), "Invalid service in event: " + service);
						return;
				}
			}
			else {
				// we dont have a internalSubscription for this service...
				Log.i(FN(), "No internalSubscription for service: " + service);
			}
		}
		else if (event instanceof WearingStateChangedEvent) {
			InternalSubscription internalSubscription = _subscriptions.get(SERVICE_WEARING_STATE);
			if (internalSubscription !=null) {
				WearingStateChangedEvent wearingStateEvent = (WearingStateChangedEvent)event;
				// TODO: Handle.
				Log.i(FN(), "********* Wearing state event: " + (wearingStateEvent.getWorn() ? "Donned" : "Doffed") + " *********");
			}
		}
		else if (event instanceof SignalStrengthEvent) {
			InternalSubscription internalSubscription = _subscriptions.get(SERVICE_PROXIMITY);
			if (internalSubscription !=null) {
				SignalStrengthEvent signalStrengthEvent = (SignalStrengthEvent)event;
				// TODO: Handle.
				Log.i(FN(), "********* Signal strength event: Near/far: " + signalStrengthEvent.getNearFar() + ", Strength: " + signalStrengthEvent.getStrength() + " *********");
			}
		}

		if (listeners!=null) {
			Iterator i = listeners.iterator();
			while (i.hasNext()) {
				((InfoListener)i.next()).onInfoReceived(info);
			}
		}
	}

	/* ****************************************************************************************************
			Helpers
	*******************************************************************************************************/

	private Quaternion quaternionFromData(int[] data) {
		int w = (data[0] << 8) + data[1];
		int x = (data[2] << 8) + data[3];
		int y = (data[4] << 8) + data[5];
		int z = (data[6] << 8) + data[7];

		if (w > 32767) w -= 65536;
		if (x > 32767) x -= 65536;
		if (y > 32767) y -= 65536;
		if (z > 32767) z -= 65536;

		double fw = ((double)w) / 16384.0f;
		double fx = ((double)x) / 16384.0f;
		double fy = ((double)y) / 16384.0f;
		double fz = ((double)z) / 16384.0f;

		Quaternion q = new Quaternion(fw, fx, fy, fz);
		if (q.w>1.0001f || q.x>1.0001f || q.y>1.0001f || q.z>1.0001f) {
			Log.i(FN(), "Bad quaternion! " + q);
		}
		else {
			return q;
		}

		return null;
	}

	private boolean getInFreeFallFromData(int[] data) {
		return (data[1]==1 ? true : false);
	}

	private int getTapCountFromData(int[] data) {
		int taps = data[3];
		return taps;
	}

	private int getTapDirectionFromData(int[] data) {
		int direction = data[1];
		return direction;
	}

	private int getPedometerCountFromData(int[] data) {
		int count = data[1];
		return count;
	}

	private boolean getGyroIsCaldFromData(int[] data) {
		return (data[1] == 3 ? true : false);
	}

	private boolean getMagIsCaldFromData(int[] data) {
		return (data[1] == 3 ? true : false);
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

	private class InternalSubscription {

		private int 					_serviceID;
		private int 					_mode;
		private int						_period;
		ArrayList<InfoListener> _listeners;

		public InternalSubscription(int serviceID, int mode, int period, InfoListener listener) {
			_serviceID = serviceID;
			_mode = mode;
			_period = period;
			_listeners = new ArrayList<InfoListener>();
			_listeners.add(listener);
		}

		public InternalSubscription(int serviceID, int mode, int period, ArrayList<InfoListener> listeners) {
			_serviceID = serviceID;
			_mode = mode;
			_period = period;
			_listeners = listeners;
		}

		public int getServiceID() {
			return _serviceID;
		}

		public int getMode() {
			return _mode;
		}

		public int getPeriod() {
			return _period;
		}

		public ArrayList<InfoListener> getListeners() {
			return _listeners;
		}

		public void addListener(InfoListener listener) {
			removeListener(listener);
			_listeners.add(listener);
		}

		public void removeListener(InfoListener listener) {
			_listeners.remove(listener);
		}

		@Override
		public String toString() {
			return getClass().getName() + ": serviceID=" + _serviceID + ", mode=" + _mode + ", period=" + _period + ", listeners=" + _listeners;
		}
	}
}
