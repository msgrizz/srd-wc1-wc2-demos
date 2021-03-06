﻿using System;
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
 *   - Microsoft Visual Studio 2010 SP1 or higher
 *   - Microsoft .NET Framework 4.0 or higher
 *   - For sample apps available please check out:
 *     http://developer.plantronics.com/community/concept1
 *     NOTE: You may need to ask for access at a hackathon event.
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
 * Version 1.6.0.3:
 * Date: 11th Sept 2014
 * Changed by: Lewis Collins
 *   Changes:
 *     - Changing to use BladeRunner 0x0E01 message to detect mic mute status
 *       (rather than 0x0E1E audio status with mic gain = 0)
 *     - Changing to recognise mobile call status as distinct from PC call status
 *       so apps don't confuse the two
 *
 * Version 1.6.0.2:
 * Date: 30th July 2014
 * Changed by: Lewis Collins
 *   Changes:
 *     - Minor documentation update
 *
 * Version 1.6.0.1:
 * Date: 30th July 2014
 * Changed by: Lewis Collins
 *   Changes:
 *     - Changed head-tracking event ID to 0xFF0D from 0xFF1A
 *
 * Version 1.6.0.0:
 * Date: 29th July 2014
 * Changed by: Lewis Collins
 *   Changes:
 *     - Modified to support WC1 head-tracking features
 *     - Re-wired certain UC/CI features via BladeRunner that
 *       are no longer supported on WC1 via Spokes, including:
 *         > Wearing state, Proximity, Mobile Call State,
 *           Mobile Mute State (new)
 *
 * Version 1.0.0.8:
 * Date: 4th May 2014
 * Changed by: Lewis Collins
 * Changes:
 *   - Minor fix for gyro calibration data format from WC1
 *
 * Version 1.0.0.7:
 * Date: 30th May 2014
 * Changed by: Lewis Collins
 * Changes:
 *   - Recompiled against updated BRLibrary so it now decodes
 *     the BladeRunner meta data (device services) correctly.
 *   - Made API subscribe head-tracking based on 0xFF1A event
 *     rather than now defunct FF00 command.
 *   - Fixed quaternion processor to work with WC1's 32-bit
 *     quaternions (were 16 bit before)
 *
 * Version 1.0.0.6:
 * Date: 22nd May 2014
 * Changed by: Lewis Collins
 * Changes:
 *   - Added auto-detect of 0xFF00 Configure Services deckard command
 *     to trigger automatic open connection of the API to connected app.
 *
 * Version 1.0.0.5:
 * Date: 21st May 2014
 * Changed by: Lewis Collins
 * Changes:
 *   - Included Deckard XML into the library release output
 *
 * Version 1.0.0.4:
 * Date: 12th May 2014
 * Changed by: Lewis Collins
 * Changes:
 *   - Have now incorporated BladeRunner PC API (BRLibrary.DLL). This allows
 *     the Innovation API to be used with WC1 rev2 and other Innovation device platforms.
 *
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
        //private bool m_isConnectedToBladeRunner = false;

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

        internal PLTMuteState m_lastmutestate = new PLTMuteState();
        internal Object m_lastmutestateLock = new Object();

        private bool m_headsetinrange = true; // assume in range initially
        private bool m_constructordone;
        private HIDDevice myDevice = null;
        private bool m_devicenotified = false;

        //// remove nasty hack
        //// NEW, a timer to wait for all host negotiates to complete
        //// before trying to register for head tracking data
        //Timer m_hostNegotiateTimer;
        //bool m_registeredForHeadTracking = false;
        //public bool m_triggerHTregister = false;
        //private Object m_triggerHTregisterLock = new Object();

        /// <summary>
        /// SDK_VERSION defines the current version of the PLTLabsAPI DLL
        /// (It matches the rev version of the Developer High-Level API Description document).
        /// </summary>
        public static string SDK_VERSION = "0.4";
        private BladeRunnerEndpoint BRendpoint;
        private bool m_wasMobIncoming = false;
        public PLTDevice m_wearingsensorDevice { get; set; }
        public PLTDevice m_proximityDevice { get; set; }

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
            m_wearingsensorDevice = null;
            m_proximityDevice = null;

            m_callbackhandler = aCallBackHandler;

            m_quatproc = new QuaternionProcessor(this);

            // New BladeRunner connect code
            //m_hostNegotiateTimer = new Timer();
            //m_hostNegotiateTimer.Interval = 7000;
            //m_hostNegotiateTimer.Elapsed += m_hostNegotiateTimer_Elapsed;

            //myDevice = new HIDDevice();
            //if (myDevice.ConnectFirstPlantronicsSupportingBladeRunner())
            //{
            //    Console.WriteLine("Successfully connected to a BladeRunner device:\r\nHID Path = " + myDevice.devicePathName + "\r\n");

            //    m_isConnectedToBladeRunner = true;

                BRendpoint = new BladeRunnerEndpoint(this);

                //BRendpoint.DiscoverDevices();

                //startHostNegotiateTimer();
            //}
            //else
            //{
            //    Console.WriteLine("Sorry, no Plantronics device supporting BladeRunner was found.\r\n");
            //}

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

        // removing old nasty hack
        //void m_hostNegotiateTimer_Elapsed(object sender, ElapsedEventArgs e)
        //{
        //    // host negotatation was complete...
        //    if (!m_registeredForHeadTracking)
        //    {
        //        Console.WriteLine("shall we register for HT?");
        //        Console.WriteLine("yes, lets...");
        //        lock (m_triggerHTregisterLock)
        //        {
        //            m_triggerHTregister = true;
        //        }
        //        //NotifyDevice();
        //        m_availableDevices.Add(new PLTDevice(myDevice));
        //        openConnection(m_availableDevices[0]);
        //        m_registeredForHeadTracking = true; // todo actually it is not yet ;-)
        //    }
        //}

        //private void RestartHostNegotiateTimer()
        //{
        //    m_hostNegotiateTimer.Stop();
        //    m_hostNegotiateTimer.Start();
        //}

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

        private void UpdateProximityStateToConnection(PLTProximityType proximitytype, byte rssistrength)
        {
            lock (m_lastproximitystateLock)
            {
                m_lastproximitystate.m_proximity = proximitytype;
                m_lastproximitystate.m_rssistrength = rssistrength;
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
            m_isConnectToDevice = false;
            m_activeConnection = null;
            m_callbackhandler.ConnectionClosed(aConnection.m_device);
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

        //bool IsConnectedToSpokes()
        //{
        //    return m_isConnectedToBladeRunner;
        //}

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
            if (myDevice != null) myDevice.Disconnect();

            

            m_quatproc.Stop();
            m_quatproc = null;

            BRendpoint.Shutdown();
            BRendpoint = null;

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

        public void HandleBRMessage(MsgReceivedArgs e)
        {
            // no BR-level action needed
        }

        void BladeRunnerHandler.HandleBRMessage(MsgReceivedArgs e)
        {
        }


        public void HandleDeckard(DeckardMessage deckardmessage, BladeRunnerDevice device)
        {
            PLTServiceSubscription subscr = null;
            // TODO
            // here interpret the deckard messages and
            // translate them into relevant service updates and service
            // messages destined for registed app's "infoUpdated" methods!!!

            // STEP 1, allow app to register for wearing state service and get that
            // working end to end

            //
            switch (deckardmessage.deckardCommand.id)
            {
                case "0x0101":
                    // likely the result of a host negatiate...
                    //if (!m_registeredForHeadTracking)
                    //{
                    //    RestartHostNegotiateTimer();
                    //    Console.WriteLine("Still probing devices...");
                    //}
                    break;
                case "0x0C00":
                    // device was connected

                    break;
                case "0x0A00":
                    string ProductName = deckardmessage.message_received.payload_received[0].stringValue;
                    Console.WriteLine("ProductName: " + ProductName);
                    break;
                case "0x0214":
                    Console.WriteLine(">>> 0x0214: ");
                    break;
                case "0x0216":
                    Console.WriteLine(">>> 0x0216: ");
                    break;
                case "0x0202":
                    Console.WriteLine(">>> 0x0202: ");
                    break;
                case "0x0200":
                    bool isworn = deckardmessage.message_received.payload_received[0].boolValue;
                    Console.WriteLine("Is Worn?: " + isworn);
                    m_lastwornstate.m_worn = isworn;
                    m_lastwornstate.m_isInitialStateEvent = false;

                    // Wearing state update
                    subscr =
                        m_activeConnection.getSubscription(PLTService.WEARING_STATE_SVC);
                    if (subscr != null)
                    {
                        lock (m_lastwornstateLock)
                        {
                            subscr.LastData = m_lastwornstate;
                        }
    
                        // if it is an on change subscription, beam to connected app now
                        // otherwise will happen in the PLTConnection's periodic timer
                        if (subscr.m_mode == PLTMode.On_Change)
                        {
                            m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.WEARING_STATE_SVC, subscr.LastData));
                        }
                    }
                    break;
                case "0x0800":
                    Console.WriteLine(">>> 0800: ");
                    break;
                case "0x0806":
                    if (deckardmessage.message_received.payload_received.Count() > 2)
                    {
                        byte connectionId = deckardmessage.message_received.payload_received[0].byteValue;
                        byte strength = deckardmessage.message_received.payload_received[1].byteValue;
                        byte nearfar = deckardmessage.message_received.payload_received[2].byteValue;

                        //<![CDATA[
                        //    The device's determination of whether it is Near to or Far from the device to which it is connected.
                        //    <a name="nearFarValues">
                        //    0 = Far<br/>
                        //    1 = Near<br/>
                        //    2 = Unknown<br/>
                        //    </a>
                        //]]>

                        UpdateProximityStateToConnection(nearfar == 0 ? PLTProximityType.Far : PLTProximityType.Near, strength);
                    }

                    break;
                //case "0x0E1E":
                //    // Audio status (mute/unmute/gain)
                //    if (deckardmessage.m_brtype == EBRMessageType.eBR_EVENT)
                //    {
                //        if (deckardmessage.message_received.payload_received.Count() > 3)
                //        {
                //            byte codec = deckardmessage.message_received.payload_received[0].byteValue;
                //            byte port = deckardmessage.message_received.payload_received[1].byteValue;
                //            byte speakergain = deckardmessage.message_received.payload_received[2].byteValue;
                //            byte micgain = deckardmessage.message_received.payload_received[3].byteValue;

                //            bool muteon = (micgain == 0);

                //            Console.WriteLine(">>> muteon: " + muteon);
                //            Console.WriteLine(">>> codec: " + codec);
                //            Console.WriteLine(">>> port: " + port);
                //            Console.WriteLine(">>> speakergain: " + speakergain);
                //            Console.WriteLine(">>> micgain: " + micgain);

                //            // update mute state to API event!
                //            m_lastmutestate.m_muted = muteon;
                //            subscr =
                //                m_activeConnection.getSubscription(PLTService.MUTESTATE_SVC);
                //            if (subscr != null)
                //            {
                //                lock (m_lastmutestateLock)
                //                {
                //                    subscr.LastData = m_lastmutestate;
                //                }

                //                // if it is an on change subscription, beam to connected app now
                //                // otherwise will happen in the PLTConnection's periodic timer
                //                if (subscr.m_mode == PLTMode.On_Change)
                //                {
                //                    m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.MUTESTATE_SVC, subscr.LastData));
                //                }
                //            }
                //        }
                //    }           
                //    break;
                case "0x0E01":
                    // Microphone Mute State
                    if (deckardmessage.m_brtype == EBRMessageType.eBR_EVENT)
                    {
                        if (deckardmessage.message_received.payload_received.Count() > 0)
                        {
                            bool muteon = deckardmessage.message_received.payload_received[0].boolValue;

                            Console.WriteLine(">>> muteon: " + muteon);

                            // update mute state to API event!
                            m_lastmutestate.m_muted = muteon;
                            subscr =
                                m_activeConnection.getSubscription(PLTService.MUTESTATE_SVC);
                            if (subscr != null)
                            {
                                lock (m_lastmutestateLock)
                                {
                                    subscr.LastData = m_lastmutestate;
                                }

                                // if it is an on change subscription, beam to connected app now
                                // otherwise will happen in the PLTConnection's periodic timer
                                if (subscr.m_mode == PLTMode.On_Change)
                                {
                                    m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.MUTESTATE_SVC, subscr.LastData));
                                }
                            }
                        }
                    }
                    break;
                case "0x0E00":
                    // Call status change
                    if (deckardmessage.m_brtype == EBRMessageType.eBR_EVENT)
                    {
                        if (deckardmessage.message_received.payload_received.Count() > 1)
                        {
                            byte state = deckardmessage.message_received.payload_received[0].byteValue;
                            string number = deckardmessage.message_received.payload_received[1].stringValue;

                            string tmp = number;
                            Console.WriteLine(">>> NUMBER: "+number);
                            Console.WriteLine(">>> state: " + state);

                            PLTCallStateInfo callstate = new PLTCallStateInfo();
                            // Did this call status come from PC call, or from Mobile device?
                            callstate.m_callsource = deckardmessage.m_addresshex != "0000000" ? 
                                "Mobile" : "PC";
                            callstate.m_callid = -1;
                            switch (state)
                            {
                                case 0: //Idle
                                    callstate.m_callstate = PLTCallState.Idle;
                                    m_wasMobIncoming = false;
                                    break;
                                case 1: //Active
                                    callstate.m_callstate = PLTCallState.OnCall;
                                    break;
                                case 2: //Ringing
                                    callstate.m_callstate = PLTCallState.Ringing;
                                    m_wasMobIncoming = true;
                                    break;
                                case 3: //Dialing
                                    callstate.m_callstate = PLTCallState.Ringing;
                                    m_wasMobIncoming = false;
                                    break;
                                case 4: // ActiveAndRinging
                                    callstate.m_callstate = PLTCallState.Ringing;
                                    m_wasMobIncoming = true;
                                    break;
                                default:
                                    break;
                            }

                            UpdateCallStateToConnection(PLTCallStateType.OnMobileCall, callstate.m_callstate,
                                callstate.m_callid, callstate.m_callsource, m_wasMobIncoming);
                            UpdateMobileCallerIdToConnection(number);                            
                        }
                    }           
                    break;
                //case "0xFF1A":
                case "0xFF0D":
                    Console.WriteLine(">>> HEAD TRACKING: ");

                    if (deckardmessage.message_received.payload_received.Count()>0)
                    {
                        //        Head orientation                0x0000<br/>
                        //        Pedometer                       0x0002<br/>
                        //        Free Fall                       0x0003<br/>
                        //        Taps                            0x0004<br/>
                        //        Magnetometer Calibration Status 0x0005<br/>
                        //        Gyroscope Calibration Status    0x0006<br/>
                        //        Versions                        0x0007<br/>
                        //        Humidity                        0x0008<br/>
                        //        Light                           0x0009<br/>
                        //        Optical proximity               0x0010<br/>
                        //        Ambient Temp 1                  0x0011<br/>
                        //        Ambient Temp 2                  0x0012<br/>
                        //        Skin Temp                       0x0013<br/>
                        //        Skin Conductivity               0x0014<br/>
                        //        Ambient Pressure                0x0015<br/>
                        //        Heart Rate                      0x0016<br/>

                        // ok, which service is this for?
                        int serviceid = deckardmessage.message_received.payload_received[0].uint16Value;
                        subscr = null;
                        bool calib, freefall;
                        switch (serviceid)
                        {
                            case 0:
                                // Head orientation
                                subscr =
                                    m_activeConnection.getSubscription(PLTService.MOTION_TRACKING_SVC);
                                if (subscr != null)
                                {
                                    // ok, let's try to break out those head tracking quatenions...
                                    m_quatproc.ProcessByteArray(deckardmessage.message_received.payload_received[2].barray);
                                }
                                break;
                            case 3:
                                // Free fall
                                subscr =
                                    m_activeConnection.getSubscription(PLTService.FREE_FALL_SVC);
                                if (subscr != null)
                                {
                                    //freefall = deckardmessage.message_received.payload_received[2].barray[1] == 1;
                                    freefall = deckardmessage.message_received.payload_received[2].barray[0] == 1;

                                    PLTFreeFall data = new PLTFreeFall();
                                    data.m_isinfreefall = freefall;

                                    subscr.LastData = data;

                                    if (subscr.m_mode == PLTMode.On_Change)
                                    {
                                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.FREE_FALL_SVC, data));
                                    }
                                }
                                break;
                            case 5:
                                // magno calib
                                //calib = deckardmessage.message_received.payload_received[2].barray[1] == 3;
                                calib = deckardmessage.message_received.payload_received[2].barray[0] == 3;

                                // SENSOR_CAL_STATE_SVC data for sensor cal state service...
                                subscr =
                                    m_activeConnection.getSubscription(PLTService.SENSOR_CAL_STATE_SVC);
                                if (subscr != null)
                                {
                                    PLTSensorCal data = new PLTSensorCal();
                                    data.m_isgyrocal = subscr.LastData != null ? ((PLTSensorCal)subscr.LastData).m_isgyrocal : false;
                                    data.m_ismagnetometercal = calib;

                                    subscr.LastData = data;

                                    if (subscr.m_mode == PLTMode.On_Change)
                                    {
                                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.SENSOR_CAL_STATE_SVC, data));
                                    }
                                }
                                break;
                            case 6:
                                // gyro calib
                                //calib = deckardmessage.message_received.payload_received[2].barray[1] == 3;
                                calib = deckardmessage.message_received.payload_received[2].barray[0] == 3;
                                // SENSOR_CAL_STATE_SVC data for sensor cal state service...
                                subscr =
                                    m_activeConnection.getSubscription(PLTService.SENSOR_CAL_STATE_SVC);
                                if (subscr != null)
                                {
                                    PLTSensorCal data = new PLTSensorCal();
                                    data.m_isgyrocal = calib;
                                    data.m_ismagnetometercal = subscr.LastData != null ? ((PLTSensorCal)subscr.LastData).m_ismagnetometercal : false;

                                    subscr.LastData = data;

                                    if (subscr.m_mode == PLTMode.On_Change)
                                    {
                                        m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.SENSOR_CAL_STATE_SVC, data));
                                    }
                                }
                                break;


                            //for (int i = 0; i < deckardmessage.message_received.payload_received.Count(); i++)
                            //{
                            //    Console.Write(deckardmessage.deckardCommand.payload_out[i].name + ": ");
                            //    switch (deckardmessage.deckardCommand.payload_out[i].mType)
                            //    {
                            //        case Deckard.BRType.BR_TYPE_UNSIGNED_INT:
                            //            Console.WriteLine(deckardmessage.message_received.payload_received[i].int32Value);
                            //            break;
                            //        case Deckard.BRType.BR_TYPE_BYTE_ARRAY:
                            //            for (int j = 0; j < deckardmessage.message_received.payload_received[i].barray.Count(); j++)
                            //            {
                            //                Console.Write(deckardmessage.message_received.payload_received[i].barray[j] + ", ");
                            //            }
                            //            Console.WriteLine();
                            //            if (m_activeConnection != null) // todo only do this if subscribed to relevant service?
                            //            {
                            //                // ok, let's try to break out those head tracking quatenions...
                            //                m_quatproc.ProcessByteArray(deckardmessage.message_received.payload_received[i].barray);
                            //                //m_callbackhandler.infoUpdated(m_activeConnection, new PLTInfo(PLTService.DEBUGINFO_SVC, payload_received[i].barray));
                            //            }
                            //            break;
                            //    }
                            //}
                        }
                    }
                    break;
                default:
                    Console.WriteLine(">> UNKNOWN Deckard received, ID was: (" + deckardmessage.deckardCommand.id + ").");
                    break;
            }
        }

        public void NotifyDeviceServices(BladeRunnerDevice device)
        {
            if (device.DeviceAddress == "2000000")
            {
                // hack - force to use headset for wear sensor
                if (m_wearingsensorDevice == null)
                {
                    PLTDevice aDevice = new PLTDevice(device);
                    m_wearingsensorDevice = aDevice;
                }
            }

            // Let's see if attached devices supports Motion Tracking and other services!
            foreach (int commandid in device.SupportedEvents)
            {
                // does the id match the Subscribed service data event id: 0xFF0D  (was 0xFF1A)
                if (commandid == 0xFF0D) //0xFF1A)
                {
                    //Found a device with Motion Tracking - lets open the connection to it...
                    PLTDevice aDevice = new PLTDevice(device);
                    if (!getIsConnected(aDevice))
                    {
                        // open the API connection to this device
                        openConnection(aDevice);
                    }
                }

                // does it match for wearing sensor don/doff?
                if (commandid == 0x0216)
                {
                    //Found a device with wearing sensor
                    PLTDevice aDevice = new PLTDevice(device);

                    if (m_wearingsensorDevice == null)
                        m_wearingsensorDevice = aDevice;
                }

                // does it match for proximity?
                if (commandid == 0x0806)
                {
                    //Found a device with wearing sensor
                    PLTDevice aDevice = new PLTDevice(device);

                    if (m_proximityDevice == null)
                        m_proximityDevice = aDevice;
                }
            }

            foreach (int commandid in device.SupportedCommands)
            {

                // does it match for wearing sensor don/doff?
                if (commandid == 0x0216)
                {
                    //Found a device with wearing sensor
                    PLTDevice aDevice = new PLTDevice(device);

                    if (m_wearingsensorDevice == null)
                        m_wearingsensorDevice = aDevice;
                }

                // does it match for proximity?
                if (commandid == 0x0806)
                {
                    //Found a device with wearing sensor
                    PLTDevice aDevice = new PLTDevice(device);

                    if (m_proximityDevice == null)
                        m_proximityDevice = aDevice;
                }
            }

            // Inform connected app about this device's services (from device BladeRunner meta data)
            if (m_callbackhandler != null)
            {
                m_callbackhandler.NotifyDeviceServices(new PLTDevice(device));
            }
        }

        //public void RegisterForHeadTracking(string deviceaddress)
        //{
        //    // device connected, ok lets query it's services
        //    // send a <setting name="Get device info" id="0xFF18"> to the received port

        //    // TODO move a lot of this logic into BladeRunnerEndpoint to make discovery
        //    // of device info and services more automatic
        //    // plus implement the ***send queue*** with ack checking before sending next command etc
        //    // as recommended by David Hudson

        //    //// work out target device address (connected address + port)
        //    //byte port = payload_received[0].byteValue;
        //    //string targetaddress = BladeRunnerEndpoint.AppendPortToEndOfAddress(addresshex, port);

        //    ////prepare query device name command
        //    //BRendpoint.SendBladeRunnerMessage(
        //    //    EBRMessageType.eBR_GET_SETTING,
        //    //    "1500000",
        //    //    //targetaddress,
        //    //    "0x0A00");

        //    //// prepare query services command
        //    //BRendpoint.SendBladeRunnerMessage(
        //    //    EBRMessageType.eBR_GET_SETTING,
        //    //    targetaddress,
        //    //    "0xFF18");

        //    // prepare subscribe to headtracking service command
        //    List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement> payload
        //        = new List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement>();
        //    payload.Add(new Deckard.BRProtocolElement((UInt16)0)); // want head tracking
        //    payload.Add(new Deckard.BRProtocolElement((UInt16)0)); // characteristic
        //    payload.Add(new Deckard.BRProtocolElement((UInt16)1)); // 2 = periodic, 1 = onchange
        //    payload.Add(new Deckard.BRProtocolElement((UInt16)50)); // period in ms
        //    BRendpoint.SendBladeRunnerMessage(
        //        EBRMessageType.eBR_COMMAND,
        //        deviceaddress,
        //        "0xFF0A",
        //        payload);

        //    //for (int i = 2; i < 17; i++)
        //    //{
        //    //    // subscribe other services
        //    //    payload
        //    //        = new List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement>();
        //    //    payload.Add(new Deckard.BRProtocolElement((UInt16)i)); // want head tracking
        //    //    payload.Add(new Deckard.BRProtocolElement((UInt16)0)); // characteristic
        //    //    payload.Add(new Deckard.BRProtocolElement((UInt16)1)); // 2 = periodic, 1 = onchange
        //    //    payload.Add(new Deckard.BRProtocolElement((UInt16)0)); // period in ms
        //    //    BRendpoint.SendBladeRunnerMessage(
        //    //        EBRMessageType.eBR_COMMAND,
        //    //        deviceaddress,
        //    //        "0xFF0A",
        //    //        payload);
        //    //}

        //    //m_registeredForHeadTracking = true;
        //}

        public void DeviceAdded(BladeRunnerDevice device)
        {
            if (m_callbackhandler != null)
            {
                m_callbackhandler.DeviceAdded(new PLTDevice(device));
            }
        }

        public void DeviceRemoved(BladeRunnerDevice device)
        {
            if (m_callbackhandler != null)
            {
                m_callbackhandler.DeviceRemoved(new PLTDevice(device));

                // Hack, always disconnect client at this point
                m_callbackhandler.ConnectionClosed(new PLTDevice(device));

                m_isConnectToDevice = false;
                m_activeConnection = null;
            }
        }

        public void NotifyDeviceInfoUpdated(BladeRunnerDevice device, DeviceInfoChange whatChanged)
        {
            if (m_callbackhandler != null)
            {
                m_callbackhandler.NotifyDeviceInfoUpdated(new PLTDevice(device), (PLTDeviceInfoChange)whatChanged);
            }
        }

        //public List<HidInformation> GetDevicesList()
        //{
        //    List<HidInformation> devices = BRendpoint.GetDevicesList();
        //    return devices;
        //}

        public void RegisterForDeviceSensorService(BladeRunnerDevice device, int service = 0, int servicemode = 1, int periodmillis = 50, int characteristic = -1)
        {
            //if (service == 1 || service > 6) return; // for now, invalid service id

            if (periodmillis < 50) periodmillis = 50;
            if (characteristic == -1) characteristic = service;

            //// turn off other services:
            //for (int i = 0; i < 7; i++)
            //{
            //    if ((i != service) && i != 1)
            //    {
            //        // turn on requested service
            //        // prepare subscribe to headtracking service command
            //        List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement> payload
            //            = new List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement>();
            //        payload.Add(new Deckard.BRProtocolElement((UInt16)i)); // want head tracking
            //        payload.Add(new Deckard.BRProtocolElement((UInt16)i)); // characteristic
            //        payload.Add(new Deckard.BRProtocolElement((UInt16)0)); // 2 = periodic, 1 = onchange, 0 = off
            //        payload.Add(new Deckard.BRProtocolElement((UInt16)periodmillis)); // period in ms
            //        BRendpoint.SendBladeRunnerMessage(
            //            EBRMessageType.eBR_COMMAND,
            //            deviceaddress,
            //            "0xFF0A",
            //            payload, 2);
            //    }
            //}

            // turn on requested service:
            // prepare subscribe to headtracking service command
            List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement> payload2
                = new List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement>();
            payload2.Add(new Deckard.BRProtocolElement((UInt16)service)); // want head tracking
            payload2.Add(new Deckard.BRProtocolElement((UInt16)characteristic)); // characteristic
            payload2.Add(new Deckard.BRProtocolElement((UInt16)servicemode)); // 2 = periodic, 1 = onchange, 0 = off
            payload2.Add(new Deckard.BRProtocolElement((UInt16)periodmillis)); // period in ms
            BRendpoint.SendBladeRunnerMessage(device,
                EBRMessageType.eBR_COMMAND,
                device.DeviceAddress,
                "0xFF0A",
                payload2, 2);
        }

        internal void RegisterForDeviceWearingStateService(BladeRunnerDevice device, bool enable)
        {
            // turn on requested service:
            // prepare subscribe to wearing state sensor service command
            List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement> payload2
                = new List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement>();
            payload2.Add(new Deckard.BRProtocolElement((bool)enable)); // enable or disable
            BRendpoint.SendBladeRunnerMessage(device,
                EBRMessageType.eBR_COMMAND,
                device.DeviceAddress,
                "0x0216",
                payload2, 2);

            // and do a get!
            BRendpoint.SendBladeRunnerMessage(device,
                EBRMessageType.eBR_GET_SETTING,
                device.DeviceAddress,
                "0x0202",
                null, 2);
        }

        internal void RegisterForDeviceProximityService(BladeRunnerDevice device, bool enable)
        {
            // turn on requested service:
            // prepare subscribe to wearing state sensor service command
            List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement> payload2
                = new List<Plantronics.Innovation.BRLibrary.Deckard.BRProtocolElement>();

            payload2.Add(new Deckard.BRProtocolElement((byte)2)); // connectionId
            payload2.Add(new Deckard.BRProtocolElement((bool)enable)); // enable
            payload2.Add(new Deckard.BRProtocolElement((bool)true)); // dononly
            payload2.Add(new Deckard.BRProtocolElement((bool)true)); // disabletrend
            payload2.Add(new Deckard.BRProtocolElement((bool)true)); // report rssi audio
            payload2.Add(new Deckard.BRProtocolElement((bool)true)); // report near far audio
            payload2.Add(new Deckard.BRProtocolElement((bool)true)); // report near far to base
            payload2.Add(new Deckard.BRProtocolElement((byte)1)); // sensitivity
            payload2.Add(new Deckard.BRProtocolElement((byte)71)); // near threshold
            payload2.Add(new Deckard.BRProtocolElement((short)10)); // max timeout

            BRendpoint.SendBladeRunnerMessage(device,
                EBRMessageType.eBR_COMMAND,
                device.DeviceAddress,
                "0x0800",
                payload2, 2);
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

        void DeviceRemoved(PLTDevice pltDevice);

        void NotifyDeviceServices(PLTDevice pltDevice);

        void NotifyDeviceInfoUpdated(PLTDevice pltDevice, PLTDeviceInfoChange whatChanged);
    }
}
