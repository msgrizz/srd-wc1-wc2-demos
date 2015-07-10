using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Reflection;
using System.Diagnostics;
using System.IO;

namespace Plantronics.UC.SmartLock
{
    public enum OptionTab
    {
        MobileCall,
        ScreenLocker,
        Misc
    }

    public partial class OptionsForm : Form
    {
        ScreenLockerForm theParent = null;
        ScreenLocker m_screenLocker = null;

        delegate void SetTextCallback(string text);
        delegate void EnableAllOptionsCallback();

        public bool changedOptions = false;

        public EnterUnlockKeyForm m_keyform = null;

        private Timer m_nearthreshtimer = null;
        private Timer m_deadbandtimer = null;

        // LC delegate for updating prox settings
        delegate void NearThresholdCallback();
        delegate void DeadZoneCallback();

        bool m_loaded = false;

        public OptionsForm(ScreenLockerForm mobileCallForm, ScreenLocker screenLocker)
        {
            InitializeComponent();
            theParent = mobileCallForm;
            m_screenLocker = screenLocker;

            SetDeviceName(theParent.GetDeviceName());

            GetVersionInfo();

            // LC enable/disable all the lock options based on whether we have a device attached...
            UpdateLockOptions();
        }

        private void GetVersionInfo()
        {
            theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to query SmartLockDW version info...");

            try
            {
                Assembly myassem = Assembly.GetExecutingAssembly();
                string assemver = myassem.GetName().Version.ToString();
                FileVersionInfo fvi = FileVersionInfo.GetVersionInfo(myassem.Location);
                string version = fvi.ProductVersion;

                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Assembly = " + assemver
                    + " File = " + fvi.FileVersion);

                if (assemver.CompareTo(fvi.FileVersion) == 0)
                {
                    assemblyLabel.Text = assemver;
                    fileLabel.Text = "";
                }
                else
                {
                    assemblyLabel.Text = "Assembly: " + assemver;
                    fileLabel.Text = "File: " + fvi.FileVersion;
                }
            }
            catch (Exception e)
            {
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "ERROR: exception caught trying to get version info: \r\n"+e.ToString());
            }
        }

        private bool HasDevice()
        {
            return theParent.GetDeviceName() != null && theParent.GetDeviceName().Length > 0;
        }

        public void SetDeviceName(string name)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (this.DeviceLabel.InvokeRequired)
            {
                SetTextCallback d = new SetTextCallback(SetDeviceName);
                this.Invoke(d, new object[] { name });
            }
            else
            {
                DeviceLabel.Text = name;
            }
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            OkAction();
        }

        public void OkAction()
        {
            if (changedOptions)
            {
                theParent.m_settings.SaveSettings(); // Save user's settings to a settings file!
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Settings were saved to store settings from Options dialog.");

                theParent.SetStartup(ScreenLockerForm.APP_NAME, theParent.m_settings.m_startWithWin); // Save user's start with win option to Registry!
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Windows startup option was saved, start with win = " + theParent.m_settings.m_startWithWin);
                // note: you don't need to enable/disable debug mode in settings because this will
                // have already occured live at the point you clicked/unclicked the debug mode radio button
            }
            else
            {
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "No settings have changed, closing dialog without saving settings.");
            }

            theParent.options = null;
            changedOptions = false;
            Close();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            if (changedOptions)
            {
                DialogResult dialogResult = MessageBox.Show("Are you sure you want to cancel the save of settings?", "Cancel Save?", MessageBoxButtons.YesNo);
                if (dialogResult == DialogResult.Yes)
                {
                    theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Settings have changed but user chose to cancel save of them, closing dialog.");
                    CancelAction();
                }
                else if (dialogResult == DialogResult.No)
                {
                    theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Settings have changed and user chose not to cancel save of them, keeping dialog open.");
                }
            }
            else
            {
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "No settings have changed or settings already saved, closing dialog without prompting user.");
                CancelAction();
            }
        }

        public void CancelAction()
        {
            string tmp_dev_id = theParent.m_settings.m_audioDeviceIDs[0].ID; // the currently set audio device

            theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Cancel or X was clicked, will restore last saved settings.");
            theParent.m_settings.LoadSettings(); // restore last saved settings to form!
            theParent.ApplyPersistedSettings(); // re-apply persisted settings from settings file

            if (tmp_dev_id.CompareTo(theParent.m_settings.m_audioDeviceIDs[0].ID) != 0)
            {
                // we've restored a different device id, lets reinit the audio side
                // regenerate alerters!
                theParent.RegenerateAudioAlerters();
            }

            theParent.options = null;
            changedOptions = false;
            Close();
        }

        private void OptionsForm_Load(object sender, EventArgs e)
        {
            //Lock options
            ckbxLockOnOutsideGeofence.Checked = theParent.m_settings.m_lockOnDoff;

            // Delay time by numeric index...
            cmbxDelay.SelectedIndex = theParent.m_settings.m_nLockDelayIndex;

            theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: applied index: " +
                theParent.m_settings.m_nLockDelayIndex + " to delay combo");

            // Lock action by enumeration string...
            int lockacttemp = 2;
            switch (theParent.m_settings.m_lockAction)
            {
                case LockAction.NoAction:
                    lockacttemp = 0;
                    break;
                case LockAction.PCHibernate:
                    lockacttemp = 4;
                    break;
                case LockAction.PCSleep:
                    lockacttemp = 3;
                    break;
                case LockAction.ScreenLock:
                    lockacttemp = 2;
                    break;
                case LockAction.ScreenSaver:
                    lockacttemp = 1;
                    break;
                default:
                    lockacttemp = 2; // default screen lock action if this fails...
                    break;
            }
            cmbxLockAction.SelectedIndex = lockacttemp;

            // General settings
            debugCheckBox.Checked = theParent.DebugMode;
            startWithWinCheckBox.Checked = theParent.m_settings.m_startWithWin;
            showToastCheckBox.Checked = theParent.m_settings.m_showToast;

            useVoicePromptsChk.Checked = theParent.m_settings.m_useVoicePrompts;
            suppressLockReasonsChkBox.Checked = theParent.m_settings.m_suppressLockReasons;

            // Help settings
            if (theParent.m_demodaysleft == 99999)
            {
                // this is an unlocked copy, hide beta controls...
                label14.Text = "Unlocked copy, will not expire.";
                var font = label14.Font;
                label14.Font = new Font(font, FontStyle.Regular);
                expireDaysLabel.Hide();
                UnlockButton.Hide();
            }
            else
            {
                int tmpDaysLeft = theParent.m_demodaysleft;
                string daysstr = tmpDaysLeft.ToString() + ((tmpDaysLeft == 1) ? " day." : " days.");
                expireDaysLabel.Text = daysstr; // number of days left of demo
            }

            // new populate available audio devices (and select the current audio device)
            PopulateAudioDevicesComboBox();

            audioVolumeTrackBar.Value = (int)(theParent.m_settings.m_audioVolume * 20.0f);

            // now ensure we set nothing has changed yet:
            changedOptions = false;

            m_loaded = true;
        }

        private void PopulateAudioDevicesComboBox()
        {
            // get list of default audio devices
            List<string> defaultDeviceIDs = new List<string>();
            List<NAudioDeviceInfo> devices = SoundAlerter.GetAudioDeviceList();

            string selected = "";
            foreach (NAudioDeviceInfo dev in devices)
            {
                AudioDevicesComboBox.Items.Add(dev.FriendlyName);
                if (dev.ID.CompareTo(theParent.m_settings.m_audioDeviceIDs[0].ID)==0)
                    selected = dev.FriendlyName;
            }

            AudioDevicesComboBox.SelectedItem = selected;
        }

        private List<string> GetFileList(string dir)
        {
            List<string> retval = new List<string>();
            var files = (from file in Directory.GetFiles(dir, "*.mp3")
                         select file).Union(
                        from file in Directory.GetFiles(dir, "*.wav")
                        select file);

            var filessorted = (from file in files
                        orderby file
                        select file);
            foreach (var file in filessorted)
            {
                int p = file.IndexOf("\\");
                if (p>0) retval.Add(file.Substring(p+1));
                else retval.Add(file);
            }
            return retval;
        }

        // activate the lock screen tab...
        internal void SelectLockTab(OptionTab whichTab)
        {
            switch (whichTab)
            {
                case OptionTab.ScreenLocker:
                    tabSmartLockDW.SelectedTab = tabLockerPage;
                    break;
                case OptionTab.Misc:
                    tabSmartLockDW.SelectedTab = tabMisc;
                    break;
            }
        }

        // LC enable/disable all the lock options based on whether we have a device attached...
        public void UpdateLockOptions()
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (this.DeviceLabel.InvokeRequired)
            {
                EnableAllOptionsCallback d = new EnableAllOptionsCallback(UpdateLockOptions);
                this.Invoke(d, new object[] { });
            }
            else
            {
                theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Info: relevant lock options will be set in GUI...");

                // LC enable/disable proximity options depending whether this device supports them
                //this.ckbxLockOnDoff.Enabled = Spokes.Instance.DeviceCapabilities.HasWearingSensor;
                //this.ckbxLockOnDock.Enabled = Spokes.Instance.DeviceCapabilities.HasDocking;
                //this.ckbxLockOnFar.Enabled = Spokes.Instance.DeviceCapabilities.HasProximity; // far (requires prox)
                //this.ckbxLockOnOutOfRange.Enabled = Spokes.Instance.DeviceCapabilities.IsWireless;
                //this.ckbxLockOnMobileOutOfRange.Enabled = Spokes.Instance.DeviceCapabilities.HasProximity; // mobile out of range (requires prox)

                //if (DeviceLabel.Text.Contains("DA45"))
                //{
                //    // special case for DA45
                //    this.ckbxLockOnFar.Enabled = false;
                //    this.ckbxLockOnMobileOutOfRange.Enabled = false;
                //}
            }
        }

        private void OptionsForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            theParent.options = null;

            // close enter key form if it is open
            if (m_keyform != null)
            {
                m_keyform.Close();
                m_keyform = null;
            }
        }

        //Smart Lock Options...

        private void ckbxLockOnDoff_CheckedChanged(object sender, EventArgs e)
        {
            if ( theParent.m_settings.m_lockOnDoff!= ckbxLockOnOutsideGeofence.Checked)
            {
                theParent.m_settings.m_lockOnDoff = ckbxLockOnOutsideGeofence.Checked;
                changedOptions = true;
            }
        }

        private void cmbxDelay_SelectedIndexChanged(object sender, EventArgs e)
        {
            if ( theParent.m_settings.m_nLockDelayIndex != cmbxDelay.SelectedIndex)
            {
                if (cmbxDelay.Text.CompareTo("Immediate") == 0)
                {
                    theParent.m_settings.m_lockDelay = 0;
                }
                else
                {
                    theParent.m_settings.m_lockDelay = Convert.ToInt32(cmbxDelay.SelectedItem);
                }
                theParent.m_settings.m_nLockDelayIndex = cmbxDelay.SelectedIndex;
                changedOptions = true;
            }
        }

        private void cmbxLockAction_SelectedIndexChanged(object sender, EventArgs e)
        {
            if ( theParent.m_settings.m_lockAction!= (LockAction)cmbxLockAction.SelectedIndex)
            {
                theParent.m_settings.m_lockAction = (LockAction)cmbxLockAction.SelectedIndex;
                changedOptions = true;
            }
        }

        // General settings...
        private void debugCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if ( theParent.DebugMode != debugCheckBox.Checked)
            {
                theParent.DebugMode = debugCheckBox.Checked;
                theParent.EnableDebug(theParent.DebugMode);
                changedOptions = true;
            }
        }

        private void startWithWinCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if ( theParent.m_settings.m_startWithWin!=startWithWinCheckBox.Checked )
            {
                theParent.m_settings.m_startWithWin = startWithWinCheckBox.Checked;
                changedOptions = true;
            }
        }

        private void showToastCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if ( theParent.m_settings.m_showToast != showToastCheckBox.Checked)
            {
                theParent.m_settings.m_showToast = showToastCheckBox.Checked;
                changedOptions = true;
            }
        }

        private void OptionsForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            // LC if user uses the X to close the Options window, make sure they want to cancel save of options
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
                    if (changedOptions)
                    {
                        DialogResult dialogResult = MessageBox.Show("Are you sure you want to cancel the save of settings?", "Cancel Save?", MessageBoxButtons.YesNo);
                        if (dialogResult == DialogResult.Yes)
                        {
                            theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Settings have changed but user chose to cancel save of them, closing dialog.");
                            CancelAction();
                        }
                        else if (dialogResult == DialogResult.No)
                        {
                            theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Settings have changed and user chose not to cancel save of them, keeping dialog open.");
                            e.Cancel = true; // cancel the dialog closing!
                        }
                    }
                    else
                    {
                        theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "No settings have changed, user is cancelling or settings were already saved, closing dialog.");
                    }
                    break;
                case CloseReason.WindowsShutDown:
                    break;
                default:
                    break;
            }           

        }

        // User has requested to enter an unlock key...
        private void UnlockButton_Click(object sender, EventArgs e)
        {
            if (m_keyform != null)
            {
                // just show the form
                m_keyform.Show();
                m_keyform.BringToFront();
            }
            else
            { 
                // open the form
                m_keyform = new EnterUnlockKeyForm(this);

                m_keyform.Show();
            }
        }

        private void useVoicePromptsChk_CheckedChanged(object sender, EventArgs e)
        {
            if (theParent.m_settings.m_useVoicePrompts != useVoicePromptsChk.Checked)
            {
                theParent.m_settings.m_useVoicePrompts = useVoicePromptsChk.Checked;
                changedOptions = true;
            }
        }

        private void AudioDevicesComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            // user has potentially changed ringtone/background noise audio device setting...
            string selecteddevname = AudioDevicesComboBox.SelectedItem.ToString();

            // get list of default audio devices
            List<string> defaultDeviceIDs = new List<string>();
            List<NAudioDeviceInfo> devices = SoundAlerter.GetAudioDeviceList();

            NAudioDeviceInfo selecteddevice = new NAudioDeviceInfo();
            foreach (NAudioDeviceInfo dev in devices)
            {
                if (dev.FriendlyName.CompareTo(selecteddevname) == 0)
                    selecteddevice = dev;
            }

            // is it the same is the currently set one?
            if (theParent.m_settings.m_audioDeviceIDs[0].ID.CompareTo(selecteddevice.ID) != 0)
            {
                // user has changed it...
                theParent.m_settings.m_audioDeviceIDs[0] = selecteddevice; // apply to settings
                // regenerate alerters!
                theParent.RegenerateAudioAlerters();
                changedOptions = true;
            }
        }

        private void audioVolumeTrackBar_Scroll(object sender, EventArgs e)
        {
            theParent.m_settings.m_audioVolume = ((float)audioVolumeTrackBar.Value) / 20.0f;
            changedOptions = true;
        }

        private void testAudioBtn_Click(object sender, EventArgs e)
        {
            // test the volume level / audio device...
            theParent.DoTextToSpeech("Sound volume set to "+ (int)(theParent.m_settings.m_audioVolume * 100.0f)
                + " percent.", true, true);
        }

        private void suppressLockReasonsChkBox_CheckedChanged(object sender, EventArgs e)
        {
            if (theParent.m_settings.m_suppressLockReasons != suppressLockReasonsChkBox.Checked)
            {
                theParent.m_settings.m_suppressLockReasons = suppressLockReasonsChkBox.Checked;
                changedOptions = true;
            }
        }

        private void TestLockBtn_Click(object sender, EventArgs e)
        {
            m_screenLocker.TriggerLock("Test Screen Lock button was clicked", false, LastLockReasonType.TestingLock);
        }
    }
}
