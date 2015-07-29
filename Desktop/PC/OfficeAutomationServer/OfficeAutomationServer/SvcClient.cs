using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace OfficeAutomationServer
{
    class SvcClient
    {
        Socket svcSocket;
        public bool ConnectOk { get; set; }

        public SvcClient(string ip, int port)
        {
            ConnectOk = false;
            try
            {
                IPAddress ipAddress = IPAddress.Parse(ip);
                IPEndPoint remoteEP = new IPEndPoint(ipAddress, port);

                // Create a TCP/IP socket.
                svcSocket = new Socket(AddressFamily.InterNetwork,
                    SocketType.Stream, ProtocolType.Tcp);

                svcSocket.Connect(remoteEP);
                //svcSocket.Blocking = false;

                ConnectOk = true;
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                ConnectOk = false;
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
                svcSocket.SendTimeout = 1000;
                svcSocket.ReceiveTimeout = 1000;
                int bytesSent = svcSocket.Send(Encoding.ASCII.GetBytes(jsonStr));

                // Receive the response from the remote device.
                int bytesRec = svcSocket.Receive(bytes);
                Console.WriteLine("From RTLS server = {0}",
                    Encoding.ASCII.GetString(bytes, 0, bytesRec));

                recvMessage = Encoding.ASCII.GetString(bytes, 0, bytesRec);
                return recvMessage;
            }
            catch (Exception e)
            {
                Program.DebugPrint(MethodInfo.GetCurrentMethod().Name, e.ToString());
                return null;
            }
        }

        internal void close()
        {
            // Release the socket.
            if (svcSocket.Connected)
            {
                svcSocket.Shutdown(SocketShutdown.Both);
            }
            svcSocket.Close();
        }
    }

    public class TagXYZ
    {
        public Decimal x;
        public Decimal y;
        public Decimal z;
        public string tagData; // general purpose field for any data for this tag
        public DateTime lastUpdate;

        public TagXYZ(Decimal x, Decimal y, Decimal z, string tagData, DateTime lastUpdate)
        {
            this.x = x;
            this.y = y;
            this.z = z;
            this.tagData = tagData;
            this.lastUpdate = lastUpdate;
        }

        public void update(Decimal x, Decimal y, Decimal z, DateTime lastUpdate)
        {
            this.x = x;
            this.y = y;
            this.z = z;
            this.lastUpdate = lastUpdate;
        }

        public void updatedata(string tagData)
        {
            this.tagData = tagData;
        }
    }
}

