using Fleck;
using Plantronics.Innovation.PLTLabsAPI;
using Plantronics.UC.SpokesWrapper;
using Plantronics.UC.WebRTCDemo;
using Procurios.Public;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HeadTrackingWebSocketMiddleware
{
    public class SpokesIntegration : PLTLabsCallbackHandler
    {
        private static PLTLabsAPI pltlabsapi;
        private Spokes spokes;
        private PLTConnection m_pltConnection;

        static IWebSocketServer server = null;
        static List<IWebSocketConnection> allSockets = null;
        static Hashtable offer = null;
        const String WEB_SOCKET_SERVICE_URL = "ws://localhost:8888/plantronics";
        private static PLTDevice m_activeDevice;
        private bool m_gyrocal = false;

        public SpokesIntegration()
        {
            
            pltlabsapi = new PLTLabsAPI(this);

            spokes = Spokes.Instance;

            InitializeWebSockets();
        }

        public void ConnectionClosed(PLTDevice pltDevice)
        {
            m_pltConnection = null;
            m_activeDevice = null;
        }

        public void ConnectionFailed(PLTDevice pltDevice)
        {
            m_pltConnection = null;
            m_activeDevice = null;
        }

        public void ConnectionOpen(PLTConnection pltConnection)
        {
            m_pltConnection = pltConnection;

            if (m_pltConnection != null)
            {
                pltlabsapi.subscribe(PLTService.MOTION_TRACKING_SVC, PLTMode.On_Change);
                pltlabsapi.configureService(PLTService.MOTION_TRACKING_SVC, PLTConfiguration.MotionSvc_Offset_Calibrated);
                pltlabsapi.configureService(PLTService.MOTION_TRACKING_SVC, PLTConfiguration.MotionSvc_Format_Orientation);
                pltlabsapi.subscribe(PLTService.SENSOR_CAL_STATE_SVC, PLTMode.On_Change);
            }
        }

        public void DeviceAdded(PLTDevice pltDevice)
        {
            m_activeDevice = pltDevice;
            pltlabsapi.openConnection(pltDevice);
        }

        public void infoUpdated(PLTConnection pltConnection, PLTInfo pltInfo)
        {
            switch (pltInfo.m_serviceType)
            {
                case PLTService.MOTION_TRACKING_SVC:
                    PLTMotionTrackingData tracking = (PLTMotionTrackingData)pltInfo.m_data;
                    PlantronicsMessage msg = new PlantronicsMessage(
                            pltInfo.m_serviceType.ToString(),
                            "heading"                           
                            );
                    msg.Payload.Add("orientation", 
                        (int)tracking.m_orientation[0] + "," +
                            (int)tracking.m_orientation[1] + "," +
                            (int)tracking.m_orientation[2]);
                    BroadcastMessage(msg
                        );
                    break;
                case PLTService.SENSOR_CAL_STATE_SVC:
                    PLTSensorCal calinfo = (PLTSensorCal)pltInfo.m_data;
                    if (calinfo.m_isgyrocal != m_gyrocal)
                    {
                        PlantronicsMessage msg2 = new PlantronicsMessage(pltInfo.m_serviceType.ToString(),
                            "gyrocalibinfo"
                            );
                        msg2.Payload.Add("gyrocalibrated",
                            calinfo.m_isgyrocal.ToString());
                        BroadcastMessage(
                        msg2
                            );
                    }
                    m_gyrocal = calinfo.m_isgyrocal;                 
                    break;
            }
        }

        #region WebSockets Methods
        //Initializes the web socket server that listens for incoming requests
        private static void InitializeWebSockets()
        {
            allSockets = new List<IWebSocketConnection>();
            server = new WebSocketServer(WEB_SOCKET_SERVICE_URL);

            server.Start(socket =>
            {
                socket.OnOpen = () =>
                {
                    Console.WriteLine("Connection Opened");
                    offer = null;
                    allSockets.Add(socket);
                };

                socket.OnClose = () =>
                {
                    Console.WriteLine("Connection Closed!");
                    offer = null;
                    allSockets.Remove(socket);
                };
                socket.OnMessage = message =>
                {
                    Console.WriteLine(message);
                    HandleMessage(message);
                };
            });
        }

        //Sends a message out to all websocket connections
        private static void BroadcastMessage(PlantronicsMessage message)
        {
            String json = JSON.JsonEncode(message.GetObjectAsHashtable());

            if (allSockets.Count()>0)
                Console.WriteLine("Sending Message: " + json);
            foreach (var socket in allSockets.ToList())
            {
                socket.Send(json);
            }
        }

        //Responsible for processing messages that have arrived via a websocket connection
        private static void HandleMessage(String message)
        {
            if (m_activeDevice == null)
            {
                Console.WriteLine("no active device, ignoring message");
                return;
            }

            PlantronicsMessage m = PlantronicsMessage.ParseMessageFromJSON(message);
            if (m.Type == PlantronicsMessage.MESSAGE_TYPE_SETTING)
            {
                if (m.Id == PlantronicsMessage.SETTING_HEADSET_INFO)
                {
                    PlantronicsMessage response = new PlantronicsMessage(PlantronicsMessage.MESSAGE_TYPE_SETTING, PlantronicsMessage.SETTING_HEADSET_INFO);
                    Device device = new Device();
                    //device.InternalName = m_activeDevice.InternalName;
                    //device.ManufacturerName = m_activeDevice.ManufacturerName;
                    //device.ProductName = m_activeDevice.ProductName;
                    //device.VendorId = String.Format("0x{0:X}", m_activeDevice.VendorID);
                    //device.ProductId = String.Format("0x{0:X}", m_activeDevice.ProductID);
                    //device.VersionNumber = m_activeDevice.VersionNumber;

                    //TODO fixup CAB - make this eventually come from Spokes or a dictionary lookup
                    device.NumberOfChannels = 1;
                    device.SampleRate = 16000;

                    response.AddToPayload("device", device);
                    BroadcastMessage(response);
                }

            }
            else if (m.Type == PlantronicsMessage.MESSAGE_TYPE_COMMAND)
            {
                if (m.Id == PlantronicsMessage.COMMAND_RING_ON)
                {
                    Console.WriteLine("Ringing headset");
                    Object o = null;
                    if (!m.Payload.TryGetValue("offer", out o))
                    {
                        Console.WriteLine("Unable to get caller id from the message skipping headset ring operation");
                        return;
                    }
                    offer = o as Hashtable;
                    //ContactCOM contact = new ContactCOM() { Name = offer["from"] as String };
                    //callId = (int)(double)m.Payload["callId"];
                    //CallCOM call = new CallCOM() { Id = callId };
                    //m_comSession.CallCommand.IncomingCall(call, contact, RingTone.RingTone_Unknown, AudioRoute.AudioRoute_ToHeadset);

                }
                else if (m.Id == PlantronicsMessage.COMMAND_CALIBRATE)
                {
                    pltlabsapi.calibrateService(PLTService.MOTION_TRACKING_SVC);
                }
                //else if (m.Id == PlantronicsMessage.COMMAND_HANG_UP)
                //{
                //    CallCOM call = new CallCOM() { Id = callId };
                //    m_comSession.CallCommand.TerminateCall(call);

                //}
                //else if (m.Id == PlantronicsMessage.COMMAND_RING_OFF)
                //{
                //    Console.WriteLine("Turning ring off headset");
                //    m_activeDevice.HostCommand.Ring(false);

                //}
                //else if (m.Id == PlantronicsMessage.COMMAND_MUTE_ON)
                //{
                //    Console.WriteLine("Muting headset");
                //    m_activeDevice.DeviceListener.Mute = true;

                //}
                //else if (m.Id == PlantronicsMessage.COMMAND_MUTE_OFF)
                //{
                //    Console.WriteLine("Unmuting headset");
                //    m_activeDevice.DeviceListener.Mute = false;

                //}
            }
            else if (m.Type == PlantronicsMessage.MESSAGE_TYPE_EVENT)
            {
                Console.WriteLine("Event message received");
            }

        }
        #endregion

        internal void ShutDown()
        {
            pltlabsapi.Shutdown();
        }
    }
}
