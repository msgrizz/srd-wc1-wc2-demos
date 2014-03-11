package com.plantronics.BRPlayground;

import android.app.Activity;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import com.plantronics.appcore.service.bluetooth.communicator.Communicator;
import com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.NativeBluetoothCommunicatorHandler;
import com.plantronics.bladerunner.communicator.BladeRunnerCommunicator;
import com.plantronics.bladerunner.model.device.BladeRunnerDevice;
import com.plantronics.bladerunner.model.device.BladeRunnerDeviceManager;
import com.plantronics.bladerunner.model.device.CapabilityFilter;
import com.plantronics.bladerunner.protocol.*;
import com.plantronics.bladerunner.protocol.command.CommandEnum;
import com.plantronics.bladerunner.protocol.command.CommandSuccessResult;
import com.plantronics.bladerunner.protocol.command.ConfigureSignalStrengthEventsCommand;
import com.plantronics.bladerunner.protocol.command.SubscribeToServicesCommand;
import com.plantronics.bladerunner.protocol.control.BladeRunnerServiceInfoResponse;
import com.plantronics.bladerunner.protocol.control.ConnectToDeviceCommand;
import com.plantronics.bladerunner.protocol.event.ConnectedDeviceEvent;
import com.plantronics.bladerunner.protocol.event.SignalStrengthEvent;
import com.plantronics.bladerunner.protocol.event.SubscribedServiceDataEvent;
import com.plantronics.bladerunner.protocol.event.WearingStateChangedEvent;
import com.plantronics.bladerunner.protocol.setting.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class MainActivity extends Activity
{
	private static final String TAG = "com.plantronics.BRPlayground";

	private Communicator 				_communicator; // from appcore
	private BladeRunnerCommunicator 	_bladeRunnerCommunicator;
	private EventListener 				_eventListener;
	private BluetoothDevice 			_connectedBluetoothDevice;
	private Set<BluetoothDevice> 		_bladerunnerCapableDevices;
	private boolean 					_isBladerunnerDevicePresent;
	private static boolean 				_isBladeRunnerDeviceConnected;
	private BladeRunnerDevice 			_device;
	private BladeRunnerDevice 			_sensorsDevice;
	private BladeRunnerInitializer 		_bladeRunnerInitializer = new BladeRunnerInitializer();
	private Context 					_context;

	private Button 						_connectToDeviceButton;
	private Button 						_getWearingStateButton;
	private Button 						_subscribeToSignalStrengthButton;
	private Button 						_getSignalStrengthButton;
	private Button 						_getDeviceInfoButton;
	private Button						 _subscribeToServicesButton;
	private Button 						_unsubscribeFromServicesButton;
	private Button						_queryServicesButton;
	private TextView  					_connectedTextView;
	private TextView 					_wearingTextView;
	private TextView  					_signalStrengthTextView;
	private ProgressBar  				_headingProgressBar;
	private ProgressBar  				_pitchProgressBar;
	private ProgressBar  				_rollProgressBar;
	private TextView  					_freeFallTextView;
	private TextView  					_tapsTextView;
	private TextView  					_pedometerTextView;
	private TextView  					_gyroCalTextView;
	private TextView  					_magCalTextView;


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
				eventReceived(event);
			}
		};

		_bladeRunnerCommunicator = BladeRunnerCommunicator.getInstance(_context);
		_bladeRunnerCommunicator.registerEventListener(_eventListener);

		// what does this do..?
		_communicator = new Communicator(_context);
		_communicator.addHandler(_nativeBluetoothCommunicatorHandler);

		_connectToDeviceButton = ((Button)findViewById(R.id.connectToDeviceButton));
		_connectToDeviceButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				openConnectionButton();
			}
		});

		_getWearingStateButton = ((Button)findViewById(R.id.getWearingStateButton));
		_getWearingStateButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				getWearingStateButton();
			}
		});

		_subscribeToSignalStrengthButton = ((Button)findViewById(R.id.subscribeToSignalStrengthButton));
		_subscribeToSignalStrengthButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				subscribeToSignalStrengthButton();
			}
		});

		_getSignalStrengthButton = ((Button)findViewById(R.id.getSignalStrengthButton));
		_getSignalStrengthButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				getSignalStrengthButton();
			}
		});

		_getDeviceInfoButton =  ((Button)findViewById(R.id.getDeviceInfoButton));
		_getDeviceInfoButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				getDeviceInfoButton();
			}
		});

		_subscribeToServicesButton = ((Button)findViewById(R.id.subscribeToServicesButton));
		_subscribeToServicesButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				subscribeToServicesButton();
			}
		});

		_unsubscribeFromServicesButton = ((Button)findViewById(R.id.unsubscribeFromServicesButton));
		_unsubscribeFromServicesButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				unsubscribeFromServicesButton();
			}
		});

		_queryServicesButton = ((Button)findViewById(R.id.queryServicesButton));
		_queryServicesButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				queryServicesButton();
			}
		});

		_connectedTextView = ((TextView)findViewById(R.id.connectedTextView));
		_wearingTextView = ((TextView)findViewById(R.id.wearingTextView));
		_signalStrengthTextView = ((TextView)findViewById(R.id.signalStrengthTextView));
		_freeFallTextView = ((TextView)findViewById(R.id.freeFallTextView));
		_tapsTextView = ((TextView)findViewById(R.id.tapsTextView));
		_pedometerTextView = ((TextView)findViewById(R.id.pedometerTextView));
		_gyroCalTextView = ((TextView)findViewById(R.id.gyroCalTextView));
		_magCalTextView = ((TextView)findViewById(R.id.magCalTextView));

		_headingProgressBar = ((ProgressBar)findViewById(R.id.headingProgressBar));
		_pitchProgressBar = ((ProgressBar)findViewById(R.id.pitchProgressBar));
		_rollProgressBar = ((ProgressBar)findViewById(R.id.rollProgressBar));
	}

	@Override
	protected void onStart() {
		super.onStart();
		Log.i(FN(), "onStart()");
		disableUI();
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

									connectionOpened();
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

	private void connectionOpened() {
		Log.i(FN(), "************ CONNECTION OPEN! ************");

		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				_connectedTextView.setText("Connected: Yes");
			}
		});

		enableUI();
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
					final WearingStateResponse response = (WearingStateResponse)incomingMessage;
					Log.i(FN(), "********* Wearing state success: " + (response.getWorn() ? "Donned" : "Doffed") + " *********");
					runOnUiThread(new Runnable() {
						@Override
						public void run() {
							_wearingTextView.setText("Wearing? " + (response.getWorn() ? "Yes" : "No"));
						}
					});
				}

				@Override
				public void onFailure(BladerunnerException exception) {
					Log.e(FN(), "********* Wearing state exception: " + exception + " *********");
				}
			});
		}
	}

	private void subscribeToSignalStrengthButton() {
		Log.i(FN(), "subscribeToSignalStrengthButton()");

		if (_device != null) {
			ConfigureSignalStrengthEventsCommand command = new ConfigureSignalStrengthEventsCommand();
			command.setEnable(true);
			command.setConnectionId(2);
			command.setDononly(false);
			command.setReportNearFarAudio(false);
			command.setReportNearFarToBase(false);
			command.setReportRssiAudio(false);
			command.setTrend(false);
			command.setSensitivity(5);
			command.setNearThreshold(70);
			command.setMaxTimeout(15);
			_bladeRunnerCommunicator.execute(command, _device, new MessageCallback() {
				@Override
				public void onSuccess(IncomingMessage incomingMessage) {
					//CurrentSignalStrengthResponse response = (CurrentSignalStrengthResponse)incomingMessage;
					Log.i(FN(), "********* Subscribe to signal strength success: " + incomingMessage + " *********");
				}

				@Override
				public void onFailure(BladerunnerException exception) {
					Log.e(FN(), "********* Subscribe to signal strength exception: " + exception + " *********");
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
					final CurrentSignalStrengthResponse response = (CurrentSignalStrengthResponse)incomingMessage;
					Log.i(FN(), "********* Current signal strength success: Near/far: " + response.getNearFar() + ", Strength: " + response.getStrength() + " *********");
					runOnUiThread(new Runnable() {
						@Override
						public void run() {
							_signalStrengthTextView.setText("Signal Strength: " + response.getStrength());
						}
					});
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
			ArrayList<SubscribeToServicesCommand> commands = new ArrayList<SubscribeToServicesCommand>();

			SubscribeToServicesCommand command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_HeadOrientation.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOnCchange.getValue());
			command.setPeriod(15);
			commands.add(command);

			command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_FreeFall.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOnCchange.getValue());
			command.setPeriod(15);
			commands.add(command);

			command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_Taps.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOnCchange.getValue());
			command.setPeriod(15);
			commands.add(command);

			command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_Pedometer.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOnCchange.getValue());
			command.setPeriod(15);
			commands.add(command);

			command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_GyroscopeCalibrationStatus.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOnCchange.getValue());
			command.setPeriod(15);
			commands.add(command);

			for (SubscribeToServicesCommand c : commands) {
				_bladeRunnerCommunicator.executeWithStreaming(c, _sensorsDevice, new MessageCallback() {
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
	}

	private void unsubscribeFromServicesButton() {
		Log.i(FN(), "unsubscribeFromServicesButton()");

		if (_sensorsDevice != null) {
			ArrayList<SubscribeToServicesCommand> commands = new ArrayList<SubscribeToServicesCommand>();

			SubscribeToServicesCommand command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_HeadOrientation.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOff.getValue());
			command.setPeriod(15);
			commands.add(command);

			command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_FreeFall.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOff.getValue());
			command.setPeriod(15);
			commands.add(command);

			command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_Taps.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOff.getValue());
			command.setPeriod(15);
			commands.add(command);

			command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_Pedometer.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOff.getValue());
			command.setPeriod(15);
			commands.add(command);

			command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_GyroscopeCalibrationStatus.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOff.getValue());
			command.setPeriod(15);
			commands.add(command);

			command = new SubscribeToServicesCommand();
			command.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_MagnetometerCalibrationStatus.getValue());
			command.setCharacteristic(0);
			command.setMode(SubscribeToServicesCommand.Mode.ModeOff.getValue());
			command.setPeriod(15);
			commands.add(command);

			for (SubscribeToServicesCommand c : commands) {
				_bladeRunnerCommunicator.execute(c, _sensorsDevice, new MessageCallback() {
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
	}

	private void queryServicesButton() {
		Log.i(FN(), "queryServicesButton()");

		if (_sensorsDevice != null) {
			ArrayList<QueryServicesDataRequest> requests = new ArrayList<QueryServicesDataRequest>();

			QueryServicesDataRequest request = new QueryServicesDataRequest();
			request.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_HeadOrientation.getValue());
			request.setCharacteristic(0);
			requests.add(request);

			request = new QueryServicesDataRequest();
			request.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_FreeFall.getValue());
			request.setCharacteristic(0);
			requests.add(request);

			request = new QueryServicesDataRequest();
			request.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_Taps.getValue());
			request.setCharacteristic(0);
			requests.add(request);

			request = new QueryServicesDataRequest();
			request.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_Pedometer.getValue());
			request.setCharacteristic(0);
			requests.add(request);

			request = new QueryServicesDataRequest();
			request.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_GyroscopeCalibrationStatus.getValue());
			request.setCharacteristic(0);
			requests.add(request);

			request = new QueryServicesDataRequest();
			request.setServiceID(SubscribeToServicesCommand.ServiceID.ServiceID_MagnetometerCalibrationStatus.getValue());
			request.setCharacteristic(0);
			requests.add(request);

			for (QueryServicesDataRequest r : requests) {
				_bladeRunnerCommunicator.execute(r, _sensorsDevice, new MessageCallback() {
					@Override
					public void onSuccess(IncomingMessage message) {
						QueryServicesDataResponse response = (QueryServicesDataResponse)message;
						Log.i(FN(), "********* Query service success: " + message + " *********");

						int serviceID = response.getServiceID();
						Log.i(FN(), "serviceID: " + serviceID);

						final int[] data = response.getServiceData();
						for (int d = 0; d<data.length; d++) {
							Log.i(FN(), "data[" + d + "] = " + data[d]);
						}

//						switch (serviceID) {
//							case 0x0000: // head orientation
//								runOnUiThread(new Runnable() {
//									@Override
//									public void run() {
//										Quaternion q = quaternionFromData(data);
//										EulerAngles angles = new EulerAngles(q);
//										_headingProgressBar.setProgress((int)Math.round(-(angles.x - 180)));
//										_pitchProgressBar.setProgress((int)Math.round(angles.y + 90));
//										_rollProgressBar.setProgress((int)Math.round(angles.z + 90));
//									}
//								});
//								break;
//							case 0x0003: // free fall
//								runOnUiThread(new Runnable() {
//									@Override
//									public void run() {
//										_freeFallTextView.setText("Free fall? " + (data[1]==1 ? "Yes" : "No"));
//									}
//								});
//								break;
//							case 0x0004: // taps
//								runOnUiThread(new Runnable() {
//									@Override
//									public void run() {
//										int taps = data[3];
//										int direction = data[1];
//										if (taps>0) {
//											_tapsTextView.setText("Taps: " + taps + " taps in " + getStringForTapDirection(direction));
//										}
//										else {
//											_tapsTextView.setText("Taps: -");
//										}
//									}
//								});
//								break;
//							case 0x0002: // pedometer
//								runOnUiThread(new Runnable() {
//									@Override
//									public void run() {
//										_pedometerTextView.setText("Pedometer: " + data[1]);
//									}
//								});
//								break;
//							case 0x0006: // gyro cal status
//								runOnUiThread(new Runnable() {
//									@Override
//									public void run() {
//										_gyroCalTextView.setText("Gyro cal'd? " + (data[1] == 3 ? "Yes" : "No"));
//									}
//								});
//								break;
//							case 0x0007: // mag cal status
//								runOnUiThread(new Runnable() {
//									@Override
//									public void run() {
//										_magCalTextView.setText("Gyro cal'd? " + (data[1] == 3 ? "Yes" : "No"));
//									}
//								});
//								break;
//						}
					}

					@Override
					public void onFailure(BladerunnerException exception) {
						Log.e(FN(), "********* Query service exception: " + exception + " *********");
					}
				});

				try {
					Thread.sleep(1000);
				}
				catch (Exception exception) {
					Log.i(FN(), "Exception in sleep(): ", exception);
					//throw exception;
				}

			}
		}
	}

	private void eventReceived(Event event) {
		Log.i(FN(), "eventReceived(): " + event);

		if (event instanceof SubscribedServiceDataEvent) {
			SubscribedServiceDataEvent serviceData = (SubscribedServiceDataEvent)event;
			final int[] data = serviceData.getServiceData();
			int serviceID = serviceData.getServiceID();

			switch (serviceID) {
				case 0x0000: // head orientation
					runOnUiThread(new Runnable() {
						@Override
						public void run() {
							Quaternion q = quaternionFromData(data);
							EulerAngles angles = new EulerAngles(q);
							_headingProgressBar.setProgress((int)Math.round(-(angles.x - 180)));
							_pitchProgressBar.setProgress((int)Math.round(angles.y + 90));
							_rollProgressBar.setProgress((int)Math.round(angles.z + 90));
						}
					});
					break;
				case 0x0003: // free fall
					runOnUiThread(new Runnable() {
						@Override
						public void run() {
							_freeFallTextView.setText("Free fall? " + (data[1]==1 ? "Yes" : "No"));
						}
					});
					break;
				case 0x0004: // taps
					runOnUiThread(new Runnable() {
						@Override
						public void run() {
							int taps = data[3];
							int direction = data[1];
							if (taps>0) {
								_tapsTextView.setText("Taps: " + taps + " taps in " + getStringForTapDirection(direction));
							}
							else {
								_tapsTextView.setText("Taps: -");
							}
						}
					});
					break;
				case 0x0002: // pedometer
					runOnUiThread(new Runnable() {
						@Override
						public void run() {
							_pedometerTextView.setText("Pedometer: " + data[1]);
						}
					});
					break;
				case 0x0006: // gyro cal status
					runOnUiThread(new Runnable() {
						@Override
						public void run() {
							_gyroCalTextView.setText("Gyro cal'd? " + (data[1] == 3 ? "Yes" : "No"));
						}
					});
					break;
				case 0x0007: // mag cal status
					runOnUiThread(new Runnable() {
						@Override
						public void run() {
							_magCalTextView.setText("Mag cal'd? " + (data[1] == 3 ? "Yes" : "No"));
						}
					});
					break;
			}
		}
		else if (event instanceof WearingStateChangedEvent) {
			final WearingStateChangedEvent e = (WearingStateChangedEvent)event;
			Log.i(FN(), "********* Wearing state event: " + (e.getWorn() ? "Donned" : "Doffed") + " *********");
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					_wearingTextView.setText("Wearing? " + (e.getWorn() ? "Yes" : "No"));
				}
			});
		}
		else if (event instanceof SignalStrengthEvent) {
			final SignalStrengthEvent e = (SignalStrengthEvent)event;
			Log.i(FN(), "********* Signal strength event: Near/far: " + e.getNearFar() + ", Strength: " + e.getStrength() + " *********");
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					_signalStrengthTextView.setText("Signal Strength: " + e.getStrength());
				}
			});
		}
	}

	private void enableUI() {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				_getWearingStateButton.setEnabled(true);
				_subscribeToSignalStrengthButton.setEnabled(true);
				_getSignalStrengthButton.setEnabled(true);
				_getDeviceInfoButton.setEnabled(true);
				_subscribeToServicesButton.setEnabled(true);
				_unsubscribeFromServicesButton.setEnabled(true);
				_queryServicesButton.setEnabled(true);
			}
		});
	}

	private void disableUI() {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				_getWearingStateButton.setEnabled(false);
				_subscribeToSignalStrengthButton.setEnabled(false);
				_getSignalStrengthButton.setEnabled(false);
				_getDeviceInfoButton.setEnabled(false);
				_subscribeToServicesButton.setEnabled(false);
				_unsubscribeFromServicesButton.setEnabled(false);
				_queryServicesButton.setEnabled(false);

				_connectedTextView.setText("Connected? No");
				_wearingTextView.setText("Wearing? -");
				_signalStrengthTextView.setText("Signal Strength: -");
				_freeFallTextView.setText("Free fall? -");
				_tapsTextView.setText("Taps: -");
				_pedometerTextView.setText("Pedometer: -");
				_gyroCalTextView.setText("Gyro cal'd? -");
				_magCalTextView.setText("Mag cal'd? -");
			}
		});
	}

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

	public static double d2r(double d)
	{
		return d * (Math.PI/180.0);
	}

	public static double r2d(double d)
	{
		return d * (180.0/Math.PI);
	}

	public Quaternion MultipliedQuaternions(Quaternion q, Quaternion p)
	{
		double quatmat[][] =
		{   { p.w, -p.x, -p.y, -p.z },
			{ p.x, p.w, -p.z, p.y },
			{ p.y, p.z, p.w, -p.x },
			{ p.z, -p.y, p.x, p.w },
		};

		double[] mulQuat = new double[4];
		for (int i = 0; i < 4; i++) {
			for (int j = 0; j < 4; j++) {
				double[] qq = { q.w, q.x, q.y, q.z };
				mulQuat[i] += quatmat[i][j] * qq[j];
			}
		}

		return new Quaternion(mulQuat[0], mulQuat[1], mulQuat[2], mulQuat[3]);
	}

	public Quaternion InverseQuaternion(Quaternion q)
	{
		return new Quaternion(q.w, -q.x, -q.y, -q.z);
	}

	public class Quaternion {
		public double w;
		public double x;
		public double y;
		public double z;

		public Quaternion(double w_, double x_, double y_, double z_) {
			w = w_;
			x = x_;
			y = y_;
			z = z_;
		}

		public Quaternion(EulerAngles eulerAngles) {
			double psi = d2r(eulerAngles.x);
			double theta = d2r(eulerAngles.y);
			double phi = d2r(eulerAngles.z);

			double q0=Math.cos(psi / 2.0)*Math.cos(theta / 2.0)*Math.cos(phi / 2.0)-Math.sin(psi / 2.0)*Math.sin(theta / 2.0)*Math.sin(phi / 2.0);
			double q1=Math.cos(psi / 2.0)*Math.sin(theta / 2.0)*Math.cos(phi / 2.0)-Math.sin(psi / 2.0)*Math.cos(theta / 2.0)*Math.sin(phi / 2.0);
			double q2=Math.cos(psi / 2.0)*Math.cos(theta / 2.0)*Math.sin(phi / 2.0)+Math.sin(psi / 2.0)*Math.sin(theta / 2.0)*Math.cos(phi / 2.0);
			double q3=Math.sin(psi / 2.0)*Math.cos(theta / 2.0)*Math.cos(phi / 2.0)+Math.cos(psi / 2.0)*Math.sin(theta / 2.0)*Math.sin(phi / 2.0);

			w = q0;
			x = q1;
			y = q2;
			z = q3;
		}

		@Override
		public String toString() {
			return "{ " + w + ", " + x + ", " + y + ", " + z + " }";
		}
	}

	public class EulerAngles {
		public double x;
		public double y;
		public double z;

		public EulerAngles(double x_, double y_, double z_) {
			x = x_;
			y = y_;
			z = z_;
		}

		public EulerAngles(Quaternion quaternion) {
			double q0 = quaternion.w;
			double q1 = quaternion.x;
			double q2 = quaternion.y;
			double q3 = quaternion.z;

			double m22 = 2*Math.pow(q0, 2) + 2*Math.pow(q2, 2) - 1;
			double m21 = 2*q1*q2 - 2*q0*q3;
			double m13 = 2*q1*q3 - 2*q0*q2;
			double m23 = 2*q2*q3 + 2*q0*q1;
			double m33 = 2*Math.pow(q0, 2) + 2*Math.pow(q3, 2) - 1;

			double psi = -r2d(Math.atan2(m21, m22));
			double theta = r2d(Math.asin(m23));
			double phi = -r2d(Math.atan2(m13, m33));

			x = psi;
			y = theta;
			z = phi;
		}

		@Override
		public String toString() {
			return "{ " + x + ", " + y + ", " + z + " }";
		}
	}

	private String getStringForTapDirection(int direction) {
		switch (direction) {
			case 1:
				return "x up";
			case 2:
				return "x down";
			case 3:
				return "y up";
			case 4:
				return "y down";
			case 5:
				return "z up";
			case 6:
				return "z down";
		}
		return "";
	}
}
