/*___Generated_by_IDEA___*/

/*
 * This file is auto-generated.  DO NOT MODIFY.
 * Original file: /Users/mdavis/plantronics-innovation/core-team/Mobile/Android/DX650 Screen Lock -- webex demo/aidl/com/plantronics/headsetdataservice/IHeadsetDataServiceCallbackSession.aidl
 */
package com.plantronics.headsetdataservice;
/**
 * Example of a callback interface used by IRemoteService to send
 * synchronous notifications back to its clients.  Note that this is a
 * one-way interface so the server does not block waiting for the client.
 */
public interface IHeadsetDataServiceCallbackSession extends android.os.IInterface
{
/** Local-side IPC implementation stub class. */
public static abstract class Stub extends android.os.Binder implements com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession
{
private static final java.lang.String DESCRIPTOR = "com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession";
/** Construct the stub at attach it to the interface. */
public Stub()
{
this.attachInterface(this, DESCRIPTOR);
}
/**
 * Cast an IBinder object into an com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession interface,
 * generating a proxy if needed.
 */
public static com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession asInterface(android.os.IBinder obj)
{
if ((obj==null)) {
return null;
}
android.os.IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
if (((iin!=null)&&(iin instanceof com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession))) {
return ((com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession)iin);
}
return new com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession.Stub.Proxy(obj);
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
case TRANSACTION_deviceClose:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
com.plantronics.headsetdataservice.io.SessionErrorException _arg1;
if ((0!=data.readInt())) {
_arg1 = com.plantronics.headsetdataservice.io.SessionErrorException.CREATOR.createFromParcel(data);
}
else {
_arg1 = null;
}
this.deviceClose(_arg0, _arg1);
return true;
}
}
return super.onTransact(code, data, reply, flags);
}
private static class Proxy implements com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession
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
@Override public void deviceClose(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, com.plantronics.headsetdataservice.io.SessionErrorException s) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
if ((s!=null)) {
_data.writeInt(1);
s.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_deviceClose, _data, null, android.os.IBinder.FLAG_ONEWAY);
}
finally {
_data.recycle();
}
}
}
static final int TRANSACTION_deviceClose = (android.os.IBinder.FIRST_CALL_TRANSACTION + 0);
}
public void deviceClose(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, com.plantronics.headsetdataservice.io.SessionErrorException s) throws android.os.RemoteException;
}
