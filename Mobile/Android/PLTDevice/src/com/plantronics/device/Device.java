package com.plantronics.device;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.ParcelUuid;
import android.os.Parcelable;
import android.util.Log;
import com.plantronics.bladerunner.protocol.command.ConfigureSignalStrengthEventsCommand;
import com.plantronics.device.calibration.Calibration;
import com.plantronics.device.calibration.OrientationTrackingCalibration;
import com.plantronics.device.calibration.PedometerCalibration;
import com.plantronics.device.configuration.Configuration;
import com.plantronics.device.info.*;
import com.plantronics.bladerunner.communicator.BladeRunnerCommunicator;
import com.plantronics.bladerunner.model.device.BladeRunnerDevice;
import com.plantronics.bladerunner.model.device.BladeRunnerDeviceManager;
import com.plantronics.bladerunner.protocol.*;
import com.plantronics.bladerunner.protocol.EventListener;
import com.plantronics.bladerunner.protocol.command.SubscribeToServicesCommand;
import com.plantronics.bladerunner.protocol.event.SignalStrengthEvent;
import com.plantronics.bladerunner.protocol.event.SubscribedServiceDataEvent;
import com.plantronics.bladerunner.protocol.event.WearingStateChangedEvent;
import com.plantronics.bladerunner.protocol.setting.*;

import java.util.*;

/**
 * Created by mdavis on 1/15/14.
 */


public class Device {

	private static final String TAG = 							"com.plantronics.device";

	private static final UUID BLADERUNNER_UUID = 				UUID.fromString("82972387-294E-4D62-97B5-2668AA35F618");

	public static final int SERVICE_WEARING_STATE = 			0x1000;
	public static final int SERVICE_PROXIMITY =			 		0x1001;
	public static final int SERVICE_ORIENTATION_TRACKING = 		0x0000;
	public static final int SERVICE_PEDOMETER = 				0x0002;
	public static final int SERVICE_FREE_FALL = 				0x0003;
	public static final int SERVICE_TAPS = 						0x0004;
	public static final int SERVICE_MAGNETOMETER_CAL_STATUS = 	0x0006;
	public static final int SERVICE_GYROSCOPE_CAL_STATUS =		0x0005;

	public static final int SUBSCRIPTION_MODE_ON_CHANGE = 		1;
	public static final int SUBSCRIPTION_MODE_PERIODIC = 		2;

	private static Context					 					_context;
	private static ArrayList<Device> 							_pairedDevices;
	private static ArrayList<PairingListener> 					_pairingListeners;
	private ArrayList<ConnectionListener> 						_connectionListeners;
	private HashMap<Integer, InternalSubscription>				_subscriptions;
	private HashMap<Integer, Info>								_cachedInfo;
	private HashMap<Integer, ArrayList<InfoListener>>			_queryListeners;
	private static boolean										_isInitialized;
	private boolean 											_isConnectionOpen;
	private BladeRunnerCommunicator								_bladeRunnerCommunicator;
	private EventListener										_eventListener;
	private BluetoothDevice										_btDevice;
	private BladeRunnerDevice 									_device;
	private BladeRunnerDevice 									_sensorsDevice;
	private int 												_localPort;
	private int 												_remotePort;
	private TimerTask											_wearingStateTimerTask;
	private TimerTask											_proximityTimerTask;
	private OrientationTrackingCalibration						_orientationTrackingCalibration;
	private int													_pedometerOffset;
	private String												_address;
	private String												_model;
	private String												_name;
	private String												_serialNumber;
	private int													_fwMajorVersion;
	private int													_fwMinorVersion;
	private ArrayList<Integer>									_supportedServices;


	/* ****************************************************************************************************
			Public
	*******************************************************************************************************/

	public Device(BluetoothDevice btDevice) {
		_btDevice = btDevice;
		_address = _btDevice.getAddress();
		//_device = BladeRunnerDeviceManager.getInstance().getBladeRunnerDevice(_btDevice);

		_eventListener = new com.plantronics.bladerunner.protocol.EventListener() {
			@Override
			public void onEventReceived(Event event) {
				Device.this.onEventReceived(event); // Device.this donno why but stack overflow otherwise
			}
		};

		_bladeRunnerCommunicator = BladeRunnerCommunicator.getInstance(_context);
		_bladeRunnerCommunicator.registerEventListener(_eventListener);
	}

	public static void initialize(Context context, final InitializationCallback callback) {
		Log.i(FN(), "initialize()");

		//TODO: check context!=null

		if (!_isInitialized) {
			_context = context.getApplicationContext();
			registerBondStateReceiver();
			updatePairedDevices(new PairedDeviceUpdateCallback() {
				@Override
				public void onPairedDevicesUpdated() {
					_isInitialized = true;
					if (callback != null) {
						callback.onInitialized();
					}
				}

				@Override
				public void onFailure() {
					if (callback != null) {
						callback.onFailure();
					}
				}
			});
		}
		else {
			if (callback != null) {
				callback.onInitialized();
			}
		}
	}

	@Override
	public boolean equals(Object obj) {
		Device otherDevice = (Device)obj;
		return this.getAddress().equals(otherDevice.getAddress());
	}

	public void onResume() {
		Log.i(FN(), "onResume()");

		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.onResume();
		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.registerEventListener(_eventListener);

		registerBondStateReceiver();
	}

	public void onPause() {
		Log.i(FN(), "onPause()");

		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.unregisterEventListener(_eventListener);
		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.onPause();
	}

	public void registerConnectionListener(ConnectionListener listener) {
		if (_connectionListeners==null) {
			_connectionListeners = new ArrayList<ConnectionListener>();
		}
		if (!_connectionListeners.contains(listener)) {
			_connectionListeners.add(listener);
		}
	}

	public void unregisterConnectionListener(ConnectionListener listener) {
		if (_connectionListeners!=null) {
			_connectionListeners.remove(listener);
		}
	}

	public static boolean getIsInitialized() {
		return _isInitialized;
	}

	public static ArrayList<Device> getPairedDevices() {
		return _pairedDevices;
	}

	public boolean getIsConnectionOpen() {
		return _isConnectionOpen;
	}

	public void openConnection() {
		Log.i(FN(), "openConnection(): " + getAddress());

		_btDevice = getBluetoothDeviceForAddress(_address);
		if (_btDevice==null) {
			Log.e(FN(), "Device at address " + _address + " has disappeared!");
		}
		_device = BladeRunnerDeviceManager.getInstance().getBladeRunnerDevice(_btDevice);

		_localPort = -1;
		_remotePort = -1;

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

				onConnectionClosed();
			}

			@Override
			public void onRemoteDeviceDiscovered(BladeRunnerDevice remoteDevice) {
				int port = remoteDevice.getRouteToDevice().getPort(0);
				Log.i(FN(), "Remote device on port " + port + " connected.");

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
				else if (port==2 || port==3) {
					_remotePort = port;
				}
			}

			@Override
			public void onRemoteDeviceDisconnected(BladeRunnerDevice remoteDevice) {
				byte port = (byte)remoteDevice.getRouteToDevice().getPort(0);
				Log.i(FN(), "Remote device on port " + port + "disconnected.");

				if (remoteDevice == null) {
					Log.i(FN(), "********************* This is happening because of an error in service, will be fixed, for now, restart headset. *********************");
					return;
				}
				if (port == 5) {
					_sensorsDevice = null;
					_isConnectionOpen = false;

					onConnectionClosed();
				}
			}
		});
	}

	public void closeConnection() {
		Log.i(FN(), "closeConnection()");
		_bladeRunnerCommunicator.close(_device);
	}

	public String getAddress() {
		return _address;
	}

	public String getModel() {
		return _model;
	}

	private String getName() {
		return _name;
	}

	private String getSerialNumber() {
		return _serialNumber;
	}

	private int getFWMajorVersion() {
		return _fwMajorVersion;
	}

	private int getFWMinorVersion() {
		return _fwMinorVersion;
	}

	private ArrayList<Integer> getSupportedServices() {
		return _supportedServices;
	}

	public void setConfiguration(Configuration config, int service) {

	}

	public Configuration getConfiguration(int service) {
		return null;
	}

	public void setCalibration(Calibration cal, int service) {
		Log.i(FN(), "setCalibration(): cal=" + cal + ", service=" + service);

		switch (service) {
			case SERVICE_ORIENTATION_TRACKING:
				OrientationTrackingCalibration theCal = null;

				if (cal==null) {
					if (_cachedInfo!=null) {
						OrientationTrackingInfo orientationInfo = (OrientationTrackingInfo)_cachedInfo.get(service);
						if (orientationInfo!=null) {
							theCal = new OrientationTrackingCalibration(orientationInfo.getUncalibratedQuaternion());
						}
					}
				}
				if (theCal==null) {
					// no saved orientation info to use for cal. query info and use that.
					queryOrientationTrackingForCal();
				}
				else {
					_orientationTrackingCalibration = theCal;
				}
				break;
			case SERVICE_PEDOMETER:
				PedometerCalibration pedCal = (PedometerCalibration)cal;
				if (pedCal==null || pedCal.getReset()) {
					if (_cachedInfo!=null) {
						PedometerInfo pedInfo = (PedometerInfo)_cachedInfo.get(service);
						if (pedInfo!=null) {
							int steps = pedInfo.getSteps();
							if (steps > 0) {
								_pedometerOffset += steps;
							}
						}
					}
				}
				break;
			default:
				break;
		}
	}

	public Calibration getCalibration(int service) {
		switch (service) {
			case SERVICE_ORIENTATION_TRACKING:
				return _orientationTrackingCalibration;
			default:
				break;
		}
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
				case SERVICE_WEARING_STATE:
				case SERVICE_PROXIMITY:
					// cool.
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
			// 4. if exists and mode is periodic for both and both periods ARE the same, remove and re-add listener. update subscription. dont notify subscribers. dont execute BR command.
					// UPDATE: how about do nothing?
			// 5. if exists and mode is periodic for both and both periods are NOT the same, remove and re-add listener. update subscription. notify all subscribers. execute BR command.

			// to help keep the "record keeping" logic on top, and the "execution" logic on bottom, save the "case" from above and reference it below for wearing state and proximity
			int casee = 0;

			ArrayList<InfoListener> listenersToNotify = new ArrayList<InfoListener>();
			InternalSubscription oldInternalSubscription;
			InternalSubscription newInternalSubscription = new InternalSubscription(service, mode, period, listener);

			InternalSubscription sub = _subscriptions.get(service);
			// 1.
			if (sub==null) {
				casee = 1;
				_subscriptions.put(service, newInternalSubscription);
				listenersToNotify.add(listener);
				oldInternalSubscription = null;
			}
			else {
				oldInternalSubscription = sub;

				// 2.
				if (mode!=sub.getMode()) {
					casee = 2;
					listenersToNotify.addAll(sub.getListeners());
					sub.addListener(listener); // removes and re-adds
					_subscriptions.put(service, newInternalSubscription);
				}
				// 3.
				else if (mode==SUBSCRIPTION_MODE_ON_CHANGE && sub.getMode()==SUBSCRIPTION_MODE_ON_CHANGE) {
					casee = 3;
					sub.addListener(listener); // removes and re-adds
					_subscriptions.put(service, newInternalSubscription);
				}
				else if (mode==SUBSCRIPTION_MODE_PERIODIC && sub.getMode()==SUBSCRIPTION_MODE_PERIODIC) {
					// 4.
					if (period==sub.getPeriod()) {
//						casee = 4;
//						sub.addListener(listener); // removes and re-adds
//						_subscriptions.put(service, newInternalSubscription);
					}
					// 5.
					else {
						casee = 5;
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
								//Device.this.onEventReceived(event);
								onEventReceived(event);
							}
						});
			}

			// now for wearing state and proximity. we'll reference the "case" from above.

			if (service==SERVICE_WEARING_STATE) {
				boolean periodic = newInternalSubscription.getMode()==SUBSCRIPTION_MODE_PERIODIC;
				switch (casee) {
					case 1:
						if (periodic) {
							startWearingStateTimerTask(period);
						}
						else if (_wearingStateTimerTask!=null) {
							_wearingStateTimerTask.cancel();
						}
						break;
					case 2:
						if (periodic) {
							startWearingStateTimerTask(period);
						}
						else if (_wearingStateTimerTask!=null) {
							_wearingStateTimerTask.cancel();
						}
						break;
					case 3:
						if (_wearingStateTimerTask!=null) {
							_wearingStateTimerTask.cancel();
						}
						break;
					case 4:
						// disabled
						break;
					case 5:
						if (periodic) {
							startWearingStateTimerTask(period);
						}
						else if (_wearingStateTimerTask!=null) {
							_wearingStateTimerTask.cancel();
						}
						break;
				}
			}
			else if (service==SERVICE_PROXIMITY) {
				boolean periodic = newInternalSubscription.getMode()==SUBSCRIPTION_MODE_PERIODIC;
				switch (casee) {
					case 1:
						if (periodic) {
							startProximityTimerTask(period);
						}
						else if (_proximityTimerTask!=null) {
							_proximityTimerTask.cancel();
						}

						// actually start the signal strength events (for ports 2 and 3)

						for (int connectionID = 2; connectionID <= 3; connectionID++) {
							ConfigureSignalStrengthEventsCommand command = new ConfigureSignalStrengthEventsCommand();
							command.setEnable(true);
							command.setConnectionId(connectionID);
							command.setDononly(false);
							command.setReportNearFarAudio(false);
							command.setReportNearFarToBase(false);
							command.setReportRssiAudio(false);
							command.setTrend(false);
							command.setSensitivity(5);
							command.setNearThreshold(70);
							command.setMaxTimeout(15);
							_bladeRunnerCommunicator.execute(command, _sensorsDevice, new MessageCallback() {
								@Override
								public void onSuccess(IncomingMessage message) {
									Log.i(FN(), "********* Configure signal strength events success: " + message + " *********");
								}

								@Override
								public void onFailure(BladerunnerException exception) {
									Log.e(FN(), "********* Configure signal strength events exception: " + exception + " *********");
								}
							});
						}

						break;
					case 2:
						if (periodic) {
							startProximityTimerTask(period);
						}
						else if (_proximityTimerTask!=null) {
							_proximityTimerTask.cancel();
						}
						break;
					case 3:
						if (_proximityTimerTask!=null) {
							_proximityTimerTask.cancel();
						}
						break;
					case 4:
						// disabled
						break;
					case 5:
						if (periodic) {
							startProximityTimerTask(period);
						}
						else if (_proximityTimerTask!=null) {
							_proximityTimerTask.cancel();
						}
						break;
				}
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
				case SERVICE_WEARING_STATE:
				case SERVICE_PROXIMITY:
					// cool.
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
				if (service==SERVICE_WEARING_STATE) {
					// wearing state events cant be turned off.
					if (_wearingStateTimerTask != null) {
						_wearingStateTimerTask.cancel();
					}
				}
				else if(service==SERVICE_PROXIMITY) {
					if (_proximityTimerTask != null) {
						_proximityTimerTask.cancel();
					}

					for (int connectionID = 2; connectionID <= 3; connectionID++) {
						ConfigureSignalStrengthEventsCommand command = new ConfigureSignalStrengthEventsCommand();
						command.setEnable(false);
						command.setConnectionId(connectionID);
						command.setDononly(false);
						command.setReportNearFarAudio(false);
						command.setReportNearFarToBase(false);
						command.setReportRssiAudio(false);
						command.setTrend(false);
						// TODO: check these values
						command.setSensitivity(5);
						command.setNearThreshold(70);
						command.setMaxTimeout(15);
						_bladeRunnerCommunicator.execute(command, _device, new MessageCallback() {
							@Override
							public void onSuccess(IncomingMessage message) {
								Log.i(FN(), "********* Configure signal strength events success: " + message + " *********");
							}

							@Override
							public void onFailure(BladerunnerException exception) {
								Log.e(FN(), "********* Configure signal strength events exception: " + exception + " *********");
							}
						});
					}
				}
				else {
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
							// TODO: handle.
						}
					});
				}
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
		unsubscribe(listener, SERVICE_WEARING_STATE);
		unsubscribe(listener, SERVICE_PROXIMITY);
		unsubscribe(listener, SERVICE_ORIENTATION_TRACKING);
		unsubscribe(listener, SERVICE_PEDOMETER);
		unsubscribe(listener, SERVICE_FREE_FALL);
		unsubscribe(listener, SERVICE_TAPS);
		unsubscribe(listener, SERVICE_MAGNETOMETER_CAL_STATUS);
		unsubscribe(listener, SERVICE_GYROSCOPE_CAL_STATUS);
	}

	public Info getCachedInfo(int service) {
		Info info = _cachedInfo.get(service);
		if (info!=null) {
			info.setRequestType(Info.REQUEST_TYPE_CACHED);
		}
		return info;
	}

	public void queryInfo(InfoListener listener, int service) {
		Log.i(FN(), "queryInfo(): listener=" + listener + ", service=" + service);

		if (_queryListeners==null) {
			_queryListeners = new HashMap<Integer, ArrayList<InfoListener>>();
		}

		boolean execRequest = false;

		ArrayList<InfoListener> listeners = _queryListeners.get(service);
		if (listeners==null) {
			// nobody is waiting for this query right now. add the listener and do the query.
			Log.i(FN(), "Adding new listener " + listener + " for service " + service);

			listeners = new ArrayList<InfoListener>();
			listeners.add(listener);
			_queryListeners.put(service, listeners);
			execRequest = true;
		}
		else if (!listeners.contains(listener)) {
			// somebody is waiting for this query, but listener isn't. add it.
			Log.i(FN(), "Adding listener " + listener + " for service " + service);

			if (!listeners.contains(listener)) {
				listeners.add(listener);
			}
			execRequest = true;
		}
		else {
			// listener is already waiting for the query result. do nothing.
			Log.i(FN(), "Listener " + listener + " is already waiting for service " + service);


//			// ************ TEMPORARY FOR TESTING ************
//			if (service!=SERVICE_WEARING_STATE && service!=SERVICE_PROXIMITY) {
//				if (!listeners.contains(listener)) {
//					listeners.add(listener);
//				}
//				execRequest = true;
//			}
//			// ***********************************************
		}

		if (execRequest) {
			if (service==SERVICE_WEARING_STATE) {
				WearingStateRequest request = new WearingStateRequest();
				_bladeRunnerCommunicator.execute(request, _device, new MessageCallback() {
					@Override
					public void onSuccess(IncomingMessage incomingMessage) {
						onSettingsResponseReceived((SettingsResponse)incomingMessage);
					}

					@Override
					public void onFailure(BladerunnerException exception) {
						Log.e(FN(), "********* Wearing state exception: " + exception + " *********");
						// TODO: handle.
					}
				});
			}
			else if(service==SERVICE_PROXIMITY) {

			}
			else {
				QueryServicesDataRequest request = new QueryServicesDataRequest();
				request.setServiceID(service);
				request.setCharacteristic(0);

				_bladeRunnerCommunicator.execute(request, _sensorsDevice, new MessageCallback() {
					@Override
					public void onSuccess(IncomingMessage message) {
						onSettingsResponseReceived((SettingsResponse)message);
					}

					@Override
					public void onFailure(BladerunnerException exception) {
						Log.e(FN(), "********* Query service exception: " + exception + " *********");
						// TODO: handle.
					}
				});
			}
		}
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	private void onConnectionOpen() {
		Log.i(FN(), "onConnectionOpen()");

		_cachedInfo = new HashMap<Integer, Info>();
		getConnectionStatus();
	}

	private void onConnectionClosed() {
		Log.i(FN(), "************ CONNECTION CLOSED! ************");

		_subscriptions = null;

		if (_wearingStateTimerTask!=null) {
			_wearingStateTimerTask.cancel();
			_wearingStateTimerTask = null;
		}
		if (_proximityTimerTask!=null) {
			_proximityTimerTask.cancel();
			_proximityTimerTask = null;
		}

		if (_connectionListeners!=null) {
			Iterator i =  _connectionListeners.iterator();
			while (i.hasNext()) {
				((ConnectionListener)i.next()).onConnectionClosed(this);
			}
		}
	}

	private void getConnectionStatus() {
		Log.i(FN(), "getConnectionStatus()");

		ConnectionStatusRequest request = new ConnectionStatusRequest();
		_bladeRunnerCommunicator.execute(request, _device, new MessageCallback() {
			@Override
			public void onSuccess(IncomingMessage message) {
				ConnectionStatusResponse reponse = (ConnectionStatusResponse)message;

				Log.i(FN(), "********* Connection status success: " + reponse + " *********");
				onConnectionStatusReceived(reponse);
			}

			@Override
			public void onFailure(BladerunnerException exception) {
				Log.e(FN(), "********* Get device info exception: " + exception + " *********");
			}
		});
	}

	private void onConnectionStatusReceived(ConnectionStatusResponse reponse) {
		_localPort = reponse.getOriginatingPortID();
		Log.i(FN(), "getConnectionStatus(): remotePort=" + _remotePort);
	}

	private void getDeviceInfo() {

		// *** temporary work-around since v010 HS and current Android SDK dont support "Get Version Info" setting. ***

		onDeviceInfoReceived(null);


//		GetDeviceInfoRequest request = new GetDeviceInfoRequest();
//		_bladeRunnerCommunicator.execute(request, _sensorsDevice, new MessageCallback() {
//			@Override
//			public void onSuccess(IncomingMessage message) {
//				GetDeviceInfoRequest reponse = (GetDeviceInfoRequest)message;
//				Log.i(FN(), "********* Get device info success: " + reponse + " *********");
//				onDeviceInfoReceived(message);
//			}
//
//			@Override
//			public void onFailure(BladerunnerException exception) {
//				Log.e(FN(), "********* Get device info exception: " + exception + " *********");
//			}
//		});
	}

	private void onDeviceInfoReceived(GetDeviceInfoRequest response) {
		Log.i(FN(), "************ onDeviceInfoReceived() ************");

		if (response==null) {
		_model = "PLT_WC1";
			_name = "Wearable Concept 1";
			_serialNumber = null;
			_fwMajorVersion = 0;
			_fwMinorVersion = 0;
			_supportedServices = new ArrayList<Integer>();
			_supportedServices.add(SERVICE_WEARING_STATE);
			_supportedServices.add(SERVICE_PROXIMITY);
			_supportedServices.add(SERVICE_ORIENTATION_TRACKING);
			_supportedServices.add(SERVICE_PEDOMETER);
			_supportedServices.add(SERVICE_FREE_FALL);
			_supportedServices.add(SERVICE_TAPS);
			_supportedServices.add(SERVICE_MAGNETOMETER_CAL_STATUS);
			_supportedServices.add(SERVICE_GYROSCOPE_CAL_STATUS);
		}
		else {
			// parse the real device info
		}

		if (_connectionListeners!=null) {
			Iterator i =  _connectionListeners.iterator();
			while (i.hasNext()) {
				((ConnectionListener)i.next()).onConnectionOpen(this);
			}
		}
	}

	private void onEventReceived(Event event) {
		Log.i(FN(), "onEventReceived(): " + event);

		int requestType = Info.REQUEST_TYPE_SUBSCRIPTION;
		Date timestamp = new Date();
		Info info = null;
		ArrayList<InfoListener> listeners = null;
		int service = -1;
		InternalSubscription internalSubscription = null;

		if (event instanceof SubscribedServiceDataEvent) {
			SubscribedServiceDataEvent serviceEvent = (SubscribedServiceDataEvent)event;
			service = serviceEvent.getServiceID();

			if (_subscriptions!=null) {
				internalSubscription = _subscriptions.get(service);
				if (internalSubscription!=null) {
					listeners = internalSubscription.getListeners();
				}
			}

			int[] data = serviceEvent.getServiceData();

			switch (service) {
				case SERVICE_ORIENTATION_TRACKING:
					Log.i(FN(), "SERVICE_ORIENTATION_TRACKING");
					Quaternion q = getQuaternionFromData(data);
					//Log.i(FN(), "angles: " + new EulerAngles(q));
					info = new OrientationTrackingInfo(requestType, timestamp, _orientationTrackingCalibration, q);
					break;
				case SERVICE_PEDOMETER:
					Log.i(FN(), "SERVICE_PEDOMETER");
					int steps = getPedometerCountFromData(data);
					int calSteps = steps - _pedometerOffset;
					if (calSteps < 0) calSteps = steps;
					info = new PedometerInfo(requestType, timestamp, null, calSteps);
					break;
				case SERVICE_FREE_FALL:
					Log.i(FN(), "SERVICE_FREE_FALL");
					info = new FreeFallInfo(requestType, timestamp, null, getIsInFreeFallFromData(data));
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
		else if (event instanceof WearingStateChangedEvent) {
			service = SERVICE_WEARING_STATE;
			WearingStateChangedEvent wearingStateEvent = (WearingStateChangedEvent)event;
			info = new WearingStateInfo(requestType, timestamp, null, wearingStateEvent.getWorn());
			if (_subscriptions!=null) {
				internalSubscription = _subscriptions.get(service);
				if (internalSubscription!=null) {
					if (internalSubscription.getMode()==SUBSCRIPTION_MODE_ON_CHANGE) {
						listeners = internalSubscription.getListeners();
					}
				}
			}
		}
		else if (event instanceof SignalStrengthEvent) {
			service = SERVICE_PROXIMITY;
			SignalStrengthEvent signalStrengthEvent = (SignalStrengthEvent)event;
			// TODO: Which connectionID is local and which is remote?
			info = new ProximityInfo(requestType, timestamp, null, ProximityInfo.PROXIMITY_UNKNOWN, ProximityInfo.PROXIMITY_UNKNOWN);
			//Log.i(FN(), "********* Signal strength event: Near/far: " + signalStrengthEvent.getNearFar() + ", Strength: " + signalStrengthEvent.getStrength() + " *********");
			if (_subscriptions!=null) {
				internalSubscription = _subscriptions.get(service);
				if (internalSubscription!=null) {
					if (internalSubscription.getMode()==SUBSCRIPTION_MODE_ON_CHANGE) {
						listeners = internalSubscription.getListeners();
					}
				}
			}
		}

		if (info!=null && _cachedInfo!=null) {
			_cachedInfo.put(service, info);
		}

		if (listeners!=null && info!=null) {
			Iterator i = listeners.iterator();
			while (i.hasNext()) {
				((InfoListener)i.next()).onInfoReceived(info);
			}
		}
	}

	private void onSettingsResponseReceived(SettingsResponse response) {
		Log.i(FN(), "onSettingsResponseReceived(): " + response);

		int requestType = Info.REQUEST_TYPE_QUERY;
		Date timestamp = new Date();
		Info info = null;
		ArrayList<InfoListener> listeners = null;
		int service = -1;

		if (response instanceof QueryServicesDataResponse) {
			QueryServicesDataResponse queryServicesDataResponse = (QueryServicesDataResponse)response;
			service = queryServicesDataResponse.getServiceID();

			listeners = _queryListeners.get(service);
			if (listeners!=null) {
				int[] data = queryServicesDataResponse.getServiceData();

				switch (service) {
					case SERVICE_ORIENTATION_TRACKING:
						Log.i(FN(), "SERVICE_ORIENTATION_TRACKING");
						Quaternion q = getQuaternionFromData(data);
						info = new OrientationTrackingInfo(requestType, timestamp, _orientationTrackingCalibration, q);
						break;
					case SERVICE_PEDOMETER:
						Log.i(FN(), "SERVICE_PEDOMETER");
						int steps = getPedometerCountFromData(data);
						int calSteps = steps - _pedometerOffset;
						if (calSteps < 0) calSteps = steps;
						info = new PedometerInfo(requestType, timestamp, null, calSteps);
						break;
					case SERVICE_FREE_FALL:
						Log.i(FN(), "SERVICE_FREE_FALL");
						info = new FreeFallInfo(requestType, timestamp, null, getIsInFreeFallFromData(data));
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
				// nodoby is waiting for this query...
				Log.i(FN(), "Odd. No query listeners for service " + service);
			}
		}
		else if (response instanceof WearingStateResponse) {
			service = SERVICE_WEARING_STATE;
			listeners = _queryListeners.get(service);
			if (listeners!=null) {
				WearingStateResponse wearingStateResponse = (WearingStateResponse)response;
				info = new WearingStateInfo(requestType, timestamp, null, wearingStateResponse.getWorn());
			}
		}
//		else if (response instanceof CurrentSignalStrengthResponse) {
//			InternalSubscription internalSubscription = _subscriptions.get(SERVICE_PROXIMITY);
//			if (internalSubscription !=null) {
//				CurrentSignalStrengthResponse currentSignalStrengthResponse = (CurrentSignalStrengthResponse)response;
//				// TODO: Handle.
//				Log.i(FN(), "********* Signal strength response: Near/far: " + currentSignalStrengthResponse.getNearFar() + ", Strength: " + currentSignalStrengthResponse.getStrength() + " *********");
//			}
//		}

		if (info!=null && _cachedInfo!=null) {
			_cachedInfo.put(service, info);
		}

		if (listeners!=null && info!=null) {
			Iterator i = listeners.iterator();
			while (i.hasNext()) {
				((InfoListener)i.next()).onInfoReceived(info);
			}
		}

		if (_queryListeners!=null) {
			_queryListeners.remove(service);
		}
	}

	public BluetoothDevice getBluetoothDeviceForAddress(String address) {
		Log.i(FN(), "getBluetoothDeviceForAddress(): " + address);

		BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
		Set<BluetoothDevice> bondedDevices = adapter.getBondedDevices();
		Iterator i = bondedDevices.iterator();
		while (i.hasNext()) {
			BluetoothDevice d = (BluetoothDevice)i.next();
			if (d.getAddress().equals(address)) {
				return d;
			}
		}
		return null;
	}

	private void startWearingStateTimerTask(long period) {
		Log.i(FN(), "startWearingStateTimerTask(): " + period);

		if (_cachedInfo.get(SERVICE_WEARING_STATE)==null) {
			queryWearingState(); // prime the cached info
		}
		if (_wearingStateTimerTask!=null) {
			_wearingStateTimerTask.cancel();
		}
		_wearingStateTimerTask = new TimerTask() {
			@Override
			public void run() {
				wearingStateTimerTask();
			}
		};

		Timer timer = new Timer();
		timer.scheduleAtFixedRate(_wearingStateTimerTask, period, period);
	}

	private void startProximityTimerTask(long period) {
		Log.i(FN(), "startProximityTimerTask(): " + period);

		_proximityTimerTask.cancel();
		_proximityTimerTask = new TimerTask() {
			@Override
			public void run() {
				proximityTimerTask();
			}
		};

		Timer timer = new Timer();
		timer.scheduleAtFixedRate(_proximityTimerTask, period, period);
	}

	private void wearingStateTimerTask() {
		Log.i(FN(), "wearingStateTimerTask()");

		InternalSubscription sub = _subscriptions.get(SERVICE_WEARING_STATE);
		if (sub!=null && sub.getMode()==SUBSCRIPTION_MODE_PERIODIC) {
			ArrayList<InfoListener> listeners = sub.getListeners();
			Info info = _cachedInfo.get(SERVICE_WEARING_STATE);
			if (listeners!=null && info!=null) {
				info.setRequestType(Info.REQUEST_TYPE_SUBSCRIPTION);
				info.setTimestamp(new Date());

				Iterator i = listeners.iterator();
				while (i.hasNext()) {
					((InfoListener)i.next()).onInfoReceived(info);
				}
			}
			else {
				Log.i(FN(), "Waiting for wearing info...");
			}
		}
	}

	private void proximityTimerTask() {
		Log.i(FN(), "proximityTimerTask()");

		InternalSubscription sub = _subscriptions.get(SERVICE_PROXIMITY);
		if (sub!=null && sub.getMode()==SUBSCRIPTION_MODE_PERIODIC) {
			ArrayList<InfoListener> listeners = sub.getListeners();
			Info info = _cachedInfo.get(SERVICE_PROXIMITY);
			if (listeners!=null && info!=null) {
				info.setRequestType(Info.REQUEST_TYPE_SUBSCRIPTION);
				info.setTimestamp(new Date());

				Iterator i = listeners.iterator();
				while (i.hasNext()) {
					((InfoListener)i.next()).onInfoReceived(info);
				}
			}
		}
	}

	private void queryWearingState() {
		// intended only as a "primer" to get cached info for periodic subscriptions.

		WearingStateRequest request = new WearingStateRequest();
		_bladeRunnerCommunicator.execute(request, _device, new MessageCallback() {
			@Override
			public void onSuccess(IncomingMessage incomingMessage) {
				WearingStateResponse response = (WearingStateResponse)incomingMessage;
				WearingStateInfo info = new WearingStateInfo(Info.REQUEST_TYPE_QUERY, new Date(), null, response.getWorn());
				_cachedInfo.put(SERVICE_WEARING_STATE, info);
			}

			@Override
			public void onFailure(BladerunnerException exception) {
				Log.e(FN(), "********* Wearing state exception: " + exception + " *********");
				// TODO: ?
			}
		});
	}

	private void queryOrientationTrackingForCal() {
		Log.i(FN(), "queryOrientationTrackingForCal()");

		QueryServicesDataRequest request = new QueryServicesDataRequest();
		request.setServiceID(SERVICE_ORIENTATION_TRACKING);
		request.setCharacteristic(0);

		_bladeRunnerCommunicator.execute(request, _sensorsDevice, new MessageCallback() {
			@Override
			public void onSuccess(IncomingMessage response) {
				QueryServicesDataResponse queryServicesDataResponse = (QueryServicesDataResponse)response;
				int[] data = queryServicesDataResponse.getServiceData();
				Quaternion q = getQuaternionFromData(data);
				_orientationTrackingCalibration = new OrientationTrackingCalibration(q);
			}

			@Override
			public void onFailure(BladerunnerException exception) {
				Log.e(FN(), "********* Query service exception: " + exception + " *********");
				// TODO: handle.
			}
		});
	}

	/* ****************************************************************************************************
			Helpers
	*******************************************************************************************************/

	private Quaternion getQuaternionFromData(int[] data) {
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

	private boolean getIsInFreeFallFromData(int[] data) {
		if (data.length > 1) { // event
			return (data[1]==1 ? true : false);
		}
		else { // setting
			return (data[0]==1 ? true : false);
		}
	}

	private int getTapCountFromData(int[] data) {
		if (data.length > 3) { // event
			return data[3];
		}
		else { // setting
			return data[1];
		}
	}

	private int getTapDirectionFromData(int[] data) {
		if (data.length > 1) { // event
			return data[1];
		}
		else { // setting
			return data[0];
		}
	}

	private int getPedometerCountFromData(int[] data) {
		if (data.length > 1) { // event
			return data[1];
		}
		else { // setting
			return data[0];
		}
	}

	private boolean getGyroIsCaldFromData(int[] data) {
		if (data.length > 1) { // event
			return (data[1] == 3 ? true : false);
		}
		else { // setting
			return (data[0] == 3 ? true : false);
		}
	}

	private boolean getMagIsCaldFromData(int[] data) {
		if (data.length > 1) { // event
			return (data[1] == 3 ? true : false);
		}
		else { // setting
			return (data[0] == 3 ? true : false);
		}
	}

	/* ****************************************************************************************************
			Static
	*******************************************************************************************************/

	public static void registerPairingListener(PairingListener listener) {
		if (_pairingListeners == null) {
			_pairingListeners = new ArrayList<PairingListener>();
		}

		if (!_pairingListeners.contains(listener)) {
			_pairingListeners.add(listener);
		}
	}

	public static void unregisterPairingListener(PairingListener listener) {
		if (!_pairingListeners.contains(listener)) {
			_pairingListeners.remove(listener);
		}
	}

	private static ArrayList<PairingListener> getPairingListeners() {
		return _pairingListeners;
	}

	private static BroadcastReceiver _receiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			BluetoothDevice btDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
			Log.i(FN(), "ACTION_BOND_STATE_CHANGED: " + btDevice);

			if (action.equals(BluetoothDevice.ACTION_BOND_STATE_CHANGED)) {
				int bondState = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, -1);

				if (bondState == BluetoothDevice.BOND_BONDED) {
					Log.i(FN(), "BONDED");

					if (isBladerunnerDevice(btDevice)) {
						Device device = new Device(btDevice);

						if (!_pairedDevices.contains(device)) {
							_pairedDevices.add(device);

							Log.i(FN(), "Adding. Devices: " + _pairedDevices);

							ArrayList<PairingListener> pairingListeners = Device.getPairingListeners();
							if (pairingListeners != null) {
								Iterator i = pairingListeners.iterator();
								while (i.hasNext()) {
									((PairingListener)i.next()).onDevicePaired(device);
								}
							}
						}
					}
					else {
						Log.i(FN(), "Not a Bladerunner device.");
					}
				}
				else if (bondState == BluetoothDevice.BOND_NONE) {
					Log.i(FN(), "NOT BONDED");

					Device device = new Device(btDevice);

					if (_pairedDevices.contains(device)) {
						_pairedDevices.remove(device);

						Log.i(FN(), "Removing. Devices: " + _pairedDevices);

						ArrayList<PairingListener> pairingListeners = Device.getPairingListeners();
						if (pairingListeners != null) {
							Iterator i = pairingListeners.iterator();
							while (i.hasNext()) {
								((PairingListener)i.next()).onDeviceUnpaired(device);
							}
						}
					}
				}
				else if (bondState == BluetoothDevice.BOND_BONDING) {
					Log.i(FN(), "BONDING");
				}
			}
		}
	};

	private static void registerBondStateReceiver() {
		Log.i(FN(), "registerBondStateReceiver()");

		try {
			_context.unregisterReceiver(_receiver);
		}
		catch (IllegalArgumentException e) {
			// do nothing.
			// this probably isnt the best way to do this, but it works...
		}
		IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED);
		_context.registerReceiver(_receiver, filter);
	}

	private static void updatePairedDevices(final PairedDeviceUpdateCallback callback) {
		Log.i(FN(), "updatePairedDevices()");

		BladeRunnerCommunicator bladeRunnerCommunicator = BladeRunnerCommunicator.getInstance(_context);
		bladeRunnerCommunicator.onResume();
		bladeRunnerCommunicator.getBladerunnerCapableDevices(new BladeRunnerCommunicator.CapableDevicesCallback() {
			@Override
			public void onCapableDevicesReceived(Set<BluetoothDevice> bladeRunnerCapableDevices) {
				ArrayList<Device> devices = new ArrayList<Device>();
				for (BluetoothDevice d : bladeRunnerCapableDevices) {
					Device device = new Device(d);
					devices.add(device);
				}

				_pairedDevices = devices;

				if (callback != null) {
					callback.onPairedDevicesUpdated();
				}
			}

			@Override
			public void failure() {
				if (callback != null) {
					callback.onFailure();
				}
			}
		});
	}

	private static boolean isBladerunnerDevice(BluetoothDevice device) {
		boolean br = false;
		ParcelUuid[] parcelUuidArray = device.getUuids();
		for (Parcelable parcelUuid : parcelUuidArray) {
			if (parcelUuid instanceof ParcelUuid) {
				//Log.i(FN(), "uuid: " + ((ParcelUuid) parcelUuid).getUuid());
				if (((ParcelUuid) parcelUuid).getUuid().equals(BLADERUNNER_UUID)) {
					br = true;
				}
			}
		}
		return br;
	}

	private static String FN() {
		StackTraceElement[] trace = Thread.currentThread().getStackTrace();
		if (trace.length >= 3) {
//			String methodName = trace[3].getMethodName();
//			return String.format("%s.%s", TAG, methodName);

			String fileName = trace[3].getFileName();
			int lineNumber = trace[3].getLineNumber();
			return String.format("%s:%d", fileName, lineNumber);
		}
		else {
			return "STACK TRACE TOO SHALLOW";
		}
	}

	/* ****************************************************************************************************
			Classes
	*******************************************************************************************************/

	public static abstract class InitializationCallback {

		public abstract void onInitialized();
		public abstract void onFailure();
	}

	private static abstract class PairedDeviceUpdateCallback {

		public abstract void onPairedDevicesUpdated();
		public abstract void onFailure();
	}

	private class InternalSubscription {

		private int 				_serviceID;
		private int 				_mode;
		private int					_period;
		ArrayList<InfoListener>		_listeners;

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