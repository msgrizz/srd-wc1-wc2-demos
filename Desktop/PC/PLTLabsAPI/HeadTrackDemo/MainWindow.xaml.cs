using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Plantronics.Innovation.PLTLabsAPI;
using System.Reflection;

namespace HeadTrackDemo
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window, PLTLabsCallbackHandler
    {
        PLTLabsAPI m_pltlabsapi;
        private PLTConnection m_pltConnection;

        public MainWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "Head Track Demo - window loaded");
            try
            {
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to instantiate PLTLabsAPI object");

                m_pltlabsapi = new PLTLabsAPI(this);

                ConnectToPlantronicsDevice();
            }
            catch (Exception exc)
            {
                ConnStatusLbl.Dispatcher.Invoke(new Action(delegate()
                {
                    ConnStatusLbl.Content = "Exception on connect! "+exc.ToString();
                    DeviceLbl.Content = "-";

                    MessageBox.Show("Exception on connect! " + exc.ToString(), "HeadTrackDemo Error");
                }));
            }
        }

        private void DebugListAvailableDevices(PLTDevice[] availableDevices)
        {
            StringBuilder sb = new StringBuilder();
            bool first = true;
            foreach (PLTDevice dev in availableDevices)
            {
                if (!first) sb.Append("\r\n");
                first = false;
                sb.Append("> ");
                sb.Append(dev.m_ProductName);
            }
            DebugPrint(MethodInfo.GetCurrentMethod().Name, "List of available devices: \r\n" + sb.ToString());
        }

        public void ConnectionClosed(PLTDevice pltDevice)
        {
            // todo
        }

        public void ConnectionFailed(PLTDevice pltDevice)
        {
            // todo
        }

        public void ConnectionOpen(PLTConnection pltConnection)
        {
            m_pltConnection = pltConnection;

            if (pltConnection != null)
            {
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "Success! Connection was opened!: " + pltConnection.m_device.m_ProductName);

                // lets register for headtracking service
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to register for head tracking data.");
                m_pltlabsapi.subscribe(PLTService.MOTION_TRACKING_SVC, PLTMode.On_Change);

                //m_pltlabsapi.configureService(PLTService.MOTION_TRACKING_SVC, PLTConfiguration.MotionSvc_Offset_Raw);
                m_pltlabsapi.configureService(PLTService.MOTION_TRACKING_SVC, PLTConfiguration.MotionSvc_Offset_Calibrated);
                //m_pltlabsapi.configureService(PLTService.MOTION_TRACKING_SVC, PLTConfiguration.MotionSvc_Offset_Calibrated,
                //    new PLTQuaternion
                //    {
                //        m_quaternion = new double[4] { 1.0d, 0.0d, 0.0d, 0.0d }
                //    });
                //m_pltlabsapi.configureService(PLTService.MOTION_TRACKING_SVC, PLTConfiguration.MotionSvc_Format_Quaternion);
                m_pltlabsapi.configureService(PLTService.MOTION_TRACKING_SVC, PLTConfiguration.MotionSvc_Format_Orientation);

                m_pltlabsapi.subscribe(PLTService.SENSOR_CAL_STATE_SVC, PLTMode.On_Change);

                // check we subcribed ok...
                DebugPrintSubscribedServices();

                ConnStatusLbl.Dispatcher.Invoke(new Action(delegate()
                {
                    if (pltConnection != null)
                    {
                        ConnStatusLbl.Content = "Yes";
                        DeviceLbl.Content = m_pltConnection.DeviceName;
                    }
                    else
                    {
                        ConnStatusLbl.Content = "No";
                        DeviceLbl.Content = "-";
                    }
                }));
            }
        }

        private void DebugPrintSubscribedServices()
        {
            if (m_pltConnection != null)
            {
                PLTService[] services = m_pltlabsapi.getSubscribed();

                StringBuilder sb = new StringBuilder();
                bool first = true;
                foreach (PLTService service in services)
                {
                    if (!first) sb.Append("\r\n");
                    first = false;
                    sb.Append("> ");
                    sb.Append(service.ToString());
                }
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "List of subscribed services: \r\n" + sb.ToString());
            }
        }

        public void ConnectToPlantronicsDevice()
        {
            if (m_pltlabsapi == null) return;

            PLTDevice[] availableDevices = m_pltlabsapi.availableDevices();

            DebugListAvailableDevices(availableDevices);

            if (availableDevices.Count()<1) return;

            if (!m_pltlabsapi.getIsConnected(availableDevices[0]))
            {
                DebugPrint(MethodInfo.GetCurrentMethod().Name, "About to open connection to device: " + availableDevices[0].m_ProductName);
                m_pltlabsapi.openConnection(availableDevices[0]);  // PC will only ever show 1 call control device
                // even if you have multiple Plantronics devices attached to PC. Change call control device
                // in Spokes 3.0 settings (system tray)
            }
        }

        // Plantronics device was added to system
        public void DeviceAdded(PLTDevice pltDevice)
        {
            ConnectToPlantronicsDevice();
        }

        public void infoUpdated(PLTConnection pltConnection, PLTInfo pltInfo)
        {
            // TODO work in progress

            switch (pltInfo.m_serviceType)
            {
                case PLTService.MOTION_TRACKING_SVC:
                    PLTMotionTrackingData trackingdata = (PLTMotionTrackingData)pltInfo.m_data;
                    //DebugPrint(MethodInfo.GetCurrentMethod().Name, "Motion Tracking Update received:\r\n" +
                    //    "raw q0: " + trackingdata.m_rawquaternion[0] + "\r\n" +
                    //    "raw q1: " + trackingdata.m_rawquaternion[1] + "\r\n" +
                    //    "raw q2: " + trackingdata.m_rawquaternion[2] + "\r\n" +
                    //    "raw q3: " + trackingdata.m_rawquaternion[3]);
                    DebugPrint(MethodInfo.GetCurrentMethod().Name, "Motion Tracking Update received:\r\n" +
                        "heading: " + trackingdata.m_orientation[0] + "\r\n" +
                        "pitch: " + trackingdata.m_orientation[1] + "\r\n" +
                        "roll: " + trackingdata.m_orientation[2]);
                    break;
                case PLTService.SENSOR_CAL_STATE_SVC:
                    PLTSensorCal sensorcaldata = (PLTSensorCal)pltInfo.m_data;
                    DebugPrint(MethodInfo.GetCurrentMethod().Name, "Sensor calibration update received:\r\n" +
                        "Gyros calibrated?: " + sensorcaldata.m_isgyrocal + "\r\n" +
                        "Magnetometer calibrated?: " + sensorcaldata.m_ismagnetometercal);
                    break;
            }
        }        
            
        /// <summary>
        /// Debugs the print.
        /// </summary>
        /// <param name="methodname">The methodname.</param>
        /// <param name="str">The STR.</param>
        public void DebugPrint(string methodname, string str)
        {
            applogtextbox.Dispatcher.Invoke(new Action(delegate()
            {
                string datetime = DateTime.Now.ToString("HH:mm:ss.fff");
                applogtextbox.AppendText((String.Format("{0}: {1}(): {2}\r\n", datetime, methodname, str)));
                applogtextbox.ScrollToEnd();
            }));
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            m_pltlabsapi.Shutdown();
        }
    }
}
