/*___Generated_by_IDEA___*/

/*
 * This file is auto-generated.  DO NOT MODIFY.
 * Original file: /Users/mdavis/plantronics-innovation/core-team/DX650 Seamless Transfer/aidl/com/plantronics/headsetdataservice/IHeadsetDataServiceCallbackMetadata.aidl
 */
package com.plantronics.headsetdataservice;
public interface IHeadsetDataServiceCallbackMetadata extends android.os.IInterface
{
/** Local-side IPC implementation stub class. */
public static abstract class Stub extends android.os.Binder implements com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata
{
private static final java.lang.String DESCRIPTOR = "com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata";
/** Construct the stub at attach it to the interface. */
public Stub()
{
this.attachInterface(this, DESCRIPTOR);
}
/**
 * Cast an IBinder object into an com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata interface,
 * generating a proxy if needed.
 */
public static com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata asInterface(android.os.IBinder obj)
{
if ((obj==null)) {
return null;
}
android.os.IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
if (((iin!=null)&&(iin instanceof com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata))) {
return ((com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata)iin);
}
return new com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata.Stub.Proxy(obj);
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
case TRANSACTION_metadataReceived:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
java.util.List<com.plantronics.headsetdataservice.io.DeviceCommandType> _arg1;
_arg1 = data.createTypedArrayList(com.plantronics.headsetdataservice.io.DeviceCommandType.CREATOR);
java.util.List<com.plantronics.headsetdataservice.io.DeviceSettingType> _arg2;
_arg2 = data.createTypedArrayList(com.plantronics.headsetdataservice.io.DeviceSettingType.CREATOR);
java.util.List<com.plantronics.headsetdataservice.io.DeviceEventType> _arg3;
_arg3 = data.createTypedArrayList(com.plantronics.headsetdataservice.io.DeviceEventType.CREATOR);
this.metadataReceived(_arg0, _arg1, _arg2, _arg3);
return true;
}
}
return super.onTransact(code, data, reply, flags);
}
private static class Proxy implements com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata
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
@Override public void metadataReceived(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, java.util.List<com.plantronics.headsetdataservice.io.DeviceCommandType> commands, java.util.List<com.plantronics.headsetdataservice.io.DeviceSettingType> settings, java.util.List<com.plantronics.headsetdataservice.io.DeviceEventType> events) throws android.os.RemoteException
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
_data.writeTypedList(commands);
_data.writeTypedList(settings);
_data.writeTypedList(events);
mRemote.transact(Stub.TRANSACTION_metadataReceived, _data, null, android.os.IBinder.FLAG_ONEWAY);
}
finally {
_data.recycle();
}
}
}
static final int TRANSACTION_metadataReceived = (android.os.IBinder.FIRST_CALL_TRANSACTION + 0);
}
public void metadataReceived(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, java.util.List<com.plantronics.headsetdataservice.io.DeviceCommandType> commands, java.util.List<com.plantronics.headsetdataservice.io.DeviceSettingType> settings, java.util.List<com.plantronics.headsetdataservice.io.DeviceEventType> events) throws android.os.RemoteException;
}
