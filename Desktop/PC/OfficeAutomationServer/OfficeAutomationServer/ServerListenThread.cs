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
                TcpListener client = new TcpListener(IPAddress.Parse("0.0.0.0"), 9050);
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
                        ClientConnectionThread newconnection = new ClientConnectionThread(client);
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

}
