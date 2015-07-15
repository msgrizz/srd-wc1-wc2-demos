using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace DecaWaveClientSocketScratchPad
{
    class SocketConnector
    {
        string m_host;
        int m_port;

        /// <summary>
        /// Event args for OnCall event handler
        /// </summary>
        public class MessageReceivedArgs : EventArgs
        {
            public string Message;

            public MessageReceivedArgs(string message)
            {
                Message = message;
            }
        }

        public delegate void ConnectedEventHandler(object sender, EventArgs e);
        public delegate void MessageReceivedEventHandler(object sender, MessageReceivedArgs e);
        public event ConnectedEventHandler Connected;
        public event MessageReceivedEventHandler MessageReceived;

        private Thread socketThread;
        private static bool _shouldStop = false;
        private bool m_quit;

        // A list of messages to send out to client
        List<string> m_messagesToSend = new List<string>();
        private static volatile object m_listlocker = new Object();

        // lock and short interuptable timeout to wait for incoming message
        object m_checkIOlock = new object();
        int m_checkIOtimeout = 100;

        public SocketConnector(string host, int port)
        {
            m_host = host;
            m_port = port;

            socketThread = new Thread(this.DoSocketWork);
            socketThread.Start();
        }

        public void DoSocketWork()
        {
            m_quit = false;
            int recv;
            byte[] buffer = new byte[1024];
            byte[] outbuffer;

            Console.WriteLine("worker thread: working...");

            TcpClient client = new TcpClient(m_host, m_port);
            NetworkStream ns = client.GetStream();

            string welcome = "help\r\n";
            outbuffer = Encoding.ASCII.GetBytes(welcome);
            ns.Write(outbuffer, 0, outbuffer.Length);
            ns.ReadTimeout = 1000;

            if (!m_quit && client.Connected)
                OnConnected(EventArgs.Empty);                

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

                Console.WriteLine("\r\nRECV: "+strin);
                // pass received message to registered apps
                OnMessageReceived(new MessageReceivedArgs(strin));

                //if (!Program.HandleInputCommand(strin, this)) // this handles server-level commands from client
                //{
                //    // The following handles client-level commands from client:
                //    switch (strin.ToUpper())
                //    {
                //        case "QUIT":
                //        case "EXIT":
                //        case "BYE":
                //        case "GOODBYE":
                //            m_quit = true;
                //            break;
                //        case "SUBSCRIBEALL":
                //            SubscribedToTagUpdates = true;
                //            break;
                //        case "SUBSCRIBEOFF":
                //            SubscribedToTagUpdates = false;
                //            break;
                //        case "HELLO":
                //        case "HI":
                //        case "HEY":
                //            SendToClient(ns, "Hey there, how are you?");
                //            break;
                //        case "HELP":
                //            SendToClient(ns, GetHelpText());
                //            break;
                //        default:
                //            if (strin.Length > 0)
                //            {
                //                SendToClient(ns, "Sorry, unrecognised command: \"" + strin + "\"");
                //            }
                //            break;
                //    }
            }
            SendToServer(ns, "Bye!");
            Console.WriteLine("server thread: closing client connection...");
            ns.Close();
            client.Close();

            Console.WriteLine("worker thread: terminating gracefully.");
        }

        internal void SendCommand(string command)
        {
            lock (m_listlocker)
            {
                m_messagesToSend.Add(command);
            }
        }

        internal void ShutDown()
        {
            m_quit = true;
        }

        public static void RequestStop()
        {
            _shouldStop = true;
        }

        private void SendToServer(NetworkStream ns, string msg)
        {
            byte[] outbuffer;
            outbuffer = Encoding.ASCII.GetBytes(msg + Environment.NewLine);
            try
            {
                ns.Write(outbuffer, 0, outbuffer.Length);
            }
            catch (Exception)
            {
                Console.WriteLine("info: error writing to server");
                m_quit = true;
            }
        }

        private void DispatchMessages(NetworkStream ns)
        {
            lock (m_listlocker)
            {
                foreach (string msg in m_messagesToSend)
                {
                    SendToServer(ns, msg);
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

        // Call state notification (is user on a call or not?): ************************************************************
        private void OnConnected(EventArgs e)
        {
            if (Connected != null)
                Connected(this, e);
        }

        private void OnMessageReceived(MessageReceivedArgs e)
        {
            if (MessageReceived != null)
                MessageReceived(this, e);
        }
    }
}
