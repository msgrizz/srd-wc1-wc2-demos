package com.plantronics.appcore.service.bluetooth.plugins.nativebluetooth.utilities;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.os.ParcelUuid;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.utilities.PlantronicsDeviceResolver;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

import java.io.*;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.UUID;

/**
 * Author: Ugljesa Jovanovic (ugljesa.jovanovic@pstech.rs)
 * Date: 7/26/12
 */
public class VolumeSettingUtility {
    public static final String TAG = LogTag.getBluetoothPackageTagPrefix() + VolumeSettingUtility.class.getSimpleName();

    public static boolean toggleVolume = false;

    public static boolean tryToConnectAndSetVolume(BluetoothDevice bluetoothDevice) {

        if (PlantronicsDeviceResolver.isDeviceA2DPOnlyConstrained(bluetoothDevice)){
            return true;
        }

        try {

            Class<BluetoothSocket> cls = BluetoothSocket.class;
            Constructor<BluetoothSocket> bluetoothSocketConstructor = null;

            try {
                bluetoothSocketConstructor = cls.getDeclaredConstructor(int.class, int.class, boolean.class,
                        boolean.class, BluetoothDevice.class, int.class, ParcelUuid.class);

                if (!bluetoothSocketConstructor.isAccessible()) {
                    bluetoothSocketConstructor.setAccessible(true);
                }

            } catch (SecurityException e) {
                Log.e(TAG, "" ,e);
            } catch (NoSuchMethodException e) {
                Log.e(TAG, "" ,e);
            }

            UUID uuid = UUID.fromString("00001108-0000-1000-8000-00805F9B34FB");
            ParcelUuid parcelUuid = new ParcelUuid(uuid);
            Method getServiceChannelMethod = BluetoothDevice.class.getMethod("getServiceChannel", ParcelUuid.class);
//            Method fetchServiceUUIDsMethod = BluetoothProfile.class.getMethod("fetchUuidsWithSdp", null);

            int channel = (Integer) getServiceChannelMethod.invoke(bluetoothDevice, parcelUuid);
//            fetchServiceUUIDsMethod.invoke(bluetoothDevice, null);
            Log.d(TAG, "Service channel: " + channel);



            Method createRfcommSocketMethod = BluetoothDevice.class.getMethod("createInsecureRfcommSocket", int.class);
//            BluetoothSocket bluetoothSocket = (BluetoothSocket) createRfcommSocketMethod.invoke(bluetoothDevice, 2);

//            BluetoothSocket bluetoothSocket = bluetoothDevice.createRfcommSocketToServiceRecord(UUID.fromString("00001108-0000-1000-8000-00805F9B34FB"));
//            This gives us the most amount of control with least amount of reflection
//            The signature of the constructor is:
//            BluetoothSocket(int type, int fd, boolean auth, boolean encrypt,
//                        BluetoothDevice device, int port, ParcelUuid uuid) throws IOException
//
//            type type of socket
//            fd fd to use for connected socket, or -1 for a new socket (I was unable to use already created socket, only new one)
//            auth require the remote device to be authenticated
//            encrypt require the connection to be encrypted
//            device remote device that this socket can connect to ( ports 1 and 2 are usually HSP HFP, both react to +VGS)
//            port remote port
//            uuid SDP uuid



            //HSP HFP is often on channels 1 or 2, but sometimes we receive a weird value for the channel, so we will be accepting only theses values
            // If channel value is not 1 or 2 we will go ahed and try channel 1 as both HFP and HSP accept +VGS unsolicited command, but I would
            // prefer to use HSP
            BluetoothSocket bluetoothSocket = null;
            if (channel == 1 && channel == 2){
                bluetoothSocket =  bluetoothSocketConstructor.newInstance(1, -1, false, false, bluetoothDevice, channel, null);
            } else {
                bluetoothSocket =  bluetoothSocketConstructor.newInstance(1, -1, false, false, bluetoothDevice, 2, null);
            }

            bluetoothSocket.connect();
            OutputStream outputStream = bluetoothSocket.getOutputStream();
            InputStream inputStream = bluetoothSocket.getInputStream();
            InputStreamReader inputStreamReader = new InputStreamReader(inputStream);

            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(outputStream);

            char[] buffer = new char[1024];
            StringBuilder message = new StringBuilder();
            int read;
            int noDataCounter = 0;
            while (true) {
                if (!(inputStream.available() > 0)) {
                    Log.d(TAG, "No data");
                    noDataCounter++;
                    Thread.sleep(500);
                    if (noDataCounter % 5 == 0) {

                        String command = "\r\n+VGS=15" + "\r\n";

                        toggleVolume = !toggleVolume;
                        Log.d(TAG, "Sending: " + command);
                        outputStreamWriter.write(command, 0, command.length());
                        outputStreamWriter.flush();
                        bluetoothSocket.close();
                        Log.d(TAG, "Attempt to set volume finished. Returning");
                        return true;
                    }
                } else {
                    read = inputStreamReader.read(buffer, 0, buffer.length);
                    if (read > 0) {
                        message.append(buffer, 0, read);
                        Log.d(TAG, message.toString());
                        message.delete(0, message.length());
                        String command = "\r\nOK\r\n";
                        Log.d(TAG, "Sending: " + command);
                        outputStreamWriter.write(command, 0, command.length());
                        outputStreamWriter.flush();
                        ;

                    }
                }

            }
        } catch (InterruptedException e) {
            Log.e(TAG, "" ,e);
        } catch (IOException e) {
            Log.e(TAG, "" ,e);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        } catch (InvocationTargetException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        } catch (IllegalAccessException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        } catch (InstantiationException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        return false;

    }
}
