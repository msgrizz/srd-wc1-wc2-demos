using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Reflection;

// Lets find out about attached audio devices - for diagnostic info...
using System.Management;
using NAudio.Wave;
using NAudio.CoreAudioApi;

namespace Plantronics.UC.SmartLock
{
    public partial class ScreenLockerDebug : Form
    {
        ScreenLockerForm m_parent;
        private bool m_exitting = false;

        delegate void SetTextCallback(string text);

        public ScreenLockerDebug(ScreenLockerForm parent)
        {
            InitializeComponent();

            m_parent = parent;
        }

        public void AppendToOutputWindow(String message)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (this.txtOutput.InvokeRequired)
            {
                SetTextCallback d = new SetTextCallback(AppendToOutputWindow);
                this.Invoke(d, new object[] { message });
            }
            else
            {
                this.txtOutput.AppendText(String.Format("{0}\r\n", message));
                this.txtOutput.SelectionStart = txtOutput.Text.Length;
                this.txtOutput.ScrollToCaret();
            }
        }

        private void ScreenLockerDebug_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!m_exitting)
                m_parent.DisableDebugFromFormClose();
        }

        private void ScreenLockerDebug_Load(object sender, EventArgs e)
        {
            DisplayDiagnosticInformation();
        }

        // Convenience function to display some useful diagnostics which debug mode is enabled
        private void DisplayDiagnosticInformation()
        {
            m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "**************** SCREENLOCK DIAGNOSTIC SUMMARY **************** ");

            ShowAudioDevices();

            m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "************** END SCREENLOCK DIAGNOSTIC SUMMARY ************** ");
        }

        private void ShowAudioDevices()
        {
            try
            {
                // Using Windows Management API to list all audio devices...
                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "AUDIO DEVICE SUMMARY: \r\n");
                SelectQuery querySound = new SelectQuery("Win32_SoundDevice");
                ManagementObjectSearcher searcherSound = new ManagementObjectSearcher(querySound);
                foreach (ManagementObject sound in searcherSound.Get())
                {
                    m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Sound device: " + sound["Name"] + ", " + sound["Status"]);
                }

                // Using Windows Management API to list all audio devices...
                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "DETERMINE DEFAULT AUDIO DEVICE: \r\n");

                int numPlaybackDevices = WaveOut.DeviceCount;

                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "NAudio reports: " + numPlaybackDevices + " playback devices.");

                MMDeviceEnumerator devEnum = new MMDeviceEnumerator();
                MMDevice defaultDevice = devEnum.GetDefaultAudioEndpoint(DataFlow.Render, Role.Multimedia);

                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "NAudio reports DEFAULT DEVICE = \r\n" +
                    "   DeviceFriendlyName: " + defaultDevice.DeviceFriendlyName + "\r\n" +
                    "   FriendlyName: " + defaultDevice.FriendlyName + "\r\n" +
                    "   Is Muted?: " + defaultDevice.AudioEndpointVolume.Mute + "\r\n" +
                    "   Volume Setting: " + (int)Math.Round(defaultDevice.AudioEndpointVolume.MasterVolumeLevelScalar * 100) + "\r\n"
                    );

            }
            catch (Exception e)
            {
                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "ERROR: Exception caught while looking at audio devices:\r\n"+e.ToString());
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            DisplayDiagnosticInformation();
        }

        internal void SetExitting(bool exitting)
        {
            m_exitting = exitting;
        }
    }
}
