using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

/**
 * This is a convenience class
 * for saving DateTime objects to secret
 * files and comparing the date now
 * with the date saved to know
 * if the software demo has expired
 * or not!
 * 
 * NOTE: If user re-installs the demo
 * the secret file will still be present
 * so the software will remain "expired"
 **/

namespace Plantronics.UC.SmartLock
{
    public static class TimeoutSystem
    {
        // get the last install time of the software
        // from a file on the disc
        public static DateTime GetInstallTime()
        {
            DateTime retval = DateTime.MaxValue;

            try
            {
                FileStream readStream;
                readStream = new FileStream("Plantronics_SmartLockIDSettings.bin", FileMode.Open);

                BinaryReader readBinary = new BinaryReader(readStream);

                retval = new DateTime(readBinary.ReadInt64());

                readBinary.Close();
            }
            catch (Exception)
            {
                // return default value
                retval = DateTime.MaxValue;
            }

            return retval;
        }

        // if the above function does not find an install time
        // then use this function to write one
        // returns true to say if it succeeded, false otherwise
        public static bool WriteInstallTime(DateTime installTime)
        {
            bool retval = false;

            try
            {
                FileStream writeStream;
                writeStream = new FileStream("Plantronics_SmartLockIDSettings.bin", FileMode.Create);

                BinaryWriter writeBinary = new BinaryWriter(writeStream);

                writeBinary.Write(installTime.Ticks);

                writeBinary.Close();

                retval = true;
            }
            catch (Exception)
            {
                // return default value
                retval = false;
            }

            return retval;
        }

        // Pass a demoValidPeriodDays in, e.g. 30 and
        // this function will tell you how many days of
        // the demo are left. If it returns 0 then demo is over
        public static int DaysLeftOfDemo(int demoValidPeriodDays)
        {
            int retval = 0;

            DateTime installed = GetInstallTime();

            // is it unlocked?
            if (installed == DateTime.MinValue)
            {
                return 99999;  // never expire
            }

            if (installed == DateTime.MaxValue)
            {
                installed = DateTime.Now;

                // if you want test timeout effect delete Plantronics_SmartLockIDSettings.bin from disk
                // then uncomment this line, taking off a number of days just before, then equal to, then just
                // greater than the validity period days...
                //    installed = installed - TimeSpan.FromDays(49);    

                WriteInstallTime(installed);
            }

            int days_ago_installed = (DateTime.Now - installed).Days;

            retval = demoValidPeriodDays - days_ago_installed;
            if (retval < 0) retval = 0;

            return retval;
        }

        internal static void UnlockDemo()
        {
            WriteInstallTime(DateTime.MinValue);
        }
    }
}
