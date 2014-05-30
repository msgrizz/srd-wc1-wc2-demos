/* ********************************************************************************************************
	Device.java
	com.plantronics.device

	Created by mdavis on 01/15/2014.
	Copyright (c) 2014 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/


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
import com.plantronics.device.ConnectionListener;
import com.plantronics.device.InfoListener;
import com.plantronics.device.PairingListener;
import com.plantronics.device.Subscription;
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
import com.plantronics.bladerunner.communicator.BladeRunnerCommunicator.FastEventListener;

import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.UUID;
import java.util.*;


public class Device {

	public static final short SERVICE_WEARING_STATE = 			0x1000;
	public static final short SERVICE_PROXIMITY =			 	0x1001;
	public static final short SERVICE_ORIENTATION_TRACKING = 	0x0000;
	public static final short SERVICE_PEDOMETER = 				0x0002;
	public static final short SERVICE_FREE_FALL = 				0x0003;
	public static final short SERVICE_TAPS = 					0x0004;
	public static final short SERVICE_MAGNETOMETER_CAL_STATUS = 0x0005;
	public static final short SERVICE_GYROSCOPE_CAL_STATUS =	0x0006;

	public static final byte SUBSCRIPTION_MODE_ON_CHANGE = 		1;
	public static final byte SUBSCRIPTION_MODE_PERIODIC = 		2;

	public static final int	ERROR_PLTHUB_NOT_AVAILABLE =		1;
	public static final int	ERROR_CONNECTION_TIMEOUT =			2;
	public static final int	ERROR_FAILED_GET_DEVICE_LIST =		3;
	public static final int	ERROR_UNKNOWN =						100;

	//public static final int	CONNECTION_TIMEOUT =				1000;

	private static final String TAG = 							"com.plantronics.device";

	private static final UUID SERVICE_UUID = 					UUID.fromString("82972387-294E-4D62-97B5-2668AA35F618");

	private static Context					 					_context;
	private static ArrayList<Device> 							_pairedDevices;
	private static ArrayList<PairingListener> 					_pairingListeners;
	private ArrayList<ConnectionListener> 						_connectionListeners;
	private HashMap<Integer, InternalSubscription>				_subscriptions;
	private HashMap<Integer, Info>								_cachedInfo;
	private HashMap<Integer, ArrayList<InfoListener>>			_queryListeners;
	private static boolean										_isInitialized;
	private boolean												_openingConnection;
	private boolean 											_isConnectionOpen;
	//private TimerTask											_openConnectionTimeoutTimerTask;
	private BladeRunnerCommunicator								_bladeRunnerCommunicator;
	private EventListener										_eventListener;
	private BluetoothDevice										_btDevice;
	private BladeRunnerDevice 									_device;
	private BladeRunnerDevice 									_sensorsDevice;
	private FastEventListener[]									_fastEventListeners;
	private FastEventListener									_localProximityFastEventListener;
	private FastEventListener									_remoteProximityFastEventListener;
	private int 												_remotePort;
	private TimerTask											_wearingStateTimerTask;
	private TimerTask											_proximityTimerTask;
	private OrientationTrackingCalibration						_orientationTrackingCalibration;
	private int													_pedometerOffset;
	private String												_address;
	private String												_model;
	private String												_name;
	private String												_serialNumber;
//	private int													_fwMajorVersion;
//	private int													_fwMinorVersion;
	private String												_hardwareVersion;
	private String												_firmwareVersion;
	private ArrayList<Integer>									_supportedServices;
	private boolean												_waitingForRemoteSignalStrengthEvent;
	private boolean												_waitingForLocalSignalStrengthEvent;
	private SignalStrengthEvent									_localQuerySignalStrengthEvent;
	private SignalStrengthEvent									_remoteQuerySignalStrengthEvent;
	private boolean												_waitingForRemoteSignalStrengthSettingResponse;
	private boolean												_waitingForLocalSignalStrengthSettingResponse;
	private CurrentSignalStrengthResponse						_localQuerySignalStrengthResponse;
	private CurrentSignalStrengthResponse						_remoteQuerySignalStrengthResponse;
	private boolean 											_queryingOrientationTrackingForCalibration;


	/* ****************************************************************************************************
			Public
	*******************************************************************************************************/

	private Device() {
		// never use this.
		// see Device(BluetoothDevice btDevice) and getOrCreateDevice().
	}

	private Device(BluetoothDevice btDevice) {
		// NEVER use "new Device()" explicitly outside the SDK! Instead pick one from Device.getPairedDevices().
		// see getOrCreateDevice().

		_btDevice = btDevice;
		_address = _btDevice.getAddress();
		//_device = BladeRunnerDeviceManager.getInstance().getBladeRunnerDevice(_btDevice);

		_eventListener = new EventListener() {
			@Override
			public void onEventReceived(Event event) {
				Device.this.onEventReceived(event); // EventListener has onEventReceived(), too.
			}
		};

		_bladeRunnerCommunicator = BladeRunnerCommunicator.getInstance(_context);
		_bladeRunnerCommunicator.registerEventListener(_eventListener);
	}

	private static Device getOrCreateDevice(BluetoothDevice btDevice) {
		// we keep a list of paired devices that doesnt have duplicates.

		Iterator i = _pairedDevices.iterator();
		while (i.hasNext()) {
			Device d = (Device)i.next();
			if (d.getAddress().equals(btDevice.getAddress())) {
				return d;
			}
		}

		return new Device(btDevice);
	}

	public static void initialize(Context context, final InitializationCallback callback) {
		Log.v(FN(), "initialize()");

		if (!_isInitialized) {
			if (context == null) {
				//TODO: throw exception
			}
			else {
				_context = context.getApplicationContext();
			}

			_pairedDevices = new ArrayList<Device>();
			registerConnectionAndBondStateReceiver();

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
						callback.onFailure(ERROR_FAILED_GET_DEVICE_LIST);
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
		Log.v(FN(), "onResume()");

		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.onResume();
		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.registerEventListener(_eventListener);

		registerConnectionAndBondStateReceiver();
	}

	public void onPause() {
		Log.v(FN(), "onPause()");

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

	public ArrayList<ConnectionListener> getConnectionListeners() {
		return _connectionListeners;
	}

	public static boolean getIsInitialized() {
		return _isInitialized;
	}

	public static ArrayList<Device> getPairedDevices() {

		if (!_isInitialized) {
			Log.w(FN(), "getPairedDevices(): Not initialized!");
		}


//		// SYNC
//		BladeRunnerDeviceManager manager = BladeRunnerDeviceManager.getInstance();
//		Set<BladeRunnerDevice> brDevices = manager.getAllBladeRunnerDevices();
//		Log.i(FN(), "SYNC COUNT DEVICES: " + brDevices.size());


//	 	// ASYNC
//		BladeRunnerCommunicator bladeRunnerCommunicator = BladeRunnerCommunicator.getInstance(_context);
//		bladeRunnerCommunicator.onResume();
//		bladeRunnerCommunicator.getBladerunnerCapableDevices(new BladeRunnerCommunicator.CapableDevicesCallback() {
//			@Override
//			public void onCapableDevicesReceived(Set<BluetoothDevice> bladeRunnerCapableDevices) {
//				Log.i(FN(), "ASYNC COUNT DEVICES: " + bladeRunnerCapableDevices.size());
//			}
//
//			@Override
//			public void failure() {
//				Log.e(FN(), "Failed to get BR capable devices!");
//			}
//		});



		return _pairedDevices;
	}

	public boolean getIsConnectionOpen() {
		return _isConnectionOpen;
	}

	public void openConnection() {
		Log.d(FN(), "openConnection(): " + getAddress());

		if (_isConnectionOpen) {
			Log.w(FN(), "Device connection already open!");
		}
		else {
			// start the timeout timer
//		if (_openConnectionTimeoutTimerTask!=null) {
//			_openConnectionTimeoutTimerTask.cancel();
//		}
//		_openConnectionTimeoutTimerTask = new TimerTask() {
//			@Override
//			public void run() {
//				onOpenConnectionTimedOut();
//			}
//		};
//		Timer timer = new Timer();
//		timer.schedule(_openConnectionTimeoutTimerTask, CONNECTION_TIMEOUT);

			// get a "fresh" BluetoothDevice for our address
			_btDevice = getBluetoothDeviceForAddress(_address);
			if (_btDevice==null) {
				Log.e(FN(), "Device at address " + _address + " has disappeared!");
			}
			else {
				//TODO: try BladerunnerDevice.setBluetoothDevice()
				_device = BladeRunnerDeviceManager.getInstance().getBladeRunnerDevice(_btDevice);

				_openingConnection = true;
				_remotePort = -1;

				_bladeRunnerCommunicator.initialize(_device, new BladeRunnerCommunicator.InitializationCallback() {
					@Override
					public void onInitializationComplete(BladeRunnerDevice device) {
						Log.d(FN(), "Local device connected!");
					}

					@Override
					public void onDeviceDisconnected(BladeRunnerDevice device) {
						Log.i(FN(), "Local device disconnected!");

						_device = null;
						_sensorsDevice = null;

						onConnectionClosed();
					}

					@Override
					public void onRemoteDeviceDiscovered(BladeRunnerDevice remoteDevice) {
						int port = remoteDevice.getRouteToDevice().getPort(0);
						Log.d(FN(), "Remote device on port " + port + " connected.");

						if (port == 5) {
							_bladeRunnerCommunicator.initialize(remoteDevice, new BladeRunnerCommunicator.InitializationCallback() {
								@Override
								public void onInitializationComplete(BladeRunnerDevice device) {
									Log.d(FN(), "Sensors device initialized!");

									_sensorsDevice = device;

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
							Log.v(FN(), "Setting remote port to " + port + ".");
							_remotePort = port;

							// if somebody is already subscribed to proximity, we need to configure the HS to send remote port events as well now
							if (_subscriptions!=null) {
								InternalSubscription sub = _subscriptions.get(new Integer(SERVICE_PROXIMITY));
								if (sub!=null) {
									configureSignalStrengthEvents(true, _remotePort);
								}
							}
						}
					}

					@Override
					public void onRemoteDeviceDisconnected(BladeRunnerDevice remoteDevice) {
						byte port = (byte)remoteDevice.getRouteToDevice().getPort(0);
						Log.d(FN(), "Remote device on port " + port + " disconnected.");

						if (port == 5) {
							_device = null;
							_sensorsDevice = null;

							onConnectionClosed();
						}
						else if (port==2 || port==3) {
							Log.v(FN(), "Clearing remote port.");
							_remotePort = -1;
						}
					}
				});
			}
		}
	}

	public void closeConnection() {
		Log.d(FN(), "closeConnection()");
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

	private String getHarewareVersion() {
		return _hardwareVersion;
	}

	private String getFirmwareVersion() {
		return _firmwareVersion;
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
		Log.d(FN(), "setCalibration(): cal=" + cal + ", service=" + service);

		switch (service) {
			case SERVICE_ORIENTATION_TRACKING:
				OrientationTrackingCalibration theCal = null;

				if (cal==null) {
					OrientationTrackingInfo orientationInfo = (OrientationTrackingInfo)_cachedInfo.get(new Integer(service));
					if (orientationInfo!=null) {
						theCal = new OrientationTrackingCalibration(orientationInfo.getUncalibratedQuaternion());
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
					PedometerInfo pedInfo = (PedometerInfo)_cachedInfo.get(new Integer(service));
					if (pedInfo!=null) {
						int steps = pedInfo.getSteps();
						if (steps > 0) {
							_pedometerOffset += steps;
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

	public void subscribe(InfoListener listener, short service, byte mode, short period) {
		Log.d(FN(), "subscribe(): listener=" + listener + ", service=" + service + ", mode=" + mode + ", period=" + period);

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

//			if (_subscriptions==null) {
//				_subscriptions = new HashMap<Integer, InternalSubscription>();
//			}

			// get the subscription with the matching serviceID.
			// 1. if doesnt exist, create it. add listener. add subscription. notify subscribers. execute BR command.
			// 2. if exists and the mode is different, change to new mode. remove and re-add listener. update subscription. notify all listeners. execute BR command.
			// 3. if exists and mode is onchange for both, remove and re-add listener. update subscription. dont notify subscribers. dont execute BR command.
			// 4. if exists and mode is periodic for both and both periods ARE the same, remove and re-add listener. update subscription. dont notify subscribers. dont execute BR command.
					// UPDATE: how about do nothing?
			// 5. if exists and mode is periodic for both and both periods are NOT the same, remove and re-add listener. update subscription. notify all subscribers. execute BR command.

			ArrayList<InfoListener> listenersToNotify = new ArrayList<InfoListener>();
			InternalSubscription oldInternalSubscription;
			InternalSubscription newInternalSubscription = new InternalSubscription(service, mode, period, listener);

			InternalSubscription sub = _subscriptions.get(new Integer(service));
			boolean case1 = false;

			// 1.
			if (sub==null) {
				case1 = true;
				_subscriptions.put(new Integer(service), newInternalSubscription);
				listenersToNotify.add(listener);
				oldInternalSubscription = null;
			}
			else {
				oldInternalSubscription = sub;

				// 2.
				if (mode!=sub.getMode()) {
					listenersToNotify.addAll(sub.getListeners());
					sub.addListener(listener); // removes and re-adds
					_subscriptions.put(new Integer(service), newInternalSubscription);
				}
				// 3.
				else if (mode==SUBSCRIPTION_MODE_ON_CHANGE && sub.getMode()==SUBSCRIPTION_MODE_ON_CHANGE) {
					sub.addListener(listener); // removes and re-adds
					_subscriptions.put(new Integer(service), newInternalSubscription);
				}
				else if (mode==SUBSCRIPTION_MODE_PERIODIC && sub.getMode()==SUBSCRIPTION_MODE_PERIODIC) {
					// 4.
					if (period==sub.getPeriod()) {
//						sub.addListener(listener); // removes and re-adds
//						_subscriptions.put(service, newInternalSubscription);
					}
					// 5.
					else {
						sub.addListener(listener); // removes and re-adds
						_subscriptions.put(new Integer(service), newInternalSubscription);
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

				if (service!=SERVICE_WEARING_STATE && service!=SERVICE_PROXIMITY) {
					SubscribeToServicesCommand command = new SubscribeToServicesCommand();
					command.setServiceID(new Integer(service));
					command.setCharacteristic(0);
					if (mode==SUBSCRIPTION_MODE_ON_CHANGE) {
						command.setMode(SubscribeToServicesCommand.Mode.ModeOnCchange.getValue());
					}
					else {
						command.setMode(SubscribeToServicesCommand.Mode.ModePeriodic.getValue());
					}
					command.setPeriod(new Integer(period));

					FastEventListener fastEventListener = _fastEventListeners[service];
					if (fastEventListener != null) {
						fastEventListener.stopListening();
						_fastEventListeners[service] = null;
					}

					fastEventListener = new FastEventListener() {
						@Override
						public void onEventReceived(Event event) {
							Device.this.onEventReceived(event); // FastEventListener has onEventReceived(), too.
						}
					};
					_fastEventListeners[service] = fastEventListener;

					Log.d(FN(), "Subscribing " + service + "...");
					_bladeRunnerCommunicator.executeWithStreaming(command, _sensorsDevice, new MessageCallback() {
								@Override
								public void onSuccess(IncomingMessage message) {
									Log.v(FN(), "********* Subscribe success: " + message + " *********");
								}

								@Override
								public void onFailure(BladerunnerException exception) {
									Log.e(FN(), "********* Subscribe exception: " + exception + " *********");
								}
							}, fastEventListener);
				}
			}

			// now for wearing state and proximity. we'll reference the "case" from above.

			if (service==SERVICE_WEARING_STATE) {
				boolean periodic = newInternalSubscription.getMode()==SUBSCRIPTION_MODE_PERIODIC;

				if (periodic) {
					startWearingStateTimerTask(period);
				}
				else if (_wearingStateTimerTask!=null) {
					_wearingStateTimerTask.cancel();
				}

//				switch (casee) {
//					case 1:
//						if (periodic) {
//							startWearingStateTimerTask(period);
//						}
//						else if (_wearingStateTimerTask!=null) {
//							_wearingStateTimerTask.cancel();
//						}
//						break;
//					case 2:
//						if (periodic) {
//							startWearingStateTimerTask(period);
//						}
//						else if (_wearingStateTimerTask!=null) {
//							_wearingStateTimerTask.cancel();
//						}
//						break;
//					case 3:
//						if (_wearingStateTimerTask!=null) {
//							_wearingStateTimerTask.cancel();
//						}
//						break;
//					case 4:
//						// disabled
//						break;
//					case 5:
//						if (periodic) {
//							startWearingStateTimerTask(period);
//						}
//						else if (_wearingStateTimerTask!=null) {
//							_wearingStateTimerTask.cancel();
//						}
//						break;
//				}
			}
			else if (service==SERVICE_PROXIMITY) {
				boolean periodic = newInternalSubscription.getMode()==SUBSCRIPTION_MODE_PERIODIC;

				if (case1) {
					configureSignalStrengthEvents(true, 0);
					if (_remotePort > 0) {
						configureSignalStrengthEvents(true, _remotePort);
					}
				}

				if (periodic) {
					startProximityTimerTask(period);
				}
				else if (_proximityTimerTask!=null) {
					_proximityTimerTask.cancel();
				}

//				switch (casee) {
//					case 1:
//						// send BR command
//
//						if (periodic) {
//							startProximityTimerTask(period);
//						}
//						else if (_proximityTimerTask!=null) {
//							_proximityTimerTask.cancel();
//						}
//						break;
//					case 2:
//						if (periodic) {
//							startProximityTimerTask(period);
//						}
//						else if (_proximityTimerTask!=null) {
//							_proximityTimerTask.cancel();
//						}
//						break;
//					case 3:
//						if (_proximityTimerTask!=null) {
//							_proximityTimerTask.cancel();
//						}
//						break;
//					case 4:
//						// disabled
//						break;
//					case 5:
//						if (periodic) {
//							startProximityTimerTask(period);
//						}
//						else if (_proximityTimerTask!=null) {
//							_proximityTimerTask.cancel();
//						}
//						break;
//				}
			}
		}
		else {
			Log.e(FN(), "Listener is null!");
			// TODO: Raise exception.
		}
	}

	public void unsubscribe(InfoListener listener, int service) {
		Log.v(FN(), "unsubscribe(): " + listener + ", service: " + service);

		if (listener != null) {
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
				InternalSubscription sub = _subscriptions.get(new Integer(service));
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
							_subscriptions.remove(new Integer(service));
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

					configureSignalStrengthEvents(false, 0);
					if (_remotePort > 0) {
						configureSignalStrengthEvents(false, _remotePort);
					}
				}
				else {
					SubscribeToServicesCommand command = new SubscribeToServicesCommand();
					command.setServiceID(service);
					command.setCharacteristic(0);
					command.setMode(SubscribeToServicesCommand.Mode.ModeOff.getValue());
					command.setPeriod(0);

					FastEventListener fastEventListener = _fastEventListeners[service];
					if (fastEventListener != null) {
						fastEventListener.stopListening();
						_fastEventListeners[service] = null;
					}

					Log.d(FN(), "Unsubscribing...");
					_bladeRunnerCommunicator.execute(command, _sensorsDevice, new MessageCallback() {
						@Override
						public void onSuccess(IncomingMessage message) {
							Log.v(FN(), "********* Unsubscribe success: " + message + " *********");
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

	public void queryInfo(InfoListener listener, int service) {
		Log.d(FN(), "queryInfo(): listener=" + listener + ", service=" + service);

		boolean execRequest = false;

		ArrayList<InfoListener> listeners = _queryListeners.get(new Integer(service));
		if (listeners==null) {
			// nobody is waiting for this query right now. add the listener and do the query.
			Log.v(FN(), "Adding new listener " + listener + " for service " + service + ".");

			listeners = new ArrayList<InfoListener>();
			listeners.add(listener);
			_queryListeners.put(new Integer(service), listeners);
			execRequest = true;
		}
		else if (!listeners.contains(listener)) {
			// somebody is waiting for this query, but listener isn't. add it.
			Log.v(FN(), "Adding listener " + listener + " for service " + service + ".");

			if (!listeners.contains(listener)) {
				listeners.add(listener);
			}
			execRequest = true;
		}
		else {
			// listener is already waiting for the query result. do nothing.
			Log.i(FN(), "Listener " + listener + " is already waiting for service " + service + ".");
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
				// signal strength query wont work unless we're subscribed
				InternalSubscription subscription = _subscriptions.get(new Integer(service));
				if (subscription != null) {
					// since signal strength is already configured, we can query it right away

					_waitingForLocalSignalStrengthSettingResponse = true;
					_localQuerySignalStrengthResponse = null;

					querySignalStrength(0);
					if (_remotePort > 0) {
						_waitingForRemoteSignalStrengthSettingResponse = true;
						_remoteQuerySignalStrengthResponse = null;
						querySignalStrength(_remotePort);
					}
				}
				else {
					// since signal strength is not already configured, we have to enable it.
					// wait for the first of each events to come though and use them as the query responses.
					// then, if there are no actual "subscriptions" disable the events.

					_waitingForLocalSignalStrengthEvent = true;
					_localQuerySignalStrengthEvent = null;

					configureSignalStrengthEvents(true, 0);
					if (_remotePort > 0) {
						_waitingForRemoteSignalStrengthEvent = true;
						_remoteQuerySignalStrengthEvent = null;
						configureSignalStrengthEvents(true, _remotePort);
					}
				}
			}
			else {
				QueryServicesDataRequest request = new QueryServicesDataRequest();
				request.setServiceID(service);
				request.setCharacteristic(0);

				FastEventListener fastEventListener = _fastEventListeners[service];
				if (fastEventListener != null) {
					fastEventListener.stopListening();
					_fastEventListeners[service] = null;
				}

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

	public Info getCachedInfo(int service) {
		Info info = _cachedInfo.get(new Integer(service));
		if (info != null) {
			info.setRequestType(Info.REQUEST_TYPE_CACHED);
		}
		return info;
	}

	@Override
	public String toString() {
		return getClass().getName() + ": address=" + _address + ", model=" + _model + ", name=" + _name + ", serialNumber=" + _serialNumber + ", hardwareVersion=" + _hardwareVersion +
				", firmwareVersion=" + _firmwareVersion + ", supportedServices=" + _supportedServices + ", isConnectionOpen=" + (_isConnectionOpen ? "true" : "false" + ", ");
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

//	private void checkInitialized() {
//		if (!_isInitialized) {
//			//TODO: throw exception
//
//			throw new NotInitializedException();
//		}
//	}

	private void onConnectionOpen() {
		Log.v(FN(), "onConnectionOpen()");

//		if (_openConnectionTimeoutTimerTask!=null) {
//			_openConnectionTimeoutTimerTask.cancel();
//			_openConnectionTimeoutTimerTask = null;
//		}

		_openingConnection = false;

		// a "padded" array that can store one FastEventListener per service
		//TODO: needs maintenance as service IDs expand!
		_fastEventListeners = new FastEventListener[SERVICE_PROXIMITY+1];

		_waitingForRemoteSignalStrengthEvent = false;
		_waitingForLocalSignalStrengthEvent = false;
		_localQuerySignalStrengthEvent = null;
		_remoteQuerySignalStrengthEvent = null;
		_waitingForRemoteSignalStrengthSettingResponse = false;
		_waitingForLocalSignalStrengthSettingResponse = false;
		_localQuerySignalStrengthResponse = null;
		_remoteQuerySignalStrengthResponse = null;
		_queryingOrientationTrackingForCalibration = false;

		getProductName();
	}

//	private void onOpenConnectionTimedOut() {
//		Log.i(FN(), "onOpenConnectionTimedOut()");
//
//		if (_connectionListeners!=null) {
//			Iterator i =  _connectionListeners.iterator();
//			while (i.hasNext()) {
//				((ConnectionListener)i.next()).onConnectionFailedToOpen(this, ERROR_CONNECTION_TIMEOUT);
//			}
//		}
//	}

	private void onConnectionClosed() {
		Log.v(FN(), "onConnectionClosed()");

//		if (_openConnectionTimeoutTimerTask!=null) {
//			_openConnectionTimeoutTimerTask.cancel();
//			_openConnectionTimeoutTimerTask = null;
//		}

		_isConnectionOpen = false;
		_subscriptions = null;
		_queryListeners = null;
		_cachedInfo = null;

		if (_wearingStateTimerTask!=null) {
			_wearingStateTimerTask.cancel();
			_wearingStateTimerTask = null;
		}
		if (_proximityTimerTask!=null) {
			_proximityTimerTask.cancel();
			_proximityTimerTask = null;
		}

		_waitingForRemoteSignalStrengthEvent = false;
		_waitingForLocalSignalStrengthEvent = false;
		_localQuerySignalStrengthEvent = null;
		_remoteQuerySignalStrengthEvent = null;
		_waitingForRemoteSignalStrengthSettingResponse = false;
		_waitingForLocalSignalStrengthSettingResponse = false;
		_localQuerySignalStrengthResponse = null;
		_remoteQuerySignalStrengthResponse = null;
		_queryingOrientationTrackingForCalibration = false;

		if (_connectionListeners != null) {
			Iterator i =  _connectionListeners.iterator();
			while (i.hasNext()) {
				if (_openingConnection) {
					// if we get a disconnect while trying to open, its actually a timeout from the SDK
					((ConnectionListener)i.next()).onConnectionFailedToOpen(this, ERROR_CONNECTION_TIMEOUT);
				}
				else {
					((ConnectionListener)i.next()).onConnectionClosed(this);
				}
			}
		}
	}

	private void getProductName() {
		Log.v(FN(), "getProductName()");

		ProductNameRequest request = new ProductNameRequest();
		_bladeRunnerCommunicator.execute(request, _device, new MessageCallback() {
			@Override
			public void onSuccess(IncomingMessage message) {
				ProductNameResponse response = (ProductNameResponse)message;
				Log.i(FN(), "********* Get product name success: " + response + " *********");
				onProductNameReceived(response);
			}

			@Override
			public void onFailure(BladerunnerException exception) {
				Log.e(FN(), "********* Get product name exception: " + exception + " *********");
			}
		});
	}

	private void onProductNameReceived(ProductNameResponse response) {
		Log.v(FN(), "onGUIDReceived()");

		_model = response.getProductName();

		if (_model.equals("PLT_WC1")) {
			_name = "Wearable Concept 1";
		}

		getGenesGUID();
	}

	private void getGenesGUID() {
		Log.v(FN(), "getGenesGUID()");

		GenesGUIDRequest request = new GenesGUIDRequest();
		_bladeRunnerCommunicator.execute(request, _device, new MessageCallback() {
			@Override
			public void onSuccess(IncomingMessage message) {
				GenesGUIDResponse response = (GenesGUIDResponse)message;
				Log.i(FN(), "********* Get Genes GUID success: " + response + " *********");
				onGUIDReceived(response);
			}

			@Override
			public void onFailure(BladerunnerException exception) {
				Log.e(FN(), "********* Get Genes GUID exception: " + exception + " *********");
			}
		});
	}

	private void onGUIDReceived(GenesGUIDResponse response) {
		Log.v(FN(), "onGUIDReceived()");

		byte[] guid = response.getGuid();
		StringBuilder serialBuilder = new StringBuilder();
		for (int i=0; i<guid.length; i++) {
			byte g = guid[i];
			serialBuilder.append(String.format("%02X", g));
			if (i==3 || i==5 || i==7 || i==9) {
				serialBuilder.append("-");
			}
		}

		_serialNumber = serialBuilder.toString(); // example: ACA367C5-E8F1-A64F-954D-F6ED817C7A69 (rev1 no. 057)

		Log.i(FN(), "Serial Number: " + _serialNumber);

		getDeviceInfo();
	}

	private void getDeviceInfo() {
		Log.v(FN(), "getDeviceInfo()");

		GetDeviceInfoRequest request = new GetDeviceInfoRequest();
		_bladeRunnerCommunicator.execute(request, _sensorsDevice, new MessageCallback() {
			@Override
			public void onSuccess(IncomingMessage message) {
				GetDeviceInfoResponse response = (GetDeviceInfoResponse)message;
				Log.i(FN(), "********* Get device info success: " + response + " *********");
				onDeviceInfoReceived(response);
			}

			@Override
			public void onFailure(BladerunnerException exception) {
				Log.e(FN(), "********* Get device info exception: " + exception + " *********");
			}
		});
	}

	private void onDeviceInfoReceived(GetDeviceInfoResponse response) {
		Log.v(FN(), "onDeviceInfoReceived()");

		_hardwareVersion = "";
		for (int i=0; i<response.getMajorHardwareVersion().length; i++) {
			byte majV = response.getMajorHardwareVersion()[i];
			byte minV = response.getMinorHardwareVersion()[i];
			_hardwareVersion += (i==0 ? "" : ", ") + majV + "." + minV;
		}

		_firmwareVersion = "";
		for (int i=0; i<response.getMajorFirmwareVersion().length; i++) {
			byte majV = response.getMajorFirmwareVersion()[i];
			byte minV = response.getMinorFirmwareVersion()[i];
			_firmwareVersion += (i==0 ? "" : ", ") + majV + "." + minV;
		}

		_supportedServices = new ArrayList<Integer>();
		_supportedServices.add(new Integer(SERVICE_WEARING_STATE));
		_supportedServices.add(new Integer(SERVICE_PROXIMITY));
		short[] shorts = new short[response.getSupportedServices().length/2];
		ByteBuffer.wrap(response.getSupportedServices()).order(ByteOrder.BIG_ENDIAN).asShortBuffer().get(shorts);
		for (int i=0; i<shorts.length; i++) {
			_supportedServices.add(new Integer(shorts[i]));
		}

		Log.i(FN(), "Hardware Version: " + _hardwareVersion);
		Log.i(FN(), "Firmware Version: " + _firmwareVersion);
		Log.i(FN(), "Supported Services: " + _supportedServices);

		// connection is now "open" for clients

		_subscriptions = new HashMap<Integer, InternalSubscription>();
		_queryListeners = new HashMap<Integer, ArrayList<InfoListener>>();
		_cachedInfo = new HashMap<Integer, Info>();

		_isConnectionOpen = true;

		if (_connectionListeners != null) {
			Iterator i =  _connectionListeners.iterator();
			while (i.hasNext()) {
				((ConnectionListener)i.next()).onConnectionOpen(this);
			}
		}
	}

	private void onEventReceived(Event event) {
		Log.v(FN(), "onEventReceived(): " + event);

		byte requestType = Info.REQUEST_TYPE_SUBSCRIPTION;
		Date timestamp = new Date();
		Info info = null;
		ArrayList<InfoListener> listeners = null;
		short service = -1;
		InternalSubscription internalSubscription = null;

		if (event instanceof SubscribedServiceDataEvent) {
			SubscribedServiceDataEvent serviceEvent = (SubscribedServiceDataEvent)event;
			service = serviceEvent.getServiceID().shortValue();

			if (_subscriptions != null) {
				internalSubscription = _subscriptions.get(new Integer(service));
				if (internalSubscription != null) {
					listeners = internalSubscription.getListeners();
				}
			}

			byte[] data = serviceEvent.getServiceData();

			switch (service) {
				case SERVICE_ORIENTATION_TRACKING:
					Log.v(FN(), "SERVICE_ORIENTATION_TRACKING");
					Quaternion quaternion = getQuaternionFromData(data);
					//Log.i(FN(), "angles: " + new EulerAngles(q));
					if (_queryingOrientationTrackingForCalibration) {
						_orientationTrackingCalibration = new OrientationTrackingCalibration(quaternion);
						_queryingOrientationTrackingForCalibration = false;
					}
					info = new OrientationTrackingInfo(requestType, timestamp, _orientationTrackingCalibration, quaternion);
					break;
				case SERVICE_PEDOMETER:
					Log.v(FN(), "SERVICE_PEDOMETER");
					int steps = getPedometerCountFromData(data);
					int calSteps = steps - _pedometerOffset;
					if (calSteps < 0) calSteps = steps;
					info = new PedometerInfo(requestType, timestamp, null, calSteps);
					break;
				case SERVICE_FREE_FALL:
					Log.v(FN(), "SERVICE_FREE_FALL");
					info = new FreeFallInfo(requestType, timestamp, null, getIsInFreeFallFromData(data));
					break;
				case SERVICE_TAPS:
					Log.v(FN(), "SERVICE_TAPS");
					info = new TapsInfo(requestType, timestamp, null, getTapCountFromData(data), getTapDirectionFromData(data));
					break;
				case SERVICE_MAGNETOMETER_CAL_STATUS:
					Log.v(FN(), "SERVICE_MAGNETOMETER_CAL_STATUS");
					info = new MagnetometerCalInfo(requestType, timestamp, null, getMagIsCaldFromData(data));
					break;
				case SERVICE_GYROSCOPE_CAL_STATUS:
					Log.v(FN(), "SERVICE_GYROSCOPE_CAL_STATUS");
					info = new GyroscopeCalInfo(requestType, timestamp, null, getGyroIsCaldFromData(data));
					break;
				default:
					Log.v(FN(), "Invalid service in event: " + service);
					return;
			}
		}
		else if (event instanceof WearingStateChangedEvent) {
			Log.v(FN(), "SERVICE_WEARING_STATE");
			service = SERVICE_WEARING_STATE;
			WearingStateChangedEvent wearingStateEvent = (WearingStateChangedEvent)event;
			info = new WearingStateInfo(requestType, timestamp, null, wearingStateEvent.getWorn());
			if (_subscriptions != null) {
				internalSubscription = _subscriptions.get(new Integer(service));
				if (internalSubscription != null) {
					if (internalSubscription.getMode() == SUBSCRIPTION_MODE_ON_CHANGE) {
						listeners = internalSubscription.getListeners();
					}
					else {
						_cachedInfo.put(new Integer(service), info); // _cachedInfo is usually set at the bottom, but we just set into to null.
						info = null;
						// periodic is taken care of by the _wearingStateTimerTask
					}
				}
			}
		}
		else if (event instanceof SignalStrengthEvent) {
			Log.v(FN(), "SERVICE_PROXIMITY");
			service = SERVICE_PROXIMITY;
			SignalStrengthEvent signalStrengthEvent = (SignalStrengthEvent)event;
			ProximityInfo cachedInfo = (ProximityInfo)getCachedInfo(service);
			int connectionID = signalStrengthEvent.getConnectionId();

			if (signalStrengthEvent.getNearFar() != ProximityInfo.PROXIMITY_UNKNOWN) {
				// check if we're waiting on a signal strength query
				ProximityInfo queryInfo = null;
				if (connectionID == _remotePort) {
					//Log.i(FN(), "REMOTE");
					if (_waitingForRemoteSignalStrengthEvent) {
						//Log.i(FN(), "SET REMOTE INFO");
						_remoteQuerySignalStrengthEvent = signalStrengthEvent;

						if (_localQuerySignalStrengthEvent != null) {
							//Log.i(FN(), "WE GOT LOCAL. DONE.");
							// we're got both.
							queryInfo = new ProximityInfo(Info.REQUEST_TYPE_QUERY, timestamp, null, _localQuerySignalStrengthEvent.getNearFar().byteValue(), _remoteQuerySignalStrengthEvent.getNearFar().byteValue());
						}
					}
				}
				else {
					//Log.i(FN(), "LOCAL");
					if (_waitingForLocalSignalStrengthEvent) {
						//Log.i(FN(), "SET LOCAL INFO");
						_localQuerySignalStrengthEvent = signalStrengthEvent;

						if (_waitingForRemoteSignalStrengthEvent) {
							//Log.i(FN(), "WAITING ON REMOTE, TOO");
							if (_remoteQuerySignalStrengthEvent != null) {
								// we're got both.
								//Log.i(FN(), "WE GOT REMOTE. DONE.");
								queryInfo = new ProximityInfo(Info.REQUEST_TYPE_QUERY, timestamp, null, _localQuerySignalStrengthEvent.getNearFar().byteValue(), _remoteQuerySignalStrengthEvent.getNearFar().byteValue());
							}
						}
						else {
							//Log.i(FN(), "WAITING ON LOCAL ONLY. DONE.");
							// not waiting on remote. we've got just the one.
							byte queryRemoteProximity = ProximityInfo.PROXIMITY_UNKNOWN;
							if (cachedInfo != null) {
								queryRemoteProximity = cachedInfo.getRemoteProximity();
							}

							queryInfo = new ProximityInfo(Info.REQUEST_TYPE_QUERY, timestamp, null, _localQuerySignalStrengthEvent.getNearFar().byteValue(), queryRemoteProximity);
						}
					}
				}

				if (queryInfo != null) {
					//Log.i(FN(), "QUERYINFO: " + queryInfo);

					ArrayList<InfoListener> queryListeners = _queryListeners.get(new Integer(service));
					if (queryListeners != null) {
						Iterator i = queryListeners.iterator();
						while (i.hasNext()) {
							((InfoListener)i.next()).onInfoReceived(queryInfo);
						}
						_queryListeners.remove(new Integer(service));

						_cachedInfo.put(new Integer(service), queryInfo);
					}

					_waitingForRemoteSignalStrengthEvent = false;
					_waitingForLocalSignalStrengthEvent = false;
					_localQuerySignalStrengthEvent = null;
					_remoteQuerySignalStrengthEvent = null;

					if (_subscriptions != null) {
						internalSubscription = _subscriptions.get(new Integer(SERVICE_PROXIMITY));
						if (internalSubscription == null) {
							// looks like this was just a query (without otherwise being subscribed)
							// turn off signal strength events

							configureSignalStrengthEvents(false, 0);
							if (_remotePort > 0) {
								configureSignalStrengthEvents(false, _remotePort);
							}
						}
					}
				}
			}

			// process events are normal (not query)
			// this code could be slimmed down a bit (combined with above), but it's simpler to understand as-is

			int localProximity = ProximityInfo.PROXIMITY_UNKNOWN;
			int remoteProximity = ProximityInfo.PROXIMITY_UNKNOWN;
			if (cachedInfo != null) {
				localProximity = cachedInfo.getLocalProximity();
				remoteProximity = cachedInfo.getRemoteProximity();
			}
			int proximity = signalStrengthEvent.getNearFar(); // maps directly
			if (connectionID == _remotePort) {
				remoteProximity = proximity;
			}
			else {
				localProximity = proximity;
			}

			info = new ProximityInfo(requestType, timestamp, null, (byte)localProximity, (byte)remoteProximity);

			if (_subscriptions != null) {
				internalSubscription = _subscriptions.get(new Integer(service));
				if (internalSubscription != null) {
					if (internalSubscription.getMode() == SUBSCRIPTION_MODE_ON_CHANGE) {
						// dont broadcast if its the same!
						ProximityInfo theInfo = (ProximityInfo)info;
						if (cachedInfo != null && (theInfo.getLocalProximity() == cachedInfo.getLocalProximity() && theInfo.getRemoteProximity() == cachedInfo.getRemoteProximity())) {
							Log.v(FN(), "Proximity info is the same. Discarding.");
							info = null;
						}
						else {
							listeners = internalSubscription.getListeners();
						}
					}
					else {
						_cachedInfo.put(new Integer(service), info); // _cachedInfo is usually set at the bottom, but we just set into to null.
						info = null;
						// periodic is taken care of by the _proximityTimerTask
					}
				}
			}
		}

		if (info!=null && _cachedInfo!=null) {
			_cachedInfo.put(new Integer(service), info);
		}

		if (listeners!=null && info!=null) {
			Iterator i = listeners.iterator();
			while (i.hasNext()) {
				((InfoListener)i.next()).onInfoReceived(info);
			}
		}
	}

	private void onSettingsResponseReceived(SettingsResponse response) {
		Log.v(FN(), "onSettingsResponseReceived(): " + response);

		byte requestType = Info.REQUEST_TYPE_QUERY;
		Date timestamp = new Date();
		Info info = null;
		ArrayList<InfoListener> listeners = null;
		short service = -1;

		if (response instanceof QueryServicesDataResponse) {
			QueryServicesDataResponse queryServicesDataResponse = (QueryServicesDataResponse)response;
			service = queryServicesDataResponse.getServiceID().shortValue();

			listeners = _queryListeners.get(new Integer(service));
			if (listeners != null) {
				byte[] data = queryServicesDataResponse.getServiceData();

				switch (service) {
					case SERVICE_ORIENTATION_TRACKING:
						Log.v(FN(), "SERVICE_ORIENTATION_TRACKING");
						Quaternion quaternion = getQuaternionFromData(data);
						//Log.i(FN(), "angles: " + new EulerAngles(q));
						if (_queryingOrientationTrackingForCalibration) {
							_orientationTrackingCalibration = new OrientationTrackingCalibration(quaternion);
							_queryingOrientationTrackingForCalibration = false;
						}
						else {
							info = new OrientationTrackingInfo(requestType, timestamp, _orientationTrackingCalibration, quaternion);
						}
						break;
					case SERVICE_PEDOMETER:
						Log.v(FN(), "SERVICE_PEDOMETER");
						int steps = getPedometerCountFromData(data);
						int calSteps = steps - _pedometerOffset;
						if (calSteps < 0) calSteps = steps;
						info = new PedometerInfo(requestType, timestamp, null, calSteps);
						break;
					case SERVICE_FREE_FALL:
						Log.v(FN(), "SERVICE_FREE_FALL");
						info = new FreeFallInfo(requestType, timestamp, null, getIsInFreeFallFromData(data));
						break;
					case SERVICE_TAPS:
						Log.v(FN(), "SERVICE_TAPS");
						info = new TapsInfo(requestType, timestamp, null, getTapCountFromData(data), getTapDirectionFromData(data));
						break;
					case SERVICE_MAGNETOMETER_CAL_STATUS:
						Log.v(FN(), "SERVICE_MAGNETOMETER_CAL_STATUS");
						info = new MagnetometerCalInfo(requestType, timestamp, null, getMagIsCaldFromData(data));
						break;
					case SERVICE_GYROSCOPE_CAL_STATUS:
						Log.v(FN(), "SERVICE_GYROSCOPE_CAL_STATUS");
						info = new GyroscopeCalInfo(requestType, timestamp, null, getGyroIsCaldFromData(data));
						break;
					default:
						Log.e(FN(), "Invalid service in event: " + service);
						return;
				}
			}
			else {
				// nodoby is waiting for this query...
				Log.d(FN(), "Odd. No query listeners for service " + service);
			}
		}
		else if (response instanceof WearingStateResponse) {
			Log.v(FN(), "SERVICE_WEARING_STATE");
			service = SERVICE_WEARING_STATE;
			listeners = _queryListeners.get(new Integer(service));
			if (listeners!=null) {
				WearingStateResponse wearingStateResponse = (WearingStateResponse)response;
				info = new WearingStateInfo(requestType, timestamp, null, wearingStateResponse.getWorn());
			}
		}
		else if (response instanceof CurrentSignalStrengthResponse) {
			Log.v(FN(), "SERVICE_PROXIMITY");
			service = SERVICE_PROXIMITY;
			listeners = _queryListeners.get(new Integer(service));
			//if (listeners != null) {
			CurrentSignalStrengthResponse signalStrengthResponse = (CurrentSignalStrengthResponse)response;

			ProximityInfo cachedInfo = (ProximityInfo)getCachedInfo(service);
			int connectionID = signalStrengthResponse.getConnectionId();

			// check if we're waiting on a signal strength query
			if (connectionID == _remotePort) {
				//Log.i(FN(), "REMOTE");
				if (_waitingForRemoteSignalStrengthSettingResponse) {
					//Log.i(FN(), "SET REMOTE INFO");
					_remoteQuerySignalStrengthResponse = signalStrengthResponse;

					if (_localQuerySignalStrengthResponse != null) {
						//Log.i(FN(), "WE GOT LOCAL. DONE.");
						// we're got both.
						info = new ProximityInfo(Info.REQUEST_TYPE_QUERY, timestamp, null,
								_localQuerySignalStrengthResponse.getNearFar().byteValue(), _remoteQuerySignalStrengthResponse.getNearFar().byteValue());
					}
				}
			}
			else {
				//Log.i(FN(), "LOCAL");
				if (_waitingForLocalSignalStrengthSettingResponse) {
					//Log.i(FN(), "SET LOCAL INFO");
					_localQuerySignalStrengthResponse = signalStrengthResponse;

					if (_waitingForRemoteSignalStrengthSettingResponse) {
						//Log.i(FN(), "WAITING ON REMOTE, TOO");
						if (_remoteQuerySignalStrengthResponse != null) {
							//Log.i(FN(), "WE GOT REMOTE. DONE.");
							// we're got both.
							info = new ProximityInfo(Info.REQUEST_TYPE_QUERY, timestamp, null,
									_localQuerySignalStrengthResponse.getNearFar().byteValue(), _remoteQuerySignalStrengthResponse.getNearFar().byteValue());
						}
					}
					else {
						//Log.i(FN(), "WAITING ON LOCAL ONLY. DONE.");
						// not waiting on remote. we've got just the one.
						byte queryRemoteProximity = ProximityInfo.PROXIMITY_UNKNOWN;
						if (cachedInfo != null) {
							queryRemoteProximity = cachedInfo.getRemoteProximity();
						}

						info = new ProximityInfo(Info.REQUEST_TYPE_QUERY, timestamp, null,
								_localQuerySignalStrengthResponse.getNearFar().byteValue(), queryRemoteProximity);
					}
				}
			}

			if (info != null) {
				//Log.d(FN(),"INFO: " + info);
				_waitingForRemoteSignalStrengthSettingResponse = false;
				_waitingForLocalSignalStrengthSettingResponse = false;
				_localQuerySignalStrengthResponse = null;
				_remoteQuerySignalStrengthResponse = null;
			}
		}

		if (info!=null && _cachedInfo!=null) {
			_cachedInfo.put(new Integer(service), info);
		}

		if (listeners!=null && info!=null) {
			Iterator i = listeners.iterator();
			while (i.hasNext()) {
				((InfoListener)i.next()).onInfoReceived(info);
			}
		}

		if (_queryListeners!=null) {
			_queryListeners.remove(new Integer(service));
		}
	}

	public BluetoothDevice getBluetoothDeviceForAddress(String address) {
		Log.v(FN(), "getBluetoothDeviceForAddress(): " + address);

		BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
		Set<BluetoothDevice> bondedDevices = adapter.getBondedDevices();
		Iterator i = bondedDevices.iterator();
		while (i.hasNext()) {
			BluetoothDevice d = (BluetoothDevice)i.next();
			//Log.v(FN(), "Bonded device: " + d.getAddress());
			if (d.getAddress().equals(address)) {
				return d;
			}
		}
		return null;
	}

	private void startWearingStateTimerTask(long period) {
		Log.v(FN(), "startWearingStateTimerTask(): " + period);

		if (_cachedInfo.get(new Integer(SERVICE_WEARING_STATE)) == null) {
			queryWearingState(); // prime the cached info
		}
		if (_wearingStateTimerTask != null) {
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
		Log.v(FN(), "startProximityTimerTask(): " + period);

		if (_proximityTimerTask != null) {
			_proximityTimerTask.cancel();
		}
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
		Log.v(FN(), "wearingStateTimerTask()");

		InternalSubscription sub = _subscriptions.get(new Integer(SERVICE_WEARING_STATE));
		if (sub!=null && sub.getMode() == SUBSCRIPTION_MODE_PERIODIC) {
			ArrayList<InfoListener> listeners = sub.getListeners();
			Info info = _cachedInfo.get(new Integer(SERVICE_WEARING_STATE));
			if (listeners!=null && info!=null) {
				info.setRequestType(Info.REQUEST_TYPE_SUBSCRIPTION);
				info.setTimestamp(new Date());

				Iterator i = listeners.iterator();
				while (i.hasNext()) {
					((InfoListener)i.next()).onInfoReceived(info);
				}
			}
			else {
				Log.d(FN(), "Waiting for wearing info...");
			}
		}
	}

	private void proximityTimerTask() {
		Log.v(FN(), "proximityTimerTask()");

		InternalSubscription sub = _subscriptions.get(new Integer(SERVICE_PROXIMITY));
		if (sub!=null && sub.getMode()==SUBSCRIPTION_MODE_PERIODIC) {
			ArrayList<InfoListener> listeners = sub.getListeners();
			Info info = _cachedInfo.get(new Integer(SERVICE_PROXIMITY));
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
				WearingStateResponse response = (WearingStateResponse) incomingMessage;
				WearingStateInfo info = new WearingStateInfo(Info.REQUEST_TYPE_QUERY, new Date(), null, response.getWorn());
				_cachedInfo.put(new Integer(SERVICE_WEARING_STATE), info);
			}

			@Override
			public void onFailure(BladerunnerException exception) {
				Log.e(FN(), "********* Wearing state exception: " + exception + " *********");
				// TODO: ?
			}
		});
	}

	private void configureSignalStrengthEvents(boolean enabled, int connectionID) {
		Log.v(FN(), "configureSignalStrengthEvents(): " + enabled + ", connectionID: " + connectionID);

		ConfigureSignalStrengthEventsCommand command = new ConfigureSignalStrengthEventsCommand();
		command.setEnable(enabled);
		command.setConnectionId(connectionID);
		command.setDononly(false);
		command.setReportNearFarAudio(false);
		command.setReportNearFarToBase(false);
		command.setReportRssiAudio(false);
		command.setTrend(false);
		command.setSensitivity(0);
		command.setNearThreshold(71);
		// this is about 45 days of signal strength monitoring.
		// if this SDK is ever adapted to be used for enterprise solutions, this limitation will need to be addressed.
		command.setMaxTimeout(new Integer(Short.MIN_VALUE)); // java is signed. min value = 0xFF FF FF FF

//		FastEventListener fastEventListener = _fastEventListeners[SERVICE_PROXIMITY];
//		if (fastEventListener != null) {
//			fastEventListener.stopListening();
//			_fastEventListeners[SERVICE_PROXIMITY] = null;
//		}

		FastEventListener fastEventListener;
		if (connectionID == _remotePort) {
			fastEventListener = _remoteProximityFastEventListener;
		}
		else {
			fastEventListener = _localProximityFastEventListener;
		}

		if (fastEventListener != null) {
			fastEventListener.stopListening();

			if (connectionID == _remotePort) {
				_remoteProximityFastEventListener = null;
			}
			else {
				_localProximityFastEventListener = null;
			}
		}

		if (enabled) {
			fastEventListener = new FastEventListener() {
				@Override
				public void onEventReceived(Event event) {
					Device.this.onEventReceived(event); // FastEventListener has onEventReceived(), too.
				}
			};

			if (connectionID == _remotePort) {
				_remoteProximityFastEventListener = fastEventListener;
			}
			else {
				_localProximityFastEventListener = fastEventListener;
			}
		}
		else {
			fastEventListener = new FastEventListener() {
				@Override
				public void onEventReceived(Event event) {
					// nothing
				}
			};
		}

		_bladeRunnerCommunicator.executeWithStreaming(command, _device, new MessageCallback() {
			@Override
			public void onSuccess(IncomingMessage message) {
				Log.v(FN(), "********* Configure signal strength events success: " + message + " *********");

//				if (_remotePort > 0) {
//					// need both local and remote enabled before querying
//				}
//				else {
//
//				}
//
//				if (_subscriptions != null) {
//					InternalSubscription internalSubscription = _subscriptions.get(SERVICE_PROXIMITY);
//					if (internalSubscription == null) {
//						// must be waiting for a query.
//
//						querySignalStrength(0);
//						if (_remotePort > 0) {
//							querySignalStrength(_remotePort);
//						}
//
//						// wait to check/disable signal strength events until the query comes back
//					}
//				}
			}

			@Override
			public void onFailure(BladerunnerException exception) {
				Log.e(FN(), "********* Configure signal strength events exception: " + exception + " *********");
				// TODO: handle.
			}
		}, fastEventListener);
	}

	private void querySignalStrength(int connectionID) {
		Log.v(FN(), "querySignalStrength(): " + connectionID);

		CurrentSignalStrengthRequest request = new CurrentSignalStrengthRequest();
		request.setConnectionId(connectionID);
		_bladeRunnerCommunicator.execute(request, _device, new MessageCallback() {
			@Override
			public void onSuccess(IncomingMessage incomingMessage) {
				final CurrentSignalStrengthResponse response = (CurrentSignalStrengthResponse)incomingMessage;
				Log.v(FN(), "********* Signal strength event: Port: " + response.getConnectionId() + ", Near/far: " + response.getNearFar() + ", Strength: " + response.getStrength() + " *********");
				onSettingsResponseReceived(response);
			}

			@Override
			public void onFailure(BladerunnerException exception) {
				Log.e(FN(), "********* Current signal strength exception: " + exception + " *********");
				// TODO: handle.
			}
		});
	}

	private void queryOrientationTrackingForCal() {
		Log.v(FN(), "queryOrientationTrackingForCal()");

		_queryingOrientationTrackingForCalibration = true;

		QueryServicesDataRequest request = new QueryServicesDataRequest();
		request.setServiceID(new Integer(SERVICE_ORIENTATION_TRACKING));
		request.setCharacteristic(0);

		_bladeRunnerCommunicator.execute(request, _sensorsDevice, new MessageCallback() {
			@Override
			public void onSuccess(IncomingMessage response) {
				onSettingsResponseReceived((SettingsResponse)response);

//				QueryServicesDataResponse queryServicesDataResponse = (QueryServicesDataResponse) response;
//				byte[] data = queryServicesDataResponse.getServiceData();
//				Quaternion q = getQuaternionFromData(data);
//				_orientationTrackingCalibration = new OrientationTrackingCalibration(q);
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

	// 4-byte quaternion components
	private Quaternion getQuaternionFromData(byte[] data) {
		int[] ints = new int[data.length/4];
		ByteBuffer.wrap(data).order(ByteOrder.BIG_ENDIAN).asIntBuffer().get(ints);

		int w = ints[0];
		int x = ints[1];
		int y = ints[2];
		int z = ints[3];

		if (w > 32767) w -= 65536;
		if (x > 32767) x -= 65536;
		if (y > 32767) y -= 65536;
		if (z > 32767) z -= 65536;

		double fw = ((double)w) / 16384.0f;
		double fx = ((double)x) / 16384.0f;
		double fy = ((double)y) / 16384.0f;
		double fz = ((double)z) / 16384.0f;

		Quaternion q = new Quaternion(fw, fx, fy, fz);
		if (q.getW()>1.0001f || q.getX()>1.0001f || q.getY()>1.0001f || q.getZ()>1.0001f) {
			Log.d(FN(), "Bad quaternion! " + q);
		}
		else {
			return q;
		}

		return new Quaternion(1, 0, 0, 0);
	}

	// 2-byte quaternion components
//	private Quaternion getQuaternionFromData(byte[] data) {
//		int w = (data[0] << 8) + data[1];
//		int x = (data[2] << 8) + data[3];
//		int y = (data[4] << 8) + data[5];
//		int z = (data[6] << 8) + data[7];
//
//		if (w > 32767) w -= 65536;
//		if (x > 32767) x -= 65536;
//		if (y > 32767) y -= 65536;
//		if (z > 32767) z -= 65536;
//
//		double fw = ((double)w) / 16384.0f;
//		double fx = ((double)x) / 16384.0f;
//		double fy = ((double)y) / 16384.0f;
//		double fz = ((double)z) / 16384.0f;
//
//		Quaternion q = new Quaternion(fw, fx, fy, fz);
//		if (q.getW()>1.0001f || q.getX()>1.0001f || q.getY()>1.0001f || q.getZ()>1.0001f) {
//			Log.d(FN(), "Bad quaternion! " + q);
//		}
//		else {
//			return q;
//		}
//
//		return null;
//	}

	private boolean getIsInFreeFallFromData(byte[] data) {
		return (data[0]==1 ? true : false);
	}

	private byte getTapCountFromData(byte[] data) {
		return data[1];
	}

	private byte getTapDirectionFromData(byte[] data) {
		return data[0];
	}

	private int getPedometerCountFromData(byte[] data) {
		return (((int)data[0]) << 24) + (((int)data[1]) << 16) + (((int)data[2]) << 8) + data[3];
	}

	private boolean getGyroIsCaldFromData(byte[] data) {
		return (data[0] == 3 ? true : false);
	}

	private boolean getMagIsCaldFromData(byte[] data) {
		return (data[0] == 3 ? true : false);
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

			if (action.equals(BluetoothDevice.ACTION_BOND_STATE_CHANGED)) {
				int bondState = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, -1);

				if (bondState == BluetoothDevice.BOND_BONDED) {
					Log.d(FN(), btDevice + " BONDED");
					checkAddDevice(btDevice);
				}
				else if (bondState == BluetoothDevice.BOND_NONE) {
					Log.d(FN(), btDevice + " NOT BONDED");

					//Device device = new Device(btDevice);
					Device device = Device.getOrCreateDevice(btDevice);

					if (_pairedDevices.contains(device)) {
						_pairedDevices.remove(device);

						Log.i(FN(), "Devices: " + _pairedDevices);

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
					Log.d(FN(), btDevice + " BONDING");
				}
			}
			else if (action.equals(BluetoothDevice.ACTION_ACL_CONNECTED)) {
				Log.d(FN(), btDevice + " CONNECTED");
				checkAddDevice(btDevice);
			}
			else if (action.equals(BluetoothDevice.ACTION_ACL_DISCONNECTED)) {
				Log.d(FN(), btDevice + " DISCONNECTED");

				if (isBladerunnerDevice(btDevice)) {
					//Device device = new Device(btDevice);
					Device device = Device.getOrCreateDevice(btDevice);

					if (device._isConnectionOpen) {
						device.onConnectionClosed();

//						ArrayList<ConnectionListener> connectionListeners = device.getConnectionListeners();
//						if (connectionListeners != null) {
//							Iterator i = connectionListeners.iterator();
//							while (i.hasNext()) {
//								((ConnectionListener)i.next()).onConnectionClosed(device);
//							}
//						}
					}
				}
				else {
					Log.d(FN(), "Not a Bladerunner device. Ignoring.");
				}
			}
		}
	};

	private static void checkAddDevice(BluetoothDevice btDevice) {
		Log.v(FN(), "checkAddDevice(): " + btDevice);

		if (isBladerunnerDevice(btDevice)) {
			//Device device = new Device(btDevice);
			Device device = Device.getOrCreateDevice(btDevice);

			if (!_pairedDevices.contains(device)) {
				_pairedDevices.add(device);

				Log.i(FN(), "Devices: " + _pairedDevices);

				ArrayList<PairingListener> pairingListeners = Device.getPairingListeners();
				if (pairingListeners != null) {
					Iterator i = pairingListeners.iterator();
					while (i.hasNext()) {
						((PairingListener)i.next()).onDevicePaired(device);
					}
				}
			}
			else {
				Log.v(FN(), "Already added.");
			}
		}
		else {
			Log.d(FN(), "Not a Bladerunner device.");
		}
	}

	private static void registerConnectionAndBondStateReceiver() {
		Log.v(FN(), "registerConnectionAndBondStateReceiver()");

		try {
			_context.unregisterReceiver(_receiver);
		}
		catch (IllegalArgumentException e) {
			// do nothing.
			// this probably isnt the best way to do this, but it works...
		}
		IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED);
		_context.registerReceiver(_receiver, filter);
		filter = new IntentFilter(BluetoothDevice.ACTION_ACL_CONNECTED);
		_context.registerReceiver(_receiver, filter);
		filter = new IntentFilter(BluetoothDevice.ACTION_ACL_DISCONNECTED);
		_context.registerReceiver(_receiver, filter);
	}

	private static void updatePairedDevices(final PairedDeviceUpdateCallback callback) {
		Log.v(FN(), "updatePairedDevices()");


//		BladeRunnerDeviceManager manager = BladeRunnerDeviceManager.getInstance();
//		Set<BladeRunnerDevice> brDevices = manager.getAllBladeRunnerDevices();
//
//		ArrayList<Device> devices = new ArrayList<Device>();
//		for (BladeRunnerDevice d : brDevices) {
//			BluetoothDevice btDevice = d.getBluetoothDevice();
//			Log.v(FN(), "Found BR device with address: " + btDevice.getAddress());
//			Device device = Device.getOrCreateDevice(btDevice);
//			devices.add(device);
//		}
//
//		_pairedDevices = devices;
//
//		if (callback != null) {
//			callback.onPairedDevicesUpdated();
//		}


		BladeRunnerCommunicator bladeRunnerCommunicator = BladeRunnerCommunicator.getInstance(_context);
		bladeRunnerCommunicator.onResume();
		bladeRunnerCommunicator.getBladerunnerCapableDevices(new BladeRunnerCommunicator.CapableDevicesCallback() {
			@Override
			public void onCapableDevicesReceived(Set<BluetoothDevice> bladeRunnerCapableDevices) {
				ArrayList<Device> devices = new ArrayList<Device>();
				for (BluetoothDevice d : bladeRunnerCapableDevices) {
					//Device device = new Device(d);
					Device device = Device.getOrCreateDevice(d);
					devices.add(device);
				}

				_pairedDevices = devices;

				if (callback != null) {
					callback.onPairedDevicesUpdated();
				}
			}

			@Override
			public void failure() {
		Log.e(FN(), "Failed to get BR capable devices!");
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
				if (((ParcelUuid) parcelUuid).getUuid().equals(SERVICE_UUID)) {
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
			Public Classes
	*******************************************************************************************************/

	public static abstract class InitializationCallback {

		public abstract void onInitialized();
		public abstract void onFailure(int error);
	}

	private static abstract class PairedDeviceUpdateCallback {

		public abstract void onPairedDevicesUpdated();
		public abstract void onFailure();
	}

//	static class NotInitializedException extends Exception {
//
//		public NotInitializedException() {}
//
//		public NotInitializedException(String message) {
//			super(message);
//		}
//	}

	/* ****************************************************************************************************
			Private Classes
	*******************************************************************************************************/

	private class InternalSubscription {

		private short 				_serviceID;
		private byte 				_mode;
		private short				_period;
		ArrayList<InfoListener>		_listeners;

		public InternalSubscription(short serviceID, byte mode, short period, InfoListener listener) {
			_serviceID = serviceID;
			_mode = mode;
			_period = period;
			_listeners = new ArrayList<InfoListener>();
			_listeners.add(listener);
		}

		public InternalSubscription(short serviceID, byte mode, short period, ArrayList<InfoListener> listeners) {
			_serviceID = serviceID;
			_mode = mode;
			_period = period;
			_listeners = listeners;
		}

		public short getServiceID() {
			return _serviceID;
		}

		public byte getMode() {
			return _mode;
		}

		public short getPeriod() {
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
