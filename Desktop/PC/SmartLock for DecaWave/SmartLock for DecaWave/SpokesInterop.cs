using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Interop.Plantronics;
using System.Runtime.InteropServices;
using System.Reflection;
using System.Threading;
using Plantronics.Device.Common;

namespace Plantronics.UC.SmartLockID
{
        // LC struct to hold info on device capabilities
        public struct SpokesDeviceCaps
        {
            public bool HasProximity;
            public bool HasCallerId;
            public bool HasDocking;
            public bool HasWearingSensor;
            public bool IsWireless;
            // Constructor:
            public SpokesDeviceCaps(bool HasProximity, bool HasCallerId, bool HasDocking, bool HasWearingSensor, bool IsWireless)
            {
                this.HasProximity = HasProximity;
                this.HasCallerId = HasCallerId;
                this.HasDocking = HasDocking;
                this.HasWearingSensor = HasWearingSensor;
                this.IsWireless = IsWireless;
            }
        }

        class SpokesInterop : SmartCRMConnector
        {
            public const int HWND_BROADCAST = 0xffff;
            public static readonly int WM_SHOWME = RegisterWindowMessage("WM_SHOWME");

            [DllImport("user32.dll")]
            public static extern int PostMessage(IntPtr hWnd, int msg, int wParam, int lParam);

            [DllImport("user32")]
            public static extern int RegisterWindowMessage(string message);

            [DllImport("user32.dll")]
            static extern bool LockWorkStation();

            public static MobileCallForm m_MobileCallWnd = null;
            public static SpokesInterop m_spokesInterop;
        
            #region Spokes interfaces definitions
            static ISessionCOMManager m_sessionComManager = null;
            static IComSession m_comSession = null;
            public static Interop.Plantronics.IDevice m_activeDevice = null;
            static ISessionCOMManagerEvents_Event m_sessionManagerEvents;
            static ICOMCallEvents_Event m_sessionEvents;
            static IDeviceCOMEvents_Event m_deviceComEvents;
            static IDeviceListenerCOMEvents_Event m_deviceListenerEvents;
            static IATDCommand m_atdCommand;
            static Interop.Plantronics.IHostCommandExt m_hostCommandExt;
            static DelphiHostCommandExt m_delphiHostCommandExt;
            public static string m_devicename = "";
            #endregion

            public SpokesInterop()
            {
                AppName = "Spokes";

                starterThread = new Thread(this.ConnectAction);
            }

            public bool InitComObjects()
            {
                m_MobileCallWnd.DeviceCapabilities = 
                    new SpokesDeviceCaps(false, false, false, false, false); // we don't yet know what the capabilities are
                bool success = false;
                try
                {
                    ////////////////////////////////////////////////////////////////////////////////////////
                    // create session manager, and attach to session manager events
                    m_sessionComManager = new SessionComManagerClass();
                    m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Session Manager created");
                    m_sessionManagerEvents = m_sessionComManager as ISessionCOMManagerEvents_Event;
                    if (m_sessionManagerEvents != null)
                    {
                        m_sessionManagerEvents.CallStateChanged += m_sessionComManager_CallStateChanged;
                        m_sessionManagerEvents.DeviceStateChanged += m_sessionComManager_DeviceStateChanged;
                        m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Attached to session manager events");
                    }
                    else
                        m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Error: Unable to attach to session manager events");

                    ////////////////////////////////////////////////////////////////////////////////////////
                    // register session to spokes
                    m_comSession = m_sessionComManager.Register("COM Session");
                    if (m_comSession != null)
                    {
                        // attach to session call events
                        m_sessionEvents = m_comSession.CallEvents as ICOMCallEvents_Event;
                        if (m_sessionEvents != null)
                        {
                            m_sessionEvents.CallRequested += m_sessionEvents_CallRequested;
                            m_sessionEvents.CallStateChanged += m_sessionEvents_CallStateChanged;

                        }
                        else
                            m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Error: Unable to attach to session call events");

                        ////////////////////////////////////////////////////////////////////////////////////////
                        // Attach to active device and print all device information
                        // and registers for proximity (if supported by device)
                        AttachDevice();
                        success = true;
                    }
                }
                catch (NullReferenceException nre)
                {
                    m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": ERROR: NullReferenceException was caught trying to init Spokes connection:\r\n"+nre.ToString());
                    success = false;
                }
                catch (System.Exception e)
                {
                    m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": ERROR: Exception was caught trying to init Spokes connection:\r\n" + e.ToString());
                    success = false;
                }
                return success;
            }// Init()
                



            // release all resources
            public void ClearComObjects()
            {
                DetachDevice();

                if (m_comSession != null)
                {
                    if (m_sessionEvents != null)
                    {
                        // release session events
                        m_sessionEvents.CallRequested -= m_sessionEvents_CallRequested;
                        m_sessionEvents.CallStateChanged -= m_sessionEvents_CallStateChanged;
                        Marshal.ReleaseComObject(m_sessionEvents);
                        m_sessionEvents = null;
                    }
                    // unregister session
                    if (m_sessionEvents != null)
                    {
                        m_sessionManagerEvents.DeviceStateChanged -= m_sessionComManager_DeviceStateChanged;
                    }
                    m_sessionComManager.UnRegister(m_comSession);
                    Marshal.ReleaseComObject(m_comSession);
                    m_comSession = null;
                }
                if (m_sessionComManager != null)
                {
                    Marshal.ReleaseComObject(m_sessionComManager);
                    m_sessionComManager = null;
                }
            }

            #region Print Session and Device events to console
            // print session manager events
            static void m_sessionComManager_DeviceStateChanged(object sender, _DeviceStateEventArgs e)
            {
               
                // if our "Active device" was unplugged, detach from it and attach to new one
                if (e.State == Interop.Plantronics.DeviceState.DeviceState_Removed && m_activeDevice != null && string.Compare(e.DevicePath, m_activeDevice.DevicePath, true) == 0)
                {
                    DetachDevice();
                    AttachDevice();
                   
                }
                else if (e.State == Interop.Plantronics.DeviceState.DeviceState_Added && m_activeDevice == null)
                {
                    // if device is plugged, and we don't have "Active device", just attach to it
                    AttachDevice();
                   
                }
            }

            // print session manager events
            static void m_sessionComManager_CallStateChanged(object sender, _CallStateEventArgs e)
            {
                // LC I don't think this is needed...
                //string id = e.CallId != null ? e.CallId.Id.ToString() : "none";
                //m_MobileCallWnd.m_sCallerID = GetCallerID();

                m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": call state event = " + e.ToString());

                // LC New, if a call is in progress we should:
                // 1. prevent any locking and 2. stop any lock countdown!
                switch (e.Action)
                {
                    case CallState.CallState_AcceptCall:
                    case CallState.CallState_CallInProgress:
                    case CallState.CallState_CallRinging:
                    case CallState.CallState_HoldCall:
                    case CallState.CallState_MobileCallInProgress:
                    case CallState.CallState_MobileCallRinging:
                    case CallState.CallState_Resumecall:
                    case CallState.CallState_TransferToHeadSet:
                    case CallState.CallState_TransferToSpeaker:
                        // all other actions indicate calling activity
                        // therefore disable locking! (and stop any timer)
                        m_MobileCallWnd.SetLockingEnabled(false);
                        m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Calling activity detected! Disabled locking and stopped any running lock timer. " + e.ToString());
                        break;
                    case CallState.CallState_CallEnded:
                    case CallState.CallState_CallIdle:
                    case CallState.CallState_MobileCallEnded:
                    case CallState.CallState_RejectCall:
                    case CallState.CallState_TerminateCall:
                        // a call is ended or call idle
                        // therefore re-enable locking
                        m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Calling activity ended. Enabled locking. " + e.ToString());
                        m_MobileCallWnd.SetLockingEnabled(true);
                        break;
                    default:
                        // ignore other call state events
                        break;
                }
            }

            public static string GetCallerID()
            {
                string retval = "";
                if (m_atdCommand != null)
                {
                    try
                    {
                        retval = m_atdCommand.CallerID;
                    }
                    catch (System.Exception e)
                    {
                        m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": INFO: Exception occured getting mobile caller id\r\nException = " + e.ToString());
                    }
                }
                return retval;
            }

            // print session events
            static void m_sessionEvents_CallStateChanged(object sender, _CallStateEventArgs e)
            {
                string id = e.CallId != null ? e.CallId.Id.ToString() : "none";
               
            }
            // print session events
            static void m_sessionEvents_CallRequested(object sender, _CallRequestEventArgs e)
            {
                string contact = e.Contact != null ? e.Contact.Name : "none";
                 m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, string.Format("Session CallRequested event: Contact:({0})", contact));
            }
            // print device listner events
            static void m_deviceListenerEvents_Handler(object sender, _DeviceListenerEventArgs e)
            {
                switch (e.DeviceEventType)
                {
                    case Interop.Plantronics.DeviceEventType.DeviceEventType_ATDButtonPressed:
                        break;
                    case Interop.Plantronics.DeviceEventType.DeviceEventType_ATDStateChanged:
                        DeviceListener_ATDStateChanged(sender, e);
                        break;
                    case Interop.Plantronics.DeviceEventType.DeviceEventType_BaseButtonPressed:
                    case Interop.Plantronics.DeviceEventType.DeviceEventType_BaseStateChanged:
                    case Interop.Plantronics.DeviceEventType.DeviceEventType_HeadsetButtonPressed:
                    case Interop.Plantronics.DeviceEventType.DeviceEventType_HeadsetStateChanged:
                    default:                
                        break;
                }
            }

            static void m_deviceListenerEvents_HandlerMethods(object sender, _DeviceListenerEventArgs e)
            {
                if (m_MobileCallWnd == null) return; // LC, for safety. Have seen case where this occured at startup!

                m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Received Spokes Event: " + e.ToString());

                switch (e.DeviceEventType)
                {
                    case Interop.Plantronics.DeviceEventType.DeviceEventType_HeadsetStateChanged:
                    switch (e.HeadsetStateChange)
                    {
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_Don:
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_DON, 0, 0);
                            break;
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_Doff:
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_DOFF, 0, 0);
                            break;
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_Near:
                            
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_NEAR, 0, 0);
                            break;
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_Far:
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_FAR, 0, 0);
                            break;
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_ProximityDisabled:
                            // Note: intepret this event as that the mobile phone has gone out of Bluetooth
                            // range and is no longer paired to the headset.
                            // Lock the PC, but immediately re-enable proximity
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_PROXDISABLED, 0, 0);
                            RegisterForProximity(true);
                            break;
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_ProximityEnabled:
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_PROXENABLED, 0, 0);
                            break;
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_ProximityUnknown:
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_PROXUNKNOWN, 0, 0);
                            break;
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_InRange:
                            RegisterForProximity(true);
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_INRANGE, 0, 0);
                            break;
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_OutofRange:
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_OUTOFRANGE, 0, 0);
                            break;
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_Docked:
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_DOCK, 0, 0);
                            break;
                        case Interop.Plantronics.HeadsetStateChange.HeadsetStateChange_UnDocked:
                            PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_UNDOCK, 0, 0);
                            break;
                        default:
                            break;
                    }
                    break;
                    default:
                    break;
                }
                
            }
            //        #region DeviceListener events
            static void DeviceListener_ATDStateChanged(object sender, _DeviceListenerEventArgs e)
            {
                //HANDLE ATD State changes
                switch (e.ATDStateChange)
                {
                    case Interop.Plantronics.ATDStateChange.ATDStateChange_MobileInComing:
                        PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_INCOMING, 0, 0);
                        // m_contextIntelliWindow.SetProximity(e.State.ToString(), e.CallerID, DateTime.Now.TimeOfDay.ToString());
                        break;
                    case Interop.Plantronics.ATDStateChange.ATDStateChange_MobileOnCall:
                        PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_ONCALL, 0, 0);
                        break;
                    case Interop.Plantronics.ATDStateChange.ATDStateChange_MobileCallEnded:
                        PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_CALLENDED, 0, 0);
                        //m_contextIntelliWindow.MobileOnCall();
                        break;
                    case Interop.Plantronics.ATDStateChange.ATDStateChange_MobileCallerID:
                        PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_CALLERID, 0, 0);
                        //m_contextIntelliWindow.MobileOnCall();
                        break;
                    case Interop.Plantronics.ATDStateChange.ATDStateChange_MobileOutGoing:
                        break;
                    case Interop.Plantronics.ATDStateChange.ATDStateChange_PstnInComingCallRingOn:
                    //break;
                    case Interop.Plantronics.ATDStateChange.ATDStateChange_PstnInComingCallRingOff:
                        break;
                }
            }

            // print device events
            static void m_deviceComEvents_Handler(object sender, _DeviceEventArgs e)
            {
                 m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, string.Format("Device Event: Audio:{0} Buton:{1} Mute:{2} Usage:{3}", e.AudioState, e.ButtonPressed, e.Mute, e.Usage.ToString()));
            }
            #endregion
            // attach to device events
            static private void AttachDevice()
            {
                m_activeDevice = m_comSession.ActiveDevice;
                if (m_activeDevice != null)
                {
                    // LC assume minimum first set of device capabilities...
                    m_MobileCallWnd.DeviceCapabilities =
                        new SpokesDeviceCaps(false, false, true, true, true);

                    // LC have seen case where ProductName was empty but InternalName was not...
                    if (m_activeDevice.ProductName.Length > 0)
                    {
                        m_devicename = m_activeDevice.ProductName;
                    }
                    else if (m_activeDevice.InternalName.Length > 0)
                    {
                        m_devicename = m_activeDevice.InternalName;
                    }
                    else
                    {
                        m_devicename = "Could not determine device name";
                    }

                    m_MobileCallWnd.SetDeviceName(m_activeDevice.ProductName);
                    m_deviceComEvents = m_activeDevice.DeviceEvents as IDeviceCOMEvents_Event;
                    if (m_deviceComEvents != null)
                    {
                        // Attach to device events
                        m_deviceComEvents.ButtonPressed += m_deviceComEvents_Handler;
                        m_deviceComEvents.AudioStateChanged += m_deviceComEvents_Handler;
                        m_deviceComEvents.FlashPressed += m_deviceComEvents_Handler;
                        m_deviceComEvents.MuteStateChanged += m_deviceComEvents_Handler;
                        m_deviceComEvents.SmartPressed += m_deviceComEvents_Handler;
                        m_deviceComEvents.TalkPressed += m_deviceComEvents_Handler;
                         m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Attached to device events");
                    }
                    else
                    {
                        m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Error: unable to attach to device events");
                        return;
                    }

                    m_deviceListenerEvents = m_activeDevice.DeviceListener as IDeviceListenerCOMEvents_Event;
                    if (m_deviceListenerEvents != null)
                    {
                        // Attach to device listener events
                        m_deviceListenerEvents.ATDStateChanged += m_deviceListenerEvents_Handler;
                        m_deviceListenerEvents.BaseButtonPressed += m_deviceListenerEvents_Handler;
                        m_deviceListenerEvents.BaseStateChanged += m_deviceListenerEvents_Handler;
                        m_deviceListenerEvents.HeadsetButtonPressed += m_deviceListenerEvents_Handler;
                        m_deviceListenerEvents.HeadsetStateChanged += m_deviceListenerEvents_Handler;
                        m_deviceListenerEvents.HeadsetStateChanged += m_deviceListenerEvents_HandlerMethods;
                    }
                    else
                    {
                        m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Error: unable to attach to device listener events");
                        return;
                    }

                    m_atdCommand = m_activeDevice.HostCommand as IATDCommand;
                    if (m_atdCommand == null) m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Error: unable to obtain atd command interface");
                    m_hostCommandExt = m_activeDevice.HostCommand as Interop.Plantronics.IHostCommandExt;
                    if (m_hostCommandExt == null) m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Error: unable to obtain host command ext interface");

                    // test, grab a proxmity tweaker interface
                    GrabProximityTweakerInterface();

                    RegisterForProximity(true, 87, 9);

                    GetMobileCallStatus(); // are we on a call?

                    m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Attached to device");
                }

            }

            private static void GrabProximityTweakerInterface()
            {
                m_delphiHostCommandExt = null;
                try
                {
                    if (m_hostCommandExt != null && m_activeDevice != null)
                    {
                        m_delphiHostCommandExt = new DelphiHostCommandExt(null);
                    }
                }
                catch (Exception e)
                {
                    m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName() + ": INFO: unable to cast hostcommand to IHostCommandExt2 (for proximity threshold config).\r\n" + e.ToString());
                }
            }
            // detach from device events
            static void DetachDevice()
            {
                if (m_activeDevice != null)
                {
                    if (m_deviceComEvents != null)
                    {
                        // unregister device event handlers
                        m_deviceComEvents.ButtonPressed -= m_deviceComEvents_Handler;
                        m_deviceComEvents.AudioStateChanged -= m_deviceComEvents_Handler;
                        m_deviceComEvents.FlashPressed -= m_deviceComEvents_Handler;
                        m_deviceComEvents.MuteStateChanged -= m_deviceComEvents_Handler;
                        m_deviceComEvents.SmartPressed -= m_deviceComEvents_Handler;
                        m_deviceComEvents.TalkPressed -= m_deviceComEvents_Handler;

                        Marshal.ReleaseComObject(m_deviceComEvents);
                        m_deviceComEvents = null;
                    }
                    if (m_deviceListenerEvents != null)
                    {
                        // unregister device listener event handlers
                        m_deviceListenerEvents.ATDStateChanged -= m_deviceListenerEvents_Handler;
                        m_deviceListenerEvents.BaseButtonPressed -= m_deviceListenerEvents_Handler;
                        m_deviceListenerEvents.BaseStateChanged -= m_deviceListenerEvents_Handler;
                        m_deviceListenerEvents.HeadsetButtonPressed -= m_deviceListenerEvents_Handler;
                        m_deviceListenerEvents.HeadsetStateChanged -= m_deviceListenerEvents_Handler;
                        m_deviceListenerEvents.HeadsetStateChanged -= m_deviceListenerEvents_HandlerMethods;

                        RegisterForProximity(false);
                        Marshal.ReleaseComObject(m_deviceListenerEvents);
                        m_deviceListenerEvents = null;
                    }

                    Marshal.ReleaseComObject(m_activeDevice);
                    m_activeDevice = null;

                    m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Detached from device");

                    // LC Device was disconnected, disable lock options in options GUI
                    m_MobileCallWnd.DeviceCapabilities = new SpokesDeviceCaps(false, false, false, false, false); // no device = no capabilities!
                    m_devicename = "";
                    m_MobileCallWnd.SetDeviceName("");
                    m_MobileCallWnd.ClearDonNearFlags();

                    // LC Device was disconnected, clear down the GUI state...
                    PostMessage(m_MobileCallWnd.m_hWnd, (int)WM.MOBILE_CALLENDED, 0, 0);
                }
                m_devicename = "";
            }



            static public void RegisterForProximity(bool register, int nearthreshold = -1, int proximitydeadband = -1)
            {
                m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": About to register for proximity.");
                try
                {
                    if (m_hostCommandExt != null)
                    {
                        m_hostCommandExt.EnableProximity(register); // enable proximity reporting for device
                        if (register) m_hostCommandExt.GetProximity();    // request to receive asyncrounous near/far proximity event to HeadsetStateChanged event handler. (note: will return it once. To get continuous updates of proximity you would need a to call GetProximity() repeatedly, e.g. in a worker thread).
                        m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Completed request to register for proximity.");

                        // test, set proximity threshold and deadband
                        if (nearthreshold > -1 && m_delphiHostCommandExt != null)
                        {
                            m_delphiHostCommandExt.SetNearProximityThresholdAndDeadBand(nearthreshold, proximitydeadband);
                        }

                        m_MobileCallWnd.SetHasProximity(true, true);
                    }
                }
               
                catch (System.Exception e)
                {
                    m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": INFO: proximity may not be supported on your device. Will disable far option.");
                    // uh-oh proximity may not be supported... disable it as option in GUI
                    m_MobileCallWnd.SetHasProximity(false, true);
                }
            }

            public static void AnswerMobileCall()
            {
                if (m_atdCommand != null)
                {
                    m_atdCommand.AnswerMobileCall();
                }
                else
                {
                    m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Error, unable to answer mobile call. atd command is null.");
                }
            }

            public static void EndMobileCall()
            {
                if (m_atdCommand != null)
                {
                    m_atdCommand.EndMobileCall();
                }
                else
                {
                    m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Error, unable to end mobile call. atd command is null.");
                }
            }

            internal static void GetMobileCallStatus()
            {
                if (m_atdCommand != null)
                {
                    try
                    {
                        m_atdCommand.GetMobileCallStatus(); // are we on a call?

                        bool tmpHasCallerId = true; // device does support caller id feature

                        // LC temporarily hard-code some device capabilities
                        // e.g. fact that Blackwire C710/C720 do not support proximity, docking and is not wireless
                        string devname = m_devicename;
                        if (devname != null)
                        {
                            devname = devname.ToUpper();
                            if (devname.Contains("SAVI 7"))
                            {
                                tmpHasCallerId = false; // Savi 7xx does not support caller id feature
                            }
                            if (devname.Contains("BLACKWIRE"))
                            {
                                tmpHasCallerId = false; // Blackwire range does not support caller id feature
                            }
                            if (devname.Contains("C710") || devname.Contains("C720"))
                            {
                                tmpHasCallerId = false; // Blackwire 700 range does not support caller id feature
                            }
                        }

                        m_MobileCallWnd.SetHasCallerId(tmpHasCallerId); // set whether device supports caller id feature
                    }
                    catch (System.Exception e)
                    {
                        m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": INFO: Exception occured getting mobile call status\r\nException = "+e.ToString());
                        m_MobileCallWnd.SetHasCallerId(false);
                    }
                }
                else
                {
                    m_MobileCallWnd.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Error, unable to get mobile status. atd command is null.");
                    m_MobileCallWnd.SetHasCallerId(false); // device does not support caller id feature
                }
            }

            public override bool Connect(int numretries = 12, int retrydelay = 20)
            {
                bool retval = false;

                m_debuglog = m_MobileCallWnd;

                m_numretries = numretries;
                m_retrydelay = retrydelay;

                // start thread and return true to indicate that we have at least commenced trying to connect...
                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Starting background thread to Connect to Spokes...");
                starterThread.Start();
                retval = true;

                return retval;
            }

            public override void ConnectAction()
            {
                int trynum = 0;
                while (trynum <= m_numretries && !IsConnected)
                {
                    trynum++;
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName()+": Try to connect to Spokes, try: " + trynum + " of " + m_numretries);
                    try
                    {
                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName() + ": About to connect to Spokes...");

                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName() + ": InitComObjects about to be called...");
                        IsConnected = SpokesInterop.m_spokesInterop.InitComObjects();
                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName() + ": InitComObjects has returned. Success = " + IsConnected.ToString());

                        if (IsConnected)
                            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName() + ": SUCCESS Got Spokes connection ok.");
                    }
                    catch (System.Exception e)
                    {
                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName() + ": INFO: Exception during Spokes connect: " + e.ToString());
                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName() + ": Failed to initialise Plantronics Spokes Software. Please ensure it is installed from http://www.plantronics.com/software/\r\n\r\nError returned was:\r\n" + e.ToString());
                    }
                    // sleep before retrying...
                    if (trynum <= m_numretries && !IsConnected)
                    {
                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName() + ": Will try Spokes again in: " + m_retrydelay + " seconds!");
                        Thread.Sleep(m_retrydelay * 1000);
                    }
                }
                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, m_spokesInterop.GetAppName() + ": Completed: " + trynum + " tries to connect to Spokes. Connected? = " + IsConnected);
            }

            public override bool Disconnect()
            {
                throw new NotImplementedException();
            }

            public override CRMContact GetContact(string callerid)
            {
                throw new NotImplementedException();
            }
        }

        #region Call Control Helper Classes
        // Call abstraction
        public class CallCOM : Interop.Plantronics.CallId
        {
            private int id = 0;
            #region ICall Members

            public int ConferenceId
            {
                get { return 0; }
                set { }
            }

            public int Id
            {
                get { return id; }
                set { id = value; }
            }

            public bool InConference
            {
                get { return false; }
                set { }
            }

            #endregion
        }
        // Contact abstraction
        public class ContactCOM : Interop.Plantronics.Contact
        {
            private string email;
            private string friendlyName;
            private string homePhone;
            private int id;
            private string mobPhone;
            private string name;
            private string phone;
            private string sipUri;
            private string workPhone;
            #region IContact Members

            public string Email
            {
                get
                {
                    return email;
                }
                set
                {
                    email = value;
                }
            }

            public string FriendlyName
            {
                get
                {
                    return friendlyName;
                }
                set
                {
                    friendlyName = value;
                }
            }

            public string HomePhone
            {
                get
                {
                    return homePhone;
                }
                set
                {
                    homePhone = value;
                }
            }

            public int Id
            {
                get
                {
                    return id;
                }
                set
                {
                    id = value;
                }
            }

            public string MobilePhone
            {
                get
                {
                    return mobPhone;
                }
                set
                {
                    mobPhone = value;
                }
            }

            public string Name
            {
                get
                {
                    return name;
                }
                set
                {
                    name = value;
                }
            }

            public string Phone
            {
                get
                {
                    return phone;
                }
                set
                {
                    phone = value;
                }
            }

            public string SipUri
            {
                get
                {
                    return sipUri;
                }
                set
                {
                    sipUri = value;
                }
            }

            public string WorkPhone
            {
                get
                {
                    return workPhone;
                }
                set
                {
                    workPhone = value;
                }
            }

            #endregion
        }
        #endregion
    }


