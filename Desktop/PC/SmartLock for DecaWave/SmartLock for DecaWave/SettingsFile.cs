using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using System.Xml.XPath;
using System.Reflection;
using System.IO;

/**
 * SettingsFile - a convenience class for saving and loading
 * application settings to and from and XML settings file
 * 
 * Author: Lewis Collins, Plantronics
 * Oct 2012
 * 
 **/

namespace Plantronics.UC.SmartLock
{
    public class SettingsFile
    {
        ScreenLockerForm m_parent;
        string m_settingsfilename;

        // Screen Lock Settings:
        public bool m_lockOnDoff { get; set; }
        public bool m_lockOnFar { get; set; }
        public bool m_lockOnOutOfRange { get; set; }
        public bool m_lockOnDock { get; set; }
        public bool m_lockOnMobileOutOfRange { get; set; }
        public int m_lockDelay { get; set; }
        public int m_nLockDelayIndex = 1;
        public LockAction m_lockAction { get; set; }

        // Proximity Tuning settings:
        public int m_nearThreshold { get; set; }
        public int m_deadband { get; set; }

        // General app setings:
        public bool m_debugMode { get; set; }
        public bool m_startWithWin { get; set; }
        public bool m_showToast { get; set; }
        public List<NAudioDeviceInfo> m_audioDeviceIDs;
        public List<NAudioDeviceInfo> m_defaultAudioDeviceIDs;
        public bool m_useVoicePrompts;
        public float m_audioVolume;
        public bool m_suppressLockReasons;

        public SettingsFile(ScreenLockerForm parent, string settingsfilename, List<NAudioDeviceInfo> defaultAudioDeviceIDs)
        {
            m_parent = parent;
            m_settingsfilename = settingsfilename;
            if (defaultAudioDeviceIDs != null)
            {
                m_defaultAudioDeviceIDs = defaultAudioDeviceIDs;
            }
            else
            {
                m_defaultAudioDeviceIDs = new List<NAudioDeviceInfo>();
            }

            ApplyDefaultSettings();
            LoadSettings(); // initial load of settings
        }

        public void ApplyDefaultSettings()
        {
            // Screen Lock Settings:
            m_lockOnDoff = false;
            m_lockOnFar = true;
            m_lockOnOutOfRange = true;
            m_lockOnDock = true;
            m_lockOnMobileOutOfRange = true;
            m_lockDelay = 15;
            m_nLockDelayIndex = 1;  // LC bug fix 8-6-2015
            m_lockAction = LockAction.ScreenLock;

            // Proximity Tuning settings:
            m_nearThreshold = 63;
            m_deadband = 1;

            // General settings:
            m_debugMode = false;
            m_startWithWin = true;
            m_showToast = true;
            m_audioDeviceIDs = m_defaultAudioDeviceIDs;
            m_useVoicePrompts = false; // default voice prompts to off
            m_suppressLockReasons = false; // default lock reasons to off
            m_audioVolume = 1.0f;

            m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "DEFAULT Settings summary: " + "\r\n" +
            "  LockOnDoff = " + m_lockOnDoff + "\r\n" +
            "  LockOnFar = " + m_lockOnFar + "\r\n" +
            "  LockOnOutOfRange = " + m_lockOnOutOfRange + "\r\n" +
            "  LockOnDock = " + m_lockOnDock + "\r\n" +
            "  LockOnMobileOutOfRange = " + m_lockOnMobileOutOfRange + "\r\n" +
            "  LockDelay = " + m_lockDelay + "\r\n" +
            "  LockAction = " + m_lockAction + "\r\n" +

            "  NearThreshold = " + m_nearThreshold + "\r\n" +
            "  DeadBand = " + m_deadband + "\r\n" +

            "  DebugMode = " + m_debugMode + "\r\n" +
            "  StartWithWin = " + m_startWithWin + "\r\n" +
            "  ShowToast = " + m_showToast + "\r\n" +
            "  UseVoicePrompts = " + m_useVoicePrompts + "\r\n" +
            "  AudioVolume = " + m_audioVolume + "\r\n" +
            "  Suppress Lock Reasons = " + m_suppressLockReasons);
        }

        // save choices to config file
        public void SaveSettings()
        {
            m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to save settings.");
            try
            {
                XElement xml = new XElement("screenlocksettings");
                    
                XElement audioDevices = new XElement("AudioDevices");

                foreach (NAudioDeviceInfo item in m_audioDeviceIDs)
                {
                    audioDevices.Add(new XElement("AudioDevice",
                        new XElement("FriendlyName", item.FriendlyName),
                        new XElement("ID", item.ID),
                        new XElement("isDefault", item.isDefault)));
                }

                // add audio devices
                xml.Add(audioDevices);

                // Add other settings
                xml.Add(new XElement("LockOnDoff", m_lockOnDoff.ToString()));
                xml.Add(new XElement("LockOnFar", m_lockOnFar.ToString()));
                xml.Add(new XElement("LockOnOutOfRange", m_lockOnOutOfRange.ToString()));
                xml.Add(new XElement("LockOnDock", m_lockOnDock.ToString()));
                xml.Add(new XElement("LockOnMobileOutOfRange", m_lockOnMobileOutOfRange.ToString()));
                xml.Add(new XElement("LockDelay", m_lockDelay.ToString()));
                xml.Add(new XElement("LockDelayIndex", m_nLockDelayIndex));
                xml.Add(new XElement("LockAction", m_lockAction));

                xml.Add(new XElement("NearThreshold", m_nearThreshold));
                xml.Add(new XElement("DeadBand", m_deadband));

                xml.Add(new XElement("DebugMode", m_debugMode));
                xml.Add(new XElement("StartWithWin", m_startWithWin));
                xml.Add(new XElement("ShowToast", m_showToast));
                xml.Add(new XElement("UseVoicePrompts", m_useVoicePrompts));
                xml.Add(new XElement("AudioVolume", m_audioVolume.ToString()));
                xml.Add(new XElement("SuppressLockReasons", m_suppressLockReasons));
                    
                xml.Save(m_settingsfilename);

                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Settings were saved to: " + m_settingsfilename + ".");
                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Settings summary: " + "\r\n" +
                "  LockOnDoff = " + m_lockOnDoff + "\r\n" +
                "  LockOnFar = " + m_lockOnFar + "\r\n" +
                "  LockOnOutOfRange = " + m_lockOnOutOfRange + "\r\n" +
                "  LockOnDock = " + m_lockOnDock + "\r\n" +
                "  LockOnMobileOutOfRange = " + m_lockOnMobileOutOfRange + "\r\n" +
                "  LockDelay = " + m_lockDelay + "\r\n" +
                "  LockDelayIndex = " + m_nLockDelayIndex + "\r\n" +
                "  LockAction = " + m_lockAction + "\r\n" +

                "  NearThreshold = " + m_nearThreshold + "\r\n" +
                "  DeadBand = " + m_deadband + "\r\n" +

                "  DebugMode = " + m_debugMode + "\r\n" +
                "  StartWithWin = " + m_startWithWin + "\r\n" +
                "  ShowToast = " + m_showToast + "\r\n" +
                "  UseVoicePrompts = " + m_useVoicePrompts + "\r\n" +
                "  AudioVolume = " + m_audioVolume + "\r\n" +
                "  Suppress Lock Reasons = " + m_suppressLockReasons);
            }
            catch (Exception e)
            {
                // uh-oh
                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Error occured while saving settings to: " + m_settingsfilename + ". " + e.ToString());
            }
        }

        // load choices from config file
        public void LoadSettings()
        {
            m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to load settings from :" + m_settingsfilename + ".");
            try
            {
                XElement xml = XElement.Load(m_settingsfilename);

                bool found = false;
                List<NAudioDeviceInfo> devIdtmp = new List<NAudioDeviceInfo>();
                XElement AudioDevices = xml.XPathSelectElement("./AudioDevices");
                if (AudioDevices != null)
                {
                    found = true; // we have found at least an empty AudioDevices, maybe a populated AudioDevices!

                    foreach (XElement item in AudioDevices.XPathSelectElements("./AudioDevice"))
                    {
                        NAudioDeviceInfo devinfo = new NAudioDeviceInfo();
                        devinfo.FriendlyName = (string)item.XPathSelectElement("./FriendlyName");
                        devinfo.ID = (string)item.XPathSelectElement("./ID");
                        devinfo.isDefault = (bool)item.XPathSelectElement("./isDefault");
                        devIdtmp.Add(devinfo);
                    }
                }

                if (found)
                    m_audioDeviceIDs = devIdtmp;

                // read other settings
                m_lockOnDoff = (bool)xml.XPathSelectElement("./LockOnDoff");
                m_lockOnFar = (bool)xml.XPathSelectElement("./LockOnFar");
                m_lockOnOutOfRange = (bool)xml.XPathSelectElement("./LockOnOutOfRange");
                m_lockOnDock = (bool)xml.XPathSelectElement("./LockOnDock");
                m_lockOnMobileOutOfRange = (bool)xml.XPathSelectElement("./LockOnMobileOutOfRange");
                m_lockDelay = (int)xml.XPathSelectElement("./LockDelay");
                m_nLockDelayIndex = (int)xml.XPathSelectElement("./LockDelayIndex");
                m_lockAction = (LockAction)Enum.Parse(typeof(LockAction), (string)xml.XPathSelectElement("./LockAction"));

                m_nearThreshold = (int)xml.XPathSelectElement("./NearThreshold");
                m_deadband = (int)xml.XPathSelectElement("./DeadBand");

                m_debugMode = (bool)xml.XPathSelectElement("./DebugMode");
                m_startWithWin = (bool)xml.XPathSelectElement("./StartWithWin");
                m_showToast = (bool)xml.XPathSelectElement("./ShowToast");
                m_useVoicePrompts = (bool)xml.XPathSelectElement("./UseVoicePrompts");
                m_audioVolume = (float)xml.XPathSelectElement("./AudioVolume");
                m_suppressLockReasons = (bool)xml.XPathSelectElement("./SuppressLockReasons");

                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Settings were loaded from: " + m_settingsfilename + ".");
                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Settings summary: " + "\r\n" +
                "  LockOnDoff = " + m_lockOnDoff + "\r\n" +
                "  LockOnFar = " + m_lockOnFar + "\r\n" +
                "  LockOnOutOfRange = " + m_lockOnOutOfRange + "\r\n" +
                "  LockOnDock = " + m_lockOnDock + "\r\n" +
                "  LockOnMobileOutOfRange = " + m_lockOnMobileOutOfRange + "\r\n" +
                "  LockDelay = " + m_lockDelay + "\r\n" +
                "  LockAction = " + m_lockAction + "\r\n" +

                "  NearThreshold = " + m_nearThreshold + "\r\n" +
                "  DeadBand = " + m_deadband + "\r\n" +

                "  DebugMode = " + m_debugMode + "\r\n" +
                "  StartWithWin = " + m_startWithWin + "\r\n" +
                "  ShowToast = " + m_showToast + "\r\n" +
                "  UseVoicePrompts = " + m_useVoicePrompts + "\r\n" +
                "  AudioVolume = " + m_audioVolume + "\r\n" +
                "  Suppress Lock Reasons = " + m_suppressLockReasons);
            }
            catch (Exception e)
            {
                // uh-oh, maybe there's no settings file yet!
                m_parent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Info: Could not load settings from: " + m_settingsfilename + ". (maybe there's no settings file yet). Will apply default settings. " + e.ToString());
                ApplyDefaultSettings(); // load failed, so apply defaults
            }
        }
    }
}
