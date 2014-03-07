package com.plantronics.BRPlayground;

import android.app.Activity;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothCommunicatorHandler;
import com.plantronics.bladerunner.communicator.BladeRunnerCommunicator;
import com.plantronics.bladerunner.model.device.BladeRunnerDevice;
import com.plantronics.bladerunner.model.device.BladeRunnerDeviceManager;
import com.plantronics.bladerunner.model.device.CapabilityFilter;
import com.plantronics.bladerunner.protocol.*;
import com.plantronics.bladerunner.protocol.command.CommandEnum;
import com.plantronics.bladerunner.protocol.command.CommandSuccessResult;
import com.plantronics.bladerunner.protocol.command.SubscribeToServicesCommand;
import com.plantronics.bladerunner.protocol.control.BladeRunnerServiceInfoResponse;
import com.plantronics.bladerunner.protocol.control.ConnectToDeviceCommand;
import com.plantronics.bladerunner.protocol.event.ConnectedDeviceEvent;
import com.plantronics.bladerunner.protocol.event.SubscribedServiceDataEvent;
import com.plantronics.bladerunner.protocol.event.WearingStateChangedEvent;
import com.plantronics.bladerunner.protocol.setting.*;

import java.util.Set;

public class MainActivity extends Activity
{
	private static final String TAG = "com.plantronics.BRPlayground";

	private Communicator _communicator; // from appcore
	private BladeRunnerCommunicator _bladeRunnerCommunicator;
	private EventListener _eventListener;
	private BluetoothDevice _connectedBluetoothDevice;
	private Set<BluetoothDevice> _bladerunnerCapableDevices;
	private boolean _isBladerunnerDevicePresent;
	private static boolean _isBladeRunnerDeviceConnected;
	private BladeRunnerDevice _device;
	private BladeRunnerDevice _sensorsDevice;
	private BladeRunnerInitializer _bladeRunnerInitializer = new BladeRunnerInitializer();
	private Context _context;


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
			 Private (Activity)
	*******************************************************************************************************/

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		_context = this;

		_eventListener = new com.plantronics.bladerunner.protocol.EventListener() {
			@Override
			public void onEventReceived(Event event) {
				Log.i(FN(), "Event: " + event);
				if (event instanceof WearingStateChangedEvent) {
				}
			}
		};

		_bladeRunnerCommunicator = BladeRunnerCommunicator.getInstance(_context);
		_bladeRunnerCommunicator.registerEventListener(_eventListener);

		// what does this do..?
		_communicator = new Communicator(_context);
		_communicator.addHandler(_nativeBluetoothCommunicatorHandler);

		// CONNECT TO DEVICE BUTTON
		((Button)findViewById(R.id.connectToDeviceButton)).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				openConnectionButton();
			}
		});

		// GET WEARING STATE BUTTON
		((Button)findViewById(R.id.getWearingStateButton)).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				getWearingStateButton();
			}
		});

		// GET SIGNAL STRENGTH BUTTON
		((Button)findViewById(R.id.getSignalStrengthButton)).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				getSignalStrengthButton();
			}
		});

		// GET DEVICE INFO BUTTON
		((Button)findViewById(R.id.getDeviceInfoButton)).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				getDeviceInfoButton();
			}
		});

		// SUBSCRIBE TO SERVICES BUTTON
		((Button)findViewById(R.id.subscribeToServicesButton)).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				subscribeToServicesButton();
			}
		});

		// UNSUBSCRIBE FROM SERVICES BUTTON
		((Button)findViewById(R.id.unsubscribeFromServicesButton)).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				unsubscribeFromServicesButton();
			}
		});

		// QUERY SERVICES BUTTON
		((Button)findViewById(R.id.queryServicesButton)).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				queryServicesButton();
			}
		});
	}

	@Override
	protected void onStart() {
		super.onStart();
		Log.i(FN(), "onStart()");
	}

	@Override
	public void onResume() {
		super.onResume();
		Log.i(FN(), "onResume()");

		if (_communicator != null) _communicator.onResume();
		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.onResume();
		//_nativeBluetoothCommunicatorHandler.getConnectedDeviceRequest(); // TEMPORARILY DISABLED
		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.registerEventListener(_eventListener);
	}

	@Override
	protected void onPause() {
		super.onPause();
		Log.i(FN(), "onPause()");

		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.unregisterEventListener(_eventListener);
		if (_bladeRunnerCommunicator != null) _bladeRunnerCommunicator.onPause();
		if (_communicator != null) _communicator.onPause();
	}

	/* ****************************************************************************************************
			Private
	*******************************************************************************************************/

	class BladeRunnerInitializer extends AsyncTask<String, Void, Boolean> {
		@Override
		protected Boolean doInBackground(String... params) {
			{
				try {
					// Initialize bladerunner communicators
					Log.i(FN(), "Beginning BR initialization...");
					//mCommunicator.startReceiver();
					_nativeBluetoothCommunicatorHandler.getConnectedDeviceRequest();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}

			return Boolean.TRUE;
		}
	}

	private NativeBluetoothCommunicatorHandler _nativeBluetoothCommunicatorHandler = new NativeBluetoothCommunicatorHandler() {

		@Override
		public void onGetConnectedDeviceResponse(BluetoothDevice connectedDevice, int responseId) {
			Log.i(FN(), "onGetConnectedDeviceResponse()");
			// Received the connected device from the Bluetooth Manager Service (null if no such device)
			_connectedBluetoothDevice = connectedDevice;
			if (_connectedBluetoothDevice != null) {
				Log.i(FN(), "_connectedBluetoothDevice: " + _connectedBluetoothDevice.getAddress());
				setupDevices();
			} else {
				Log.i(FN(), "No connected bluetooth device available!!!");
			}
		}

		@Override
		public void onDeviceConnectedEvent(BluetoothDevice bluetoothDevice) {
			Log.i(FN(), "Device connected - " + bluetoothDevice.getAddress());

			// TEMPORARILY DISABLED

			//_connectedBluetoothDevice = bluetoothDevice;
			//setupDevices();
		}

		@Override
		public void onDeviceDisconnectedEvent(BluetoothDevice bluetoothDevice) {
			Log.i(FN(), "Device disconnected - " + bluetoothDevice.getAddress());

			// TEMPORARILY DISABLED

			//_connectedBluetoothDevice = null;
			//_isBladerunnerDevicePresent = false;
		}
	};

	private void setupDevices() {

		Log.i(FN(), "setupDevices()");

		_bladeRunnerCommunicator.getBladerunnerCapableDevices(new BladeRunnerCommunicator.CapableDevicesCallback() {
			@Override
			public void onCapableDevicesReceived(Set<BluetoothDevice> bladeRunnerCapableDevices) {

				_bladerunnerCapableDevices = bladeRunnerCapableDevices;
				if (!_bladerunnerCapableDevices.contains(_connectedBluetoothDevice)) {
					Log.i(FN(), "This device is not BR capable!");
					return;
				}
				_isBladerunnerDevicePresent = true;

				_device = BladeRunnerDeviceManager.getInstance().getBladeRunnerDevice(_connectedBluetoothDevice);
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
						_isBladeRunnerDeviceConnected = false;
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
									_isBladeRunnerDeviceConnected = true;

									Log.i(FN(), "************ CONNECTION OPEN! ************");
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
							_isBladeRunnerDeviceConnected = false;
						}
					}
				});
			}

			@Override
			public void failure() {
				//To change body of implemented methods use File | Settings | File Templates.
			}
		});
	}

	private void openConnectionButton() {
		Log.i(FN(), "openConnectionButton()");

		if (_bladeRunnerInitializer.getStatus() != AsyncTask.Status.RUNNING) {
			_bladeRunnerInitializer.execute();
		}
	}

	private void getWearingStateButton() {
		Log.i(FN(), "getWearingStateButton()");

		if (_device != null) {
			WearingStateRequest request = new WearingStateRequest();
			_bladeRunnerCommunicator.execute(request, _device, new MessageCallback() {
				@Override
				public void onSuccess(IncomingMessage incomingMessage) {
					WearingStateResponse response = (WearingStateResponse)incomingMessage;
					Log.i(FN(), "********* Wearing state success: " + (response.getWorn() ? "Donned" : "Doffed") + " *********");
				}

				@Override
				public void onFailure(BladerunnerException exception) {
					Log.e(FN(), "********* Wearing state exception: " + exception + " *********");
				}
			});
		}
	}

	private void getSignalStrengthButton() {
		Log.i(FN(), "getSignalStrengthButton()");

		if (_device != null) {
			CurrentSignalStrengthRequest request = new CurrentSignalStrengthRequest();
			request.setConnectionId(2); // ??
			_bladeRunnerCommunicator.execute(request, _device, new MessageCallback() {
				@Override
				public void onSuccess(IncomingMessage incomingMessage) {
					CurrentSignalStrengthResponse response = (CurrentSignalStrengthResponse)incomingMessage;
					Log.i(FN(), "********* Current signal strength success: Near/far: " + response.getNearFar() + ", Strength: " + response.getStrength() + " *********");
				}

				@Override
				public void onFailure(BladerunnerException exception) {
					Log.e(FN(), "********* Current signal strength exception: " + exception + " *********");
				}
			});
		}
	}

	private void getDeviceInfoButton() {
		Log.i(FN(), "getDeviceInfoButton()");

		if (_sensorsDevice != null) {
			GetDeviceInfoRequest request = new GetDeviceInfoRequest();
			_bladeRunnerCommunicator.execute(request, _sensorsDevice, new MessageCallback() {
				@Override
				public void onSuccess(IncomingMessage message) {
					GetDeviceInfoRequest reponse = (GetDeviceInfoRequest)message;
					Log.i(FN(), "********* Get device info success: " + message + " *********");
				}

				@Override
				public void onFailure(BladerunnerException exception) {
					Log.e(FN(), "********* Get device info exception: " + exception + " *********");
				}
			});
		}
	}

	private void subscribeToServicesButton() {
		Log.i(FN(), "subscribeToServicesButton()");

		if (_sensorsDevice != null) {
			SubscribeToServicesCommand command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_HeadOrientation.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOnCchange.getValue());
			//command.setMode(SubscribeToServicesCommand.Mode.ModePeriodic.getValue());
			command.setPeriod(1000);
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
							Log.i(FN(), "\"********* Streaming: " + event.toString() + "*********");
							SubscribedServiceDataEvent serviceData = (SubscribedServiceDataEvent)event;
							int[] data = serviceData.getServiceData();
							for (int i=0; i<data.length; i++) {
								Log.i(FN(), "data[" + i + "] = " + data[i]);
							}
						}
					});
		}
	}

	private void unsubscribeFromServicesButton() {
		Log.i(FN(), "unsubscribeFromServicesButton()");

		if (_sensorsDevice != null) {
			SubscribeToServicesCommand command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_HeadOrientation.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOff.getValue());
			command.setPeriod(1000);

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
	}

	private void queryServicesButton() {
		Log.i(FN(), "queryServicesButton()");

		if (_sensorsDevice != null) {
			QueryServicesDataRequest request = new QueryServicesDataRequest();
			request.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_HeadOrientation.getValue());
			request.setCharacteristic(0);
			_bladeRunnerCommunicator.execute(request, _sensorsDevice, new MessageCallback() {
				@Override
				public void onSuccess(IncomingMessage message) {
					QueryServicesDataResponse reponse = (QueryServicesDataResponse)message;
					Log.i(FN(), "********* Query service success: " + message + " *********");
					int[] data = reponse.getServiceData();
					for (int i=0; i<data.length; i++) {
						Log.i(FN(), "data[" + i + "] = " + data[i]);
					}
				}

				@Override
				public void onFailure(BladerunnerException exception) {
					Log.e(FN(), "********* Query service exception: " + exception + " *********");
				}
			});
		}
	}

//	private BladeRunnerDevice getCapableDevice(Object element) {
//		Set<BladeRunnerDevice> devices = null;
//		CapabilityFilter capabilityFilter = new CapabilityFilter();
//
//		if (element instanceof SettingEnum) {
//			capabilityFilter.addSetting((SettingEnum)element);
//			devices = BladeRunnerDeviceManager.getInstance().getCompatibleDevices(capabilityFilter);
//		}
//		else if (element instanceof CommandEnum) {
//			capabilityFilter.addCommand((CommandEnum)element);
//			devices = BladeRunnerDeviceManager.getInstance().getCompatibleDevices(capabilityFilter);
//		}
//
//		BladeRunnerDevice bladeRunnerDevice = null;
//		if ((devices == null) || !devices.iterator().hasNext()) {
//			Log.i(FN(), "No capable device found!");
//		}
//		else {
//			bladeRunnerDevice = devices.iterator().next();
//		}
//
//		return bladeRunnerDevice;
//	}
//
//	private BladeRunnerDevice getLocalDevice() {
//		if (_device == null) {
//			_device = getCapableDevice(SettingEnum.WEARING_STATE);
//		}
//		if (_device == null) {
//			Log.e(FN(), "Local device not found!");
//		}
//		return _device;
//	}
//
//	private BladeRunnerDevice getSensorsDevice() {
//		if (_sensorsDevice == null) {
//			_sensorsDevice = getCapableDevice(CommandEnum.SUBSCRIBE_TO_SERVICES);
//		}
//		if (_sensorsDevice == null) {
//			Log.e(FN(), "Sensors device not found!");
//		}
//		return _sensorsDevice;
//	}

//	typedef struct {
//	double x;
//	double y;
//	double z;
//} PLTEulerAngles;
//
//	typedef struct {
//	double w;
//	double x;
//	double y;
//	double z;
//} PLTQuaternion;
//
//
//	PLTEulerAngles EulerAnglesFromQuaternion(PLTQuaternion quaternion);
//	PLTQuaternion QuaternionFromEulerAngles(PLTEulerAngles eulerAngles);
//	NSString *NSStringFromEulerAngles(PLTEulerAngles angles);
//	NSString *NSStringFromQuaternion(PLTQuaternion quaternion);
}
