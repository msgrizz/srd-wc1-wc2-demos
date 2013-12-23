using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Plantronics.Innovation.Util;
using Plantronics.Innovation.BRLibrary;
using System.Timers;

/*******
 * 
 * PLTLabsAPI DLL
 * 
 * A share DLL library for accessing features of the Concept 1 Plantronics headset device.
 * This enables hackers to easily create apps for the Plantronics innovation
 * Concept 1 product for use with http://pltlabs.com/
 * 
 * This library allows the following:
 * 
 *   - Connect to attached Concept 1
 *     
 *   - Register for up to 12 support services, including motion tracking, sensor calibration
 *     status, etc.
 *     
 *   - Configure the way the services function, in particular how the motion tracking
 *     data is formatted
 *   
 *   - Receive the data from those services
 *      
 * PRE-REQUISITES for building apps with this library:
 * To leverage the API and sample code presented in this developer guide your PC will require the following:
 *   - Microsoft Visual Studio 2010 SP1
 *   - Microsoft .NET Framework 4.0
 *   - Plantronics Spokes SDK 3.0 beta 2, available from PDC site here:
 *     http://developer.plantronics.com/community/nychack
 *     NOTE: you need to Log out of PDC and login again using the following user in order to access this beta:
 *     User: NYChack
 *     Password: IoThack
 *
 * INSTRUCTIONS FOR USE OF CONCEPT 1 DEVICE
 * 
 *   - If you turn headset on and leave it still on the desk.
 *     Wait for sensor calibration service to report that
 *     the gyro is Calibrated - BUT leave headset
 *     a few seconds longer until angles arriving from motion
 *     tracking service to stop creeping.
 *     
 * Lewis Collins
 * 
 * VERSION HISTORY:
 * ********************************************************************************
 * Version 1.0.0.3:
 * Date: 1st November 2013
 * Changed by: Lewis Collins
 * Changes:
 *   - Adding Douglas Wong's suggested quatmult fix and address re-order of pitch and roll
 *     angles in returned motion tracking data.
 *
 * Version 1.0.0.2:
 * Date: 25th September 2013
 * Changed by: Lewis Collins
 * Changes:
 *   - Adding embedded XML documentation to all public classes and members
 *
 * Version 1.0.0.1:
 * Date: 24th September 2013
 * Changed by: Lewis Collins
 * Changes:
 *   - Applied Doug's fixed C# maths algorithm (quat to angles) - thanks Doug :-)
 *
 * Version 1.0.0.0:
 * Date: 24th September 2013
 * Changed by: Lewis Collins
 * Changes:
 *   - Initial version.
 * ********************************************************************************
 *
 **/

namespace Plantronics.Innovation.PLTLabsAPI2
{
    /// <summary>
    /// PLTLabsAPI - the main object class for PLTLabsAPI for using
    /// motion tracking etc headset sensors.
    /// WARNING: only instantiate 1 of these objects (pending to
    /// convert this to a singleton).
    /// </summary>
    public class PLTLabsAPI2 : HeadtrackingUpdateHandler, BladeRunnerHandler
    {
        QuaternionProcessor m_quatproc;
        internal PLTLabsCallbackHandler m_callbackhandler;
        private bool m_isConnectedToBladeRunner = false;

        // List of available devices (PC Spokes 3.0 there will be only 1 active call control device)
        List<PLTDevice> m_availableDevices = new List<PLTDevice>();
        private bool m_isConnectToDevice = false;
        internal PLTConnection m_activeConnection = null;

        // For all services track the LAST KNOWN value here
        // (Note: app will be informed if connection closes to device via connectionClosed
        // callback).
        // Note: each one has a lock to prevent multi-threaded access issues
        internal PLTWearingState m_lastwornstate = new PLTWearingState();
        internal Object m_lastwornstateLock = new Object();
        internal PLTBatteryState m_lastbattstate = new PLTBatteryState();
        internal Object m_lastbattstateLock = new Object();
        internal PLTProximity m_lastproximitystate = new PLTProximity();
        internal Object m_lastproximitystateLock = new Object();

        internal PLTCallerId m_lastcallerid = new PLTCallerId();
        internal Object m_lastcalleridLock = new Object();
        internal PLTCallStateInfo m_lastcallstate = new PLTCallStateInfo();
        internal Object m_lastcallstateLock = new Object();
        internal PLTDock m_lastdockstate = new PLTDock();
        internal Object m_lastdockstateLock = new Object();

        private bool m_headsetinrange = true; // assume in range initially
        private bool m_constructordone;
        private HIDDevice myDevice = null;
        private bool m_devicenotified = false;

        // NEW, a timer to wait for all host negotiates to complete
        // before trying to register for head tracking data
        Timer m_hostNegotiateTimer;
        bool m_registeredForHeadTracking = false;
        public bool m_triggerHTregister = false;
        private Object m_triggerHTregisterLock = new Object();

        /// <summary>
        /// SDK_VERSION defines the current version of the PLTLabsAPI DLL
        /// (It matches the rev version of the Developer High-Level API Description document).
        /// </summary>
        public static string SDK_VERSION = "0.4";
        private BladeRunnerEndpoint BRendpoint;

        /// <summary>
        /// Constructor for PLTLabsAPI object which is used to connect
        /// to the Plantronics motion sensor headset devices.
        /// ***NOTE: Only instantiate 1 of these objects - pending to do make a singleton***
        /// </summary>
        /// <param name="aCallBackHandler">Pass reference to your object class that implements
        /// the PLTLabsCallbackHandler interface to be able to receive motion tracking and other
        /// sensor data.</param>
        public PLTLabsAPI2(PLTLabsCallbackHandler aCallBackHandler)
        {
            m_callbackhandler = aCallBackHandler;

            m_quatproc = new QuaternionProcessor(this);

            // New BladeRunner connect code
            m_hostNegotiateTimer = new Timer();
            m_hostNegotiateTimer.Interval = 7000;
            m_hostNegotiateTimer.Elapsed += m_hostNegotiateTimer_Elapsed;

            myDevice = new HIDDevice();
            if (myDevice.ConnectFirstPlantronicsSupportingBladeRunner())
            {
                Console.WriteLine("Successfully connected to a BladeRunner device:\r\nHID Path = " + myDevice.devicePathName + "\r\n");

                m_isConnectedToBladeRunner = true;

                BRendpoint = new BladeRunnerEndpoint(myDevice, this);

                BRendpoint.DiscoverDevices();

                RestartHostNegotiateTimer();
            }
            else
            {
                Console.WriteLine("Sorry, no Plantronics device supporting BladeRunner was found.\r\n");
            }

            //m_spokes = Spokes.Instance;

            //// register for device attach/detach events
            //m_spokes.Attached += new Spokes.AttachedEventHandler(m_spokes_Attached);
            //m_spokes.Detached += new Spokes.DetachedEventHandler(m_spokes_Detached);

            //// Register for some special device events that we need initial
            //// status for as soon as we call connect
            //m_spokes.PutOn += new Spokes.PutOnEventHandler(m_spokes_PutOn);
            //m_spokes.TakenOff += new Spokes.TakenOffEventHandler(m_spokes_TakenOff);

            //// register for battery level events
            //m_spokes.BatteryLevelChanged += new Spokes.BatteryLevelChangedEventHandler(m_spokes_BatteryLevelChanged);

            //// register for device proximity events
            //// NOTE: these are also used to infer whether the actual Concept 1 headset is connected
            //// to the BT300 dongle - i.e. if we have any of Near/Far/InRange then we can announce
            //// the device as attached to the application
            //m_spokes.OutOfRange += new Spokes.OutOfRangeEventHandler(m_spokes_OutOfRange);
            //m_spokes.InRange += new Spokes.InRangeEventHandler(m_spokes_InRange);
            //m_spokes.Near += new Spokes.NearEventHandler(m_spokes_Near);
            //m_spokes.Far += new Spokes.FarEventHandler(m_spokes_Far);

            //// call state events:
            //m_spokes.MobileCallerId += new Spokes.MobileCallerIdEventHandler(m_spokes_MobileCallerId);
            //m_spokes.OnCall += new Spokes.OnCallEventHandler(m_spokes_OnCall);
            //m_spokes.OnMobileCall += new Spokes.OnMobileCallEventHandler(m_spokes_OnMobileCall);
            //m_spokes.NotOnCall += new Spokes.NotOnCallEventHandler(m_spokes_NotOnCall);
            //m_spokes.NotOnMobileCall += new Spokes.NotOnMobileCallEventHandler(m_spokes_NotOnMobileCall);

            //// Docked state
            //m_spokes.Docked += new Spokes.DockedEventHandler(m_spokes_Docked);
            //m_spokes.UnDocked += new Spokes.DockedEventHandler(m_spokes_UnDocked);

            //m_isConnectedToSpokes = m_spokes.Connect("PLTLabsAPI");

            // we are connected to Spokes at this point in time
            // however lets still let connecting app openConnection to a specific device
            // (even though Spokes PC only has 1 active call control device configured
            //  through spokes settings)

            // mark constructor as done so we can avoid sending
            // client app a DeviceChanged callback
            m_constructordone = true;
        }

        void m_hostNegotiateTimer_Elapsed(object sender, ElapsedEventArgs e)
        {
            // host negotatation was complete...
            if (!m_registeredForHeadTracking)
            {
                Console.WriteLine("shall we register for HT?");
                Console.WriteLine("yes, lets...");
                lock (m_triggerHTregisterLock)
                {
                    m_triggerHTregister = true;
                }
                //NotifyDevice();
                m_availableDevices.Add(new PLTDevice(myDevice));
                openConnection(m_availableDevices[0]);
                m_registeredForHeadTracking = true; // todo actually it is not yet ;-)
            }
        }

        private void RestartHostNegotiateTimer()
        {
            m_hostNegotiateTimer.Stop();
            m_hostNegotiateTimer.Start();
        }

        //void m_spokes_UnDocked(object sender, DockedStateArgs e)
        //{
        //    UpdateDockedStateToConnection(e.m_docked, e.m_isInitialStateEvent);
        //}

        //void m_spokes_Docked(object sender, DockedStateArgs e)
        //{
        //    UpdateDockedStateToConnection(e.m_docked, e.m_isInitialStateEvent);
        //}

        private void UpdateDockedStateToConnection(bool docked, bool initial)
        {
            lock (m_lastdockstateLock)
            {
                m_lastdockstate.m_isdocked = docked;
                m_lastdockstate.m_isinitialstatus = initial;
            }

            if (m_activeConnection != null) // todo only do this if subscribed to relevant service?
            {
                PLTServiceSubscription subscr =
                    m_activeConnection.getSubscription(PLTService.DOCKSTATE_SVC);
                if (subscr != null)
                {
                    lock (m_lastdockstateLock)
                    {
                        subscr.LastData = m_lastdockstate;
                    }

                    // if it is an on change subscription, beam to connected app now
                    // otherwise will happen in the PLTConnection's periodic timer
                    if (subscr.m_mode == PLTMode.On_Change)
                    {
                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.DOCKSTATE_SVC, subscr.LastData));
                    }
                }
            }
        }
        
        private void UpdateCallStateToConnection(PLTCallStateType calltype,PLTCallState callstate,int callid = 0,string callsource = "",
            bool incoming = false)
        {
            lock (m_lastcallstateLock)
            {
                m_lastcallstate.m_callstatetype = calltype;
                m_lastcallstate.m_callstate = callstate;
                m_lastcallstate.m_callid = callid;
                m_lastcallstate.m_callsource = callsource;
                m_lastcallstate.m_incoming = incoming;
            }

            if (m_activeConnection != null) // todo only do this if subscribed to relevant service?
            {
                PLTServiceSubscription subscr =
                    m_activeConnection.getSubscription(PLTService.CALLSTATE_SVC);
                if (subscr != null)
                {
                    lock (m_lastcallstateLock)
                    {
                        subscr.LastData = m_lastcallstate;
                    }

                    // if it is an on change subscription, beam to connected app now
                    // otherwise will happen in the PLTConnection's periodic timer
                    if (subscr.m_mode == PLTMode.On_Change)
                    {
                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.CALLSTATE_SVC, subscr.LastData));
                    }
                }
            }
        }

        //void m_spokes_NotOnMobileCall(object sender, EventArgs e)
        //{
        //    UpdateCallStateToConnection(PLTCallStateType.NotOnMobileCall, PLTCallState.Idle);
        //}

        //void m_spokes_NotOnCall(object sender, NotOnCallArgs e)
        //{
        //    UpdateCallStateToConnection(PLTCallStateType.NotOnCall,PLTCallState.Idle,e.CallId,e.CallSource);
        //}

        //void m_spokes_OnMobileCall(object sender, OnMobileCallArgs e)
        //{
        //    UpdateCallStateToConnection(PLTCallStateType.OnMobileCall,PLTCallState.OnCall, 0, "", e.Incoming);
        //}

        //void m_spokes_OnCall(object sender, OnCallArgs e)
        //{
        //    UpdateCallStateToConnection(PLTCallStateType.OnCall, (PLTCallState)e.State, e.CallId, e.CallSource, e.Incoming);
        //}

        //void m_spokes_MobileCallerId(object sender, MobileCallerIdArgs e)
        //{
        //    UpdateMobileCallerIdToConnection(e.MobileCallerId);
        //}

        private void UpdateMobileCallerIdToConnection(string mobilecallid)
        {
            lock (m_lastcalleridLock)
            {
                m_lastcallerid.m_calltype = PLTCallerIdType.Mobile; // only this supported at present
                m_lastcallerid.m_callerid = mobilecallid;
            }

            if (m_activeConnection != null) // todo only do this if subscribed to relevant service?
            {
                PLTServiceSubscription subscr =
                    m_activeConnection.getSubscription(PLTService.CALLERID_SVC);
                if (subscr != null)
                {
                    lock (m_lastcalleridLock)
                    {
                        subscr.LastData = m_lastcallerid;
                    }

                    // if it is an on change subscription, beam to connected app now
                    // otherwise will happen in the PLTConnection's periodic timer
                    if (subscr.m_mode == PLTMode.On_Change)
                    {
                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.CALLERID_SVC, subscr.LastData));
                    }
                }
            }
        }

        //void m_spokes_Far(object sender, EventArgs e)
        //{
        //    NotifyDevice();
        //    UpdateProximityStateToConnection(PLTProximityType.Far);
        //}

        //void m_spokes_Near(object sender, EventArgs e)
        //{
        //    NotifyDevice();
        //    UpdateProximityStateToConnection(PLTProximityType.Near);
        //}

        //void m_spokes_InRange(object sender, EventArgs e)
        //{
        //    NotifyDevice();
        //    UpdateProximityStateToConnection(PLTProximityType.Unknown);
        //}

        // if device attached has not yet been notified then notify it to connected app
        private void NotifyDevice()
        {
            m_headsetinrange = true;
            if (!m_devicenotified)
            {
                if (m_activeConnection == null)
                {
                    //NotifyDeviceAvailable(m_attacheddevice);
                }
                else
                {
                    m_callbackhandler.ConnectionOpen(m_activeConnection);
                }
                m_devicenotified = true;
            }
        }

        //void m_spokes_OutOfRange(object sender, EventArgs e)
        //{
        //    m_devicenotified = false;
        //    m_headsetinrange = false;
        //    if (m_activeConnection != null)
        //    {
        //        m_callbackhandler.ConnectionFailed(m_activeConnection.m_device);
        //    }
        //    UpdateProximityStateToConnection(PLTProximityType.Unknown);
        //}

        //void m_spokes_BatteryLevelChanged(object sender, EventArgs e)
        //{
        //    if (m_headsetinrange)
        //    {
        //        Interop.Plantronics.DeviceBatteryLevel batlev =
        //            m_spokes.GetBatteryLevel();

        //        lock (m_lastbattstateLock)
        //        {
        //            m_lastbattstate.m_batterylevel = (PLTBatteryLevel)batlev;
        //        }

        //        if (m_activeConnection != null) // todo only do this if subscribed to relevant service?
        //        {
        //            PLTServiceSubscription subscr =
        //                m_activeConnection.getSubscription(PLTService.CHARGESTATE_SVC);
        //            if (subscr != null)
        //            {
        //                lock (m_lastwornstateLock)
        //                {
        //                    subscr.LastData = m_lastbattstate;
        //                }

        //                // if it is an on change subscription, beam to connected app now
        //                // otherwise will happen in the PLTConnection's periodic timer
        //                if (subscr.m_mode == PLTMode.On_Change)
        //                {
        //                    m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.CHARGESTATE_SVC, subscr.LastData));
        //                }
        //            }
        //        }
        //    }
        //}

        //void m_spokes_TakenOff(object sender, WearingStateArgs e)
        //{
        //    UpdateWearingStateToConnection(e);
        //}

        //void m_spokes_PutOn(object sender, WearingStateArgs e)
        //{
        //    UpdateWearingStateToConnection(e);
        //}

        //private void UpdateWearingStateToConnection(WearingStateArgs e)
        //{
        //    lock (m_lastwornstateLock)
        //    {
        //        m_lastwornstate.m_worn = e.m_worn;
        //        m_lastwornstate.m_isInitialStateEvent = e.m_isInitialStateEvent;
        //    }

        //    if (m_activeConnection != null) // todo only do this if subscribed to relevant service?
        //    {
        //        PLTServiceSubscription subscr =
        //            m_activeConnection.getSubscription(PLTService.WEARING_STATE_SVC);
        //        if (subscr != null)
        //        {
        //            lock (m_lastwornstateLock)
        //            {
        //                subscr.LastData = m_lastwornstate;
        //            }
    
        //            // if it is an on change subscription, beam to connected app now
        //            // otherwise will happen in the PLTConnection's periodic timer
        //            if (subscr.m_mode == PLTMode.On_Change)
        //            {
        //                m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.WEARING_STATE_SVC, subscr.LastData));
        //            }
        //        }
        //    }
        //}

        private void UpdateProximityStateToConnection(PLTProximityType proximitytype)
        {
            lock (m_lastproximitystateLock)
            {
                m_lastproximitystate.m_proximity = proximitytype;
            }

            if (m_activeConnection != null) // todo only do this if subscribed to relevant service?
            {
                PLTServiceSubscription subscr =
                    m_activeConnection.getSubscription(PLTService.PROXIMITY_SVC);
                if (subscr != null)
                {
                    lock (m_lastproximitystateLock)
                    {
                        subscr.LastData = m_lastproximitystate;
                    }

                    // if it is an on change subscription, beam to connected app now
                    // otherwise will happen in the PLTConnection's periodic timer
                    if (subscr.m_mode == PLTMode.On_Change)
                    {
                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.PROXIMITY_SVC, subscr.LastData));
                    }
                }
            }
        }

        /// <summary>
        /// Call this method to find out which device(s) are connected.
        /// NOTE: will only return 1 device with PC Spokes API, that
        /// being the currently configured Spokes "call control" device.
        /// </summary>
        /// <returns>Returns an array of connected Plantronics devices as PLTDevice[] objects.</returns>
        public PLTDevice[] availableDevices()
        {
            return m_availableDevices.ToArray();
        }

        /// <summary>
        /// Call this method to instruct device to open a connection to the
        /// specified device. Once connected you will be able to subscribe
        /// to data services of the device.
        /// </summary>
        /// <param name="aDevice">Pass the PLTDevice object you want to connect to.</param>
        public void openConnection(PLTDevice aDevice)
        {
            if (m_activeConnection != null) return;

            // TODO in future instruct Spokes to change call control device
            // to passed PLTDevice (not currently available with Spokes 3.0
            // in which we are already attached to the 1 call control device)

            // just register for raw data received to receive sensor data
            //m_spokes.RawDataReceived += new Spokes.RawDataReceivedEventHandler(m_spokes_RawDataReceived);

            m_isConnectToDevice = true;
            m_activeConnection = new PLTConnection(this, aDevice);

            m_callbackhandler.ConnectionOpen(m_activeConnection);
        }

        /// <summary>
        /// Call this method to close a conection to the Plantronics
        /// device. Pass the PLTConnection object reference that you
        /// wish to close. This method will close all the active
        /// subscriptions for the device and unattach from the device
        /// motion sensors.
        /// </summary>
        /// <param name="aConnection">Pass the PLTConnection object reference
        /// that you wish to close.</param>
        public void closeConnection(PLTConnection aConnection)
        {
            //// TODO: get ALL the subscribed services
            //// and UNSUBSCRIBE them - in particular STOP any periodic TIMERS
            //// otherwise you will get exceptions
            //aConnection.CloseAllSubscriptions();

            //// unregister for raw data received event
            //m_spokes.RawDataReceived -= m_spokes_RawDataReceived;
            //m_isConnectToDevice = false;
            //m_activeConnection = null;
            //m_callbackhandler.ConnectionClosed(aConnection.m_device);
        }

        /// <summary>
        /// Call this method to find out if a particular device is attached or not.
        /// </summary>
        /// <param name="aDevice">The PLTDevice you want to check if it is connected</param>
        /// <returns>Returns true if the device is connected</returns>
        public bool getIsConnected(PLTDevice aDevice)
        {
            return m_isConnectToDevice;
        }

        bool IsConnectedToSpokes()
        {
            return m_isConnectedToBladeRunner;
        }

        /// <summary>
        /// Call this method to initiate a calibration process of the
        /// selected PLTService. For example, if you call it for
        /// the MOTION_TRACKING_SVC it will cause a calibration
        /// (set to zero) of the motion tracking angles.
        /// </summary>
        /// <param name="aService">The PLTService type you want to calibrate.</param>
        public void calibrateService(PLTService aService)
        {
            switch (aService)
            {
                case PLTService.MOTION_TRACKING_SVC:
                    m_quatproc.Calibrate(true);
                    break;
            }
        }

        /// <summary>
        /// Call this method to apply service-specific configurations to a service.
        /// For example, to configure the motion tracking service to provide only raw
        /// quaternions or calibrated quaternions (calibrated to a reference quaternion).
        /// Or to tell motion tracking service to provide quaternions as output or
        /// to  also include orientations (Euler angles).
        /// </summary>
        /// <param name="aService">PLTService name being configured</param>
        /// <param name="aConfiguration">PLTConfiguration enum value of config to be applied</param>
        /// <param name="data">Optional reference to object for user data, e.g. a PLTQuaternion
        /// object as a user-supplied reference quaternion for calibration.</param>
        public void configureService(PLTService aService, PLTConfiguration aConfiguration, object data = null)
        {
            switch (aService)
            {
                case PLTService.MOTION_TRACKING_SVC:
                    switch (aConfiguration)
                    {
                        case PLTConfiguration.MotionSvc_Offset_Raw:
                            QuaternionProcessor.m_doCalibrate = false;
                            break;
                        case PLTConfiguration.MotionSvc_Offset_Calibrated:
                            QuaternionProcessor.m_doCalibrate = true;
                            // pass in optional data quat!
                            double[] userquatvalues = null;;
                            if (data!=null)
                            {
                                try
                                {
                                    PLTQuaternion userquat = (PLTQuaternion)data;
                                    userquatvalues = userquat.m_quaternion;
                                }
                                catch (Exception e)
                                {
                                    throw new Exception("PLT Labs API Configure Service: Sorry, problem casting user calibration quaternion", e);
                                }
                            }
                            m_quatproc.Calibrate(false, userquatvalues); 
                            break;
                        case PLTConfiguration.MotionSvc_Format_Quaternion:
                            QuaternionProcessor.m_doOrientation = false;
                            break;
                        case PLTConfiguration.MotionSvc_Format_Orientation:
                            QuaternionProcessor.m_doOrientation = true;
                            break;

                    }
                    break;
            }
        }

        /// <summary>
        /// Call this method to subscribe to the specified data service (PLTService enum) from the
        /// device. For example you can subscribe to motion tracking service to receive
        /// head tracking angles etc.
        /// </summary>
        /// <param name="aService">The PLTService enum value defines which service to subscribe to</param>
        /// <param name="aMode">The PLTMode defines On_Change (as soon as new data is available)
        /// or Periodic mode (return data on specific period). Note not all services are compatible
        /// with Periodic mode (These are not: Tap service, Free fall service and Call state service)</param>
        /// <param name="aPeriodmilliseconds">The period in milliseconds to return data
        /// if using Periodic mode</param>
        public void subscribe(PLTService aService, PLTMode aMode, int aPeriodmilliseconds = 0)
        {
            if (m_activeConnection != null)
            {
                m_activeConnection.subscribe(aService, aMode, aPeriodmilliseconds);
            }
            else
            {
                throw new Exception("PLT Labs API subscribe Service: Sorry, you must connect to headset first (see openConnection method)");
            }
        }

        /// <summary>
        /// Call this method to unsunscribe a previously subscribed device service.
        /// </summary>
        /// <param name="aService">The PLTService enum value defines which service to unsubscribe from</param>
        public void unsubscribe(PLTService aService)
        {
            if (m_activeConnection != null)
            {
                m_activeConnection.unsubscribe(aService);
            }
            else
            {
                throw new Exception("PLT Labs API unsubscribe Service: Sorry, you must connect to headset first (see openConnection method)");
            }
        }

        /// <summary>
        /// Call this method to query if the specified service is currently subscribed
        /// </summary>
        /// <param name="aService">The PLTService enum value defines which service to check</param>
        /// <returns>Returns a boolean to indicate if service was subscribed or not.</returns>
        public bool getSubscribed(PLTService aService)
        {
            if (m_activeConnection != null)
            {
                return m_activeConnection.isSubscribed(aService);
            }
            else
            {
                throw new Exception("PLT Labs API getSubscribed: Sorry, you must connect to headset first (see openConnection method)");
            }
        }

        /// <summary>
        /// Call this method to obtain a list of currently subscribed services
        /// </summary>
        /// <returns>Returns an array of subscribed services as PLTService[] enum values.</returns>
        public PLTService[] getSubscribed()
        {
            if (m_activeConnection != null)
            {
                return m_activeConnection.getSubscribed();
            }
            else
            {
                throw new Exception("PLT Labs API getSubscribed Services: Sorry, you must connect to headset first (see openConnection method)");
            }
        }

        //void m_spokes_RawDataReceived(object sender, RawDataReceivedArgs e)
        //{
        //    string odpreport = System.Text.Encoding.UTF8.GetString(e.m_datarawbytes);

        //    if (m_activeConnection != null) // todo only do this if subscribed to relevant service?
        //    {
        //        // ok, let's try to break out those head tracking quatenions...
        //        m_quatproc.ProcessODPReport(odpreport);
        //    }
        //}

        /// <summary>
        /// Call this method to perform a clean shutdown of the
        /// PLTLabsAPI object and ensure threads are stopped and
        /// resources released.
        /// </summary>
        public void Shutdown()
        {
            m_quatproc.Stop();

            if (m_isConnectedToBladeRunner && myDevice != null) myDevice.Disconnect();

            //m_spokes.Attached -= m_spokes_Attached;
            //m_spokes.Detached -= m_spokes_Detached;

            //m_spokes.PutOn -= m_spokes_PutOn;
            //m_spokes.TakenOff -= m_spokes_TakenOff;

            //m_spokes.BatteryLevelChanged -= m_spokes_BatteryLevelChanged;

            //m_spokes.OutOfRange -= m_spokes_OutOfRange;
            //m_spokes.InRange -= m_spokes_InRange;
            //m_spokes.Near -= m_spokes_Near;
            //m_spokes.Far -= m_spokes_Far;

            //m_spokes.MobileCallerId -= m_spokes_MobileCallerId;
            //m_spokes.OnCall -= m_spokes_OnCall;
            //m_spokes.OnMobileCall -= m_spokes_OnMobileCall;
            //m_spokes.NotOnCall -= m_spokes_NotOnCall;
            //m_spokes.NotOnMobileCall -= m_spokes_NotOnMobileCall;

            //m_spokes.Docked -= m_spokes_Docked;
            //m_spokes.UnDocked -= m_spokes_UnDocked;

            //if (m_activeConnection != null) closeConnection(m_activeConnection);

            //m_spokes.Disconnect();
        }

        void m_spokes_Detached(object sender, EventArgs e)
        {
            m_availableDevices.Clear();
            myDevice = null;
            m_devicenotified = false;
            if (m_activeConnection != null)
            {
                m_callbackhandler.ConnectionClosed(m_activeConnection.m_device);
                closeConnection(m_activeConnection);
            }
        }

        //void m_spokes_Attached(object sender, AttachedArgs e)
        //{
        //    m_availableDevices.Clear();
        //    m_attacheddevice = e.m_device;
        //    m_devicenotified = false;
        //    // new: device is not considered available to headtracking api
        //    // until inrange event!
        //}

        //private void NotifyDeviceAvailable(Interop.Plantronics.ICOMDevice dev)
        //{
        //    m_availableDevices.Clear(); // note: only 1 call control device for pc spokes
        //    PLTDevice deviceTmp = new PLTDevice(dev);
        //    m_availableDevices.Add(deviceTmp);

        //    if (m_constructordone)
        //    {
        //        m_callbackhandler.DeviceAdded(deviceTmp); // tell connected app that a Plantronics
        //        // device was added (or selected as call control device in Spokes 3.0 control panel).
        //        // Connected app may then choose to make a PLTLabsAPI connection to this device
        //        // for purpose of reading sensor data from it.
        //    }
        //}

        /// <summary>
        /// This is a method used by the internals of the PLTLabsAPI DLL to receive
        /// Motion Tracking events from the headset and then distribute them to 
        /// applications that are subscribed to those data services.
        /// *** DO NOT CALL THIS METHOD ***
        /// </summary>
        /// <param name="headsetData">The data received from headset *** DO NOT CALL THIS METHOD ***</param>
        public void HeadsetTrackingUpdate(HeadsetTrackingData headsetData)
        {
            // todo, if registered for various services (headtracking, pedometer etc )
            // then send back the data to the infoUpdated callback!!!

            if (m_activeConnection != null) // todo only do this if subscribed to relevant service?
            {
                m_activeConnection.vermaj = headsetData.vermaj;
                m_activeConnection.vermin = headsetData.vermin;

                // MOTION_TRACKING_SVC data for motion tracking service...
                PLTServiceSubscription subscr =
                    m_activeConnection.getSubscription(PLTService.MOTION_TRACKING_SVC);
                if (subscr != null)
                {
                    PLTMotionTrackingData data = new PLTMotionTrackingData();
                    data.m_rawreport = headsetData.rawreport;

                    // avoid NaN conditions!
                    if (Double.IsNaN(headsetData.psi_heading)) headsetData.psi_heading = 0.0;
                    if (Double.IsNaN(headsetData.theta_pitch)) headsetData.theta_pitch = 0.0;
                    if (Double.IsNaN(headsetData.phi_roll)) headsetData.phi_roll = 0.0;

                    data.m_orientation[0] = headsetData.psi_heading;
                    data.m_orientation[1] = headsetData.theta_pitch;
                    data.m_orientation[2] = headsetData.phi_roll;

                    data.m_calquaternion[0] = headsetData.quatcalib_q0;
                    data.m_calquaternion[1] = headsetData.quatcalib_q1;
                    data.m_calquaternion[2] = headsetData.quatcalib_q2;
                    data.m_calquaternion[3] = headsetData.quatcalib_q3;

                    data.m_rawquaternion[0] = headsetData.quatraw_q0;
                    data.m_rawquaternion[1] = headsetData.quatraw_q1;
                    data.m_rawquaternion[2] = headsetData.quatraw_q2;
                    data.m_rawquaternion[3] = headsetData.quatraw_q3;

                    // tell app what the quaternion processing config was:
                    data.m_format_config = QuaternionProcessor.m_doCalibrate ? PLTConfiguration.MotionSvc_Offset_Calibrated :
                        PLTConfiguration.MotionSvc_Offset_Raw;
                    data.m_offset_config = QuaternionProcessor.m_doOrientation ? PLTConfiguration.MotionSvc_Format_Orientation :
                        PLTConfiguration.MotionSvc_Format_Quaternion;

                    subscr.LastData = data;

                    if (subscr.m_mode == PLTMode.On_Change)
                    {
                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.MOTION_TRACKING_SVC, data));
                    }
                }

                // MOTION_STATE_SVC
                // TODO: I don't think this data is available

                // SENSOR_CAL_STATE_SVC data for sensor cal state service...
                subscr =
                    m_activeConnection.getSubscription(PLTService.SENSOR_CAL_STATE_SVC);
                if (subscr != null)
                {
                    PLTSensorCal data = new PLTSensorCal();
                    data.m_isgyrocal = headsetData.gyrocalib == 3;
                    data.m_ismagnetometercal = headsetData.magnetometercalib == 3;

                    subscr.LastData = data;

                    if (subscr.m_mode == PLTMode.On_Change)
                    {
                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.SENSOR_CAL_STATE_SVC, data));
                    }
                }

                // PEDOMETER_SVC
                subscr =
                    m_activeConnection.getSubscription(PLTService.PEDOMETER_SVC);
                if (subscr != null)
                {
                    PLTPedometerCount data = new PLTPedometerCount();
                    data.m_pedometercount = headsetData.pedometersteps;

                    subscr.LastData = data;

                    if (subscr.m_mode == PLTMode.On_Change)
                    {
                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.PEDOMETER_SVC, data));
                    }
                }

                // TAP_SVC
                subscr =
                    m_activeConnection.getSubscription(PLTService.TAP_SVC);
                if (subscr != null)
                {
                    PLTTapInfo data = new PLTTapInfo();
                    data.m_tapcount = headsetData.taps;
                    data.m_tapdirection = (PLTTapDirection)headsetData.tapdir;

                    subscr.LastData = data;

                    if (subscr.m_mode == PLTMode.On_Change)
                    {
                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.TAP_SVC, data));
                    }
                }

                // FREE_FALL_SVC
                subscr =
                    m_activeConnection.getSubscription(PLTService.FREE_FALL_SVC);
                if (subscr != null)
                {
                    PLTFreeFall data = new PLTFreeFall();
                    data.m_isinfreefall = headsetData.freefall;

                    subscr.LastData = data;

                    if (subscr.m_mode == PLTMode.On_Change)
                    {
                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.FREE_FALL_SVC, data));
                    }
                }

                //// TEMPERATURE_SVC
                //subscr =
                //    m_activeConnection.getSubscription(PLTService.TEMPERATURE_SVC);
                //if (subscr != null)
                //{
                //    PLTTemperature data = new PLTTemperature();
                //    data.m_temperature = headsetData.temperature;

                //    subscr.LastData = data;

                //    if (subscr.m_mode == PLTMode.On_Change)
                //    {
                //        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.TEMPERATURE_SVC, data));
                //    }
                //}
            }
        }

        public void HandleBRMessage(HIDDevice.MsgReceivedArgs e)
        {
            //switch (e.
        }

        void BladeRunnerHandler.HandleBRMessage(HIDDevice.MsgReceivedArgs e)
        {
        }


        public void HandleDeckard(Plantronics.Innovation.BRLibrary.Deckard.DeckardCommand deckardcommand,
            List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement> payload_received,
            EBRMessageType brtype, string addresshex)
        {
            // TODO
            // here interpret the deckard messages and
            // translate them into relevant service updates and service
            // messages destined for registed app's "infoUpdated" methods!!!

            // STEP 1, allow app to register for wearing state service and get that
            // working end to end

            //
            switch (deckardcommand.id)
            {
                case "0x0101":
                    // likely the result of a host negatiate...
                    if (!m_registeredForHeadTracking)
                    {
                        RestartHostNegotiateTimer();
                        Console.WriteLine("Still probing devices...");
                    }
                    break;
                case "0x0C00":
                    // device was connected

                    break;
                case "0x0A00":
                    string ProductName = payload_received[0].stringValue;
                    Console.WriteLine("ProductName: " + ProductName);
                    break;
                case "0x0200":
                    bool isworn = payload_received[0].boolValue;
                    Console.WriteLine("Is Worn?: " + isworn);
                    break;
                case "0xFF0A":
                    Console.WriteLine(">>> HEAD TRACKING: ");

                    for (int i = 0; i < payload_received.Count(); i++)
                    {
                        Console.Write(deckardcommand.payload_out[i].name + ": ");
                        switch (deckardcommand.payload_out[i].mType)
                        {
                            case Deckard.BRType.BR_TYPE_UNSIGNED_INT:
                                Console.WriteLine(payload_received[i].int32Value);
                                break;
                            case Deckard.BRType.BR_TYPE_BYTE_ARRAY:
                                for (int j = 0; j < payload_received[i].barray.Count(); j++)
                                {
                                    Console.Write(payload_received[i].barray[j] + ", ");
                                }
                                Console.WriteLine();
                                if (m_activeConnection != null) // todo only do this if subscribed to relevant service?
                                {
                                    // ok, let's try to break out those head tracking quatenions...
                                    //m_quatproc.ProcessByteArray(payload_received[i].barray);
                                    m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.DEBUGINFO_SVC, payload_received[i].barray));
                                }
                                break;
                        }
                    }

                    break;
                default:
                    Console.WriteLine(">> UNKNOWN Deckard received, ID was: (" + deckardcommand.id + ").");
                    break;
            }
        }

        internal void RegisterForHeadTracking()
        {
            // device connected, ok lets query it's services
            // send a <setting name="Get device info" id="0xFF18"> to the received port

            // TODO move a lot of this logic into BladeRunnerEndpoint to make discovery
            // of device info and services more automatic
            // plus implement the ***send queue*** with ack checking before sending next command etc
            // as recommended by David Hudson

            //// work out target device address (connected address + port)
            //byte port = payload_received[0].byteValue;
            //string targetaddress = BladeRunnerEndpoint.AppendPortToEndOfAddress(addresshex, port);

            //prepare query device name command
            BRendpoint.SendBladeRunnerMessage(
                EBRMessageType.eBR_GET_SETTING,
                "1500000",
                //targetaddress,
                "0x0A00",
                null, true);

            //// prepare query services command
            //BRendpoint.SendBladeRunnerMessage(
            //    EBRMessageType.eBR_GET_SETTING,
            //    targetaddress,
            //    "0xFF18",
            //    null, true);

            // prepare subscribe to headtracking service command
            List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement> payload
                = new List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement>();
            payload.Add(new Deckard.BRProtocolElement((UInt16)0)); // want head tracking
            payload.Add(new Deckard.BRProtocolElement((UInt16)0)); // characteristic
            payload.Add(new Deckard.BRProtocolElement((UInt16)1)); // 2 = periodic, 1 = onchange
            payload.Add(new Deckard.BRProtocolElement((UInt16)0)); // period in ms
            BRendpoint.SendBladeRunnerMessage(
                EBRMessageType.eBR_COMMAND,
                "1500000",
                //targetaddress,
                "0xFF0A",
                payload, true);

            m_registeredForHeadTracking = true;
        }
    }

    // 

    /// <summary>
    /// This interface allows your application to receive data from the motion
    /// tracking service and other sensor services of the Plantronics device
    /// </summary>
    public interface PLTLabsCallbackHandler
    {
        void ConnectionOpen(PLTConnection pltConnection);

        void ConnectionFailed(PLTDevice pltDevice);

        void ConnectionClosed(PLTDevice pltDevice);

        void infoUpdated(PLTConnection pltConnection, PLTInfo pltInfo);

        void DeviceAdded(PLTDevice pltDevice);
    }
}
