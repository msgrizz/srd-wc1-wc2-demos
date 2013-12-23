using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Plantronics.Innovation.Util
{
    // A class to process incoming quats on a background thread
    // and return the computed angles and calibrated flag to
    // main application
    public class QuaternionProcessor
    {
        private Thread m_worker;
        private static HeadtrackingUpdateHandler m_headsetDataHandler;

        // List of incoming odp payloads
        static Queue<string> m_odppayloads = new Queue<string>();

        // locking flag/handle, thanks: http://www.albahari.com/threading/part4.aspx
        static readonly object _locker = new object();
        static bool _go = false;

        // flags for signalling to calibrate etc
        private static double[] calquat;
        private static bool calon = false;
        private static bool initialcalibrate = false; // flag to perform auto-calibrate once gyro calibrate is complete
        public static bool m_doCalibrate = false;
        public static bool m_doOrientation = false;
        private static bool m_usercalquat = false;

        public QuaternionProcessor(HeadtrackingUpdateHandler headsetDataHandler,
            bool doCalibrate = false, bool doOrientation = false)
        {
            // flags to control how much processing to do on inbound packets
            m_doCalibrate = doCalibrate;
            m_doOrientation = doOrientation;

            calon = false;
            calquat = new double[4];
            for (int i = 0; i < 4; i++)
            {
                calquat[i] = 0;
            }

            m_headsetDataHandler = headsetDataHandler;
            m_worker = new Thread(ProcessorMainFunction);
            m_worker.Start();
        }
        private static void ProcessorMainFunction()
        {
            try
            {
                while (true)
                {
                    lock (_locker)
                        while (!_go)
                            Monitor.Wait(_locker);

                    string odppayload = "";

                    lock (_locker)
                    {
                        int count = m_odppayloads.Count();
                        if (count > 0)
                        {
                            // Dequeue the "freshest" odp report! (the one at the end/bottom
                            // of the queue)
                            odppayload = m_odppayloads.ElementAt(m_odppayloads.Count() - 1);
                            m_odppayloads.Clear(); //kill all the older ones
                        }

                        _go = false;
                    }

                    HeadsetTrackingData headsetdata = ExtractHeadsetData(odppayload);

                    if (!headsetdata.badpacket)
                        m_headsetDataHandler.HeadsetTrackingUpdate(headsetdata);                    
                }
            }
            catch (Exception)
            {
                // thread exit
            }
        }

        private static HeadsetTrackingData ExtractHeadsetData(string odpreport)
        {
            HeadsetTrackingData retval = new HeadsetTrackingData();

            // extract the headtracking payload:
            int lastcomma = odpreport.LastIndexOf(",");
            string odppayload = odpreport.Substring(lastcomma + 1, odpreport.Length - lastcomma - 2);

            // convert the headtracking payload into values:
            long[] quatn;
            double[] quat;
            quatn = new long[16];
            quat = new double[4];
            int gyrocalib = 0;
            //int temperature = 0;
            int freefall = 0;
            int tapdir = 0;
            int tapcount = 0;
            int magcalib = 0;
            int vermaj = 0;
            int vermin = 0;
            int pedometersteps = 0;

            bool badpacket = false;

            try
            {
                quatn[0] = ExtractQuatFromHex(odppayload.Substring(6, 4), 0); //, Quat0_hex_label);  // quat 0 is 4 hex chars from char 6 (0-based index)
                quatn[1] = ExtractQuatFromHex(odppayload.Substring(14, 4), 1); //, Quat1_hex_label);  // quat 1 is 4 hex chars from char 14 (0-based index)
                quatn[2] = ExtractQuatFromHex(odppayload.Substring(22, 4), 2); //, Quat2_hex_label);  // quat 2 is 4 hex chars from char 22 (0-based index)
                quatn[3] = ExtractQuatFromHex(odppayload.Substring(30, 4), 3); //, Quat3_hex_label);  // quat 3 is 4 hex chars from char 30 (0-based index)
                gyrocalib = ExtractIntFromHex(odppayload.Substring(36, 2));  // gyrocalibration info is 2 hex chars from char 36 (0-based index)

                // extract other sensor info...
                //temperature = ExtractIntFromHex(odppayload.Substring(4, 2));
                freefall = ExtractIntFromHex(odppayload.Substring(12, 2));
                tapdir = ExtractIntFromHex(odppayload.Substring(26, 2));
                tapcount = ExtractIntFromHex(odppayload.Substring(28, 2));
                magcalib = ExtractIntFromHex(odppayload.Substring(34, 2));
                vermaj = ExtractIntFromHex(odppayload.Substring(38, 2));
                vermin = ExtractIntFromHex(odppayload.Substring(40, 2));
                pedometersteps = ExtractIntFromHex(odppayload.Substring(18, 4));
            }
            catch (Exception)
            {
                badpacket = true;
                retval.badpacket = true;
            }

            if (!badpacket)
            {
                //process for use
                for (int i = 0; i < 4; i++)
                {
                    if (quatn[i] > 32767)
                    {
                        quatn[i] -= 65536;
                    }
                    quat[i] = ((double)quatn[i]) / 16384.0f;

                }

                retval.gyrocalib = gyrocalib;

                // other data
                //retval.temperature = temperature;
                retval.freefall = freefall == 1 ? true : false;
                retval.tapdir = (TapDirection)tapdir;
                retval.taps = tapcount;
                retval.gyrocalib = gyrocalib;
                retval.magnetometercalib = magcalib;
                retval.vermaj = vermaj;
                retval.vermin = vermin;
                retval.pedometersteps = pedometersteps;

                // auto calibrate by headset:
                if (!initialcalibrate && gyrocalib == 3)
                {
                    calon = true;
                    initialcalibrate = true;
                }

                // handle calibrate request (auto or manual):
                if (calon)
                {
                    if (!m_usercalquat) calquat = quat;
                    calon = false;
                }

                double[] newquat;
                if (m_doCalibrate)
                {
                    //correct for calibration
                    newquat = new double[4];

                    //create inverse of cal vector
                    newquat = quatinv(calquat);

                    ////reapply current state to cal (old version, params in wrong order)
                    //newquat = quatmult(newquat, quat);

                    //reapply current state to cal (fixed reverse parameters, thanks Doug)
                    //newquat = quatmult(quat, newquat);                
                    newquat = quatmult(newquat, quat); // Douglas Wong proposed fix
                }
                else
                {
                    // no calibration
                    newquat = quat;
                }

                if (m_doOrientation)
                {
                    // Old C# version, problem with roll:
                    ////bank-roll
                    //retval.phi_roll = -180.0 / 3.14159 * Math.Asin(-2.0 * newquat[1] * newquat[3] + 2.0 * newquat[0] * newquat[2]);
                    ////heading
                    //retval.psi_heading = -180.0 / 3.14159 * Math.Atan2((newquat[2] * newquat[1] + newquat[0] * newquat[3]), (newquat[0] * newquat[0] + newquat[1] * newquat[1] - (double)0.5));
                    ////elevation-pitch
                    //retval.theta_pitch = -180.0 / 3.14159 * Math.Atan2((newquat[2] * newquat[3] + newquat[0] * newquat[1]), (newquat[0] * newquat[0] + newquat[3] * newquat[3] - (double)0.5));

                    // C# version, new and improved, thanks Doug:

                    //heading
                    retval.psi_heading = -180.0 / 3.14159 * Math.Atan2((newquat[2] * newquat[1] - newquat[0] * newquat[3]), (newquat[0] * newquat[0] + newquat[2] * newquat[2] - (double)0.5));

                    // elevation-pitch
                    retval.theta_pitch = 180.0 / 3.14159 * Math.Asin(2.0 * newquat[2] * newquat[3] + 2.0 * newquat[0] * newquat[1]);
                    //retval.theta_pitch = -180.0 / 3.14159 * Math.Atan2((newquat[1] * newquat[3] - newquat[0] * newquat[2]), (newquat[0] * newquat[0] + newquat[3] * newquat[3] - (double)0.5));

                    // bank-roll 
                    retval.phi_roll = -180.0 / 3.14159 * Math.Atan2((newquat[1] * newquat[3] - newquat[0] * newquat[2]), (newquat[0] * newquat[0] + newquat[3] * newquat[3] - (double)0.5));
                    //retval.phi_roll = 180.0 / 3.14159 * Math.Asin(2.0 * newquat[2] * newquat[3] + 2.0 * newquat[0] * newquat[1]);
                }

                //debug
                retval.rawreport = odppayload;
                retval.quatcalib_q0 = newquat[0];
                retval.quatcalib_q1 = newquat[1];
                retval.quatcalib_q2 = newquat[2];
                retval.quatcalib_q3 = newquat[3];

                retval.quatraw_q0 = quat[0];
                retval.quatraw_q1 = quat[1];
                retval.quatraw_q2 = quat[2];
                retval.quatraw_q3 = quat[3];
            }

            return retval;
        }

        private static int ExtractIntFromHex(string hexchrs)
        {
            return Convert.ToByte(hexchrs, 16);
        }

        private static long ExtractQuatFromHex(string hexchrs, int labelnum)
        {
            string digit1hexchrs = hexchrs.Substring(0, 2);
            string digit2hexchrs = hexchrs.Substring(2, 2);
            byte digit1 = Convert.ToByte(digit1hexchrs, 16);
            byte digit2 = Convert.ToByte(digit2hexchrs, 16);

            ulong temp;
            temp = (((ulong)digit1) << 8) + ((ulong)digit2);
            return checked((long)temp);
        }

        public static double[] quatmult(double[] p, double[] q)
        {
            //quaternion multiplication
            double[] newquat = new double[4];

            double[,] quatmat = new double[,] { {p[0], -p[1], -p[2],-p[3]}, 
                                                {p[1], p[0], -p[3], p[2]  }, 
                                                {p[2], p[3], p[0], -p[1]  }, 
                                                {p[3], -p[2], p[1], p[0]  }, 
                                                };
            for (int i = 0; i < 4; i++)
                for (int j = 0; j < 4; j++)
                    newquat[i] += quatmat[i, j] * q[j];

            return newquat;
        }

        public static double[] quatinv(double[] quat)
        {
            double[] newquat = new double[4];
            newquat[0] = quat[0];
            newquat[1] = -quat[1];
            newquat[2] = -quat[2];
            newquat[3] = -quat[3];
            return newquat;
        }


        internal void Stop()
        {
            m_worker.Abort();
        }

        internal void ProcessODPReport(string odpreport)
        {
            lock (_locker)
            {
                m_odppayloads.Enqueue(odpreport);
                _go = true;
                Monitor.Pulse(_locker);
            }
        }

        internal void Calibrate(bool doinitialcalibrate = false, object usercalquat = null)
        {
            calon = true; // lets calibrate now!
            if (doinitialcalibrate) initialcalibrate = true; // handle case where user manually calibrates before auto-calibrate is complete
            // allow user to pass in usercalquat (their own calibration quaternion)
            if (usercalquat != null)
            {
                // user sent their own calquat:
                try
                {
                    double[] userquat = (double[])usercalquat;
                    m_usercalquat = true;
                    calquat = userquat;
                }
                catch (Exception e)
                {
                    throw new Exception("QuaternionProcessor: Sorry, problem casting user calibration quaternion", e);
                }
            }
            else
            {
                m_usercalquat = false;
            }
        }

        internal void ProcessByteArray(List<byte> list)
        {
            lock (_locker)
            {
                try
                {
                    StringBuilder sb = new StringBuilder();
                    sb.Append(",000000");
                    sb.Append(list[0].ToString("X2"));
                    sb.Append(list[1].ToString("X2"));
                    sb.Append("0000");
                    sb.Append(list[2].ToString("X2"));
                    sb.Append(list[3].ToString("X2"));
                    sb.Append("0000");
                    sb.Append(list[4].ToString("X2"));
                    sb.Append(list[5].ToString("X2"));
                    sb.Append("0000");
                    sb.Append(list[6].ToString("X2"));
                    sb.Append(list[7].ToString("X2"));
                    sb.Append("000000000");

                    m_odppayloads.Enqueue(sb.ToString());
                    _go = true;
                    //Monitor.Pulse(_locker);
                }
                catch(Exception)
                {
                    // oh dear...
                }
            }
        }
    }

    public enum TapDirection
    {
        None,
        XUp,
        XDown,
        YUp,
        YDown,
        ZUp,
        ZDown
    }

    // struct to pass values back to app of processed headset tracking packet...
    public class HeadsetTrackingData
    {
        public double theta_pitch;
        public double psi_heading;
        public double phi_roll;
        public double quatcalib_q0;
        public double quatcalib_q1;
        public double quatcalib_q2;
        public double quatcalib_q3;
        public int gyrocalib;
        public int magnetometercalib;
        public bool badpacket;
        public string rawreport;
        public double quatraw_q0;
        public double quatraw_q1;
        public double quatraw_q2;
        public double quatraw_q3;

        //public int temperature;
        public bool freefall;
        public int pedometersteps;
        public int taps;
        public TapDirection tapdir;
        public int vermaj;
        public int vermin;
    }

    // interface to allow main app to receive head tracking data...
    public interface HeadtrackingUpdateHandler
    {
        void HeadsetTrackingUpdate(HeadsetTrackingData headsetData);
    }
}
