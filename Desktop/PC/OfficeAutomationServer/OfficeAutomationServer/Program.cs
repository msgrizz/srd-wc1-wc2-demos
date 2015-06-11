using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace OfficeAutomationServer
{
    class Program
    {
        private static string APP_NAME = "Plantronics Office Automation Server";
        private static string m_assemblyVersion;
        private static string m_fileVersion;
        static volatile object m_loglocker = new Object();

        static void Main(string[] args)
        {
            DebugPrint(MethodInfo.GetCurrentMethod().Name, APP_NAME+": startup...");
            GetVersionInfo();
            DebugPrint(MethodInfo.GetCurrentMethod().Name, APP_NAME + ": shutdown.");
        }

        /// <summary>
        /// Generate purpose text logging feature.
        /// Adding locking so can be called from more than one thread.
        /// </summary>
        /// <param name="callingmethodname">name of method the logging originated from 
        /// (use MethodInfo.GetCurrentMethod().Name in your call to DebugPrint)</param>
        /// <param name="message">The text message you want to log</param>
        private static void DebugPrint(string callingmethodname, string message)
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
    }
}
