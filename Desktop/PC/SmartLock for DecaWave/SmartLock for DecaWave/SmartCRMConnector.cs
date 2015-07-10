using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Threading;

/**
 * SmartCRMConnector
 * 
 * This is a virtual base class for creating connectors to CRM applications
 * such as Outlook, Lync, Salesforce etc.
 * 
 * Create a sub-class of this class and implement the virtual methods
 * for GetAppName, Connect, Disconnect, GetContact.
 * 
 * Note: it is recommended that you utilise try catch blocks in the calling code
 * where you call any methods in this connector class, as the connections to
 * 3rd party can fail. These exceptions need to be trapped.
 * 
 * In the case of connecting if you get an exception it is recommended in the
 * calling code to retry every 10 or 30 seconds or so up to a defined maximum
 * number of retries before giving up.
 * 
 **/

namespace Plantronics.UC.SmartLockID
{
    public enum SmartCRMConnectorErrorState
    {
        noerror = 0,  // means it found contact ok
        notconnected,
        contactnotfound,  // when it does not find contact
        unknown
    }

    public interface CRMContactReceiver
    {
        void ContactCallback(CRMContact aContact);
    }

    public struct CRMContact
    {
        public string FirstName;
        public string LastName;
        public string CompanyName;
        public Image ContactImage;
        public SmartCRMConnectorErrorState errorstate; // return error state, 0 = no error
    }

    public abstract class SmartCRMConnector
    {
        private bool m_isConnected = false;
        public CRMContactReceiver m_receiver = null;
        public DebugLogger m_debuglog = null;
        protected int m_numretries = 12;
        protected int m_retrydelay = 20;

        // a lock for allowing multi-threaded access to sensitive member data
        // such as the m_isConnected member.
        private System.Object lockThis = new System.Object();

        // Define thread safe property for finding if we are connected or not?
        public bool IsConnected 
        {
            get
            {
                bool retval;
                lock (lockThis)
                {
                    retval = m_isConnected;
                }
                return retval;
            }
            set
            {
                lock (lockThis)
                {
                    m_isConnected = value;
                }
            }
        }

        // Thread to attempt connect in!
        public Thread starterThread;

        // Return a free-text name name of the application you want to connect to, e.g. Outlook, Lync, Salesforce
        public string AppName { get; set; }
        public string GetAppName()
        {
            return "["+AppName+"]";
        }

        // Connect to the application
        // numretries = number of times to retry connection
        // retrydelay = delay time between retries
        // defaults to trying for 4 minutes with 20 seconds between each try
        public abstract bool Connect(int numretries = 12, int retrydelay = 20);

        // The actual method that tries the connection (threaded method)
        public abstract void ConnectAction();

        // Connect to the application
        public abstract bool Disconnect();

        // Get a contact name and image from the CRM app based on a callerid (phone number).
        // Note: if you CRM app does not support images just leave that field null in the Contact returned.
        // Note: within the Contact struct there is an errorstate value you
        // can use to return any problems getting date from CRM app
        public abstract CRMContact GetContact(string callerid);

        // Set a reference to a class that will receive asyncronous CRM data, e.g. from Lync
        public void SetCRMReceiver(CRMContactReceiver aReceiver)
        {
            m_receiver = aReceiver;
        }
    }
}
