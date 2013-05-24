/*___Generated_by_IDEA___*/

/*
 * This file is auto-generated.  DO NOT MODIFY.
 * Original file: /Users/mdavis/plantronics-innovation/core-team/DX650 Seamless Transfer/aidl/com/plantronics/headsetdataservice/IHeadsetDataService.aidl
 */
package com.plantronics.headsetdataservice;
// declare the AIDL interface for the HeadsetData Service

public interface IHeadsetDataService extends android.os.IInterface
{
/** Local-side IPC implementation stub class. */
public static abstract class Stub extends android.os.Binder implements com.plantronics.headsetdataservice.IHeadsetDataService
{
private static final java.lang.String DESCRIPTOR = "com.plantronics.headsetdataservice.IHeadsetDataService";
/** Construct the stub at attach it to the interface. */
public Stub()
{
this.attachInterface(this, DESCRIPTOR);
}
/**
 * Cast an IBinder object into an com.plantronics.headsetdataservice.IHeadsetDataService interface,
 * generating a proxy if needed.
 */
public static com.plantronics.headsetdataservice.IHeadsetDataService asInterface(android.os.IBinder obj)
{
if ((obj==null)) {
return null;
}
android.os.IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
if (((iin!=null)&&(iin instanceof com.plantronics.headsetdataservice.IHeadsetDataService))) {
return ((com.plantronics.headsetdataservice.IHeadsetDataService)iin);
}
return new com.plantronics.headsetdataservice.IHeadsetDataService.Stub.Proxy(obj);
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
case TRANSACTION_register:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.Registration _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.Registration.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
this.register(_arg0);
reply.writeNoException();
if ((_arg0!=null)) {
reply.writeInt(1);
_arg0.writeToParcel(reply, android.os.Parcelable.PARCELABLE_WRITE_RETURN_VALUE);
}
else {
reply.writeInt(0);
}
return true;
}
case TRANSACTION_unregister:
{
data.enforceInterface(DESCRIPTOR);
java.lang.String _arg0;
_arg0 = data.readString();
this.unregister(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_geApiVersion:
{
data.enforceInterface(DESCRIPTOR);
int _result = this.geApiVersion();
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_enableCaching:
{
data.enforceInterface(DESCRIPTOR);
this.enableCaching();
reply.writeNoException();
return true;
}
case TRANSACTION_disableCaching:
{
data.enforceInterface(DESCRIPTOR);
this.disableCaching();
reply.writeNoException();
return true;
}
case TRANSACTION_enableDebug:
{
data.enforceInterface(DESCRIPTOR);
this.enableDebug();
reply.writeNoException();
return true;
}
case TRANSACTION_disableDebug:
{
data.enforceInterface(DESCRIPTOR);
this.disableDebug();
reply.writeNoException();
return true;
}
case TRANSACTION_isEnableDebug:
{
data.enforceInterface(DESCRIPTOR);
int _result = this.isEnableDebug();
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_addDeviceOpenListener:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _result = this.addDeviceOpenListener(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_removeDeviceOpenListener:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _result = this.removeDeviceOpenListener(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_addDeviceSessionListener:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _result = this.addDeviceSessionListener(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_removeDeviceSessionListener:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _result = this.removeDeviceSessionListener(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_addDeviceEventListener:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _result = this.addDeviceEventListener(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_removeDeviceEventListener:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _result = this.removeDeviceEventListener(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_addMetadataListener:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _result = this.addMetadataListener(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_removeMetadataListener:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _result = this.removeMetadataListener(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_getSupportedEvents:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
java.util.List<com.plantronics.headsetdataservice.io.DeviceEventType> _result = this.getSupportedEvents(_arg0);
reply.writeNoException();
reply.writeTypedList(_result);
return true;
}
case TRANSACTION_getSupportedSettings:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
java.util.List<com.plantronics.headsetdataservice.io.DeviceSettingType> _result = this.getSupportedSettings(_arg0);
reply.writeNoException();
reply.writeTypedList(_result);
return true;
}
case TRANSACTION_getSupportedCommands:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
java.util.List<com.plantronics.headsetdataservice.io.DeviceCommandType> _result = this.getSupportedCommands(_arg0);
reply.writeNoException();
reply.writeTypedList(_result);
return true;
}
case TRANSACTION_discoverHeadsetDataServiceDevices:
{
data.enforceInterface(DESCRIPTOR);
int _result = this.discoverHeadsetDataServiceDevices();
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_getConnectedBladeRunnerBluetoothDevice:
{
data.enforceInterface(DESCRIPTOR);
int _result = this.getConnectedBladeRunnerBluetoothDevice();
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_newDevice:
{
data.enforceInterface(DESCRIPTOR);
java.lang.String _arg0;
_arg0 = data.readString();
int _result = this.newDevice(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_newRemoteDevice:
{
data.enforceInterface(DESCRIPTOR);
java.lang.String _arg0;
_arg0 = data.readString();
int _arg1;
_arg1 = data.readInt();
com.plantronics.headsetdataservice.io.HeadsetDataDevice _result = this.newRemoteDevice(_arg0, _arg1);
reply.writeNoException();
if ((_result!=null)) {
reply.writeInt(1);
_result.writeToParcel(reply, android.os.Parcelable.PARCELABLE_WRITE_RETURN_VALUE);
}
else {
reply.writeInt(0);
}
return true;
}
case TRANSACTION_open:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _result = this.open(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_getConnectedPorts:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
java.util.List<com.plantronics.headsetdataservice.io.RemotePort> _result = this.getConnectedPorts(_arg0);
reply.writeNoException();
reply.writeTypedList(_result);
return true;
}
case TRANSACTION_getSettingType:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _arg1;
_arg1 = data.readInt();
com.plantronics.headsetdataservice.io.DeviceSettingType _result = this.getSettingType(_arg0, _arg1);
reply.writeNoException();
if ((_result!=null)) {
reply.writeInt(1);
_result.writeToParcel(reply, android.os.Parcelable.PARCELABLE_WRITE_RETURN_VALUE);
}
else {
reply.writeInt(0);
}
return true;
}
case TRANSACTION_getSetting:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
com.plantronics.headsetdataservice.io.DeviceSettingType _arg1;
if ((0!=data.readInt())) {
_arg1 = com.plantronics.headsetdataservice.io.DeviceSettingType.CREATOR.createFromParcel(data);
}
else {
_arg1 = null;
}
com.plantronics.headsetdataservice.io.DeviceSetting _result = this.getSetting(_arg0, _arg1);
reply.writeNoException();
if ((_result!=null)) {
reply.writeInt(1);
_result.writeToParcel(reply, android.os.Parcelable.PARCELABLE_WRITE_RETURN_VALUE);
}
else {
reply.writeInt(0);
}
return true;
}
case TRANSACTION_fetch:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
com.plantronics.headsetdataservice.io.DeviceSetting _arg1;
if ((0!=data.readInt())) {
_arg1 = com.plantronics.headsetdataservice.io.DeviceSetting.CREATOR.createFromParcel(data);
}
else {
_arg1 = null;
}
com.plantronics.headsetdataservice.io.RemoteResult _arg2;
if ((0!=data.readInt())) {
_arg2 = com.plantronics.headsetdataservice.io.RemoteResult.CREATOR.createFromParcel(data);
}
else {
_arg2 = null;
}
int _result = this.fetch(_arg0, _arg1, _arg2);
reply.writeNoException();
reply.writeInt(_result);
if ((_arg1!=null)) {
reply.writeInt(1);
_arg1.writeToParcel(reply, android.os.Parcelable.PARCELABLE_WRITE_RETURN_VALUE);
}
else {
reply.writeInt(0);
}
if ((_arg2!=null)) {
reply.writeInt(1);
_arg2.writeToParcel(reply, android.os.Parcelable.PARCELABLE_WRITE_RETURN_VALUE);
}
else {
reply.writeInt(0);
}
return true;
}
case TRANSACTION_getCommandType:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _arg1;
_arg1 = data.readInt();
com.plantronics.headsetdataservice.io.DeviceCommandType _result = this.getCommandType(_arg0, _arg1);
reply.writeNoException();
if ((_result!=null)) {
reply.writeInt(1);
_result.writeToParcel(reply, android.os.Parcelable.PARCELABLE_WRITE_RETURN_VALUE);
}
else {
reply.writeInt(0);
}
return true;
}
case TRANSACTION_getCommand:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
com.plantronics.headsetdataservice.io.DeviceCommandType _arg1;
if ((0!=data.readInt())) {
_arg1 = com.plantronics.headsetdataservice.io.DeviceCommandType.CREATOR.createFromParcel(data);
}
else {
_arg1 = null;
}
com.plantronics.headsetdataservice.io.DeviceCommand _result = this.getCommand(_arg0, _arg1);
reply.writeNoException();
if ((_result!=null)) {
reply.writeInt(1);
_result.writeToParcel(reply, android.os.Parcelable.PARCELABLE_WRITE_RETURN_VALUE);
}
else {
reply.writeInt(0);
}
return true;
}
case TRANSACTION_perform:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
com.plantronics.headsetdataservice.io.DeviceCommand _arg1;
if ((0!=data.readInt())) {
_arg1 = com.plantronics.headsetdataservice.io.DeviceCommand.CREATOR.createFromParcel(data);
}
else {
_arg1 = null;
}
com.plantronics.headsetdataservice.io.RemoteResult _arg2;
if ((0!=data.readInt())) {
_arg2 = com.plantronics.headsetdataservice.io.RemoteResult.CREATOR.createFromParcel(data);
}
else {
_arg2 = null;
}
int _result = this.perform(_arg0, _arg1, _arg2);
reply.writeNoException();
reply.writeInt(_result);
if ((_arg2!=null)) {
reply.writeInt(1);
_arg2.writeToParcel(reply, android.os.Parcelable.PARCELABLE_WRITE_RETURN_VALUE);
}
else {
reply.writeInt(0);
}
return true;
}
case TRANSACTION_close:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
this.close(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_isOpen:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _result = this.isOpen(_arg0);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_addRemotePort:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _arg1;
_arg1 = data.readInt();
int _result = this.addRemotePort(_arg0, _arg1);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_removeRemotePort:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.io.HeadsetDataDevice _arg0;
if ((0!=data.readInt())) {
_arg0 = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(data);
}
else {
_arg0 = null;
}
int _arg1;
_arg1 = data.readInt();
int _result = this.removeRemotePort(_arg0, _arg1);
reply.writeNoException();
reply.writeInt(_result);
return true;
}
case TRANSACTION_registerOpenCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackOpen _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackOpen.Stub.asInterface(data.readStrongBinder());
this.registerOpenCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_registerEventsCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackEvents _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackEvents.Stub.asInterface(data.readStrongBinder());
this.registerEventsCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_registerSessionCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession.Stub.asInterface(data.readStrongBinder());
this.registerSessionCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_registerMetadataCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata.Stub.asInterface(data.readStrongBinder());
this.registerMetadataCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_registerDiscoveryCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackDiscovery _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackDiscovery.Stub.asInterface(data.readStrongBinder());
this.registerDiscoveryCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_registerBluetoothConnectionCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection.Stub.asInterface(data.readStrongBinder());
this.registerBluetoothConnectionCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_unregisterOpenCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackOpen _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackOpen.Stub.asInterface(data.readStrongBinder());
this.unregisterOpenCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_unregisterEventsCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackEvents _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackEvents.Stub.asInterface(data.readStrongBinder());
this.unregisterEventsCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_unregisterSessionCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession.Stub.asInterface(data.readStrongBinder());
this.unregisterSessionCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_unregisterMetadataCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata.Stub.asInterface(data.readStrongBinder());
this.unregisterMetadataCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_unregisterDiscoveryCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackDiscovery _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackDiscovery.Stub.asInterface(data.readStrongBinder());
this.unregisterDiscoveryCallback(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_unregisterBluetoothConnectionCallback:
{
data.enforceInterface(DESCRIPTOR);
com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection _arg0;
_arg0 = com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection.Stub.asInterface(data.readStrongBinder());
this.unregisterBluetoothConnectionCallback(_arg0);
reply.writeNoException();
return true;
}
}
return super.onTransact(code, data, reply, flags);
}
private static class Proxy implements com.plantronics.headsetdataservice.IHeadsetDataService
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
//void registerExceptionSignatures(in String bdaddr, in int id);
//void registerSettingSignatures(in String bdaddr, in int id);
//void registerEventSignatures(in String bdaddr, in int id);
//Device Registration  APIs

@Override public void register(com.plantronics.headsetdataservice.Registration registration) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((registration!=null)) {
_data.writeInt(1);
registration.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_register, _data, _reply, 0);
_reply.readException();
if ((0!=_reply.readInt())) {
registration.readFromParcel(_reply);
}
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void unregister(java.lang.String registrationName) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeString(registrationName);
mRemote.transact(Stub.TRANSACTION_unregister, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
// API to get the version of the interface

@Override public int geApiVersion() throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
mRemote.transact(Stub.TRANSACTION_geApiVersion, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
//APIs added for SQA testing; remove them from the final product

@Override public void enableCaching() throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
mRemote.transact(Stub.TRANSACTION_enableCaching, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void disableCaching() throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
mRemote.transact(Stub.TRANSACTION_disableCaching, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
//APIs added to enable disable and query debug setting

@Override public void enableDebug() throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
mRemote.transact(Stub.TRANSACTION_enableDebug, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void disableDebug() throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
mRemote.transact(Stub.TRANSACTION_disableDebug, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public int isEnableDebug() throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
mRemote.transact(Stub.TRANSACTION_isEnableDebug, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int addDeviceOpenListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_addDeviceOpenListener, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int removeDeviceOpenListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_removeDeviceOpenListener, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int addDeviceSessionListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_addDeviceSessionListener, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int removeDeviceSessionListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_removeDeviceSessionListener, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int addDeviceEventListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_addDeviceEventListener, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int removeDeviceEventListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_removeDeviceEventListener, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int addMetadataListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_addMetadataListener, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int removeMetadataListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_removeMetadataListener, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public java.util.List<com.plantronics.headsetdataservice.io.DeviceEventType> getSupportedEvents(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
java.util.List<com.plantronics.headsetdataservice.io.DeviceEventType> _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_getSupportedEvents, _data, _reply, 0);
_reply.readException();
_result = _reply.createTypedArrayList(com.plantronics.headsetdataservice.io.DeviceEventType.CREATOR);
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public java.util.List<com.plantronics.headsetdataservice.io.DeviceSettingType> getSupportedSettings(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
java.util.List<com.plantronics.headsetdataservice.io.DeviceSettingType> _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_getSupportedSettings, _data, _reply, 0);
_reply.readException();
_result = _reply.createTypedArrayList(com.plantronics.headsetdataservice.io.DeviceSettingType.CREATOR);
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public java.util.List<com.plantronics.headsetdataservice.io.DeviceCommandType> getSupportedCommands(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
java.util.List<com.plantronics.headsetdataservice.io.DeviceCommandType> _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_getSupportedCommands, _data, _reply, 0);
_reply.readException();
_result = _reply.createTypedArrayList(com.plantronics.headsetdataservice.io.DeviceCommandType.CREATOR);
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
/**
    * API to call the Service to discover HeadsetData protocol supporting headset devices
    */
@Override public int discoverHeadsetDataServiceDevices() throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
mRemote.transact(Stub.TRANSACTION_discoverHeadsetDataServiceDevices, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
/**
    * API to call the Service to retrieve the HeadsetData protocol supporting connected headset device
    *
    */
@Override public int getConnectedBladeRunnerBluetoothDevice() throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
mRemote.transact(Stub.TRANSACTION_getConnectedBladeRunnerBluetoothDevice, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
/**
    * API called to create a placeholder object which supports HeadsetData API for the headset
    * @param bdaddr   String
    *                 bluetooth address of the headset
    * @return int : 0 success
    */
@Override public int newDevice(java.lang.String bdaddr) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeString(bdaddr);
mRemote.transact(Stub.TRANSACTION_newDevice, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public com.plantronics.headsetdataservice.io.HeadsetDataDevice newRemoteDevice(java.lang.String bdaddr, int port) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
com.plantronics.headsetdataservice.io.HeadsetDataDevice _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeString(bdaddr);
_data.writeInt(port);
mRemote.transact(Stub.TRANSACTION_newRemoteDevice, _data, _reply, 0);
_reply.readException();
if ((0!=_reply.readInt())) {
_result = com.plantronics.headsetdataservice.io.HeadsetDataDevice.CREATOR.createFromParcel(_reply);
}
else {
_result = null;
}
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int open(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_open, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public java.util.List<com.plantronics.headsetdataservice.io.RemotePort> getConnectedPorts(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
java.util.List<com.plantronics.headsetdataservice.io.RemotePort> _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_getConnectedPorts, _data, _reply, 0);
_reply.readException();
_result = _reply.createTypedArrayList(com.plantronics.headsetdataservice.io.RemotePort.CREATOR);
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public com.plantronics.headsetdataservice.io.DeviceSettingType getSettingType(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, int id) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
com.plantronics.headsetdataservice.io.DeviceSettingType _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
_data.writeInt(id);
mRemote.transact(Stub.TRANSACTION_getSettingType, _data, _reply, 0);
_reply.readException();
if ((0!=_reply.readInt())) {
_result = com.plantronics.headsetdataservice.io.DeviceSettingType.CREATOR.createFromParcel(_reply);
}
else {
_result = null;
}
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public com.plantronics.headsetdataservice.io.DeviceSetting getSetting(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, com.plantronics.headsetdataservice.io.DeviceSettingType dst) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
com.plantronics.headsetdataservice.io.DeviceSetting _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
if ((dst!=null)) {
_data.writeInt(1);
dst.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_getSetting, _data, _reply, 0);
_reply.readException();
if ((0!=_reply.readInt())) {
_result = com.plantronics.headsetdataservice.io.DeviceSetting.CREATOR.createFromParcel(_reply);
}
else {
_result = null;
}
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int fetch(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, com.plantronics.headsetdataservice.io.DeviceSetting setting, com.plantronics.headsetdataservice.io.RemoteResult result) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
if ((setting!=null)) {
_data.writeInt(1);
setting.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
if ((result!=null)) {
_data.writeInt(1);
result.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_fetch, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
if ((0!=_reply.readInt())) {
setting.readFromParcel(_reply);
}
if ((0!=_reply.readInt())) {
result.readFromParcel(_reply);
}
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public com.plantronics.headsetdataservice.io.DeviceCommandType getCommandType(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, int id) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
com.plantronics.headsetdataservice.io.DeviceCommandType _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
_data.writeInt(id);
mRemote.transact(Stub.TRANSACTION_getCommandType, _data, _reply, 0);
_reply.readException();
if ((0!=_reply.readInt())) {
_result = com.plantronics.headsetdataservice.io.DeviceCommandType.CREATOR.createFromParcel(_reply);
}
else {
_result = null;
}
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public com.plantronics.headsetdataservice.io.DeviceCommand getCommand(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, com.plantronics.headsetdataservice.io.DeviceCommandType dct) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
com.plantronics.headsetdataservice.io.DeviceCommand _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
if ((dct!=null)) {
_data.writeInt(1);
dct.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_getCommand, _data, _reply, 0);
_reply.readException();
if ((0!=_reply.readInt())) {
_result = com.plantronics.headsetdataservice.io.DeviceCommand.CREATOR.createFromParcel(_reply);
}
else {
_result = null;
}
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int perform(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, com.plantronics.headsetdataservice.io.DeviceCommand command, com.plantronics.headsetdataservice.io.RemoteResult result) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
if ((command!=null)) {
_data.writeInt(1);
command.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
if ((result!=null)) {
_data.writeInt(1);
result.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_perform, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
if ((0!=_reply.readInt())) {
result.readFromParcel(_reply);
}
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
/**
    * API to close the HeadsetData Service connection to the headset
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    */
@Override public void close(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_close, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
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
@Override public int isOpen(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
mRemote.transact(Stub.TRANSACTION_isOpen, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int addRemotePort(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, int port) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
_data.writeInt(port);
mRemote.transact(Stub.TRANSACTION_addRemotePort, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
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
@Override public int removeRemotePort(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, int port) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
int _result;
try {
_data.writeInterfaceToken(DESCRIPTOR);
if ((hdDevice!=null)) {
_data.writeInt(1);
hdDevice.writeToParcel(_data, 0);
}
else {
_data.writeInt(0);
}
_data.writeInt(port);
mRemote.transact(Stub.TRANSACTION_removeRemotePort, _data, _reply, 0);
_reply.readException();
_result = _reply.readInt();
}
finally {
_reply.recycle();
_data.recycle();
}
return _result;
}
//
// callbacks
//
/**
    * This inerface allows the service to call back to its clients.
    * This shows how to do so, by registering a callback interface with
    * the service.
    */
@Override public void registerOpenCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackOpen cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_registerOpenCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void registerEventsCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackEvents cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_registerEventsCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void registerSessionCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_registerSessionCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void registerMetadataCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_registerMetadataCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void registerDiscoveryCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackDiscovery cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_registerDiscoveryCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void registerBluetoothConnectionCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_registerBluetoothConnectionCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
/**
     * Remove a previously registered callback interface.
     */
@Override public void unregisterOpenCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackOpen cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_unregisterOpenCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void unregisterEventsCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackEvents cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_unregisterEventsCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void unregisterSessionCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_unregisterSessionCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void unregisterMetadataCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_unregisterMetadataCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void unregisterDiscoveryCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackDiscovery cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_unregisterDiscoveryCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
@Override public void unregisterBluetoothConnectionCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection cb) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeStrongBinder((((cb!=null))?(cb.asBinder()):(null)));
mRemote.transact(Stub.TRANSACTION_unregisterBluetoothConnectionCallback, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
}
static final int TRANSACTION_register = (android.os.IBinder.FIRST_CALL_TRANSACTION + 0);
static final int TRANSACTION_unregister = (android.os.IBinder.FIRST_CALL_TRANSACTION + 1);
static final int TRANSACTION_geApiVersion = (android.os.IBinder.FIRST_CALL_TRANSACTION + 2);
static final int TRANSACTION_enableCaching = (android.os.IBinder.FIRST_CALL_TRANSACTION + 3);
static final int TRANSACTION_disableCaching = (android.os.IBinder.FIRST_CALL_TRANSACTION + 4);
static final int TRANSACTION_enableDebug = (android.os.IBinder.FIRST_CALL_TRANSACTION + 5);
static final int TRANSACTION_disableDebug = (android.os.IBinder.FIRST_CALL_TRANSACTION + 6);
static final int TRANSACTION_isEnableDebug = (android.os.IBinder.FIRST_CALL_TRANSACTION + 7);
static final int TRANSACTION_addDeviceOpenListener = (android.os.IBinder.FIRST_CALL_TRANSACTION + 8);
static final int TRANSACTION_removeDeviceOpenListener = (android.os.IBinder.FIRST_CALL_TRANSACTION + 9);
static final int TRANSACTION_addDeviceSessionListener = (android.os.IBinder.FIRST_CALL_TRANSACTION + 10);
static final int TRANSACTION_removeDeviceSessionListener = (android.os.IBinder.FIRST_CALL_TRANSACTION + 11);
static final int TRANSACTION_addDeviceEventListener = (android.os.IBinder.FIRST_CALL_TRANSACTION + 12);
static final int TRANSACTION_removeDeviceEventListener = (android.os.IBinder.FIRST_CALL_TRANSACTION + 13);
static final int TRANSACTION_addMetadataListener = (android.os.IBinder.FIRST_CALL_TRANSACTION + 14);
static final int TRANSACTION_removeMetadataListener = (android.os.IBinder.FIRST_CALL_TRANSACTION + 15);
static final int TRANSACTION_getSupportedEvents = (android.os.IBinder.FIRST_CALL_TRANSACTION + 16);
static final int TRANSACTION_getSupportedSettings = (android.os.IBinder.FIRST_CALL_TRANSACTION + 17);
static final int TRANSACTION_getSupportedCommands = (android.os.IBinder.FIRST_CALL_TRANSACTION + 18);
static final int TRANSACTION_discoverHeadsetDataServiceDevices = (android.os.IBinder.FIRST_CALL_TRANSACTION + 19);
static final int TRANSACTION_getConnectedBladeRunnerBluetoothDevice = (android.os.IBinder.FIRST_CALL_TRANSACTION + 20);
static final int TRANSACTION_newDevice = (android.os.IBinder.FIRST_CALL_TRANSACTION + 21);
static final int TRANSACTION_newRemoteDevice = (android.os.IBinder.FIRST_CALL_TRANSACTION + 22);
static final int TRANSACTION_open = (android.os.IBinder.FIRST_CALL_TRANSACTION + 23);
static final int TRANSACTION_getConnectedPorts = (android.os.IBinder.FIRST_CALL_TRANSACTION + 24);
static final int TRANSACTION_getSettingType = (android.os.IBinder.FIRST_CALL_TRANSACTION + 25);
static final int TRANSACTION_getSetting = (android.os.IBinder.FIRST_CALL_TRANSACTION + 26);
static final int TRANSACTION_fetch = (android.os.IBinder.FIRST_CALL_TRANSACTION + 27);
static final int TRANSACTION_getCommandType = (android.os.IBinder.FIRST_CALL_TRANSACTION + 28);
static final int TRANSACTION_getCommand = (android.os.IBinder.FIRST_CALL_TRANSACTION + 29);
static final int TRANSACTION_perform = (android.os.IBinder.FIRST_CALL_TRANSACTION + 30);
static final int TRANSACTION_close = (android.os.IBinder.FIRST_CALL_TRANSACTION + 31);
static final int TRANSACTION_isOpen = (android.os.IBinder.FIRST_CALL_TRANSACTION + 32);
static final int TRANSACTION_addRemotePort = (android.os.IBinder.FIRST_CALL_TRANSACTION + 33);
static final int TRANSACTION_removeRemotePort = (android.os.IBinder.FIRST_CALL_TRANSACTION + 34);
static final int TRANSACTION_registerOpenCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 35);
static final int TRANSACTION_registerEventsCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 36);
static final int TRANSACTION_registerSessionCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 37);
static final int TRANSACTION_registerMetadataCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 38);
static final int TRANSACTION_registerDiscoveryCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 39);
static final int TRANSACTION_registerBluetoothConnectionCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 40);
static final int TRANSACTION_unregisterOpenCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 41);
static final int TRANSACTION_unregisterEventsCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 42);
static final int TRANSACTION_unregisterSessionCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 43);
static final int TRANSACTION_unregisterMetadataCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 44);
static final int TRANSACTION_unregisterDiscoveryCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 45);
static final int TRANSACTION_unregisterBluetoothConnectionCallback = (android.os.IBinder.FIRST_CALL_TRANSACTION + 46);
}
//void registerExceptionSignatures(in String bdaddr, in int id);
//void registerSettingSignatures(in String bdaddr, in int id);
//void registerEventSignatures(in String bdaddr, in int id);
//Device Registration  APIs

public void register(com.plantronics.headsetdataservice.Registration registration) throws android.os.RemoteException;
public void unregister(java.lang.String registrationName) throws android.os.RemoteException;
// API to get the version of the interface

public int geApiVersion() throws android.os.RemoteException;
//APIs added for SQA testing; remove them from the final product

public void enableCaching() throws android.os.RemoteException;
public void disableCaching() throws android.os.RemoteException;
//APIs added to enable disable and query debug setting

public void enableDebug() throws android.os.RemoteException;
public void disableDebug() throws android.os.RemoteException;
public int isEnableDebug() throws android.os.RemoteException;
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
public int addDeviceOpenListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public int removeDeviceOpenListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public int addDeviceSessionListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public int removeDeviceSessionListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public int addDeviceEventListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public int removeDeviceEventListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public int addMetadataListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public int removeMetadataListener(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public java.util.List<com.plantronics.headsetdataservice.io.DeviceEventType> getSupportedEvents(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public java.util.List<com.plantronics.headsetdataservice.io.DeviceSettingType> getSupportedSettings(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public java.util.List<com.plantronics.headsetdataservice.io.DeviceCommandType> getSupportedCommands(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
/**
    * API to call the Service to discover HeadsetData protocol supporting headset devices
    */
public int discoverHeadsetDataServiceDevices() throws android.os.RemoteException;
/**
    * API to call the Service to retrieve the HeadsetData protocol supporting connected headset device
    *
    */
public int getConnectedBladeRunnerBluetoothDevice() throws android.os.RemoteException;
/**
    * API called to create a placeholder object which supports HeadsetData API for the headset
    * @param bdaddr   String
    *                 bluetooth address of the headset
    * @return int : 0 success
    */
public int newDevice(java.lang.String bdaddr) throws android.os.RemoteException;
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
public com.plantronics.headsetdataservice.io.HeadsetDataDevice newRemoteDevice(java.lang.String bdaddr, int port) throws android.os.RemoteException;
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
public int open(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public java.util.List<com.plantronics.headsetdataservice.io.RemotePort> getConnectedPorts(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public com.plantronics.headsetdataservice.io.DeviceSettingType getSettingType(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, int id) throws android.os.RemoteException;
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
public com.plantronics.headsetdataservice.io.DeviceSetting getSetting(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, com.plantronics.headsetdataservice.io.DeviceSettingType dst) throws android.os.RemoteException;
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
public int fetch(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, com.plantronics.headsetdataservice.io.DeviceSetting setting, com.plantronics.headsetdataservice.io.RemoteResult result) throws android.os.RemoteException;
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
public com.plantronics.headsetdataservice.io.DeviceCommandType getCommandType(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, int id) throws android.os.RemoteException;
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
public com.plantronics.headsetdataservice.io.DeviceCommand getCommand(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, com.plantronics.headsetdataservice.io.DeviceCommandType dct) throws android.os.RemoteException;
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
public int perform(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, com.plantronics.headsetdataservice.io.DeviceCommand command, com.plantronics.headsetdataservice.io.RemoteResult result) throws android.os.RemoteException;
/**
    * API to close the HeadsetData Service connection to the headset
    * @param hdDevice   HeadsetDataDevice
    *          HeadsetDataDevice identify the bluetooth device as local (this phone) or remote device
    *          connected to the headset.
    *          For both local and remote devices, HeadsetDataDevice stores the local device's bluetooth address.
    *          For local device, the port number is always zero and for remote device its the HeadsetDataDevice
    *          protocol port number at which the remote device is connected to the headset.
    */
public void close(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public int isOpen(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice) throws android.os.RemoteException;
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
public int addRemotePort(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, int port) throws android.os.RemoteException;
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
public int removeRemotePort(com.plantronics.headsetdataservice.io.HeadsetDataDevice hdDevice, int port) throws android.os.RemoteException;
//
// callbacks
//
/**
    * This inerface allows the service to call back to its clients.
    * This shows how to do so, by registering a callback interface with
    * the service.
    */
public void registerOpenCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackOpen cb) throws android.os.RemoteException;
public void registerEventsCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackEvents cb) throws android.os.RemoteException;
public void registerSessionCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession cb) throws android.os.RemoteException;
public void registerMetadataCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata cb) throws android.os.RemoteException;
public void registerDiscoveryCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackDiscovery cb) throws android.os.RemoteException;
public void registerBluetoothConnectionCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection cb) throws android.os.RemoteException;
/**
     * Remove a previously registered callback interface.
     */
public void unregisterOpenCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackOpen cb) throws android.os.RemoteException;
public void unregisterEventsCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackEvents cb) throws android.os.RemoteException;
public void unregisterSessionCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackSession cb) throws android.os.RemoteException;
public void unregisterMetadataCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackMetadata cb) throws android.os.RemoteException;
public void unregisterDiscoveryCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackDiscovery cb) throws android.os.RemoteException;
public void unregisterBluetoothConnectionCallback(com.plantronics.headsetdataservice.IHeadsetDataServiceCallbackBluetoothConnection cb) throws android.os.RemoteException;
}
