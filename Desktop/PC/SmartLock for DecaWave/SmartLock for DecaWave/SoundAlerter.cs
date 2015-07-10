using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

// NAudio packages for accessing audio devices, playing sounds...
using NAudio.Wave;
using NAudio.CoreAudioApi;
using System.Threading;

using System.Speech.Synthesis;
using System.Speech.AudioFormat;
using System.IO;

namespace Plantronics.UC.SmartLock
{
    public struct NAudioDeviceInfo
    {
        public string FriendlyName;
        public string ID;
        public bool isDefault;

        public override string ToString()
        {
            return "Friendly Name: "+FriendlyName+"\r\nID: "+ID+"\r\nIs Default?: "+isDefault+"\r\n";
        }
    }

    public enum AlerterType
    {
        WAVAlerter,
        MP3Alerter,
        TextToSpeechAlerter
    }

    /**
     * This is a convenience class for playing a sound on a single audio device
     * You can instantiate multiple of these classes, one per audio device
     * to play back on multiple devices
     **/
    public class SoundAlerter
    {
        private AlerterType m_alerterType;

        IWavePlayer waveOutDevice = null;
        WaveStream mainOutputStream = null;
        WaveChannel32 volumeStream = null;
        WaveStream fileReader = null;

        private string m_deviceid = "";
        private string m_deviceguid = "";
        private string m_randfilename = "";

        public string Randfilename
        {
            get { return m_randfilename; }
            set { m_randfilename = value; }
        }

        public bool Loop { get; set; }

        public SoundAlerter(AlerterType alerterType, string deviceid, bool loop = false)
        {
            m_alerterType = alerterType;
            Loop = loop; 
            SetDeviceId(deviceid);
            if (alerterType == AlerterType.TextToSpeechAlerter)
            {
                RandomizeFilename();
            }
        }

        private void RandomizeFilename()
        {
            // make a random filename for this speech alerter...
            m_randfilename = "SNDALRT."+Guid.NewGuid().ToString() + ".wav";
        }

        private void SetDeviceId(string deviceid)
        {
            m_deviceid = deviceid;
            int pos = deviceid.IndexOf("}.{");
            if (pos > 0)
            {
                m_deviceguid = deviceid.Substring(pos + 2);
            }
        }

        // a sound alerter for playing file
        public SoundAlerter(AlerterType alerterType, string deviceid, string filename, bool loop = false)
        {
            m_alerterType = alerterType;
            Loop = loop;
            SetDeviceId(deviceid);
            if (filename != null && deviceid != null)
            {
                PreLoadSound(filename);
            }
        }

        ~SoundAlerter()
        {
            TidyUpResources();
        }

        public void TidyUpResources()
        {
            if (waveOutDevice != null)
            {
                waveOutDevice.Stop();
                waveOutDevice = null;
            }
            if (mainOutputStream != null)
            {
                if (volumeStream != null)
                {
                    // this one really closes the file and ACM conversion
                    volumeStream.Close();
                    volumeStream = null;
                }
                // this one does the metering stream
                mainOutputStream.Close();
                mainOutputStream = null;
            }
            if (waveOutDevice != null)
            {
                waveOutDevice.Dispose();
                waveOutDevice = null;
            }
            if (fileReader != null)
            {
                fileReader.Close();
                fileReader = null;
            }
        }

        public static List<NAudioDeviceInfo> GetAudioDeviceList()
        {
            List<NAudioDeviceInfo> retval = new List<NAudioDeviceInfo>();
            int numPlaybackDevices = WaveOut.DeviceCount;
            MMDeviceEnumerator devEnum = new MMDeviceEnumerator();
            MMDevice defaultDevice = devEnum.GetDefaultAudioEndpoint(DataFlow.Render, Role.Multimedia);
            foreach (MMDevice dev in devEnum.EnumerateAudioEndPoints(DataFlow.Render, DeviceState.Active))
            {
                NAudioDeviceInfo devinfo = new NAudioDeviceInfo();
                devinfo.FriendlyName = dev.FriendlyName;
                devinfo.ID = dev.ID;
                devinfo.isDefault = (defaultDevice.ID == devinfo.ID);
                retval.Add(devinfo);
            }
            return retval;
        }

        private WaveStream CreateInputStream(string fileName, float volume = 1.0f)
        {
            WaveChannel32 inputStream;
            if (fileName.ToUpper().EndsWith(".MP3"))
            {
                fileReader = new Mp3FileReader(fileName);
                if (!Loop) inputStream = new WaveChannel32(fileReader);
                else inputStream = new WaveChannel32(new LoopStream(fileReader));
            }
            else if (fileName.ToUpper().EndsWith(".WAV"))
            {
                fileReader = new WaveFileReader(fileName);
                if (!Loop) inputStream = new WaveChannel32(fileReader);
                else inputStream = new WaveChannel32(new LoopStream(fileReader));
            }
            else
            {
                throw new InvalidOperationException("Unsupported extension");
            }
            if (inputStream != null) inputStream.Volume = volume;
            return inputStream;
        }

        public void PreLoadSound(string filename, float volume = 1.0f)
        {
            TidyUpResources();
            waveOutDevice = new DirectSoundOut(new Guid(m_deviceguid));

            mainOutputStream = CreateInputStream(filename, volume);

            volumeStream = (WaveChannel32)mainOutputStream;

            waveOutDevice.Init(mainOutputStream);
        }

        public void PreLoadTextToSpeech(string text, float volume = 1.0f)
        {
            TidyUpResources();
            // Plan
            // 1. Save Text to Speech output to file to WAV
            // 2. Pre-load the WAV file into this alerter ready to Play()
            SpeechSynthesizer _Speech = new SpeechSynthesizer();

            RandomizeFilename();
            _Speech.SetOutputToWaveFile(m_randfilename);
            _Speech.Speak(text);
            _Speech.SetOutputToNull();

            waveOutDevice = new DirectSoundOut(new Guid(m_deviceguid));

            mainOutputStream = CreateInputStream(m_randfilename, volume);

            volumeStream = (WaveChannel32)mainOutputStream;

            waveOutDevice.Init(mainOutputStream);
        }

        public void Play()
        {
            Stop();
            if (waveOutDevice != null)
                waveOutDevice.Play();
        }

        internal void Stop()
        {
            if (waveOutDevice != null)
            {
                if (waveOutDevice.PlaybackState == PlaybackState.Playing)
                {
                    waveOutDevice.Stop();
                }
                if (mainOutputStream != null)
                    mainOutputStream.Position = 0;
            }
        }

        public static void CleanTempFiles()
        {
            string[] filePaths = Directory.GetFiles(".", "SNDALRT.*.wav");

            foreach (string filePath in filePaths)
            {
                File.Delete(filePath);
            }
        }

        internal bool IsPlaying()
        {
            // our stream is playing if
            // we are in playing state
            // and our stream position is less than total time of stream
            // OR are a looping stream
            if (waveOutDevice != null)
                return Loop || (
                    waveOutDevice.PlaybackState == PlaybackState.Playing
                    &&
                    mainOutputStream.CurrentTime < mainOutputStream.TotalTime
                    );
            return false;
        }
    }

    /// <summary>
    /// Stream for looping playback (modified from http://mark-dot-net.blogspot.co.uk/2009/10/looped-playback-in-net-with-naudio.html)
    /// http://opensebj.blogspot.com/2009/03/naudio-tutorial-3-sample-properties.html
    /// </summary>
    public class LoopStream : WaveStream
    {
        WaveStream sourceStream;

        /// <summary>
        /// Creates a new Loop stream
        /// </summary>
        /// <param name="sourceStream">The stream to read from. Note: the Read method of this stream should return 0 when it reaches the end
        /// or else we will not loop to the start again.</param>
        public LoopStream(WaveStream sourceStream)
        {
            this.sourceStream = sourceStream;
            this.EnableLooping = true;
        }

        /// <summary>
        /// Use this to turn looping on or off
        /// </summary>
        public bool EnableLooping { get; set; }

        /// <summary>
        /// Return source stream's wave format
        /// </summary>
        public override WaveFormat WaveFormat
        {
            get { return sourceStream.WaveFormat; }
        }

        /// <summary>
        /// LoopStream simply returns
        /// </summary>
        public override long Length
        {
            get { return sourceStream.Length; }
        }

        /// <summary>
        /// LoopStream simply passes on positioning to source stream
        /// </summary>
        public override long Position
        {
            get { return sourceStream.Position; }
            set { sourceStream.Position = value; }
        }

        public override int Read(byte[] buffer, int offset, int count)
        {
            // Check if the stream has been set to loop
            if (EnableLooping)
            {
                // Looping code taken from NAudio Demo
                int read = 0;
                while (read < count)
                {
                    int required = count - read;
                    int readThisTime = sourceStream.Read(buffer, offset + read, required);
                    if (readThisTime < required)
                    {
                        sourceStream.Position = 0;
                    }

                    if (sourceStream.Position >= sourceStream.Length)
                    {
                        sourceStream.Position = 0;
                    }
                    read += readThisTime;
                }
                return read;
            }
            else
            {
                // Normal read code, sample has not been set to loop
                return sourceStream.Read(buffer, offset, count);
            }
        }
    }
}
