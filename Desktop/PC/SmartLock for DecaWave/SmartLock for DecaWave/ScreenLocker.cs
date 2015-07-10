using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Reflection;

/**
 * ScreenLocker - a class that implements screen locking
 * functionality based on CI (Contextual Intelligence) sensor events
 * 
 * Author: Lewis Collins, Plantronics
 * Oct 2012
 * 
 **/

namespace Plantronics.UC.SmartLock
{
    public enum LockAction
    {
        NoAction = 0,
        ScreenSaver = 1,
        ScreenLock = 2,
        PCSleep = 3,
        PCHibernate = 4
    }

    public class ScreenLocker
    {
        // LC moving screen locking code to here (here some definitions) so that when locking screen
        // it can close the LockMessageForm, then reopen it again with past-tense message
        // and button for Settings...

        string m_lastLockReason = "";
        private LastLockReasonType m_lastLockReasonCode = LastLockReasonType.None;

        public LastLockReasonType GetLastLockReason()
        {
            return m_lastLockReasonCode;
        }

        public void SetLastLockReason(LastLockReasonType reason)
        {
            m_lastLockReasonCode = reason;
        }

        public void ClearLastLockReason()
        {
            m_lastLockReasonCode = LastLockReasonType.None;
        }

        public int m_currLockDelayTime = 15;
        Timer lockDelayTimer;
        public LockMessageForm lmf = null;
        public LockMessageForm postlockform = null;
        ScreenLockerForm m_mobileCallForm = null;

        public string LockReason { get; set; }

        public bool m_bSreenLocked = false;

        // is locking enabled (set to false when user is on a phone call
        // to prevent erroneous events from locking PC when you are on a call!
        public bool LockingEnabled { get; set; }

        public Timer attachDelayTimer;

        public ScreenLocker(ScreenLockerForm mobileCallForm)
        {
            m_mobileCallForm = mobileCallForm;

            LockingEnabled = true;

            lockDelayTimer = new Timer();
            lockDelayTimer.Tick += new EventHandler(LockDelayTimer_Tick);
            lockDelayTimer.Interval = 1000;

            // new timer to prevent attach of device when doffed locking screen...
            attachDelayTimer = new Timer();
            attachDelayTimer.Tick += new EventHandler(attachDelayTimer_Tick);
            attachDelayTimer.Interval = 250;
        }

        void attachDelayTimer_Tick(object sender, EventArgs e)
        {
            if (!m_mobileCallForm.m_onVoIPCall && !m_mobileCallForm.m_onMobileCall)
                m_mobileCallForm.SetLockingEnabled(true); // enable locking again after attach delay
            attachDelayTimer.Stop(); // stop myself
        }

        // LC moving screen locking code to here so that when locking screen
        // it can close the LockMessageForm, then reopen it again with past-tense message
        // and button for Settings...
        public void LockScreen()
        {
            m_bSreenLocked = true;

            if (m_mobileCallForm.m_settings.m_lockAction != LockAction.NoAction) DisplayPostLockMessage();

            //btnCancel.Text = "Close";
            switch (m_mobileCallForm.m_settings.m_lockAction)
            {
                case LockAction.ScreenLock:
                    m_mobileCallForm.EnterDeadZoneLoginDetect(); // stop erroneous events
                    if (!WinAPI.LockWorkStation())
                    {
                        throw new Win32Exception(Marshal.GetLastWin32Error()); // or any other thing
                    }

                    break;
                case LockAction.ScreenSaver:

                    WinAPI.PostMessage(
               new IntPtr((int)WinAPI.HWND_BROADCAST),
               WinAPI.WM_SYSCOMMAND,
               WinAPI.SC_SCREENSAVE,
               0);
                    break;
                case LockAction.PCSleep:
                    Application.SetSuspendState(PowerState.Suspend, true, true);
                    break;
                case LockAction.PCHibernate:
                    Application.SetSuspendState(PowerState.Hibernate, true, true);
                    break;
                default:
                    break;
            }
        }

        private void DisplayPostLockMessage()
        {
            if (!m_mobileCallForm.m_settings.m_suppressLockReasons)
            {
                postlockform = new LockMessageForm(m_mobileCallForm, this, m_lastLockReason);
                postlockform.SetAsPostLock(m_lastLockReason);
                WindowPosition.PositionToCenter(postlockform);
                postlockform.Show();  // Note, using Show, to ensure non-modal!
                postlockform.BringToFront();
            }
            else
            {
                m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: Suppressing lock reason dialog according to user's chosen setting.");
            }
        }

        public void ResetTimer()
        {
            m_currLockDelayTime = m_mobileCallForm.m_settings.m_lockDelay;
        }

        public void StopTimer()
        {

            lockDelayTimer.Stop();
            ResetTimer();
            CloseLockMessageForm();
        }

        public void CloseLockMessageForm()
        {
            if (lmf != null)
            {
                lmf.Close();
                lmf = null;
            }
        }

        public void ClosePostLockMessageForm()
        {
            if (postlockform != null)
            {
                postlockform.StopHideTimer();
                postlockform.Close();
                postlockform = null;
            }
        }

        public void StartTimer()
        {
            ResetTimer();
            lockDelayTimer.Start();
        }

        void LockDelayTimer_Tick(object sender, EventArgs e)
        {
            if (lmf != null)
            {
                // if user activity in last 2 seconds then pause timer countdown...
                if (WinAPI.GetIdleTime() > 2)
                {
                    m_currLockDelayTime--;
                }

                lmf.txtCounter.Text = m_currLockDelayTime.ToString() + " Seconds";
                if (m_currLockDelayTime < 10) lmf.txtCounter.Text = " " + lmf.txtCounter.Text;

                if (m_currLockDelayTime < 0)
                {
                    lockDelayTimer.Stop();
                    CloseLockMessageForm();
                    m_mobileCallForm.WaitForSpeechAlerters();
                    m_mobileCallForm.DoTextToSpeech(GetLockActionSpeech(m_mobileCallForm.m_settings.m_lockAction), true);
                    LockScreen();
                }
            }
            else
            {
                m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: Lock timer tick occured however lock message was null. No action.");
                StopTimer();
            }
        }

        internal void TriggerLock(string sLockReason, bool isDoffOrDock, LastLockReasonType reasonTypeCode)
        {
            if (LockingEnabled)
            {
                m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to trigger lock action: reason: " + sLockReason + ", is doff or dock: " + isDoffOrDock);
                m_lastLockReason = sLockReason;
                m_lastLockReasonCode = reasonTypeCode;

                if (/*isDoffOrDock && */ m_mobileCallForm.m_settings.m_lockDelay > 0)
                {
                    ClosePostLockMessageForm(); // close old post lock form, note will stop hide timer

                    // lock after delay...
                    lmf = new LockMessageForm(m_mobileCallForm, this, sLockReason);
                    WindowPosition.PositionToCenter(lmf);
                    StartTimer();
                    lmf.Show(); // note: LC changed to non-modal
                    lmf.BringToFront();
                }
                else
                {
                    ClosePostLockMessageForm(); // close old post lock form, note will stop hide timer

                    m_mobileCallForm.WaitForSpeechAlerters();
                    m_mobileCallForm.DoTextToSpeech(GetLockActionSpeech(m_mobileCallForm.m_settings.m_lockAction), true);

                    // lock now!
                    LockScreen();
                }
            }
            else
            {
                m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: Will NOT lock PC - LOCKING is Disabled (due to calling activity)");
            }
        }

        private string GetLockActionSpeech(LockAction lockAction)
        {
            string retval = "";
            switch (lockAction)
            {
                case LockAction.PCHibernate:
                    retval = "Hibernating PC.";
                    break;
                case LockAction.PCSleep:
                    retval = "Sleeping PC.";
                    break;
                case LockAction.ScreenLock:
                    retval = "Locking screen.";
                    break;
                case LockAction.ScreenSaver:
                    retval = "Starting screen saver.";
                    break;
            }
            return retval;
        }

        // LC new, able to stop screen saver based on Don
        // this will only do that when screen saver is NOT password protected
        internal void StopScreenSaverIfRunning()
        {
            if (m_mobileCallForm.m_settings.m_lockAction == LockAction.ScreenSaver)
            {
                m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "User is using screen saver, lets try stopping it!");
                if (GetScreenSaverRunning())
                {
                    if (!IsScreenSaverPasswordProtected())
                    {
                        m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "It is not password protected, lets do it...");

                            m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to kill screen saver");
                            m_mobileCallForm.DoTextToSpeech("Stopping screen saver.", true);
                            KillScreenSaver();

                            HidePostLockIfPresent();
                    }
                    else
                    {
                        m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: It IS password protected, we cannot stop it");
                    }
                }
                else
                {
                    m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: Screen saver is not running.");

                    HidePostLockIfPresent();
                }

            }
            else
            {
                m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: User is NOT using screen saver lock action");
            }
        }

        private void HidePostLockIfPresent()
        {
            if (postlockform != null)
            {
                if (postlockform.Visible)
                {
                    m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "The popup is visible, starting hide timeout for 8 seconds.");
                    postlockform.HideTimeout(8); // hide popup after 8 seconds
                    m_bSreenLocked = false; // LC new, set this right away so you can re-lock if you take headset off before post lock form timesout
                }
            }
            else
            {
                m_bSreenLocked = false; // LC new 8-6-2015, set this now so it works with the new "suppress lock reasons" feature
            }
        }

        // Returns TRUE if the screen saver is actually running
        public static bool GetScreenSaverRunning()
        {
            bool isRunning = false;

            WinAPI.SystemParametersInfo(WinAPI.SPI_GETSCREENSAVERRUNNING, 0,
               ref isRunning, 0);
            return isRunning;
        }

        // From Microsoft's Knowledge Base article #140723: 
        // http://support.microsoft.com/kb/140723
        // "How to force a screen saver to close once started 
        // in Windows NT, Windows 2000, and Windows Server 2003"

        public static void KillScreenSaver()
        {
            IntPtr hDesktop = WinAPI.OpenDesktop("Screen-saver", 0,
               false, WinAPI.DESKTOP_READOBJECTS | WinAPI.DESKTOP_WRITEOBJECTS);
            if (hDesktop != IntPtr.Zero)
            {
                WinAPI.EnumDesktopWindows(hDesktop, new
                   WinAPI.EnumDesktopWindowsProc(KillScreenSaverFunc),
                   IntPtr.Zero);
                WinAPI.CloseDesktop(hDesktop);
            }
            else
            {
                WinAPI.PostMessage(WinAPI.GetForegroundWindow(), WinAPI.WM_CLOSE,
                   0, 0);
            }
        }

        private static bool KillScreenSaverFunc(IntPtr hWnd,
            IntPtr lParam)
        {
            if (WinAPI.IsWindowVisible(hWnd))
                WinAPI.PostMessage(hWnd, WinAPI.WM_CLOSE, 0, 0);
            return true;
        }

        /// <summary>
        /// get if password is protected in registry!
        /// </summary>
        public bool IsScreenSaverPasswordProtected()
        {
            bool retval = false;
            m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to check registry to see if screen saver is secure or not.");
            try
            {
                // get user's setting
                string desktopKeyStr = @"Control Panel\Desktop";

                Microsoft.Win32.RegistryKey desktopKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(desktopKeyStr, true);

                if (desktopKey != null)
                {
                    if (desktopKey.GetValue("ScreenSaverIsSecure") != null)
                    {
                        desktopKey.Close();
                        desktopKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(desktopKeyStr, true);
                        string curval = (string)desktopKey.GetValue("ScreenSaverIsSecure", "");
                        if (curval != null && curval.Length > 0)
                        {
                            m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: ScreenSaverIsSecure user setting = " + curval);
                            retval = (curval.CompareTo("0")!=0);
                            m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: return value will be = " + retval);
                        }
                    }
                    else
                    {
                        m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: ScreenSaverIsSecure user setting not present.");
                    }

                    desktopKey.Close();
                }
                else
                {
                    m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: ScreenSaverIsSecure user setting not present.");
                }

                // get local policy setting?
                desktopKeyStr = @"Software\Policies\Microsoft\Windows\Control Panel\Desktop";

                desktopKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(desktopKeyStr, true);

                if (desktopKey != null)
                {
                    if (desktopKey.GetValue("ScreenSaverIsSecure") != null)
                    {
                        desktopKey.Close();
                        desktopKey = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(desktopKeyStr, true);
                        string curval = (string)desktopKey.GetValue("ScreenSaverIsSecure", "");
                        if (curval != null && curval.Length > 0)
                        {
                            m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: ScreenSaverIsSecure policy setting = " + curval);
                            retval = retval || (curval.CompareTo("0") != 0);
                            m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: is pretected = " + retval);
                        }
                    }
                    else
                    {
                        m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: ScreenSaverIsSecure user setting not present.");
                    }

                    desktopKey.Close();
                }
                else
                {
                    m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: ScreenSaverIsSecure policy setting not present.");
                }
            }
            catch (Exception e)
            {
                m_mobileCallForm.DebugPrint(MethodInfo.GetCurrentMethod().Name, "An exception was caught while trying to read screen saver registry key\r\nException = " + e.ToString());
            }
            return retval;
        }
    }
}
