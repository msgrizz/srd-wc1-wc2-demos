using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Office.Interop.Outlook;
using System.Windows.Media.Imaging;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Reflection;
using System.Threading;

namespace Plantronics.UC.SmartLockID
{
    public class OutlookConnector : SmartCRMConnector
    {
        ApplicationClass outlookApplication = null;
        NameSpace mapiNamespace = null;
        public MAPIFolder contacts = null;


        public OutlookConnector(DebugLogger aLogger)
        {
            AppName = "Microsoft Outlook";

            m_debuglog = aLogger;

            starterThread = new Thread(this.ConnectAction);
        }

        public override bool Connect(int numretries = 12, int retrydelay = 20)
        {
            bool retval = false;

            m_numretries = numretries;
            m_retrydelay = retrydelay;

            // start thread and return true to indicate that we have at least commenced trying to connect...
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Starting background thread to Connect to Outlook...");
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
                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Try to connect to Outlook, try: "+trynum+" of "+m_numretries);
                try
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": About to create Outlook ApplicationClass...");

                    outlookApplication = new ApplicationClass();

                    mapiNamespace = outlookApplication.GetNamespace("MAPI");
                    contacts = mapiNamespace.GetDefaultFolder(OlDefaultFolders.olFolderContacts);
                    IsConnected = true;

                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Let's clear out any old thumbnails from temp folder...");
                    CleanupContactPictures();

                    outlookApplication.ApplicationEvents_Event_Quit += new ApplicationEvents_QuitEventHandler(outlookApplication_ApplicationEvents_Event_Quit);

                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": SUCCESS Got Outlook connection ok.");
                }
                catch (System.Exception e)
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": INFO: Exception during Outlook connect: " + e.ToString());
                }
                // sleep before retrying...
                if (trynum <= m_numretries && !IsConnected)
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Will try Outlook again in: " + m_retrydelay + " seconds!");
                    Thread.Sleep(m_retrydelay * 1000);
                }
            }
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Completed: " + trynum + " tries to connect to Outlook. Connected? = " + IsConnected);
        }

        void outlookApplication_ApplicationEvents_Event_Quit()
        {
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": INFO, Outlook client was DISCONNECTED!");
            Disconnect();
        }

        public override bool Disconnect()
        {
            contacts = null;
            mapiNamespace = null;
            outlookApplication = null;
            IsConnected = false;

            if (starterThread.IsAlive) starterThread.Abort();

            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Let's clear out any old thumbnails from temp folder...");
            CleanupContactPictures();

            return true;
        }

        public override CRMContact GetContact(string callerid)
        {
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": About to search Outlook for contact = " + callerid);
            CRMContact retval = new CRMContact();

            string callerid2 = "";
            if (callerid.StartsWith("0"))
            {
                callerid2 = callerid.Substring(1);
                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Will also try searching for this (without space): " + callerid2);
            }

            if (IsConnected)
            {
                retval.errorstate = SmartCRMConnectorErrorState.contactnotfound;
                if (callerid.Length == 10)
                {
                    callerid = "1" + callerid;
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Caller id was 10 long, so was modded to this: " + callerid);
                }

                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Number of contacts to search = " + contacts.Items.Count);
                bool gotMatch = false;
                for (int i = 1; i < contacts.Items.Count + 1; i++)
                {
                    var contact = (Microsoft.Office.Interop.Outlook.ContactItem)contacts.Items[i];
                    List<string> numbers = new List<string>();
                    //regex pattern replacement to eliminate all characters that aren't digits from the contact results.
                    //ex. +1 (831) 123-4567 will result in 18311234567
                    numbers.Add(System.Text.RegularExpressions.Regex.Replace(contact.BusinessTelephoneNumber != null ? contact.BusinessTelephoneNumber : "0", "[^0-9]", ""));
                    numbers.Add(System.Text.RegularExpressions.Regex.Replace(contact.Business2TelephoneNumber != null ? contact.Business2TelephoneNumber : "0", "[^0-9]", ""));
                    numbers.Add(System.Text.RegularExpressions.Regex.Replace(contact.CarTelephoneNumber != null ? contact.CarTelephoneNumber : "0", "[^0-9]", ""));
                    numbers.Add(System.Text.RegularExpressions.Regex.Replace(contact.CallbackTelephoneNumber != null ? contact.CallbackTelephoneNumber : "0", "[^0-9]", ""));
                    numbers.Add(System.Text.RegularExpressions.Regex.Replace(contact.CompanyMainTelephoneNumber != null ? contact.CompanyMainTelephoneNumber : "0", "[^0-9]", ""));
                    numbers.Add(System.Text.RegularExpressions.Regex.Replace(contact.MobileTelephoneNumber != null ? contact.MobileTelephoneNumber : "0", "[^0-9]", ""));
                    numbers.Add(System.Text.RegularExpressions.Regex.Replace(contact.HomeTelephoneNumber != null ? contact.HomeTelephoneNumber : "0", "[^0-9]", ""));
                    numbers.Add(System.Text.RegularExpressions.Regex.Replace(contact.Home2TelephoneNumber != null ? contact.Home2TelephoneNumber : "0", "[^0-9]", ""));
                    numbers.Add(System.Text.RegularExpressions.Regex.Replace(contact.PrimaryTelephoneNumber != null ? contact.PrimaryTelephoneNumber : "0", "[^0-9]", ""));
                    numbers.Add(System.Text.RegularExpressions.Regex.Replace(contact.OtherTelephoneNumber != null ? contact.OtherTelephoneNumber : "0", "[^0-9]", ""));

                    //// For in depth debug...
                    //m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": ******************************************************");
                    //m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Searching the following numbers for contains caller id = " + callerid + ", and caller id = " + callerid2);

                    //foreach (string item in numbers)
                    //{
                    //    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Number: " + item);
                    //}
                    //m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": ******************************************************");

                    if (numbers.Contains(callerid) || (callerid2.Length > 0 && numbers.Contains(callerid2)))
                    {
                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Found match with: "+contact.LastName+ ", "+ contact.FirstName + "! On callerid = "+callerid+", or callerid2 = "+callerid2);

                        gotMatch = true;

                        retval.LastName = contact.LastName;
                        retval.FirstName = contact.FirstName;
                        retval.CompanyName = contact.CompanyName;
                        retval.errorstate = SmartCRMConnectorErrorState.noerror;
                        
                        // LC does the contact have a picture?
                        if (contact.HasPicture)
                        {
                            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": The contact: " + contact.LastName + ", " + contact.FirstName + " HAS A PICTURE!");
                            // lets extract the image...
                            Image tmpImage = ConvertOutlookImage(contact);
                            if (tmpImage != null)
                            {
                                Image resizedImage = GraphicsUtility.FixedSize(tmpImage, MobileCallForm.PICTURE_SIZEX, MobileCallForm.PICTURE_SIZEY);

                                if (resizedImage != null)
                                {
                                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Extracted picture OK!");
                                    retval.ContactImage = resizedImage;
                                }
                            }
                        }

                        break;
                    }
                }
                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Got match? = " + gotMatch);
            }
            else
            {
                retval.errorstate = SmartCRMConnectorErrorState.notconnected;
            }
            return retval;
        }

        public static string GetContactPicturePath(Microsoft.Office.Interop.Outlook.ContactItem contact)
        {
            return GetContactPicturePath(contact, System.IO.Path.GetTempPath());
        }

        public static string GetContactPicturePath(Microsoft.Office.Interop.Outlook.ContactItem contact, string path)
        {
            string picturePath = "";

            if (contact.HasPicture)
            {
                foreach (Microsoft.Office.Interop.Outlook.Attachment att in contact.Attachments)
                {
                    if (att.DisplayName == "ContactPicture.jpg")
                    {
                        try
                        {
                            picturePath = System.IO.Path.GetDirectoryName(path) + "\\Contact_" + contact.EntryID + ".jpg";
                            if (!System.IO.File.Exists(picturePath))
                                att.SaveAsFile(picturePath);
                        }
                        catch
                        {
                            picturePath = "";
                        }
                    }
                }
            }

            return picturePath;
        }

        public static void CleanupContactPictures()
        {
            CleanupContactPictures(System.IO.Path.GetTempPath());
        }

        public static void CleanupContactPictures(string path)
        {
            foreach (string picturePath in System.IO.Directory.GetFiles(path, "Contact_*.jpg"))
            {
                try
                {
                    System.IO.File.Delete(picturePath);
                }
                catch
                {
                }
            }
        }

        public Image ConvertOutlookImage(Microsoft.Office.Interop.Outlook.ContactItem contact)
        {
            Bitmap bitmap = null;

            string picturePath = OutlookConnector.GetContactPicturePath(contact);

            if ((picturePath != "") && (System.IO.File.Exists(picturePath)))
                bitmap = new Bitmap(picturePath);

            return bitmap;
        }
    }
}
