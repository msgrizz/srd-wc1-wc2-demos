

using System;
using System.Timers;
namespace Plantronics.Innovation.PLTLabsAPI2
{
    /// <summary>
    /// An enumeration of all the services you can register for on device
    /// </summary>
    public enum PLTService
    {
        MOTION_TRACKING_SVC,
        MOTION_STATE_SVC,
        SENSOR_CAL_STATE_SVC,
        PEDOMETER_SVC,
        TAP_SVC,
        WEARING_STATE_SVC,
        FREE_FALL_SVC,
        PROXIMITY_SVC,
        CALLERID_SVC,
        CALLSTATE_SVC,
        DOCKSTATE_SVC,
        CHARGESTATE_SVC,
        //TEMPERATURE_SVC - not currently available
        DEBUGINFO_SVC
    }

    /// <summary>
    /// An enumaration of datatypes that can be received from subscribed services
    /// (used for casting void reference back to correct data type when you receive
    /// some data)
    /// </summary>
    public enum PLTStatussDataType
    {
        PLTQuaternion,
        PLTOrientation,
        PLTMoving,
        PLTSensorCal,
        PLTPedometerCount,
        PLTTapInfo,
        PLTWear,
        PLTFreeFall,
        PLTProximity,
        PLTCallerId,
        PLTCallState,
        PLTDock,
        PLTCharge
    }

    /// <summary>
    /// The mode to receice data, to a time period or as soon as it changes
    /// </summary>
    public enum PLTMode
    {
        Periodic,
        On_Change
    }

    // OK, lets define data types for all the status objects (PLTInfo data) that come from head track API

    /// <summary>
    /// An object to hold quaternion
    /// </summary>
    public class PLTQuaternion
    {
        public double[] m_quaternion = new double[4]; // TODO is this the right data type?
    }

    /// <summary>
    /// An object to hold an orientation (Euler angles)
    /// </summary>
    public class PLTOrientation
    {
        public double[] m_orientation = new double[3]; // TODO is this the right data type?
    }

    /// <summary>
    /// An object to return motion tracking data to the application that is
    /// registered for motion tracking service.
    /// Note, depending how you have configured motion tracking you may receive
    /// raw quaternion only, calibrated quaternions and orientations (Euler
    /// angles). Refer to the SDK configureService method
    /// </summary>
    public class PLTMotionTrackingData
    {
        public double[] m_orientation = new double[3];
        public double[] m_calquaternion = new double[4];
        public double[] m_rawquaternion = new double[4];
        public string m_rawreport = null;
        public PLTConfiguration m_offset_config = PLTConfiguration.MotionSvc_Offset_Raw;
        public PLTConfiguration m_format_config = PLTConfiguration.MotionSvc_Format_Quaternion;
    }

    /// <summary>
    /// Flag to indicate if device is moving (Motion state service)
    /// </summary>
    public class PLTMoving
    {
        public bool m_ismoving = false;
    }

    /// <summary>
    /// Object to specify if gyro is calibrated.
    /// **NOTE:** from device switch on place it on desk until the
    /// SENSOR_CAL_STATE_SVC returns a PLTSensorCal with
    /// m_isgyrocal == true.
    /// </summary>
    public class PLTSensorCal
    {
        public bool m_isgyrocal = false;
        public bool m_ismagnetometercal = false;
    }

    /// <summary>
    /// Object with how many steps have been taken with device.
    /// Note, only starts counting after person has set up a steady
    /// gait and taken about 8 steps.
    /// </summary>
    public class PLTPedometerCount
    {
        public int m_pedometercount = 0;
    }

    /// <summary>
    /// Enum values to determine direction of tap on the device
    /// </summary>
    public enum PLTTapDirection
    {
        None,
        XUp,
        XDown,
        YUp,
        YDown,
        ZUp,
        ZDown
    }

    /// <summary>
    /// Object to return how many taps where made on device and
    /// in which direction
    /// </summary>
    public class PLTTapInfo
    {
        public int m_tapcount = 0;
        public PLTTapDirection m_tapdirection = PLTTapDirection.None;
    }

    /// <summary>
    /// Object to return if the headset is worn or not
    /// and if this is the initial state at application start
    /// </summary>
    public class PLTWear
    {
        public bool m_isworn = false;
        public bool m_isinitialstatus = false;
    }

    /// <summary>
    /// Object to return if device is in freefall
    /// </summary>
    public class PLTFreeFall
    {
        public bool m_isinfreefall = false;
    }

    /// <summary>
    /// Types of proximity states than can occur with device
    /// PC-to-device proximity
    /// </summary>
    public enum PLTProximityType
    {
        Near,
        Far,
        Unknown
    }

    /// <summary>
    /// Object to return the current proximity state between
    /// PC and Device (is it near/far/unknown)
    /// </summary>
    public class PLTProximity
    {
        /// <summary>
        /// Proximity state enumeration value (Near, Far, Unknown)
        /// </summary>
        public PLTProximityType m_proximity;
    }

    /// <summary>
    /// Type of caller id (Mobile, Softphone, Deskphone)
    /// (Platform only currently returns Mobile caller id's)
    /// </summary>
    public enum PLTCallerIdType
    {
        Mobile,
        Softphone,
        Deskphone
    }

    /// <summary>
    /// Used to return the caller id from the Plantronics device
    /// for example during inbound mobile call with mobile paired
    /// with headset, the PC app will receive the mobile caller id
    /// </summary>
    public class PLTCallerId
    {
        public PLTCallerIdType m_calltype;
        public string m_callerid = "";
    }

    /// <summary>
    /// A type of call state that can occur
    /// (on or not on a VoIP call, on or not on a Mobile call)
    /// </summary>
    public enum PLTCallStateType
    {
        NotOnCall,
        OnCall,
        NotOnMobileCall,
        OnMobileCall
    }

    /// <summary>
    /// A call status that can occur for given call state type
    /// i.e. is that call Ringing/OnCall or Idle
    /// </summary>
    public enum PLTCallState
    {
        Ringing,
        OnCall,
        Idle
    }

    /// <summary>
    /// Used to return a call state data event from Plantronics
    /// to your application. This can be used to inform you of
    /// changes in softphone call state for the ~13 Spokes-supported
    /// softphones, and also in mobile call states for mobile that
    /// is paired with headset.
    /// </summary>
    public class PLTCallStateInfo
    {
        public PLTCallStateType m_callstatetype;
        public PLTCallState m_callstate;
        public int m_callid;
        public string m_callsource = "";
        public bool m_incoming;
    }

    /// <summary>
    /// Type of configurations that can be set in the PLTLabsAPI
    /// services. For example Motion Service you can configure
    /// raw or calibrated quaternions, plus quaternion only or
    /// also orientation output (Euler angles)
    /// </summary>
    public enum PLTConfiguration
    {
        MotionSvc_Offset_Raw,
        MotionSvc_Offset_Calibrated,
        MotionSvc_Format_Quaternion,
        MotionSvc_Format_Orientation
    }

    /// <summary>
    /// Used to pass back to your app whether the headset device
    /// is docked or not (when registered for docking service)
    /// </summary>
    public class PLTDock
    {
        /// <summary>
        /// Flag to indicate if headset is in it's docking base or not
        /// </summary>
        public bool m_isdocked = false;
        public bool m_isinitialstatus = false;
    }

    /// <summary>
    /// Used to return to app registed for charge service the current
    /// battery level information of headset.
    /// </summary>
    //public class PLTCharge
    //{
    //    DeviceBatteryLevel m_batteryLevel = DeviceBatteryLevel.BatteryLevel_Empty;
    //}

    //public class PLTTemperature
    //{
    //    public int m_temperature = 0; // in degrees celcius
    //}

    internal class PLTServiceSubscription
    {
        public PLTService m_service = PLTService.MOTION_TRACKING_SVC;
        public PLTMode m_mode = PLTMode.On_Change;
        public int m_periodMilliseconds = 0;
        public Timer m_periodTimer = null;

        // hold a copy of that last data object received for each subscription type:
        private object m_lastData = null;
        private object m_lastDataLock = new Object();
        private PLTConnection m_pltconnection;

        public object LastData { 
            get
            {
                Object retval = null;
                lock (m_lastDataLock)
                {
                    retval = m_lastData;
                }
                return retval;
            }
            
            set
            {
                lock (m_lastDataLock)
                {
                    m_lastData = value;
                }
            }
        }

        public PLTServiceSubscription(PLTConnection aConnection, PLTService aService, PLTMode aMode, int aPeriodMilliseconds,
            object aLastdata = null)
        {
            m_pltconnection = aConnection;
            m_service = aService;
            m_mode = aMode;
            m_periodMilliseconds = aPeriodMilliseconds;
            m_lastData = aLastdata; // last data or initial value
            if (aMode == PLTMode.Periodic)
            {
                if (aPeriodMilliseconds < 1)
                {
                    throw new Exception("Sorry, for periodic service subscription you must specify the period in milliseconds!");
                }
                else
                {
                    m_periodTimer = new Timer();
                    m_periodTimer.Interval = aPeriodMilliseconds;
                    m_periodTimer.Elapsed += new ElapsedEventHandler(m_periodTimer_Elapsed);
                    m_periodTimer.Start();
                }
            }
        }

        void m_periodTimer_Elapsed(object sender, ElapsedEventArgs e)
        {
            m_pltconnection.ServiceTimerElapsed(m_service, this, m_lastData);
        }
    }

    /// <summary>
    /// Used to return to your app whether the headset is worn or not
    /// and if the wearing state is at application start (initial state event)
    /// or not.
    /// </summary>
    public class PLTWearingState
    {
        public bool m_worn = false;
        public bool m_isInitialStateEvent = true;
    }

    /// <summary>
    /// Enum to define the possible headset battery levels
    /// </summary>
    public enum PLTBatteryLevel
    {
        BatteryLevel_Empty = 0,
        BatteryLevel_Low = 1,
        BatteryLevel_Medium = 2,
        BatteryLevel_High = 3,
        BatteryLevel_Full = 4,
    }

    /// <summary>
    /// Used to return to your app the current headset battery level
    /// when registered for charging service.
    /// </summary>
    public class PLTBatteryState
    {
        public PLTBatteryLevel m_batterylevel = PLTBatteryLevel.BatteryLevel_Empty;
    }
}