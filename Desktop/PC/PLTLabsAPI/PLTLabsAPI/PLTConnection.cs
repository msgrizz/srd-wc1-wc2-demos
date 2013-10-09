using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Plantronics.UC.SpokesWrapper;
using Interop.Plantronics;

namespace Plantronics.Innovation.PLTLabsAPI
{
    /// <summary>
    /// PLTConnection is like a proxy service between
    /// the application and the PLTLabsAPI / Spokes connection.
    /// When you connect to PLTLabsAPI you receive a PLTConnection
    /// object, which includes vermaj, vermin members that reveal
    /// the device firmware version, and the PLTDevice of this
    /// connection, being the device that is connected to.
    /// </summary>
    public class PLTConnection
    {
        private Spokes m_spokes;
        private PLTLabsAPI m_pltlabsapi;

        /// <summary>
        /// This member holds a reference to the PLTDevice object for this connection
        /// (the device that is connected to)
        /// </summary>
        public PLTDevice m_device;

        List<PLTServiceSubscription> m_subscribedServices = new List<PLTServiceSubscription>();
        private object m_subscribedServicesLock = new Object();

        /// <summary>
        /// The major version number of connected device firmware
        /// </summary>
        public int vermaj;
        /// <summary>
        /// The minor version number of connected device firmware
        /// </summary>
        public int vermin;

        /// <summary>
        /// Returns a string representation of the device Product Name
        /// </summary>
        public string DeviceName 
        {
            get 
            {
                return (m_device != null && m_device.m_ProductName != "" ? m_device.m_ProductName : "");
            }
        }

        internal PLTConnection(Spokes aSpokesConnection, PLTLabsAPI aPLTLabsAPI, PLTDevice aDevice)
        {
            m_spokes = aSpokesConnection;
            m_pltlabsapi = aPLTLabsAPI;
            m_device = aDevice; 
        }

        internal void subscribe(PLTService aService, PLTMode aMode, int aPeriodmilliseconds = 0)
        {
            // cannot subscribe to same service twice
            if (isSubscribed(aService)) return;

            bool doSubscribe = false;
            object lastData = null;

            // work out if we can/should subscribe to the service
            switch (aService)
            {
                case PLTService.MOTION_TRACKING_SVC:
                    // TODO add to Spokes knowledge of which device
                    // has motion tracking. For now just assume all
                    // devices do.
                    doSubscribe = true;
                    break;
                case PLTService.MOTION_STATE_SVC:
                    // TODO: does the headset provide this info?
                    throw new Exception("Sorry, motion state service is not yet implemented.");
                    doSubscribe = false;
                    break;
                case PLTService.SENSOR_CAL_STATE_SVC:
                    doSubscribe = true;
                    break;
                case PLTService.PEDOMETER_SVC:
                    doSubscribe = true;
                    break;
                case PLTService.TAP_SVC:
                    if (aMode == PLTMode.On_Change) doSubscribe = true;
                    else throw new Exception("Sorry, tap service only supports PLTMode.On_Change mode (not PLTMode.Periodic).");
                    break;
                case PLTService.WEARING_STATE_SVC:
                    if (m_spokes.DeviceCapabilities.HasWearingSensor)
                    {
                        doSubscribe = true;
                        lock (m_pltlabsapi.m_lastwornstateLock)
                        {
                            lastData = m_pltlabsapi.m_lastwornstate;
                        }
                    }
                    else
                    {
                        throw new Exception("Sorry, device does not have a wearing sensor. Unable to subscribe to wearing sensor data.");
                    }
                    break;
                case PLTService.FREE_FALL_SVC:
                    if (aMode == PLTMode.On_Change) doSubscribe = true;
                    else throw new Exception("Sorry, tap service only supports PLTMode.On_Change mode (not PLTMode.Periodic).");
                    break;
                case PLTService.PROXIMITY_SVC:
                    // Don't bother checking m_spokes.DeviceCapabilities.HasProximity, as this is
                    // generally populated with correct value later asyncronously if enable proximity call
                    // succeeded
                    doSubscribe = true;
                    lock (m_pltlabsapi.m_lastproximitystateLock)
                    {
                        lastData = m_pltlabsapi.m_lastproximitystate;
                    }
                    break;
                case PLTService.CALLERID_SVC:
                    doSubscribe = true;
                    lock (m_pltlabsapi.m_lastcalleridLock)
                    {
                        lastData = m_pltlabsapi.m_lastcallerid;
                    }
                    break;
                case PLTService.CALLSTATE_SVC:
                    if (aMode == PLTMode.On_Change)
                    {
                        doSubscribe = true;
                        lock (m_pltlabsapi.m_lastcallstateLock)
                        {
                            lastData = m_pltlabsapi.m_lastcallstate;
                        }
                    }
                    else throw new Exception("Sorry, call state only supports PLTMode.On_Change mode (not PLTMode.Periodic).");
                    break;
                case PLTService.DOCKSTATE_SVC:
                    doSubscribe = true;
                    lock (m_pltlabsapi.m_lastdockstateLock)
                    {
                        lastData = m_pltlabsapi.m_lastdockstate;
                    }
                    break;
                case PLTService.CHARGESTATE_SVC:
                    // todo consider not making wireless devices subcribe - no battery
                    doSubscribe = true;
                    lock (m_pltlabsapi.m_lastbattstateLock)
                    {
                        lastData = m_pltlabsapi.m_lastbattstate;
                    }
                    break;
                //case PLTService.TEMPERATURE_SVC:
                //    doSubscribe = true;
                //    break;
            }

            if (doSubscribe)
            {
                PLTServiceSubscription subscr;
                subscr = new PLTServiceSubscription(this,
                    aService, aMode, aPeriodmilliseconds, lastData);
                lock (m_subscribedServicesLock)
                {
                    m_subscribedServices.Add(subscr);
                }

                // NOTE: for SOME services we want to ship the last known value right
                // away to connected app, because for those services such as wearing sensor
                // the last known value will be the "initial" value. (Does not apply to
                // headtracking).
                if (aService == PLTService.WEARING_STATE_SVC
                    || aService == PLTService.CHARGESTATE_SVC
                    )
                {
                    ShipLastKnownDataToAppForService(aService, subscr);
                }
            }

        }

        // Pass lastSubscriptionData to contain reference to last value for this subscription
        // or NULL where no value is available (for instance with wearing sensor before
        // a subcription has been made).
        private void ShipLastKnownDataToAppForService(PLTService aService, PLTServiceSubscription aSubscription)
        {
            if (m_pltlabsapi.
                m_callbackhandler != null && m_pltlabsapi.m_activeConnection != null
                && aSubscription != null)
            {
                // now work out if we should send the last known value (applies to some services
                // e.g. wearing sensor, so app can receive initial value)
                switch (aService)
                {
                    case PLTService.MOTION_TRACKING_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTMotionTrackingData)aSubscription.LastData));
                        break;
                    case PLTService.MOTION_STATE_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTMoving)aSubscription.LastData));
                        break;
                    case PLTService.SENSOR_CAL_STATE_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTSensorCal)aSubscription.LastData));
                        break;
                    case PLTService.PEDOMETER_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTPedometerCount)aSubscription.LastData));
                        break;
                    case PLTService.TAP_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTTapInfo)aSubscription.LastData));
                        break;
                    case PLTService.WEARING_STATE_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTWearingState)aSubscription.LastData));
                        break;
                    case PLTService.FREE_FALL_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTFreeFall)aSubscription.LastData));
                        break;
                    case PLTService.PROXIMITY_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTProximityType)aSubscription.LastData));
                        break;
                    case PLTService.CALLERID_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTCallerId)aSubscription.LastData));
                        break;
                    case PLTService.CALLSTATE_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTCallStateInfo)aSubscription.LastData));
                        break;
                    case PLTService.DOCKSTATE_SVC:
                        m_pltlabsapi.
                            m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTDock)aSubscription.LastData));
                        break;
                    case PLTService.CHARGESTATE_SVC:
                        m_pltlabsapi.m_callbackhandler.infoUpdated(
                                m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTBatteryState)aSubscription.LastData));
                        break;
                    //case PLTService.TEMPERATURE_SVC:
                    //    m_pltlabsapi.
                    //        m_callbackhandler.infoUpdated(
                    //            m_pltlabsapi.m_activeConnection, new PLTInfo(aService, (PLTTemperature)aSubscription.LastData));
                    //    break;
                }
            }
        }

        internal void unsubscribe(PLTService aService)
        {
            List<PLTServiceSubscription> m_deleteList = new List<PLTServiceSubscription>();

            lock (m_subscribedServicesLock)
            {
                foreach (PLTServiceSubscription subscr in m_subscribedServices)
                {
                    if (subscr.m_service == aService)
                    {
                        m_deleteList.Add(subscr);
                    }
                }

                // now actually delete those found matching service type
                foreach (PLTServiceSubscription subscr in m_deleteList)
                {
                    m_subscribedServices.Remove(subscr);
                }
            }
        }

        internal PLTService[] getSubscribed()
        {
            PLTService[] retval = new PLTService[0];
            lock (m_subscribedServicesLock)
            {
                retval = new PLTService[m_subscribedServices.Count()];

                int i = 0;
                foreach (PLTServiceSubscription subscr in m_subscribedServices)
                {
                    retval[i] = subscr.m_service;
                    i++;
                }
            }
            return retval;
        }

        internal bool isSubscribed(PLTService pLTService)
        {
            bool retval = false;
            lock (m_subscribedServicesLock)
            {
                foreach (PLTServiceSubscription subscr in m_subscribedServices)
                {
                    if (subscr.m_service == pLTService)
                    {
                        retval = true;
                        break;
                    }
                }
            }
            return retval;            
        }

        internal PLTServiceSubscription getSubscription(PLTService pLTService)
        {
            PLTServiceSubscription retval = null;
            lock (m_subscribedServicesLock)
            {
                foreach (PLTServiceSubscription subscr in m_subscribedServices)
                {
                    if (subscr.m_service == pLTService)
                    {
                        retval = subscr;
                        break;
                    }
                }
            }
            return retval;
        }

        // a periodic service subscription timer has fired
        // ship the last known data to the connected app
        internal void ServiceTimerElapsed(PLTService aService, PLTServiceSubscription aSubscription, object lastSubscriptionData)
        {
            ShipLastKnownDataToAppForService(aService, aSubscription);
        }

        internal void CloseAllSubscriptions()
        {
            lock (m_subscribedServicesLock)
            {
                foreach (PLTServiceSubscription subscr in m_subscribedServices)
                {
                    if (subscr.m_mode == PLTMode.Periodic)
                    {
                        subscr.m_periodTimer.Stop();
                    }
                }
                m_subscribedServices.Clear();
            }
        }
    }
}
