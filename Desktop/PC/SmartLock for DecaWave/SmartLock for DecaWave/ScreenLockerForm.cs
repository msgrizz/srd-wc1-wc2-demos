using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Media;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Reflection;
using System.Threading;
using System.IO;
using Microsoft.Win32;

namespace Plantronics.UC.SmartLock
{
    public enum RingOption
    {
        RingWhenDoff = 0,  //default
        AlwaysRing = 1,
        NoRing = 2
    }

    public enum DecaWaveEventActionType
    {
        OutsideGeofence,
        InsideGeofence
    }

    public enum LastLockReasonType
    {
        None,
        OutsideGeofence,
        TestingLock
    }

    public partial class ScreenLockerForm : Form //, DebugLogger
    {
        public OptionsForm options = null;

        private NotifyIcon trayIcon;
        private ContextMenu trayMenu;

        public enum MobileCallState
        {
            Idle = 0,
            InComing = 1,
            OutGoing = 2,
            OnCall = 3,
            CallerID = 4,
        }

        MobileCallState m_mobileCallState = MobileCallState.Idle;
        public bool m_isMobileRinging = false;
        public bool m_isDON = false;
        public bool m_isNEAR = false;
        
        public IntPtr m_hWnd = (IntPtr)0;
        public string m_sCallerID = "";


        // LC All screen locker functionality now handled by the following object class:
        ScreenLocker m_screenLocker = null;

        // LC New save settings (persist to file) facility
        public SettingsFile m_settings = null;
        static List<SoundAlerter> m_alerters = new List<SoundAlerter>();
        static List<SoundAlerter> m_speechalerters = new List<SoundAlerter>();

        // LC New debug facility (enabled and disabled via boolean in the settings file)
        ScreenLockerDebug m_screenLockerDebug = null;
        public bool DebugMode
        {
            get
            {
                if (m_settings != null)
                {
                    return m_settings.m_debugMode;
                }
                else
                {
                    return false;
                }
            }
            set
            {
                if (m_settings != null)
                {
                    m_settings.m_debugMode = value;
                }
            }
        }

        // LC used for registry entry
        public static string APP_NAME = "Plantronics SmartLock for DecaWave";

        // LC re-add interactive session notification (logon)
        #region detect_winlogin
        // dead zone for log back in detection
        System.Windows.Forms.Timer m_logindetectdeadzonetimer;
        bool m_detectlogin = true;

        // sound alerter reapers to ensure we release audio/rf link to wireless device
        System.Windows.Forms.Timer m_WaveAlerterReaper;
        System.Windows.Forms.Timer m_SpeechAlerterReaper;


        // flag to indicate if we've registered for notifications or not
        private bool registered = false;

        /// <summary>
        /// Is this form receiving lock / unlock notifications
        /// </summary>
        protected bool ReceivingLockNotifications
        {
            get { return registered; }
        }
        #endregion

        // LC some constants for defining caller picture thumbnail size:
        public const int PICTURE_SIZEX = 60;
        public const int PICTURE_SIZEY = 60;

        // LC delegate for enable or disable locking
        delegate void SetEnableLockingCallback(bool enable);

        // LC delegate for enable or disable mobile call controls
        delegate void UpdateCallControlsCallback(bool enable);

        // LC delegate for triggering locking
        delegate void TriggerLockingCallback(string sLockReason, bool isDoffOrDock, LastLockReasonType reasonTypeCode);

        // LC delegate for heatset event actions
        delegate void SpokesEventActionCallback(DecaWaveEventActionType type);

        // LC delegate for triggering locking
        delegate void AttachDelayCallback();

        // LC delegate for updating options GUI
        delegate void OptionsGUICallback(int rssi);
        delegate void OptionsGUICallback2(bool near);

        // LC new demo validity period...
        public const int DEMO_VALIDITY_PERIOD_DAYS = 30;
        public bool m_demoexpired = false;
        public int m_demodaysleft = DEMO_VALIDITY_PERIOD_DAYS;
        private bool m_exitting = false;

        public ScreenLockerForm()
        {
            InitializeComponent();

            // LC new has the demo expired???
            CalculateDemoExpiry();

            m_hWnd = this.Handle;

            // LC screen lock / settings / debug...
            m_screenLocker = new ScreenLocker(this);

            // get list of default audio devices

            List<NAudioDeviceInfo> defaultDeviceIDs = new List<NAudioDeviceInfo>();
            List<NAudioDeviceInfo> devices = SoundAlerter.GetAudioDeviceList();

            foreach (NAudioDeviceInfo dev in devices)
            {
                if (dev.isDefault)
                    defaultDeviceIDs.Add(dev);
            }

            m_settings = new SettingsFile(this, "Plantronics_SmartLockSettings.xml", defaultDeviceIDs);
            InitAlerters();
            PreLoadAudioAssemblies();

            if (m_demoexpired)
            {
                // TODO add option to allow to unlock via modal unlock dialog!
                DialogResult res = MessageBox.Show("Sorry, the SmartLockDW Demo Software has Expired! Would you like to enter an unlock key (click Yes for information on obtaining your key)?",
                    "Plantronics ScreenLockDW Expired", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Exclamation);

                switch (res)
                {
                    case System.Windows.Forms.DialogResult.Yes:
                        EnterUnlockKeyForm unlockform = new EnterUnlockKeyForm(null);
                        unlockform.ShowDialog(); // modal dialog show!
                        CalculateDemoExpiry(); // are we still expired?
                        if (m_demoexpired)
                            MessageBox.Show("Please uninstall using the Windows Control Panel\\Programs and Features. The program will now exit.",
                                "Plantronics ScreenLock Expired", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        break;
                    case System.Windows.Forms.DialogResult.No:
                        MessageBox.Show("Please uninstall using the Windows Control Panel\\Programs and Features. The program will now exit.",
                            "Plantronics ScreenLock Expired", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        break;
                    default:
                        MessageBox.Show("Please uninstall using the Windows Control Panel\\Programs and Features. The program will now exit.",
                            "Plantronics ScreenLock Expired", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        break;
                }
            }

            // user may have unlocked at this point...
            if (!m_demoexpired)
            {
                // LC New Create tray menu
                // Create tray menu
                trayMenu = new ContextMenu();
                trayMenu.MenuItems.Add("SmartLockDW Settings", OnSettings);
                trayMenu.MenuItems.Add("Exit", OnExit);
                // create tray icon
                trayIcon = new NotifyIcon();
                trayIcon.Text = "Plantronics SmartLockDW";
                trayIcon.Icon = new Icon(Properties.Resources.screenlockmulti, 40, 40);   // SystemIcons.Application

                // add menu to tray icon and show it
                trayIcon.ContextMenu = trayMenu;
                trayIcon.Visible = true;

                this.trayIcon.MouseUp += new MouseEventHandler(this.notifyIcon1_MouseUp);

                // LC Apply some of the persisted settings
                ApplyPersistedSettings();

                // LC deadzone timer for login detection
                m_logindetectdeadzonetimer = new System.Windows.Forms.Timer();
                m_logindetectdeadzonetimer.Interval = 1500;
                m_logindetectdeadzonetimer.Tick += new EventHandler(m_logindetectdeadzonetimer_Tick);

                m_WaveAlerterReaper = new System.Windows.Forms.Timer();
                m_WaveAlerterReaper.Interval = 1000;
                m_WaveAlerterReaper.Tick += new EventHandler(m_WaveAlerterReaper_Tick);

                m_SpeechAlerterReaper = new System.Windows.Forms.Timer();
                m_SpeechAlerterReaper.Interval = 1000;
                m_SpeechAlerterReaper.Tick += new EventHandler(m_SpeechAlerterReaper_Tick);

                // NOTE TO SELF: do not call ShowInTaskbar = false; or Hide(); in constructor
                // or the broadcast message to show already running instance is not received!
            }
        }

        void m_SpeechAlerterReaper_Tick(object sender, EventArgs e)
        {
            if (!SpeechAlertersBusy()) // if the non-looping speech sounds have finished playing...
            {
                // force streams to stop...
                StopAllSpeechAlerters(true);
                m_SpeechAlerterReaper.Stop();

                // note: this code doesn't seem to work
                if (m_ibroughtuplink)
                {
                    //m_spokes.ConnectAudioLinkToDevice(false);
                    m_ibroughtuplink = false;
                }
            }
        }

        void m_WaveAlerterReaper_Tick(object sender, EventArgs e)
        {
            if (!SoundAlertersBusy()) // if the non-looping sounds have finished playing...
            {
                // force streams to stop...
                StopAllSoundAlerters(true);
                m_WaveAlerterReaper.Stop();

                // note: this code doesn't seem to work
                if (m_ibroughtuplink)
                {
                    //m_spokes.ConnectAudioLinkToDevice(false);
                    m_ibroughtuplink = false;
                }
            }
        }

        // LC New tray icon menu handler for settings
        private void OnSettings(object sender, EventArgs e)
        {
            OpenOptionsDialog(); // user has asked for settings, lets open options dialog...
        }

        // LC New tray icon menu handler for exit
        private void OnExit(object sender, EventArgs e)
        {
            m_exitting = true;
            if (m_screenLockerDebug != null) m_screenLockerDebug.SetExitting(m_exitting);
            Application.Exit(); // The user has asked to exit, lets tell it to exit!
        }

        // deal with context menu
        private void OpenContextMenu()
        {
            System.Reflection.MethodInfo mi = typeof(NotifyIcon).GetMethod("ShowContextMenu", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
            mi.Invoke(trayIcon, null);
        }

        // deal with context menu
        private void notifyIcon1_MouseUp(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                OpenContextMenu();
            }
        }

        private void CalculateDemoExpiry()
        {
            m_demodaysleft = TimeoutSystem.DaysLeftOfDemo(DEMO_VALIDITY_PERIOD_DAYS);
            m_demoexpired = (m_demodaysleft <= 0);
        }

        public void ApplyPersistedSettings()
        {
            EnableDebug(DebugMode);
            SetStartup(APP_NAME, m_settings.m_startWithWin);

            //if (m_spokes!=null) EncodeAndSendProximityConfigCommand();
        }

        private void ShowMe()
        {
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: Showing the mobile call window because other app instance messaged us!");

            OpenOptionsDialog(OptionTab.MobileCall);

            ShowApplication(); // will hide main window if option to hide is set...
        }

        protected override void DefWndProc(ref Message msg)
        {
            const int WM_EXITSIZEMOVE = 0x232;

            if (msg.Msg == WinAPI.WM_SHOWME)
            {
                ShowMe();
            }

            switch (msg.Msg)
            {
                case WM_EXITSIZEMOVE:
                    // detect when window has finished being moved!

                    //WindowWasMoved();
                    break;

                case WinAPI.SessionChangeMessage:
                    {
                        if (msg.WParam.ToInt32() == WinAPI.SessionLockParam)
                            OnSessionLock();
                        else if (msg.WParam.ToInt32() == WinAPI.SessionUnlockParam)
                            OnSessionUnlock();
                    }
                    break;
            };
            base.DefWndProc(ref msg);
        }

        private void ScreenLockerForm_Load(object sender, EventArgs e)
        {
            if (m_demoexpired)
            {
                Application.Exit(); // The demo has expired, lets tell it to exit!
            }
            else
            {
                //// Get the Spokes object singleton
                //m_spokes = Spokes.Instance;

                //m_spokes.SetLogger(this); // tell spokes to log debug output to me using DebugLogger interface

                //// Sign up for Plantronics events of interest...

                //// Wearing sensor:
                //m_spokes.PutOn += new Spokes.PutOnEventHandler(m_spokes_PutOn);
                //m_spokes.TakenOff += new Spokes.TakenOffEventHandler(m_spokes_TakenOff);

                //// Proximity:
                //m_spokes.Near += new Spokes.NearEventHandler(m_spokes_Near);
                //m_spokes.Far += new Spokes.FarEventHandler(m_spokes_Far);
                //m_spokes.ProximityEnabled += new Spokes.ProximityEnabledEventHandler(m_spokes_ProximityEnabled);
                //m_spokes.ProximityDisabled += new Spokes.ProximityDisabledEventHandler(m_spokes_ProximityDisabled);
                //m_spokes.ProximityUnknown += new Spokes.ProximityEnabledEventHandler(m_spokes_ProximityUnknown);
                //m_spokes.InRange += new Spokes.InRangeEventHandler(m_spokes_InRange);
                //m_spokes.OutOfRange += new Spokes.OutOfRangeEventHandler(m_spokes_OutOfRange);
                //m_spokes.Docked += new Spokes.DockedEventHandler(m_spokes_Docked);
                //m_spokes.UnDocked += new Spokes.DockedEventHandler(m_spokes_UnDocked);

                //// Mobile caller id:
                //m_spokes.OnMobileCall += new Spokes.OnMobileCallEventHandler(m_spokes_OnMobileCall);
                //m_spokes.NotOnMobileCall += new Spokes.NotOnMobileCallEventHandler(m_spokes_NotOnMobileCall);

                //// Call control:
                //m_spokes.OnCall += new Spokes.OnCallEventHandler(m_spokes_OnCall);
                //m_spokes.NotOnCall += new Spokes.NotOnCallEventHandler(m_spokes_NotOnCall);

                //// Device attach/detach:
                //m_spokes.Attached += new Spokes.AttachedEventHandler(m_spokes_Attached);
                //m_spokes.Detached += new Spokes.DetachedEventHandler(m_spokes_Detached);
                //m_spokes.CapabilitiesChanged += new Spokes.CapabilitiesChangedEventHandler(m_spokes_CapabilitiesChanged);

                //// RAW OLMP
                //m_spokes.RawDataReceived += new Spokes.RawDataReceivedEventHandler(m_spokes_RawDataReceived);

                //// Now connect to attached device, if any
                //m_spokes.Connect(APP_NAME);

                DoTextToSpeech("Plantronics Smart Lock active.", true);

                ShowApplication();
            }
        }

        //void m_spokes_RawDataReceived(object sender, RawDataReceivedArgs e)
        //{
        //    //DebugPrint(MethodInfo.GetCurrentMethod().Name, "RAW OLMP RCV: " + e.m_datareporthex);
        //    string stringbytes = System.Text.Encoding.Default.GetString(e.m_datarawbytes);
        //    //DebugPrint(MethodInfo.GetCurrentMethod().Name, "OLMP STRING: " + stringbytes);
        //    // ok we are interested in proximity threshold and dead zone for
        //    // attached device:
        //    int pos = stringbytes.IndexOf("ODP,01,1000,065,");
        //    if (pos > -1)
        //    {
        //        if (stringbytes.IndexOf("065,OK") == -1)
        //        {
        //            string odpchop = stringbytes.Substring(18);
        //            DebugPrint(MethodInfo.GetCurrentMethod().Name, "PROX PAYLOAD: " + odpchop);

        //            m_deviceprox_proxanytime = odpchop.Substring(0, 1) == "1";
        //            int deviceprox_deadband = Convert.ToInt32(odpchop.Substring(1, 1));

        //            m_deviceprox_reportrssi = odpchop.Substring(2, 1) == "1";
        //            m_deviceprox_reportnearfar = odpchop.Substring(3, 1) == "1";
        //            m_deviceprox_streamrssitobase = odpchop.Substring(4, 1) == "1";
        //            int deviceprox_nearthreshold = Convert.ToInt32(odpchop.Substring(5, 2)); // bytes 5 and 6
        //            m_deviceprox_trenddetectdisabled = odpchop.Substring(7, 1) == "1";
        //            m_deviceprox_devicesleeptimeout = Convert.ToInt32(odpchop.Substring(8, 5)); // bytes 8-12
        //            m_deviceprox_proximityoff = odpchop.Substring(13, 1) == "1";

        //            //DebugPrint(MethodInfo.GetCurrentMethod().Name, "NEAR THRESHOLD: " + nearthreshold);
        //            //DebugPrint(MethodInfo.GetCurrentMethod().Name, "DEAD ZONE: " + deadband);

        //            m_hasreceiveddeviceproxinfo = true;

        //            // if user has their stored settings, reapply the settings to headset:
        //            if (m_settings.m_deadband != deviceprox_deadband ||
        //                m_settings.m_nearThreshold != deviceprox_nearthreshold)
        //            {
        //                EncodeAndSendProximityConfigCommand();
        //            }
        //        }
        //        else
        //        {
        //            // re-register for proximity
        //            if (!m_proxreg)
        //            {
        //                m_spokes.SendCustomMessageToHeadset("ODP,01,1000,066,01");
        //                m_proxreg = true;
        //            }
        //        }
        //    }

        //    pos = stringbytes.IndexOf("ODP,01,1000,063,0-");
        //    if (pos > -1)
        //    {
        //        string odpchop = stringbytes.Substring(19, 2);
        //        DebugPrint(MethodInfo.GetCurrentMethod().Name, "PROX DB PAYLOAD: " + odpchop);

        //        if (options != null)
        //        {
        //            UpdateProximityRSSItoGUI(Convert.ToInt32(odpchop));
        //        }
        //    }
        //}

        private void DecaWaveEventAction(DecaWaveEventActionType action)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (this.InvokeRequired)
            {
                SpokesEventActionCallback d = new SpokesEventActionCallback(DecaWaveEventAction);
                this.Invoke(d, new object[] { action });
            }
            else
            {
                switch (action)
                {
                    case DecaWaveEventActionType.OutsideGeofence:
                        break;
                    case DecaWaveEventActionType.InsideGeofence:
                        break;
                }
            }
        }

        private void TriggerLockIfRequired(string sLockReason, bool isDoffOrDock, LastLockReasonType reasonTypeCode)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (this.InvokeRequired)
            {
                TriggerLockingCallback d = new TriggerLockingCallback(TriggerLockIfRequired);
                this.Invoke(d, new object[] { sLockReason, isDoffOrDock, reasonTypeCode });
            }
            else
            {
                if (sLockReason != "")
                {
                    if (m_screenLocker.m_bSreenLocked == true)
                    {
                        DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: Not initating lock screen action because screen recently locked or still showing post-lock message!");
                        return;
                    }
                    m_screenLocker.TriggerLock(sLockReason, isDoffOrDock, reasonTypeCode);
                }
            }
        }

        // initial show to user of app - mobile call window, toast popup
        private void ShowApplication()
        {
            Hide(); // LC always hide screenlocker form - its just used for creating sys tray etc

            // LC do a toast popup to inform user how to interact with application...
            if (m_settings.m_showToast)
            {
                ToastPopup mypopup = new ToastPopup("Click icon in system tray to configure the Plantronics SmartLockDW settings.\r\n\r\nClick this message for settings...", this);
                mypopup.Show();
            }
        }
      
        public void OpenOptionsDialog(OptionTab whichTab = OptionTab.MobileCall)
        {
            if (options == null)
            {
                CalculateDemoExpiry();
                options = new OptionsForm(this, m_screenLocker);
                options.Show();
                options.SelectLockTab(whichTab);
                WindowPosition.PositionToTray(options);
            }
            else
            {
                // LC bring the App to Front!
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "Bringing all the application Windows to the front so user can see them!");
                if (m_settings.m_debugMode)
                {
                    if (m_screenLockerDebug != null) m_screenLockerDebug.BringToFront();
                }
                options.BringToFront();
                if (this.Visible) this.BringToFront();
            }
        }

        private void MobileCallForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            // LC if user uses the X to close the MobileCall window, just hide window, toggle the window hide feature, save settings
            switch (e.CloseReason)
            {
                case CloseReason.ApplicationExitCall:
                    break;
                case CloseReason.FormOwnerClosing:
                    break;
                case CloseReason.MdiFormClosing:
                    break;
                case CloseReason.None:
                    break;
                case CloseReason.TaskManagerClosing:
                    break;
                case CloseReason.UserClosing:
                    if (!m_demoexpired)  // only hide if we are not expired, otherwise allow close!
                    {
                        if (e.CloseReason == CloseReason.UserClosing)
                        {
                            Hide(); // just hide the form instead!
                            e.Cancel = true; // cancel real closing
                        }
                    }
                    break;
                case CloseReason.WindowsShutDown:
                    break;
                default:
                    break;
            }           
        }

        public void EnableDebug(bool enable)
        {
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "Setting debugging mode = " + enable.ToString() + ".");

            DebugMode = enable;

            if (enable)
            {
                if (m_screenLockerDebug == null)
                {
                    m_screenLockerDebug = new ScreenLockerDebug(this);
                    m_screenLockerDebug.Show();
                    m_screenLockerDebug.WindowState = FormWindowState.Normal;
                    DebugPrint(MethodInfo.GetCurrentMethod().Name, "Debugging was enabled.");
                }
                else
                {
                    m_screenLockerDebug.Show();
                    m_screenLockerDebug.WindowState = FormWindowState.Normal;
                    DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: Debugging was ALREADY enabled.");
                }
            }
            else
            {
                if (m_screenLockerDebug != null)
                {
                    m_screenLockerDebug.Hide();
                    m_screenLockerDebug.Close();
                    m_screenLockerDebug = null;
                }
            }
        }

        internal void DisableDebugFromFormClose()
        {
            m_screenLockerDebug = null; // remove reference to the form as it is closing

            if (options != null)
            {
                options.debugCheckBox.Checked = false; // flip the checkbox - note, will ALSO update DebugMode through event handler
            }
            else
            {
                DebugMode = false; // just update DebugMode (note: will persist this change in the settings file to
                    // prevent debug dialog popping up again unless user turns back on via Misc tab of options form)
                m_settings.m_debugMode = false;
                m_settings.SaveSettings();
            }
        }

        /// <summary>
        /// Add/Remove registry entries for windows startup.
        /// Note: LC modified to write to user key
        /// </summary>
        /// <param name="AppName">Name of the application.</param>
        /// <param name="enable">if set to <c>true</c> [enable].</param>
        public void SetStartup(string AppName, bool enable)
        {
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to maintain registry run keys for app: " +
                AppName + ", enable = " + enable + "...");
            try
            {
                // reg keys of interest...
                string runKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run";

                // NOTE, losing un-needed App Paths stuff!
                // (using CMD /C START was the final solution to get it to run in correct folder from registry)
                //string appPathsKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths";
                //string currVerKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion";

                // open them all...
                Microsoft.Win32.RegistryKey startupKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(runKey, true);
                //Microsoft.Win32.RegistryKey pathsKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(appPathsKey, true);
                //Microsoft.Win32.RegistryKey currVKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(currVerKey, true);
                
                //// create App Paths key if it doesn't exist...
                //if (pathsKey == null)
                //{
                //    pathsKey = currVKey.CreateSubKey("App Paths");
                //}

                if (enable)
                {
                    // Step 1. Maintain the run key entry...
                    if (startupKey.GetValue(AppName) == null)
                    {
                        // Add startup reg key
                        DebugPrint(MethodInfo.GetCurrentMethod().Name, "Key not present so setting new reg run key: " +
                            AppName + ", value = " + Application.ExecutablePath.ToString());
                        startupKey.SetValue(AppName, "CMD /C START \"Plantronics SmartLock\" /D\"" + Application.StartupPath
                                + "\" \"" + Application.ExecutablePath + "\"");
                        startupKey.Close();
                    }
                    else
                    {
                        // reg key is already there...
                        // lets see if it has the right value
                        string curval = (string)startupKey.GetValue(AppName, "");
                        DebugPrint(MethodInfo.GetCurrentMethod().Name, "Current value of reg run key: " +
                            AppName + ", value = " + curval);
                        if (curval.ToUpper().Contains(Application.ExecutablePath.ToString().ToUpper())
                            &&
                            curval.ToUpper().Contains("CMD /C"))
                        {
                            DebugPrint(MethodInfo.GetCurrentMethod().Name, "Value is the SAME! No action needed.");
                        }
                        else
                        {
                            DebugPrint(MethodInfo.GetCurrentMethod().Name, "Value DIFFERS! Re-setting reg run key: " +
                                AppName + ", value = " + Application.ExecutablePath.ToString());
                            startupKey.SetValue(AppName, "CMD /C START \"Plantronics SmartLock\" /D\""+Application.StartupPath
                                +"\" \""+Application.ExecutablePath+"\"");
                        }
                        startupKey.Close();
                    }

                    //// Step 2. Maintain the app paths key entry...
                    //RegistryKey apppathkey = pathsKey.OpenSubKey(Path.GetFileName(Application.ExecutablePath));
                    //if (apppathkey == null)
                    //{
                    //    // Add app paths reg key
                    //    DebugPrint(MethodInfo.GetCurrentMethod().Name, "Key not present so setting new reg app paths key: " +
                    //        AppName + ", value/path = " + Application.StartupPath.ToString());
                    //    RegistryKey apppath = pathsKey.CreateSubKey(Path.GetFileName(Application.ExecutablePath)); // create our app path sub key
                    //    apppath.SetValue(String.Empty, Application.ExecutablePath);
                    //    apppath.SetValue("Path", Application.StartupPath);
                    //    apppath.Close();
                    //    pathsKey.Close();
                    //}
                    //else
                    //{
                    //    // reg key for app path is already there...
                    //    // lets see if it has the right value
                    //    RegistryKey apppath = pathsKey.OpenSubKey(Path.GetFileName(Application.ExecutablePath), true); // get our app path sub key
                    //    if (apppath == null)
                    //    {
                    //        apppath = pathsKey.CreateSubKey(Path.GetFileName(Application.ExecutablePath)); // create our app path sub key
                    //    }
                    //    string curval = (string)apppath.GetValue("", "");
                    //    DebugPrint(MethodInfo.GetCurrentMethod().Name, "Current value of reg app path key: " +
                    //        AppName + ", value = " + curval);
                    //    if (curval.ToUpper().CompareTo(Application.ExecutablePath.ToString().ToUpper()) == 0)
                    //    {
                    //        DebugPrint(MethodInfo.GetCurrentMethod().Name, "Value is the SAME! No action needed.");
                    //    }
                    //    else
                    //    {
                    //        DebugPrint(MethodInfo.GetCurrentMethod().Name, "Value DIFFERS! Re-setting reg app path key: " +
                    //            AppName + ", value = " + Application.ExecutablePath.ToString());
                    //        apppath.SetValue(String.Empty, Application.ExecutablePath);
                    //        apppath.SetValue("Path", Application.StartupPath);
                    //    }
                    //    apppath.Close();
                    //    pathsKey.Close();
                    //}
                }
                else
                {
                    // remove startup
                    DebugPrint(MethodInfo.GetCurrentMethod().Name, "Deleting reg run key: " +
                        AppName + ".");
                    startupKey.DeleteValue(AppName, false);
                    startupKey.Close();
                    //// remove app path
                    //DebugPrint(MethodInfo.GetCurrentMethod().Name, "Deleting reg app path key: " +
                    //    AppName + ".");
                    //pathsKey.DeleteSubKey(AppName, false); // delete our app path sub key
                    //pathsKey.Close();
                }
            }
            catch (Exception e)
            {
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "An exception was caught while trying to add or remove registry key for app: "+AppName+".\r\nException = "+e.ToString());
            }
        }

        // Re-add code to close notification window 8 seconds after interactive login to windows...
        #region more_detect_winlogin
        /// <summary>
        /// Register for event notifications
        /// </summary>
        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);

            // WtsRegisterSessionNotification requires Windows XP or higher
            bool haveXp = Environment.OSVersion.Platform == PlatformID.Win32NT &&
                                (Environment.OSVersion.Version.Major > 5 ||
                                    (Environment.OSVersion.Version.Major == 5 &&
                                     Environment.OSVersion.Version.Minor >= 1));

            if (haveXp)
                registered = WinAPI.WTSRegisterSessionNotification(Handle, WinAPI.NotifyForThisSession);

            return;
        }

        /// <summary>
        /// The windows session has been locked
        /// </summary>
        protected virtual void OnSessionLock()
        {
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "Screen locker has detected that the windows session has been locked. NOTE: setting m_bSreenLocked = true");
            // LC new, lets tell ScreenLock not to do any locking action while
            // screen is locked...
            m_screenLocker.m_bSreenLocked = true;
            return;
        }

        /// <summary>
        /// The windows session has been unlocked
        /// </summary>
        protected virtual void OnSessionUnlock()
        {
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "Screen locker has detected that the windows session has been UNLOCKED.");
            if (m_detectlogin)
            {
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "In active detection mode (not in dead zone).");
                if (m_screenLocker.postlockform != null)
                {
                    if (m_screenLocker.postlockform.Visible)
                    {
                        DebugPrint(MethodInfo.GetCurrentMethod().Name, "The popup is visible, starting hide timeout for 8 seconds.");
                        m_screenLocker.postlockform.HideTimeout(8); // hide popup after 8 seconds
                    }
                }
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "NOTE: setting m_bSreenLocked = false");
                m_screenLocker.m_bSreenLocked = false; // LC new, set this right away so you can re-lock if you take headset off before post lock form timesout
            }

            return;
        }

        ///// <summary>
        /// Process windows messages
        /// </summary>
        protected override void WndProc(ref Message m)
        {
            // check for session change notifications
            if (m.Msg == WinAPI.SessionChangeMessage)
            {
                if (m.WParam.ToInt32() == WinAPI.SessionLockParam)
                    OnSessionLock();
                else if (m.WParam.ToInt32() == WinAPI.SessionUnlockParam)
                    OnSessionUnlock();
            }

            //const int WM_SYSCOMMAND = 0x0112;
            //const int SC_RESTORE = 0xF120;

            //if (m.Msg == WM_SYSCOMMAND && (int)m.WParam == SC_RESTORE)
            //{
            //    // Do whatever processing you need here, or raise an event
            //    // ...
            //    MessageBox.Show("Window was restored");
            //}

            base.WndProc(ref m);
            return;
        }

        void m_logindetectdeadzonetimer_Tick(object sender, EventArgs e)
        {
            m_detectlogin = true;
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "Dead zone timer expired, reenabling windows login detection.");
            m_logindetectdeadzonetimer.Stop();
        }

        public void EnterDeadZoneLoginDetect()
        {
            m_detectlogin = false;
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "Dead zone timer starting, disabling windows login detection.");
            m_logindetectdeadzonetimer.Start();
        }

        private void MobileCallForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            if (registered)
            {
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "Form closed, unregister windows session notification.");
                WinAPI.WTSUnRegisterSessionNotification(Handle);
                registered = false;
            }
        }
        #endregion

        // Get the plantronics device name from spokes interop
        internal string GetDeviceName()
        {
            return m_devicename;
        }

        internal void SetDeviceName(string devicename)
        {
            m_devicename = devicename;
            if (options != null)
            {
                options.SetDeviceName(devicename);
                options.UpdateLockOptions(); // update lock options depending on device
            }
        }

        // a lock for allowing multi-threaded access to sensitive member data
        // such as the m_isConnected member.
        private System.Object lockdcaps = new System.Object();
        private string m_devicename = "";
        public bool m_onVoIPCall = false;
        public bool m_onMobileCall = false;
        private int m_deviceid;
        private string m_devicepath;
        //private ICOMDevice m_device;
        private bool m_ibroughtuplink = false;

        // proximity settings for connected device:
        public bool m_deviceprox_proxanytime;
        //public int m_deviceprox_deadband;
        public bool m_deviceprox_reportrssi;
        public bool m_deviceprox_reportnearfar;
        public bool m_deviceprox_streamrssitobase;
        //public int m_deviceprox_nearthreshold;
        public bool m_deviceprox_trenddetectdisabled;
        public int m_deviceprox_devicesleeptimeout;
        public bool m_deviceprox_proximityoff;
        public bool m_hasreceiveddeviceproxinfo = false;
        private bool m_proxreg = false;

        // cross thread safe - set enable or disable locking (used depending on calling state)
        internal void SetLockingEnabled(bool enable)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (this.InvokeRequired)
            {
                SetEnableLockingCallback d = new SetEnableLockingCallback(SetLockingEnabled);
                this.Invoke(d, new object[] { enable });
            }
            else
            {
                if (!enable) m_screenLocker.StopTimer(); // if disabling locking, also stop the timer of any running lock window!
                m_screenLocker.LockingEnabled = enable;
            }
        }

        #region Audio Playing Stuff
        private void InitAlerters()
        {
            SoundAlerter.CleanTempFiles();

            // remove old alerters...
            m_alerters.Clear();
            m_speechalerters.Clear();

            // add 1 alerter per audio device...
            for (int i = 0; i < m_settings.m_audioDeviceIDs.Count; i++)
            {
                m_alerters.Add(new SoundAlerter(AlerterType.MP3Alerter, m_settings.m_audioDeviceIDs[i].ID));
            }

            // add 1 text to speech alerter per audio device...
            for (int i = 0; i < m_settings.m_audioDeviceIDs.Count; i++)
            {
                m_speechalerters.Add(new SoundAlerter(AlerterType.TextToSpeechAlerter, m_settings.m_audioDeviceIDs[i].ID));
            }
        }

        private void PreLoadAudioAssemblies()
        {
            // just pre-load some audio file and text to speech BUT DON'T PLAY
            // as this will speed up the user's subsequent choice...
            //DoPlayAudioFile("Ringtone Sounds\\Popular.mp3", false);
            DoTextToSpeech("Pre-loading audio assemblies", false);
        }

        public void DoPlayAudioFile(string filename, bool play = true, bool loop = false)
        {
            // Load audio file to all alerters...
            for (int i = 0; i < m_alerters.Count; i++)
            {
                m_alerters[i].Loop = loop;
                m_alerters[i].PreLoadSound(filename, m_settings.m_audioVolume);
            }
            if (play)
            {
                // Play all alerters...
                for (int i = 0; i < m_alerters.Count; i++)
                {
                    m_alerters[i].Play();
                }
                m_WaveAlerterReaper.Start(); // wait for dead alerters so we stop audio stream to device (otherwise audio sensing
                    // gets stuck on).
            }
        }

        public void DoTextToSpeech(string text, bool play = true, bool forceplay = false)
        {
            if (!m_settings.m_useVoicePrompts && forceplay == false)
            {
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: Voice Prompts (Text to Speech) is disabled.");
                return;
            }
          
            if (m_speechalerters.Count == 0) return;
            // load text to WAV file using first alerter
            m_speechalerters[0].PreLoadTextToSpeech(text, m_settings.m_audioVolume);
            string filename = m_speechalerters[0].Randfilename;
            // load text to speech WAV file to remaining alerters
            for (int i = 1; i < m_speechalerters.Count; i++)
            {
                File.Copy(filename, filename.Substring(0, filename.Length - 4) + "_" + i + ".wav"); // note: nasty hack, make duplicate of file to avoid 2 input stream readers trying to read same file
                m_speechalerters[i].PreLoadSound(filename.Substring(0, filename.Length - 4) + "_" + i + ".wav");
            }
            if (play)
            {
                // Play all alerters...
                for (int i = 0; i < m_speechalerters.Count; i++)
                {
                    m_speechalerters[i].Play();
                }
                m_SpeechAlerterReaper.Start(); // wait for dead alerters so we stop audio stream to device (otherwise audio sensing
                    // gets stuck on).
            }
        }

        // are we using Plantronics device for audio playback (ringtone,background,voice prompt)?
        private bool UsingPltDeviceForAudio()
        {
            bool usingpltdevice = false;
            if (m_devicename != null && m_devicename.Length>0) // do we have spokes device
            {
                if (m_settings.m_audioDeviceIDs[0].FriendlyName.ToUpper().Contains(m_devicename.ToUpper()))
                {
                    // we have found plt device name inside the naudio device friendly name... this is a plt device
                    usingpltdevice = true;
                }
            }
            return usingpltdevice;
        }

        private void CleanUpAudioAlerterResources()
        {
            // tidy up resources... (so we can delete the temp WAV files!)
            for (int i = 1; i < m_speechalerters.Count; i++)
            {
                m_speechalerters[i].TidyUpResources();
            }
            for (int i = 0; i < m_speechalerters.Count; i++)
            {
                m_speechalerters[i].TidyUpResources();
            }
            SoundAlerter.CleanTempFiles();
        }

        private void StopAllSpeechAlerters(bool force = false)
        {
            foreach (SoundAlerter item in m_speechalerters)
            {
                if (force || item.IsPlaying())
                {
                    item.Stop();
                }
            }
        }

        private bool SpeechAlertersBusy()
        {
            bool busy = false;
            foreach (SoundAlerter item in m_speechalerters)
            {
                if (item.IsPlaying())
                {
                    busy = true;
                    break;
                }
            }
            return busy;
        }

        private void StopAllSoundAlerters(bool force = false)
        {
            foreach (SoundAlerter item in m_alerters)
            {
                if (force || item.IsPlaying())
                {
                    item.Stop();
                }
            }
        }

        private bool SoundAlertersBusy()
        {
            bool busy = false;
            foreach (SoundAlerter item in m_alerters)
            {
                if (item.IsPlaying())
                {
                    busy = true;
                    break;
                }
            }
            return busy;
        }

        public void WaitForSpeechAlerters()
        {
            while (SpeechAlertersBusy())
            {
                Thread.Sleep(100);
            }
        }

        public void WaitForSoundAlerters()
        {
            while (SoundAlertersBusy())
            {
                Thread.Sleep(100);
            }
        }

        public void RegenerateAudioAlerters()
        {
            // regenerate alerters!
            StopAllSoundAlerters();
            StopAllSpeechAlerters();
            CleanUpAudioAlerterResources();
            InitAlerters();
            PreLoadAudioAssemblies();
        }

        #endregion

        #region DebugLogger implementation
        // LC New debug feature...
        public void DebugPrint(string methodname, string str)
        {
            LogMessage(methodname, str);
        }

        // Add a log entry to the log text box, ensure cross-thread support, as Spokes events come in on a different thread
        public void LogMessage(string callingmethodname, string message)
        {
            if (DebugMode)
            {
                if (m_screenLockerDebug != null)
                {
                    string datetime = DateTime.Now.ToString("HH:mm:ss.fff");
                    m_screenLockerDebug.AppendToOutputWindow(String.Format("{0}: {1}(): {2}", datetime, callingmethodname, message));
                }
            }
        }
        #endregion

        private void ScreenLockerForm_VisibleChanged(object sender, EventArgs e)
        {
            Hide();
        }
    }
}
