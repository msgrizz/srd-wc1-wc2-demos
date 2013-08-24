/*
 * This file is auto-generated.  DO NOT MODIFY.
 * Original file: /Users/mdavis/plantronics-innovation/core-team/DX650 Screen Lock/src/com/plantronics/DX650ScreenLock/PlantronicsXEventListener.aidl
 */
package com.plantronics.DX650ScreenLock;
public interface PlantronicsXEventListener extends android.os.IInterface
{
/** Local-side IPC implementation stub class. */
public static abstract class Stub extends android.os.Binder implements com.plantronics.DX650ScreenLock.PlantronicsXEventListener
{
private static final java.lang.String DESCRIPTOR = "com.plantronics.DX650ScreenLock.PlantronicsXEventListener";
/** Construct the stub at attach it to the interface. */
public Stub()
{
this.attachInterface(this, DESCRIPTOR);
}
/**
 * Cast an IBinder object into an com.plantronics.DX650ScreenLock.PlantronicsXEventListener interface,
 * generating a proxy if needed.
 */
public static com.plantronics.DX650ScreenLock.PlantronicsXEventListener asInterface(android.os.IBinder obj)
{
if ((obj==null)) {
return null;
}
android.os.IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
if (((iin!=null)&&(iin instanceof com.plantronics.DX650ScreenLock.PlantronicsXEventListener))) {
return ((com.plantronics.DX650ScreenLock.PlantronicsXEventListener)iin);
}
return new com.plantronics.DX650ScreenLock.PlantronicsXEventListener.Stub.Proxy(obj);
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
}
return super.onTransact(code, data, reply, flags);
}
private static class Proxy implements com.plantronics.DX650ScreenLock.PlantronicsXEventListener
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
}
}
}
