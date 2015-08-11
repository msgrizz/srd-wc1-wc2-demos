using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace OfficeAutomationServer
{
    public class ClientConnectionThread
    {
        public TcpListener threadListener;
        private bool m_quit = false;

        // A list of messages to send out to client
        List<string> m_messagesToSend = new List<string>();
        private static volatile object m_listlocker = new Object();

        public volatile bool SubscribedToTagUpdates = false;
        private bool m_loggedon = false; // if not logged on we can't do much
        private PermissionLevels m_permissions = PermissionLevels.NormalUser;

        public enum PermissionLevels
        {
            NormalUser,
            AdminUser            
        }

        // lock and short interuptable timeout to wait for incoming message
        object m_checkIOlock = new object();
        int m_checkIOtimeout = 100;

        public ClientConnectionThread(TcpListener lis)
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
                            int len = bit.Length;
                            if (bit != null)
                            {
                                // new, handle backspaces
                                while (bit.EndsWith("\b"))
                                {
                                    if (bit.Length > 0)
                                    {
                                        bit = bit.Substring(0, bit.Length - 1);
                                        if (sb.Length>0)
                                        {
                                            sb.Remove(sb.Length - 1, 1);
                                        }
                                    }
                                    else
                                    {
                                        bit = null;
                                    }
                                }
                                if (bit != null && bit.Length > 0)
                                {
                                    //string tmp = bit.Replace("\r", string.Empty);
                                    //tmp = tmp.Replace("\n", string.Empty);
                                    sb.Append(bit);  // tmp
                                }
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
                string[] commands = sb.ToString().Split(new string[] { Environment.NewLine }, StringSplitOptions.None);
                foreach (string commanditer in commands)
                {
                    string command = commanditer;
                    string arguments = "";
                    if (command == null || command.Length < 1) break;
                    if (!Program.HandleInputCommand(command, this, m_loggedon, m_permissions, ns)) // this handles server-level commands from client
                    {
                        // NEW LC 10-08-2015 split incoming command into
                        // command and then any args
                        int space_pos = command.IndexOf(' ');
                        if (space_pos > -1 && command != String.Empty)
                        {
                            arguments = command.Substring(space_pos + 1);
                            command = command.Substring(0, space_pos).ToUpper();
                        }

                        // The following handles client-level commands from client:
                        switch (command.ToUpper())
                        {
                            case "LOGON":
                                DoProcessLogon(arguments, ns);
                                break;
                            case "QUIT":
                            case "EXIT":
                            case "BYE":
                            case "GOODBYE":
                                m_quit = true;
                                break;
                            case "GEOFENCE":
                                DoGeoFence(ns);
                                break;
                            case "SUBSCRIBEALL":
                                if (m_loggedon)
                                {
                                    SendToClient(ns, "SUCCESS SUBSCRIBEALL");
                                    SubscribedToTagUpdates = true;
                                }
                                else
                                {
                                    SendToClient(ns, "FAILED SUBSCRIBEALL " + ErrorCodes.UserNotLoggedOn + " SUBSCRIBEALL command requires that you LOGON first.");
                                }
                                break;
                            case "SUBSCRIBEOFF":
                                if (m_loggedon)
                                {
                                    SendToClient(ns, "SUCCESS SUBSCRIBEOFF");
                                    SubscribedToTagUpdates = false;
                                }
                                else
                                {
                                    SendToClient(ns, "FAILED SUBSCRIBEOFF " + ErrorCodes.UserNotLoggedOn + " SUBSCRIBEOFF command requires that you LOGON first.");
                                }
                                break;
                            case "GETENTITIES":
                                if (m_loggedon)
                                {
                                    SendToClient(ns, "SUCCESS GETENTITIES");
                                    // TODO initiate transfer of entities to
                                    // client. Each entity as a JSON message.
                                }
                                else
                                {
                                    SendToClient(ns, "FAILED GETENTITIES " + ErrorCodes.UserNotLoggedOn + " GETENTITIES command requires that you LOGON first.");
                                }
                                break;
                            case "UPDATEENTITY":
                                if (m_loggedon)
                                {
                                    SendToClient(ns, "SUCCESS UPDATEENTITY");
                                    // TODO write entity data from JSON
                                    // in arguments to database
                                }
                                else
                                {
                                    SendToClient(ns, "FAILED UPDATEENTITY " + ErrorCodes.UserNotLoggedOn + " UPDATEENTITY command requires that you LOGON first.");
                                }
                                break;
                            case "DELETEENTITY":
                                if (m_loggedon)
                                {
                                    SendToClient(ns, "SUCCESS DELETEENTITY");
                                    // TODO delete entity from database using entity id in arguments
                                }
                                else
                                {
                                    SendToClient(ns, "FAILED DELETEENTITY " + ErrorCodes.UserNotLoggedOn + " DELETEENTITY command requires that you LOGON first.");
                                }
                                break;
                            case "UPDATEREGION":
                                if (m_loggedon)
                                {
                                    SendToClient(ns, "SUCCESS UPDATEREGION");
                                    // TODO write region data from JSON
                                    // in arguments to database
                                }
                                else
                                {
                                    SendToClient(ns, "FAILED UPDATEREGION " + ErrorCodes.UserNotLoggedOn + " UPDATEREGION command requires that you LOGON first.");
                                }
                                break;
                            case "DELETEREGION":
                                if (m_loggedon)
                                {
                                    SendToClient(ns, "SUCCESS DELETEREGION");
                                    // TODO delete region from database using entity id in arguments
                                }
                                else
                                {
                                    SendToClient(ns, "FAILED DELETEREGION " + ErrorCodes.UserNotLoggedOn + " DELETEREGION command requires that you LOGON first.");
                                }
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
                                if (command.Length > 0)
                                {
                                    SendToClient(ns, "Sorry, unrecognised command: \"" + command + "\"");
                                }
                                break;
                        }
                    }
                }
            }
            SendToClient(ns, "Bye!");
            Console.WriteLine("server thread: closing client connection...");
            ns.Close();
            client.Close();
        }

        private void DoProcessLogon(string arguments, NetworkStream ns)
        {
            arguments = arguments.ToUpper();
            if (arguments.Length == 0)
            {
                m_permissions = PermissionLevels.NormalUser;
                m_loggedon = false;
                SendToClient(ns, "FAILED LOGON " + ErrorCodes.UserAccountNotRecognized + " Check LOGON command usage:"+ Environment.NewLine+
                    "LOGON <Windows User Name> - Log on as this user to use OAS features." + Environment.NewLine);
            }
            else
            {
                if (arguments == "LCOLLINS" || arguments == "SHAYWARD-I")
                {
                    m_permissions = PermissionLevels.NormalUser;
                    m_loggedon = true;
                    SendToClient(ns, "SUCCESS LOGON");
                    if (arguments == "LCOLLINS")
                    {
                        m_permissions = PermissionLevels.AdminUser;
                    }
                }
                else
                {
                    m_permissions = PermissionLevels.NormalUser;
                    m_loggedon = false;
                    SendToClient(ns, "FAILED LOGON " + ErrorCodes.UserAccountNotRecognized + " User does not have an account.");
                }
            }
        }

        public enum ErrorCodes
        {
            NoError,
            UnknownError,
            UserAccountNotRecognized,
            UserNotLoggedOn,
            CommandNotImplemented,
            InsufficientPermissions
        }

        private void DoGeoFence(NetworkStream ns)
        {
            // create a 2 meter geofence around the user's tag location
            // this will be stored in memory, will it also go into database?
            // probably yes, so oas can survive restart and maintain the active geofences
            //
            // question: how to cope with moving laptop?
            // should laptop have a tag? OR should you be able to overide the geofence.
            // maybe provide easy "cancel geofence e.g. for 5/15 mins" options on system tray

            if (m_loggedon)
            {
                SendToClient(ns, "FAILED GEOFENCE " + ErrorCodes.CommandNotImplemented + " GEOFENCE command is not yet implemented.");
            }
            else
            {
                SendToClient(ns, "FAILED LOGON " + ErrorCodes.UserNotLoggedOn + " GEOGENCE command requires that you LOGON first.");
            }
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
            sb.Append("LOGON <Windows User Name> - Log on as this user to use OAS features." + Environment.NewLine);
            sb.Append("GEOFENCE - Make a new geofence for current user." + Environment.NewLine);
            sb.Append("SUBSCRIBEALL - subscribe to tag updates for all tags in system" + Environment.NewLine);
            sb.Append("SUBSCRIBEOFF - unsubscribe to tag updates for all tags in system" + Environment.NewLine);
            sb.Append("GETENTITIES - gets the entity data from database" + Environment.NewLine);
            sb.Append("UPDATEENTITY <{JSON ENTITY DATA}> - add/update the entity in database" + Environment.NewLine);
            sb.Append("DELETEENTITY <ENTITY ID> - delete the entity from database" + Environment.NewLine);
            sb.Append("UPDATEREGION <{JSON REGION DATA}> - add/update the region in database" + Environment.NewLine);
            sb.Append("DELETEREGION <REGION ID> - delete the region in database" + Environment.NewLine);
            sb.Append("HELP - display this list of available commands" + Environment.NewLine);
            sb.Append("VERSION - displays server version information" + Environment.NewLine);
            sb.Append("SHUTDOWN - shut down the server" + Environment.NewLine);
            return sb.ToString();
        }

        public void SendToClient(NetworkStream ns, string msg)
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
