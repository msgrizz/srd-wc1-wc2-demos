using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace DecaWaveClientSocketScratchPad
{
    class Program
    {
        private static string APP_NAME = "Plantronics DecaWave Client Test";
        private static string m_assemblyVersion;
        private static string m_fileVersion;
        private static volatile object m_loglocker = new Object();
        private static volatile bool m_quit = false; // using volatile so can access/update from multiple threads

        private static string m_host;
        private static int m_port = 9050;
        private static bool m_debug = false;

        private static SocketConnector connector;

        static void Main(string[] args)
        {
            DebugPrint(MethodInfo.GetCurrentMethod().Name, APP_NAME + ": startup...");
            GetVersionInfo();

            DebugPrint(MethodInfo.GetCurrentMethod().Name, "RTLS example start.\n");

            if (args.Count() < 1)
            {
                System.Console.WriteLine("\r\nUsage: ");
                System.Console.WriteLine("   DecaWaveClientTest <OAS server ip address> [<port> - defaults to 9050] [<debugon>]\r\n");
            }
            else
            {
                m_host = args[0];
                if (args.Count() > 1)
                {
                    try
                    {
                        m_port = Convert.ToInt32(args[1]);
                    }
                    catch (Exception)
                    {
                        m_port = 9050;
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
                connector = new SocketConnector(m_host, m_port);

                Thread.Sleep(500);

                while (!m_quit)
                {
                    DoReadCommand();
                }
            }

            DebugPrint(MethodInfo.GetCurrentMethod().Name, APP_NAME + ": shutdown.");

            Thread.Sleep(500);
            Console.Write("Press enter to continue...");
            Console.ReadLine();
        }

        private static void DoReadCommand()
        {
            Console.Write("Type a command >");
            string command = Console.ReadLine();

            switch (command.ToUpper())
            {
                case "QUIT":
                    connector.ShutDown();
                    m_quit = true;
                    break;
                case "HELP":
                    DisplayCommands();
                    break;
                case "SS":
                    connector.SendCommand("SUBSCRIBEALL");
                    break;
                case "OFF":
                    connector.SendCommand("SUBSCRIBEOFF");
                    break;
            }
        }

        private static void DisplayCommands()
        {
            Console.WriteLine("\r\n\r\nAVAILABLE COMMANDS:\r\n--\r\n");
            Console.WriteLine("QUIT - quit program");
            Console.WriteLine("HELP - display this");
            Console.WriteLine("SS - subscribe all tag updates");
            Console.WriteLine("OFF - unsubscribe all tag updates");
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
                string outstr = String.Format("{0}: {1}(): {2}{3}", datetime, callingmethodname, message, Environment.NewLine);
                File.AppendAllText(Path.GetTempPath() + @"DecaWaveClientTest_log" + GetFileDateString() + ".log", outstr);
                if (m_debug)
                {
                    Console.WriteLine(outstr);
                }
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

    }
}
