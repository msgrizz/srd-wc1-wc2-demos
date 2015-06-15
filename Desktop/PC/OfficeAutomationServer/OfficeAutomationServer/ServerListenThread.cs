using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading;

namespace OfficeAutomationServer
{
    public class ServerListenThread
    {
        public ServerListenThread()
        {
        }

        // This method will be called when the thread is started. 
        public void DoWork()
        {
            try
            {
                TcpListener client = new TcpListener(IPAddress.Parse("127.0.0.1"), 9050);
                client.Start();

                Console.WriteLine("server thread: working...");
                bool preventMultiple = false;
                while (!_shouldStop)
                {
                    if (!client.Pending())
                    {
                        preventMultiple = false;
                        Console.WriteLine("server thread: Waiting for clients...");
                    }
                    while (!client.Pending() && !_shouldStop)
                    {
                        Thread.Sleep(1000);
                        preventMultiple = false;
                    }
                    if (client.Pending() && !preventMultiple)
                    {
                        Console.WriteLine("server thread: new client connection...");
                        ConnectionThread newconnection = new ConnectionThread(client);
                        Program.AddConnection(newconnection);
                        preventMultiple = true;
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("info server thread: caught exception: " + e.ToString());
                //m_myWindow.NotifyExceptionOnStartup(e); // todo?
                Program.DebugPrint(MethodInfo.GetCurrentMethod().Name, "info server thread: caught exception: " + e.ToString());
            }
            Console.WriteLine("server thread: terminating gracefully.");
        }
        public void RequestStop()
        {
            _shouldStop = true;
        }
        // Volatile is used as hint to the compiler that this data 
        // member will be accessed by multiple threads. 
        private volatile bool _shouldStop;
    }

    class ConnectionThread
    {
        public TcpListener threadListener;
        private bool m_quit = false;

        // A list of messages to send out to client
        List<string> m_messagesToSend = new List<string>();
        private static volatile object m_listlocker = new Object();

        public volatile bool SubscribedToTagUpdates = false;

        // lock and short interuptable timeout to wait for incoming message
        object m_checkIOlock = new object();
        int m_checkIOtimeout = 100;

        public ConnectionThread(TcpListener lis)
        {
            threadListener = lis;
            ThreadPool.QueueUserWorkItem(new WaitCallback(HandleConnection));
        }

        public void QueueMessageToSend(string msg)
        {
            lock (m_listlocker)
            {
                m_messagesToSend.Add(msg);
                lock (m_checkIOlock)
                {
                    Monitor.PulseAll(m_checkIOlock);
                }
            }
        }

        public void HandleConnection(object state)
        {
            m_quit = false;
            int recv;
            byte[] buffer = new byte[1024];
            byte[] outbuffer;

            TcpClient client = threadListener.AcceptTcpClient();
            NetworkStream ns = client.GetStream();

            string welcome = "Welcome to OAS, Plantronics Innovations 2015\r\n";
            outbuffer = Encoding.ASCII.GetBytes(welcome);
            ns.Write(outbuffer, 0, outbuffer.Length);

            while (!m_quit && client.Connected)
            {
                StringBuilder sb = new StringBuilder();
                try
                {
                    string bit = "";
                    while (bit != null && !bit.EndsWith("\r") && !bit.EndsWith("\n"))
                    {
                        Array.Clear(buffer, 0, buffer.Length);
                        // wait until some data is available, otherwise service
                        // outbound messages to send
                        while (!ns.DataAvailable && !m_quit && client.Connected)
                        {
                            if (GetMessagesToSendCount() > 0)
                            {
                                DispatchMessages(ns);
                            }
                            else
                            {
                                //Thread.Sleep(100);
                                lock (m_checkIOlock)
                                {
                                    bool ret = Monitor.Wait(m_checkIOlock, m_checkIOtimeout);
                                }
                            }
                        }
                        recv = ns.Read(buffer, 0, buffer.Length);
                        if (recv > 0)
                        {
                            bit = Encoding.ASCII.GetString(buffer);
                            bit = bit.Replace("\0", string.Empty);
                            if (bit != null)
                            {
                                string tmp = bit.Replace("\r", string.Empty);
                                tmp = tmp.Replace("\n", string.Empty);
                                sb.Append(tmp);
                            }
                        }
                        else
                        {
                            bit = null;
                        }
                    }
                }
                catch (Exception)
                {
                    Console.WriteLine("info: error reading from client");
                    m_quit = true;
                }
                string strin = sb.ToString();
                if (!Program.HandleInputCommand(strin, this)) // this handles server-level commands from client
                {
                    // The following handles client-level commands from client:
                    switch (strin.ToUpper())
                    {
                        case "QUIT":
                        case "EXIT":
                        case "BYE":
                        case "GOODBYE":
                            m_quit = true;
                            break;
                        case "SUBSCRIBEALL":
                            SubscribedToTagUpdates = true;
                            break;
                        case "SUBSCRIBEOFF":
                            SubscribedToTagUpdates = false;
                            break;
                        case "HELLO":
                        case "HI":
                        case "HEY":
                            SendToClient(ns, "Hey there, how are you?");
                            break;
                        case "HELP":
                            SendToClient(ns, GetHelpText());
                            break;
                        default:
                            if (strin.Length > 0)
                            {
                                SendToClient(ns, "Sorry, unrecognised command: \"" + strin + "\"");
                            }
                            break;
                    }
                }
            }
            SendToClient(ns, "Bye!");
            Console.WriteLine("server thread: closing client connection...");
            ns.Close();
            client.Close();
        }

        /// <summary>
        /// Generate a text list of all available commands
        /// </summary>
        /// <returns></returns>
        private string GetHelpText()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(Environment.NewLine);
            sb.Append("AVAILABLE COMMANDS:" + Environment.NewLine);
            sb.Append("-------------------" + Environment.NewLine);
            sb.Append("QUIT - closes your client connection" + Environment.NewLine);
            sb.Append("SUBSCRIBEALL - subscribe to tag updates for all tags in system" + Environment.NewLine);
            sb.Append("SUBSCRIBEOFF - unsubscribe to tag updates for all tags in system" + Environment.NewLine);
            sb.Append("HELP - display this list of available commands" + Environment.NewLine);
            sb.Append("VERSION - displays server version information" + Environment.NewLine);
            sb.Append("SHUTDOWN - shut down the server" + Environment.NewLine);
            return sb.ToString();
        }

        private void SendToClient(NetworkStream ns, string msg)
        {
            byte[] outbuffer;
            outbuffer = Encoding.ASCII.GetBytes(msg + Environment.NewLine);
            try
            {
                ns.Write(outbuffer, 0, outbuffer.Length);
            }
            catch (Exception)
            {
                Console.WriteLine("info: error writing to client");
                m_quit = true;
            }
        }

        private void DispatchMessages(NetworkStream ns)
        {
            lock (m_listlocker)
            {
                foreach (string msg in m_messagesToSend)
                {
                    SendToClient(ns, msg);
                }
                m_messagesToSend.Clear();
            }
        }

        private int GetMessagesToSendCount()
        {
            lock (m_listlocker)
            {
                return m_messagesToSend.Count();
            }
        }
    }
}
