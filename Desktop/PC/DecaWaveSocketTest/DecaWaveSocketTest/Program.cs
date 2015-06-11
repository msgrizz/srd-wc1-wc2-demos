using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net; 
using System.Net.Sockets;
using System.Threading; 

namespace DecaWaveSocketTest
{
    class Program
    {
        private static volatile bool _shouldStop;
        static Thread decaWaveThread;
        private static SvcClient svcClient;
        private static string m_ip;
        private static int m_port = 8784;
        private static bool m_debug = false;

        static void Main(string[] args)
        {
            System.Console.WriteLine("RTLS example start.\n");

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
                    try {
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

                System.Console.WriteLine("press enter to quit");

                System.Console.ReadLine();

                RequestStop();
            }
        }

        public static void DoDecaWaveWork()
        {
            bool connected = false;

            while (!_shouldStop)
            {
                Console.WriteLine("worker thread: working...");

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
                                System.Console.WriteLine(string.Format("Received LS listener: {0}\n", lsAddress.mode));

                                UdpClient socket = new UdpClient();
                                IPEndPoint localEp = new IPEndPoint(IPAddress.Parse(lsAddress.ip), 8787);
                                socket.Client.Bind(localEp);
                                socket.Client.ReceiveTimeout = 10000;
                                bool isTimeExpired = false;
                                // Data buffer for incoming data.
                                byte[] recvData;

                                while (!_shouldStop && !isTimeExpired)
                                {
                                    try
                                    {
                                        recvData = socket.Receive(ref localEp);
                                        if (recvData.Length>0)
                                        {
                                            string recv = 
                                                Encoding.ASCII.GetString(recvData, 0, recvData.Length);
                                            if (m_debug)
                                            {
                                                System.Console.Write("LS: Received: ");
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
                                                    System.Console.WriteLine(
                                                        string.Format("ID: {0}, x: {1}, y: {2}",
                                                        tagMsg.id,
                                                        tagMsg.coordinates.x,
                                                        tagMsg.coordinates.y
                                                        )
                                                    );
                                                }
                                                else
                                                {
                                                    if (m_debug)
                                                    {
                                                        System.Console.Write("LS: Recv'd tag msg with NO coords ");
                                                        if (tagMsg != null &&
                                                            tagMsg.id != null)
                                                        {
                                                            System.Console.Write("from tag ID: " + tagMsg.id);
                                                        }
                                                        System.Console.WriteLine();
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            if (m_debug)
                                            {
                                                System.Console.WriteLine("LS: Received empty");
                                            }
                                        }
                                    }
                                    catch(Exception e)
                                    {
                                        System.Console.WriteLine(e);
                                        isTimeExpired = true;
                                        _shouldStop = true;
                                    }
                                }
                        }

                    }
                    catch (Exception e)
                    {
                        System.Console.WriteLine(e);
                    }
                }

                Thread.Sleep(1000);
                Console.Write(".");
            }
            svcClient.close();
            Console.WriteLine("worker thread: terminating gracefully.");
        }

        public static void RequestStop()
        {
            _shouldStop = true;
        }
    }

    class SvcClient
    {
        Socket svcSocket;

        public SvcClient(string ip, int port)
        {
            try 
            {
                IPAddress ipAddress = IPAddress.Parse(ip);
                IPEndPoint remoteEP = new IPEndPoint(ipAddress, port);

                // Create a TCP/IP socket.
                svcSocket = new Socket(AddressFamily.InterNetwork,
                    SocketType.Stream, ProtocolType.Tcp);

                svcSocket.Connect(remoteEP);
            }
            catch (Exception e) 
            {
                Console.WriteLine( e.ToString());
            }
        }
    
        internal string request(string jsonStr, int timeout = 20)
        {
            // Data buffer for incoming data.
            byte[] bytes = new byte[1024];

            string recvMessage = "";
            try
            {
                // Send the data through the socket.
                int bytesSent = svcSocket.Send(Encoding.ASCII.GetBytes(jsonStr));

                // Receive the response from the remote device.
                int bytesRec = svcSocket.Receive(bytes);
                Console.WriteLine("Echoed test = {0}",
                    Encoding.ASCII.GetString(bytes, 0, bytesRec));

                recvMessage = Encoding.ASCII.GetString(bytes, 0, bytesRec);
                return recvMessage;
            }
            catch (Exception e)
            {
                System.Console.WriteLine(e.ToString());
                return null;
            }
        }

        internal void close()
        {
            // Release the socket.
            svcSocket.Shutdown(SocketShutdown.Both);
            svcSocket.Close();
        }
    }
}
