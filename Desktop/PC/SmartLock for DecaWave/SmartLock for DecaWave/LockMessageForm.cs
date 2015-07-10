using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Reflection;


namespace Plantronics.UC.SmartLock
{
    public partial class LockMessageForm : Form
    {
        ScreenLockerForm theParent = null;
        ScreenLocker m_screenLocker = null;
        bool m_postlock = false;

        // hide timeout
        Timer m_hidetimer;

        public LockMessageForm(ScreenLockerForm parent, ScreenLocker screenLocker, string sReason)
        {
            InitializeComponent();
            theParent = parent;
            m_screenLocker = screenLocker;
            txtCounter.Text = theParent.m_settings.m_lockDelay.ToString() + " Seconds";
            if (theParent.m_settings.m_lockDelay < 10) txtCounter.Text = " " + txtCounter.Text;

            // Normal message
            ciTxtMessage.Text = "Plantronics Marauder has detected that your";

            // Reason message in bold
            rtxtMessage.Text = sReason + ".";

            // action message
            lockTxtMessage.Location = new Point(rtxtMessage.Location.X + rtxtMessage.Width - 2, lockTxtMessage.Location.Y);
            lockTxtMessage.Text = GetLockActionText();

            m_hidetimer = new Timer();
            m_hidetimer.Interval = 8000; // ms
            m_hidetimer.Tick += new EventHandler(m_hidetimer_Tick);
        }

        void m_hidetimer_Tick(object sender, EventArgs e)
        {
            if (m_screenLocker.postlockform != null)
            {
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to HIDE popup window due to expired hide timer!");
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Stopping popup window timer.");
                m_hidetimer.Stop();
                m_screenLocker.m_bSreenLocked = false;
                m_screenLocker.ClosePostLockMessageForm();
            }
            else
            {
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: hide timer expired but postlock message already closed.");
            }
        }

        // hide this form after timeout seconds
        internal void HideTimeout(int timeout)
        {
            m_hidetimer.Interval = timeout * 1000;
            theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Starting popup window hide timer for " + timeout + " seconds.");
            m_hidetimer.Start();
        }

        string GetLockActionText()
        {
            string sLockAction = "";
            switch (theParent.m_settings.m_lockAction)
            {
                case LockAction.ScreenLock:
                    sLockAction = "Screen will lock in ";
                    break;
                case LockAction.ScreenSaver:
                    sLockAction = "Screen Saver will activate in ";

                    break;
                case LockAction.PCSleep:
                    sLockAction = "This PC will go into sleep in ";
                    break;
                case LockAction.PCHibernate:
                    sLockAction = "This PC will go into hybernation in ";
                    break;
                default:
                    break;
            }
            return sLockAction;
        }

        string GetPostLockActionText()
        {
            string sLockAction = "";
            switch (theParent.m_settings.m_lockAction)
            {
                case LockAction.ScreenLock:
                    sLockAction = "Your screen was locked because ";
                    break;
                case LockAction.ScreenSaver:
                    sLockAction = "Your screen saver was activated because ";

                    break;
                case LockAction.PCSleep:
                    sLockAction = "Your PC was put to sleep because ";
                    break;
                case LockAction.PCHibernate:
                    sLockAction = "Your PC was hibernated because ";
                    break;
                default:
                    break;
            }
            return sLockAction;
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            m_screenLocker.StopTimer();
            m_screenLocker.m_bSreenLocked = false;
            m_screenLocker.CloseLockMessageForm();
        }

        // convert dialog into a post lock message including settings button
        internal void SetAsPostLock(string reason)
        {
            m_postlock = true;

            txtCounter.Hide();
            btnCancel.Hide();
            lockScreenBtn.Hide();

            okbutton.Show();
            settingsButton.Show();

            bannerPicBox.Image = Properties.Resources.message;

            // Post Action message
            ciTxtMessage.Text = GetPostLockActionText() + "Plantronics Marauder";

            // Normal message
            lockTxtMessage.Text = "detected that your";
            lockTxtMessage.Location = new Point(ciTxtMessage.Location.X, lockTxtMessage.Location.Y);
                
            // Reason message in bold
            rtxtMessage.Text = reason + ".";
            rtxtMessage.Location = new Point(lockTxtMessage.Location.X + lockTxtMessage.Width - 2, rtxtMessage.Location.Y);

            this.Height = this.Height - 39;
            okbutton.Location = new Point(okbutton.Location.X, okbutton.Location.Y - 39);
            settingsButton.Location = new Point(settingsButton.Location.X, settingsButton.Location.Y - 39);
            panel1.Height = panel1.Height - 39;

            btnCancel.NotifyDefault(false);
            okbutton.NotifyDefault(true);
            okbutton.Focus();
        }

        private void settingsButton_Click(object sender, EventArgs e)
        {
            theParent.OpenOptionsDialog(OptionTab.ScreenLocker);
            m_screenLocker.m_bSreenLocked = false;
            m_screenLocker.ClosePostLockMessageForm();
        }

        private void okbutton_Click(object sender, EventArgs e)
        {
            m_screenLocker.m_bSreenLocked = false;
            m_screenLocker.ClosePostLockMessageForm();
        }

        private void lockScreenBtn_Click(object sender, EventArgs e)
        {
            // lock screen now!
            m_screenLocker.m_bSreenLocked = false;
            m_screenLocker.StopTimer();
            m_screenLocker.LockScreen();
        }

        private void ciTxtMessage_KeyPress(object sender, KeyPressEventArgs e)
        {
            // handle enter press for closing post lock window... (default 
            if (e.KeyChar == 13 && m_postlock)
            {
                m_screenLocker.m_bSreenLocked = false;
                m_screenLocker.ClosePostLockMessageForm();
            }
        }

        public void StopHideTimer()
        {
            m_hidetimer.Stop();
        }

        // LC new - have got to set the lock message form member variables in screenlocker
        // to null if user closes with the X
        private void LockMessageForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            if (m_postlock)
            {
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "User closed postlock message, setting member variable to null.");
                m_screenLocker.postlockform = null;
                m_screenLocker.m_bSreenLocked = false;
            }
            else
            {
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "User closed prelock message, setting member variable to null.");
                m_screenLocker.lmf = null;
            }
        }
    }
}
