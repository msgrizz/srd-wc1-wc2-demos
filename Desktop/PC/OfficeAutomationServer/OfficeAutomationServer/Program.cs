using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace OfficeAutomationServer
{
    class Program
    {
        private static string APP_NAME = "Plantronics Office Automation Server";
        private static string m_assemblyVersion;
        private static string m_fileVersion;
        private static volatile object m_loglocker = new Object();
        private static bool m_quit = false;

        // DecaWave connection
        private static volatile bool _shouldStop;
        private static Thread decaWaveThread;
        private static SvcClient svcClient;
        private static readonly object m_updateLock = new object();
        private static Dictionary<string, TagXYZ> m_tags = new Dictionary<string, TagXYZ>();
        private static string m_ip;
        private static int m_port = 8784;
        private static bool m_debug = false;
        private static System.Timers.Timer periodicReporter;

        static void Main(string[] args)
        {
            DebugPrint(MethodInfo.GetCurrentMethod().Name, APP_NAME + ": startup...");
            GetVersionInfo();

            DebugPrint(MethodInfo.GetCurrentMethod().Name, "RTLS example start.\n");

            if (args.Count() < 1)
            {
                System.Console.WriteLine("\r\nUsage: ");
                System.Console.WriteLine("   DecaWaveSocketTest <master anchor ip address> [<port> - defaults to 8784] [<debugon>]\r\n");
            }
            else
            {
                m_ip = args[0];
                if (args.Count() > 1)
                {
                    try
                    {
                        m_port = Convert.ToInt32(args[1]);
                    }
                    catch (Exception)
                    {
                        m_port = 8784;
                    }
                }
                if (args.Count() > 2)
                {
                    try
                    {
                        m_debug = (args[2].ToUpper() == "DEBUGON");
                    }
                    catch (Exception)
                    {
                        m_debug = false;
                    }
                }

                decaWaveThread = new Thread(DoDecaWaveWork);
                decaWaveThread.Start();

                periodicReporter = new System.Timers.Timer();
                periodicReporter.Interval = 5000;
                periodicReporter.AutoReset = true;
                periodicReporter.Elapsed += PeriodicReporter_Elapsed;
                periodicReporter.Start();

                while (!m_quit) // todo, what will cause main thread to quit? (or just Ctrl-C?)
                {
                    Thread.Sleep(1000); // sleep main thread while decawave thread works
                }

                periodicReporter.Stop();
                RequestStop();
            }

            DebugPrint(MethodInfo.GetCurrentMethod().Name, APP_NAME + ": shutdown.");
        }

        private static void PeriodicReporter_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            int numtags = 0;
            int numstaletags = 0;
            DateTime now = DateTime.Now;
            lock (m_updateLock)
            {
                if (m_tags.Count() > 1)
                {
                    IEnumerator enumerator = m_tags.Keys.GetEnumerator();
                    while (enumerator.MoveNext())
                    {
                        string key = (string)enumerator.Current;
                        if (!key.StartsWith("old_"))
                        {
                            TagXYZ aTag = m_tags[key];
                            if (aTag != null)
                            {
                                if (now.Subtract(aTag.lastUpdate).TotalSeconds < 20) numtags++;
                                else numstaletags++; // stale tag has had no update for >= 20 seconds!
                            }
                        }
                    }
                }
                DebugPrint(MethodInfo.GetCurrentMethod().Name,
                    String.Format("Currently tracking {0} tags. There are {1} stale tags.", numtags, numstaletags));
            }
        }


        /// <summary>
        /// Generate purpose text logging feature.
        /// Adding locking so can be called from more than one thread.
        /// </summary>
        /// <param name="callingmethodname">name of method the logging originated from 
        /// (use MethodInfo.GetCurrentMethod().Name in your call to DebugPrint)</param>
        /// <param name="message">The text message you want to log</param>
        public static void DebugPrint(string callingmethodname, string message)
        {
            lock (m_loglocker) // a thread waits here until other thread has finished
            {
                string datetime = DateTime.Now.ToString("HH:mm:ss.fff");
                File.AppendAllText(Path.GetTempPath() + @"OfficeAutomationServer_log" + GetFileDateString() + ".log", String.Format("{0}: {1}(): {2}{3}", datetime, callingmethodname, message, Environment.NewLine));
            }
        }

        /// <summary>
        /// Generate a short string based on today's date
        /// </summary>
        /// <returns></returns>
        private static string GetFileDateString()
        {
            return DateTime.Now.ToString("yyyyMMdd");
        }

        private static void GetVersionInfo()
        {
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to query application version info...");

            try
            {
                Assembly myassem = Assembly.GetExecutingAssembly();
                string assemver = myassem.GetName().Version.ToString();
                FileVersionInfo fvi = FileVersionInfo.GetVersionInfo(myassem.Location);
                string version = fvi.ProductVersion;

                DebugPrint(MethodInfo.GetCurrentMethod().Name, "Assembly = " + assemver
                    + " File = " + fvi.FileVersion);

                m_assemblyVersion = assemver;
                m_fileVersion = fvi.FileVersion;
            }
            catch (Exception e)
            {
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "ERROR: exception caught trying to get version info: \r\n" + e.ToString());
            }
        }

        private static void DoDecaWaveWork()
        {
            bool connected = false;

            while (!_shouldStop)
            {
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "worker thread: working...");

                if (!connected)
                {
                    svcClient = new SvcClient(m_ip, m_port);
                    string listener = svcClient.request("{\"command\":\"getLsListener\"}");
                    connected = true;

                    try
                    {
                        var lsAddress = System.Web.Helpers.Json.Decode(listener);

                        if (lsAddress.mode == "unicast")
                        {
                            DebugPrint(MethodInfo.GetCurrentMethod().Name, string.Format("Received LS listener: {0}\n", lsAddress.mode));

                            UdpClient socket = new UdpClient();
                            IPEndPoint localEp = new IPEndPoint(IPAddress.Parse(lsAddress.ip), 8787);
                            socket.Client.Bind(localEp);
                            socket.Client.ReceiveTimeout = 20000;
                            bool isTimeExpired = false;
                            // Data buffer for incoming data.
                            byte[] recvData;

                            while (!_shouldStop && !isTimeExpired)
                            {
                                try
                                {
                                    recvData = socket.Receive(ref localEp);
                                    if (recvData.Length > 0)
                                    {
                                        string recv =
                                            Encoding.ASCII.GetString(recvData, 0, recvData.Length);
                                        if (m_debug)
                                        {
                                            DebugPrint(MethodInfo.GetCurrentMethod().Name, "LS: Received: ");
                                        }
                                        string[] lines = recv.Split(new string[] { "\r\n", "\n" }, StringSplitOptions.None);
                                        foreach (string line in lines)
                                        {

                                            var tagMsg = System.Web.Helpers.Json.Decode(line);
                                            if (tagMsg != null &&
                                                tagMsg.id != null &&
                                                tagMsg.coordinates != null &&
                                                tagMsg.coordinates.x != null &&
                                                tagMsg.coordinates.y != null)
                                            {
                                                if (m_debug)
                                                {
                                                    DebugPrint(MethodInfo.GetCurrentMethod().Name,
                                                        string.Format("ID: {0}, x: {1}, y: {2}",
                                                        tagMsg.id,
                                                        tagMsg.coordinates.x,
                                                        tagMsg.coordinates.y
                                                        )
                                                    );
                                                }

                                                // TODO communicate here to registered/interested clients
                                                // that the xyz pos of a tag has been updated

                                                UpdateTagXYZ(
                                                    tagMsg.id,
                                                    tagMsg.coordinates.x,
                                                    tagMsg.coordinates.y,
                                                    tagMsg.coordinates.z);
                                            }
                                            else
                                            {
                                                if (m_debug)
                                                {
                                                    DebugPrint(MethodInfo.GetCurrentMethod().Name, "LS: Recv'd tag msg with NO coords ");
                                                    if (tagMsg != null &&
                                                        tagMsg.id != null)
                                                    {
                                                        DebugPrint(MethodInfo.GetCurrentMethod().Name, "from tag ID: " + tagMsg.id);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if (m_debug)
                                        {
                                            DebugPrint(MethodInfo.GetCurrentMethod().Name, "LS: Received empty");
                                        }
                                    }
                                }
                                catch (Exception e)
                                {
                                    DebugPrint(MethodInfo.GetCurrentMethod().Name, e.ToString());
                                    isTimeExpired = true;
                                    _shouldStop = true;
                                }
                            }
                        }

                    }
                    catch (Exception e)
                    {
                        DebugPrint(MethodInfo.GetCurrentMethod().Name, e.ToString());
                    }
                }

                Thread.Sleep(1000);
                DebugPrint(MethodInfo.GetCurrentMethod().Name, ".");
            }
            svcClient.close();
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "worker thread: terminating gracefully.");
        }

        public static void UpdateTagXYZ(string id, Decimal x, Decimal y, Decimal z)
        {
            lock (m_updateLock)
            {
                // see if tag coords have changed
                if (m_tags.ContainsKey(id))
                {
                    m_tags[id].update(x, y, z, DateTime.Now); // update tag record
                }
                else
                {
                    m_tags.Add(id, new TagXYZ(x, y, z, "", DateTime.Now)); // add updated tag record
                    DebugPrint(MethodInfo.GetCurrentMethod().Name,
                        String.Format("Got new tag id: {0}, initial pos {1},{2},{3}", id, x, y, z));
                }
            }
        }

        public static void RequestStop()
        {
            _shouldStop = true;
        }
    }
}
