/*___Generated_by_IDEA___*/

/*
 * This file is auto-generated.  DO NOT MODIFY.
 * Original file: /Users/mdavis/plantronics-innovation/core-team/Mobile/Android/DX650 Screen Lock -- webex demo/aidl/com/plantronics/headsetdataservice/IHeadsetDataServiceCallbackBluetoothConnection.aidl
 */
package com.plantronics.headsetdataservice;
/**
 * Example of a callback interface used by IRemoteService to send
 * synchronous notifications back to its clients.  Note that this is a
 * one-way interface so the server does not block waiting for the client.
 */
public interface IHeadsetDataServiceCallbackBluetoothConnection extends android.os.IInterface
{
/** Local-side IPC implementation stub class. */
public static abstract class Stub extends android.os.Binder implements com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection
{
private static final java.lang.String DESCRIPTOR = "com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection";
/** Construct the stub at attach it to the interface. */
public Stub()
{
this.attachInterface(this, DESCRIPTOR);
}
/**
 * Cast an IBinder object into an com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection interface,
 * generating a proxy if needed.
 */
public static com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection asInterface(android.os.IBinder obj)
{
if ((obj==null)) {
return null;
}
android.os.IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
if (((iin!=null)&&(iin instanceof com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection))) {
return ((com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection)iin);
}
return new com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection.Stub.Proxy(obj);
}
@Override public android.os.IBinder asBinder()
{
return this;
}
@Override public boolean onTransact(int code, android.os.Parcel data, android.os.Parcel reply, int flags) throws android.os.RemoteException
{
switch (code)
{
case INTERFACE_TRANSACTION:
{
reply.writeString(DESCRIPTOR);
return true;
}
case TRANSACTION_onBluetoothDeviceConnected:
{
data.enforceInterface(DESCRIPTOR);
java.lang.String _arg0;
_arg0 = data.readString();
this.onBluetoothDeviceConnected(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_onBluetoothDeviceDisconnected:
{
data.enforceInterface(DESCRIPTOR);
java.lang.String _arg0;
_arg0 = data.readString();
this.onBluetoothDeviceDisconnected(_arg0);
reply.writeNoException();
return true;
}
}
return super.onTransact(code, data, reply, flags);
}
private static class Proxy implements com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection
{
private android.os.IBinder mRemote;
Proxy(android.os.IBinder remote)
{
mRemote = remote;
}
@Override public android.os.IBinder asBinder()
{
return mRemote;
}
public java.lang.String getInterfaceDescriptor()
{
return DESCRIPTOR;
}
/**
     * Callback when a bluetooth device gets connected
     * @param deviceBluetoothAddress 
     * 		The currently connected Bluetooth Device
     */
@Override public void onBluetoothDeviceConnected(java.lang.String deviceBluetoothAddress) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeString(deviceBluetoothAddress);
mRemote.transact(Stub.TRANSACTION_onBluetoothDeviceConnected, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
/**
     * Callback when a bluetooth device gets disconnected
     * @param deviceBluetoothAddress 
     * 		The Bluetooth Device that has just been disconnected
     */
@Override public void onBluetoothDeviceDisconnected(java.lang.String deviceBluetoothAddress) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeString(deviceBluetoothAddress);
mRemote.transact(Stub.TRANSACTION_onBluetoothDeviceDisconnected, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
}
static final int TRANSACTION_onBluetoothDeviceConnected = (android.os.IBinder.FIRST_CALL_TRANSACTION + 0);
static final int TRANSACTION_onBluetoothDeviceDisconnected = (android.os.IBinder.FIRST_CALL_TRANSACTION + 1);
}
/**
     * Callback when a bluetooth device gets connected
     * @param deviceBluetoothAddress 
     * 		The currently connected Bluetooth Device
     */
public void onBluetoothDeviceConnected(java.lang.String deviceBluetoothAddress) throws android.os.RemoteException;
/**
     * Callback when a bluetooth device gets disconnected
     * @param deviceBluetoothAddress 
     * 		The Bluetooth Device that has just been disconnected
     */
public void onBluetoothDeviceDisconnected(java.lang.String deviceBluetoothAddress) throws android.os.RemoteException;
}
