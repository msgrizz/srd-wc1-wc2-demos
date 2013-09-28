/**
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */

package com.plantronics.headsetdataservice;

import com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackOpen;
import com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackEvents;
import com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession;
import com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata;
import com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackDiscovery;
import com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection;

import com.plantronics.headsetdataservice.io.DeviceSettingType;
import com.plantronics.headsetdataservice.io.DeviceCommandType;
import com.plantronics.headsetdataservice.io.DeviceEventType;

import com.plantronics.headsetdataservice.io.DeviceSetting;
import com.plantronics.headsetdataservice.io.DeviceCommand;

import com.plantronics.headsetdataservice.io.HeadsetDataDevice;
import com.plantronics.headsetdataservice.io.RemotePort;
import com.plantronics.headsetdataservice.Registration;

import com.plantronics.headsetdataservice.io.RemoteResult;

// declare the AIDL interface for the HeadsetData Service
interface IHeadsetDataService {

   //void registerExceptionSignatures(in String bdaddr, in int id);
   //void registerSettingSignatures(in String bdaddr, in int id);
   //void registerEventSignatures(in String bdaddr, in int id);

   //Device Registration  APIs
   void register(inout Registration registration);
   void unregister(in String registrationName);
   
   // API to get the version of the interface
   int geApiVersion();

   //APIs added for SQA testing; remove them from the final product
   void enableCaching();
   void disableCaching();

   //APIs added to enable disable and query debug setting
   void enableDebug();
   void disableDebug();
   int isEnableDebug();

  /**
    * API to register a listener to update on the HeadsetData Protocol open connection status
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return  int
    *               0  : Success
    *              -1 : Error
    */
   int addDeviceOpenListener(in HeadsetDataDevice hdDevice);

   /**
    * Remote API to remove the listener  for a given app
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return   int
    *           0  : Success
    *          -1 : Error
    */
   int removeDeviceOpenListener(in HeadsetDataDevice hdDevice);

   /**
    * API to add a listener for the connection status
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return   int
    *           0  : Success
    *          -1 : Error
    */
   int addDeviceSessionListener(in HeadsetDataDevice hdDevice);
   /**
    * API to remove the listener for the connection status for an App id
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return   int
    *           0  : Success
    *          -1 : Error
    */
   int removeDeviceSessionListener(in HeadsetDataDevice hdDevice);

   /**
    * API to add a listner to notify all the events generated by the headset
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return   int
    *           0  : Success
    *          -1 : Error
    */
   int addDeviceEventListener(in HeadsetDataDevice hdDevice);

   /**
    *  API to remove the event listener for an app
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return   int
    *           0  : Success
    *          -1 : Error
    */
   int removeDeviceEventListener(in HeadsetDataDevice hdDevice);

   /**
    * Api to add a listener to notify when Metadat is received from the headset
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return   int
    *           0  : Success
    *          -1 : Error
    */
   int addMetadataListener(in HeadsetDataDevice hdDevice);

   /**
    * API to remove the metadata listener for an App
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return   int
    *           0  : Success
    *          -1 : Error
    */
   int removeMetadataListener(in HeadsetDataDevice hdDevice);

   /**
    * API to get the list of ids of all the supported Deckard Events
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return   A list of DeviceEventType
    */
   List<DeviceEventType> getSupportedEvents(in HeadsetDataDevice hdDevice);

   /**
    * API to get the list of ids of all the supported Deckard Settings
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @param command The DeviceCommand object with the payload data and the id
    * @return   A list of DeviceSettingType
    */
   List<DeviceSettingType> getSupportedSettings(in HeadsetDataDevice hdDevice);

    /**
     * API to get the list of ids of all the supported Deckard Commands
     * @param hdDevice   HeadsetDataDevice
     *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
     *          connected to the headset.
     *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
     *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
     *          protocol port number at which the remote device is connected to the headset.
     * @param command The DeviceCommand object with the payload data and the id
     * @return   A list of DeviceCommandType
     */
   List<DeviceCommandType> getSupportedCommands(in HeadsetDataDevice hdDevice);

   /**
    * API to call the Service to discover HeadsetData protocol supporting headset devices
    */
   int discoverHeadsetDataServiceDevices();
   
   /**
    * API to call the Service to retrieve the HeadsetData protocol supporting connected headset device
    *
    */
   int getConnectedBladeRunnerBluetoothDevice();

   /**
    * API called to create a placeholder object which supports HeadsetData API for the headset
    * @param bdaddr   String
    *                 bluetooth address of the headset
    * @return int : 0 success
    */
   int newDevice(in String bdaddr);

   /**
    * API called to create a remote HeadsetDataDevice object which supports HeadsetDataService API for
    * the remote device connected to the headset.
    * For this remote device a {@link Definitions.Events.CONNECTED_DEVICE_EVENT} event was received with
    * the HeadsetDataService port address as payload, when this device was bluetooth connected to the headset.
    * @param bdaddr   String
    *                 bluetooth address of the local device on which this app/sdk is running
    * @param port     int
    *                 port number to identify the remote device which is connected to the (headset
    *                 in between) on this port.
    *                 This is the port number which was received with the {@link Definitions.Events.CONNECTED_DEVICE_EVENT} Event
    */
   HeadsetDataDevice newRemoteDevice(in String bdaddr, int port);

   /**
    * API to initiate a open connection request to the headset
    * Its an asynchronous API and the success and failure is reported by the callback interface
    * If the connection is already opened to the headset, this API returns success (1) and the App
    * does not need to wait for the open notification
    *
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return  int
    *          0  : The connection is opened by this call
    *          1  : connection was already opened
    *          -1 : Error during open connection
    */
   int open(in HeadsetDataDevice hdDevice);

   /**
    * API to get the list of remote ports which are open on the headset to remote devices.
    * This app can connect to the remote devices by using the api {@open(in String, int)} and
    *
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return  List<RemotePort>
    *            list of port numbers for the remote devices which are connected to the headset
    *
    */
   List<RemotePort>getConnectedPorts(in HeadsetDataDevice hdDevice);

   /**
    * API that checks that given a input  DeviceSetting Type id, whether its implemented by the
    * HeadsetData Service and the headset. The API returns a null value if that Setting is not supported
    * of return a DeviceSettingType if its supported
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @param id  int
    *            The id of the Settings app want to use
    * @return    DeviceSettingType
    *            object to use
    */
   DeviceSettingType getSettingType(in HeadsetDataDevice hdDevice, in int id);

   /**
    * This Api, given a DeviceSettingType id, returns the corresponding DeviceSetting object
    *
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @param dst     DeviceSettingType object
    * @return       DeviceSetting object which contains the placeholder for the setting payload
    */

    DeviceSetting getSetting(in HeadsetDataDevice hdDevice, in DeviceSettingType dst);

   /**
    * API to query the setting of the Headset
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @param setting  DeviceSetting
    *                 object that will contain the setting payload returned by the headset
    * @param result
    *        Input a new {@link RemoteResult} object. Output is a {@link RemoteResult} object with the result code and message
    *        string set as reason for failure in case of error.
    * @return int
    *         0: success ; -1 : failure
   */
   int fetch(in HeadsetDataDevice hdDevice, inout DeviceSetting setting, inout RemoteResult result);

   /**
    * API that checks that given a input  DeviceCommand Type id, whether its implemented by the
    * HeadsetData Service and the headset. The API returns a null value if that Command is not supported
    * of return a DeviceCommandType if its supported
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @param id  int
    *            The id of the Command app want to use
    * @return    DeviceCommandType
    *            object to pass in {@getCommand(in HeadsetDataDevice, in DeviceCommandType)}
    */
   DeviceCommandType getCommandType(in HeadsetDataDevice hdDevice, in int id);

   /**
    * This Api, given a DeviceCommandType id, returns the corresponding DeviceCommand object
    *
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @param dct     DeviceCommandType object with the Id set.
    * @return       DeviceCommand object which contains the placeholder for setting payload
    */

   DeviceCommand getCommand(in HeadsetDataDevice hdDevice, in DeviceCommandType dct);

   /**
    * API to invoke a command on the Headset
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @param command
    *         The {@link DeviceCommand} object with the payload data and the id. This is the command to be performed
    * @param result
    *        Input a new {@link RemoteResult} object. Output is a {@link RemoteResult} object with the result code and messege
    *        string set as reason for failure in case of error. In case the perform command resulted in Exception from
    *        the headset, the exception id and payload is also set for the result object.
    * @return   int
    *          0 success - it means that the command was recieved by the headset and is acting upon it
    *          -1 failure - not successful
    */
   int perform(in HeadsetDataDevice hdDevice, in DeviceCommand command, inout RemoteResult result);

   /**
    * API to close the HeadsetData Service connection to the headset
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    */
   void close(in HeadsetDataDevice hdDevice);

   /**
    * API to query whether a Headset Data service connection is open
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @return     1 Open; 0 not open
    */
   int isOpen(in HeadsetDataDevice hdDevice);

   /**
    * API to add the remote port from the list of connected devices, in case a connect event is received
    * for that remote device
    * @param hdDevice {@link HeadsetDataService}
    *        HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @param port
    *        HeadsetData Protocol port number on which the remote device is connected to the headset
    * @return   int
    *           0 success
    *           -1 failure
    */
   int addRemotePort(in HeadsetDataDevice hdDevice, int port);

   /**
    * API to remove the remote port from the list of connected devices, in case a disconnect event is received
    * for that remote device
    * @param hdDevice
    *        HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    * @param port
    *        HeadsetData Protocol port number on which the remote device is connected to the headset
    * @return  int
    *           0 success
    *           -1 failure
   */
   int removeRemotePort(in HeadsetDataDevice hdDevice, int port);

   //
   // callbacks
   //
   /**
    * This inerface allows the service to call back to its clients.
    * This shows how to do so, by registering a callback interface with
    * the service.
    */
    void registerOpenCallback(IHeadsetDataServiceCallbackOpen cb);
    void registerEventsCallback(IHeadsetDataServiceCallbackEvents cb);
    void registerSessionCallback(IHeadsetDataServiceCallbackSession cb);
    void registerMetadataCallback(IHeadsetDataServiceCallbackMetadata cb);
    void registerDiscoveryCallback(IHeadsetDataServiceCallbackDiscovery cb);
    void registerBluetoothConnectionCallback(IHeadsetDataServiceCallbackBluetoothConnection cb);

    /**
     * Remove a previously registered callback interface.
     */
     void unregisterOpenCallback(IHeadsetDataServiceCallbackOpen cb);
     void unregisterEventsCallback(IHeadsetDataServiceCallbackEvents cb);
     void unregisterSessionCallback(IHeadsetDataServiceCallbackSession cb);
     void unregisterMetadataCallback(IHeadsetDataServiceCallbackMetadata cb);
     void unregisterDiscoveryCallback(IHeadsetDataServiceCallbackDiscovery cb);  
     void unregisterBluetoothConnectionCallback(IHeadsetDataServiceCallbackBluetoothConnection cb);
}
