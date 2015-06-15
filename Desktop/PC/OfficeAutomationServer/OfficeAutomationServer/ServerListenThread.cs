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
                    }
                    if (client.Pending() && !preventMultiple)
                    {
                        Console.WriteLine("server thread: new client connection...");
                        ConnectionThread newconnection = new ConnectionThread(client);
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

        public ConnectionThread(TcpListener lis)
        {
            threadListener = lis;
            ThreadPool.QueueUserWorkItem(new WaitCallback(HandleConnection));
        }

        public void HandleConnection(object state)
        {
            bool quit = false;
            int recv;
            byte[] buffer = new byte[1024];
            byte[] outbuffer;

            TcpClient client = threadListener.AcceptTcpClient();
            NetworkStream ns = client.GetStream();

            string welcome = "Welcome to OAS, Plantronics Innovations 2015\r\n";
            outbuffer = Encoding.ASCII.GetBytes(welcome);
            ns.Write(outbuffer, 0, outbuffer.Length);

            while (!quit && client.Connected)
            {
                StringBuilder sb = new StringBuilder();
                try
                {
                    string bit = "";
                    while (bit != null && !bit.EndsWith("\r") && !bit.EndsWith("\n"))
                    {
                        Array.Clear(buffer, 0, buffer.Length);
                        recv = ns.Read(buffer, 0, buffer.Length);
                        if (recv > 0)
                        {
                            bit = Encoding.ASCII.GetString(buffer);
                            bit = bit.Replace("\0", string.Empty);
                            if (bit != null && !bit.EndsWith("\r") && !bit.EndsWith("\n"))
                            {
                                sb.Append(bit);
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
                    quit = true;
                }
                string strin = sb.ToString();
                Program.HandleInputCommand(strin);
                if (strin.ToUpper() == "QUIT")
                {
                    quit = true;
                }
            }
            welcome = "bye";
            outbuffer = Encoding.ASCII.GetBytes(welcome);
            try
            {
                ns.Write(outbuffer, 0, outbuffer.Length);
                Console.WriteLine("server thread: closing client connection...");
                ns.Close();
                client.Close();
            }
            catch (Exception)
            {
                Console.WriteLine("info: error writing to client");
                quit = true;
            }
        }
    }
}
