using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Lync.Model;
using Microsoft.Lync.Model.Conversation;
using Microsoft.Lync.Model.Group;
using System.Drawing;
using System.IO;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Runtime.InteropServices;
using System.Reflection;
using System.Threading;

namespace Plantronics.UC.SmartLockID
{
    public class LyncConnector : SmartCRMConnector
    {
        // to allow to make Lync calls (uses Lync client sdk)...
        private LyncClient _LyncClient;
        private Self _self;
        private bool lyncinitted = false;
        private Conversation _Conversation;
        private string targetUri;
        bool m_callinprog = false;

        // search stuff
        ContactManager _ContactManager;
        private ContactSubscription _SearchResultSubscription;
        private List<SearchProviders> myActiveSearchProviders = new List<SearchProviders>();

        public LyncConnector(CRMContactReceiver aReceiver, DebugLogger debuglog)
        {
            AppName = "Microsoft Lync";

            SetCRMReceiver(aReceiver);
            m_debuglog = debuglog;

            starterThread = new Thread(this.ConnectAction);
        }

        public override bool Connect(int numretries = 12, int retrydelay = 20)
        {
            bool retval = false;

            m_numretries = numretries;
            m_retrydelay = retrydelay;

            // start thread and return true to indicate that we have at least commenced trying to connect...
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Starting background thread to Connect to Lync...");
            starterThread.Start();
            retval = true;

            return retval;
        }

        public override void ConnectAction()
        {
            int trynum = 0;
            while (trynum <= m_numretries && !IsConnected)
            {
                trynum++;
                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Try to connect to Lync, try: "+trynum+" of "+m_numretries);
                try
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": About to get Lync client...");

                    _LyncClient = LyncClient.GetClient();

                    if (_LyncClient == null)
                    {
                        IsConnected = false;
                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": FAILED! Could not get Lync client.");
                    }
                    else
                    {
                        IsConnected = true;
                        _self = _LyncClient.Self;
                        _ContactManager = _LyncClient.ContactManager;

                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": SUCCESS got Lync client OK.");

                        _LyncClient.ClientDisconnected += new EventHandler(_LyncClient_ClientDisconnected);
                    }
                }
                catch (System.Exception e)
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": INFO: Exception during Lync connect: " + e.ToString());
                }
                // sleep before retrying...
                if (trynum <= m_numretries && !IsConnected)
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Will try Lync again in: " + m_retrydelay + " seconds!");
                    Thread.Sleep(m_retrydelay * 1000);
                }
            }
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Completed: " + trynum + " tries to connect to Lync. Connected? = " + IsConnected);
        }

        void _LyncClient_ClientDisconnected(object sender, EventArgs e)
        {
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": INFO, Lync client was DISCONNECTED!");
            Disconnect();
        }

        public override bool Disconnect()
        {
            _LyncClient = null;
            _self = null;
            IsConnected = false;

            if (starterThread.IsAlive) starterThread.Abort();

            return true;
        }

        public override CRMContact GetContact(string callerid)
        {
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": About to search Lync for contact = " + callerid);
            CRMContact retval = new CRMContact();
            if (IsConnected)
            {
                retval.errorstate = SmartCRMConnectorErrorState.contactnotfound;

                // search for contact in Lync
                SearchForNumber(callerid);
            }
            else 
            {
                retval.errorstate = SmartCRMConnectorErrorState.notconnected;
            }
            return retval;
        }

        private void SearchForNumber(string callerid)
        {
            _ContactManager.BeginSearch(
                callerid,
                SearchProviders.GlobalAddressList,
                SearchFields.AllFields,
                SearchOptions.Default,
                10, // 10 results should do it
                SearchCallback,
                new object[] { _ContactManager, "Searching contacts" }
                );
        }

        private void SearchCallback(IAsyncResult result)
        {
            object[] parameters = (object[])result.AsyncState;

            string statestr = (string)parameters[1];

            if (statestr == "Searching contacts")
            {
                SearchResults results = _ContactManager.EndSearch(result);

                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": EndSearch occured. Number of results = " + results.AllResults.Count);

                if (results.AllResults.Count == 0)
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": No results.");
                }
                else
                {
                    // prep a crm contact to send back to receiver...
                    CRMContact crmcontact = new CRMContact();
                    crmcontact.FirstName = "";
                    crmcontact.LastName = "";
                    crmcontact.CompanyName = "";
                    crmcontact.ContactImage = null;
                    string tmpfname, tmplname, tmpcname;

                    // iterate all the contacts getting best of the info...
                    foreach (Contact cnt in results.Contacts)
                    {
                        tmpfname = cnt.GetContactInformation(ContactInformationType.FirstName).ToString();
                        tmplname = cnt.GetContactInformation(ContactInformationType.LastName).ToString();
                        tmpcname = cnt.GetContactInformation(ContactInformationType.Company).ToString();
                        if (crmcontact.FirstName.Length == 0 && tmpfname != null && tmpfname.Length > 0)
                        {
                            crmcontact.FirstName = tmpfname;
                        }
                        if (crmcontact.LastName.Length == 0 && tmplname != null && tmplname.Length > 0)
                        {
                            crmcontact.LastName = tmplname;
                        }
                        if (crmcontact.CompanyName.Length == 0 && tmpcname != null && tmpcname.Length > 0)
                        {
                            crmcontact.CompanyName = tmpcname;
                        }

                        if (crmcontact.ContactImage == null)
                        {
                            // lets extract the image...
                            Image tmpImage = GetContactPhoto(cnt);
                            if (tmpImage != null)
                            {
                                Image resizedImage = GraphicsUtility.FixedSize(tmpImage, MobileCallForm.PICTURE_SIZEX, MobileCallForm.PICTURE_SIZEY);

                                if (resizedImage != null)
                                {
                                    crmcontact.ContactImage = resizedImage;
                                }
                            }
                        }
                    }

                    // have we got a any contact result?
                    if (crmcontact.FirstName.Length > 0 ||
                        crmcontact.LastName.Length > 0 ||
                        crmcontact.CompanyName.Length > 0 ||
                        crmcontact.ContactImage != null)
                    {
                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": INFO: we found a contact - lets inform our receiver - the main app form!");
                        // we found a contact - lets inform our receiver - the main app form!
                        m_receiver.ContactCallback(crmcontact);
                    }
                    else
                    {
                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": INFO! No name, company name or picture data found in returned results!");
                    }
                }
            }
        }

        private Image GetContactPhoto(Microsoft.Lync.Model.Contact contact)
        {
            try
            {
                using (Stream photoStream = contact.GetContactInformation(ContactInformationType.Photo) as Stream)
                {
                    if (photoStream != null)
                    {
                        MemoryStream TransportStream = new MemoryStream();
                        BitmapEncoder enc = new BmpBitmapEncoder();
                        enc.Frames.Add(BitmapFrame.Create(photoStream));
                        enc.Save(TransportStream);
                        return new System.Drawing.Bitmap(TransportStream);
                    }
                }
            }
            catch (LyncClientException e)
            {
                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": INFO, could not extract image. This contact maybe doesn't have one.");
            }
            catch (SystemException systemException)
            {
                if (IsLyncException(systemException))
                {
                    // Log the exception thrown by the Lync Model API.
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": SystemException occured! \r\nError: " + systemException.ToString());
                }
                else
                {
                    // Rethrow the SystemException which did not come from the Lync Model API.
                    throw;
                }
            }
            return null;
        }

        /// <summary>
        /// Identify if a particular SystemException is one of the exceptions which may be thrown
        /// by the Lync Model API.
        /// </summary>
        /// <param name="ex"></param>
        /// <returns></returns>
        private bool IsLyncException(SystemException ex)
        {
            return
                ex is NotImplementedException ||
                ex is ArgumentException ||
                ex is NullReferenceException ||
                ex is NotSupportedException ||
                ex is ArgumentOutOfRangeException ||
                ex is IndexOutOfRangeException ||
                ex is InvalidOperationException ||
                ex is TypeLoadException ||
                ex is TypeInitializationException ||
                ex is InvalidComObjectException ||
                ex is InvalidCastException;
        }
    }
}
