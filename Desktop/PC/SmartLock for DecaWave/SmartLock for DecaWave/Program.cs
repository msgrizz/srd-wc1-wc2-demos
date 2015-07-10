using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using System.Diagnostics;
using System.ComponentModel;
//using Microsoft.Office.Interop.Outlook; 
using System.Runtime.InteropServices;
using System.Threading;

enum ProxValue
    {
        near,
        far,
        unknown,
        outofrange
    }


namespace Plantronics.UC.SmartLock
{
    static class Program
    {
        // Create a Mutex to use to ensure only 1 instance of app will run
        static Mutex mutex = new Mutex(true, "{B9CF00A0-73DC-49FB-AA60-E0E33484EE57}");

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            if (mutex.WaitOne(TimeSpan.Zero, true))
            {
                try
                {
                    // Command Loop, wait for user input
                    System.Windows.Forms.Application.EnableVisualStyles();
                    System.Windows.Forms.Application.SetCompatibleTextRenderingDefault(false);
                    System.Windows.Forms.Application.Run(new ScreenLockerForm());
                }
                catch (System.Exception ex)
                {
                    string msg = "An unhandled exception has occured. Exiting application.\r\n"
                    + "\r\nError: " + ex.Message
                    + "\r\n.";
                    MessageBox.Show(msg, "Error Detected");
                }
                mutex.ReleaseMutex();
            }
            else
            {
                // Workaround if I can't get the broadcast message below working, show user a message box...
                //MessageBox.Show("Another instance of SmartLock is already running. Please check your system tray area for the SmartLock icon.\r\n\r\nExiting this instance.", "SmartLock message");

                // send our Win32 message to make the currently running instance
                // jump on top of all the other windows
                WinAPI.PostMessage(
                    (IntPtr)WinAPI.HWND_BROADCAST,
                    WinAPI.WM_SHOWME,
                    0,
                    0);
                return;
            }
        } //Main()
    }// class Program
}

