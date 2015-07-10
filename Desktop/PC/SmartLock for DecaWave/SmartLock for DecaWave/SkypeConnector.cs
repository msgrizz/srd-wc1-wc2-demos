using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Media.Imaging;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Reflection;
using System.Threading;

using SKYPE4COMLib;
using System.Text.RegularExpressions;
using System.IO;

/**
 * A CRM connector for Skype to retrieve user contact name and avatar picture
 * from Skype version 6 based on mobile caller id.
 * 
 * NOTE: limitation: this connector will ONLY find mobile numbers on your Skype friends
 * list when the mobile number was added to the contact by the contact him/her self
 * NOT the alternate calling numbers you may have added to the contact in your own
 * Skype client, as these are not actually on the user's own Skype profile.
 **/

namespace Plantronics.UC.SmartLockID
{
    /// <summary>
    /// Connector to Skype to be retrieve contact information based on caller id from mobile phone...
    /// </summary>
    public class SkypeConnector : SmartCRMConnector
    {
        Skype skype = null;

        public SkypeConnector(DebugLogger aLogger)
        {
            AppName = "Skype";

            m_debuglog = aLogger;

            starterThread = new Thread(this.ConnectAction);
        }

        public override bool Connect(int numretries = 12, int retrydelay = 20)
        {
            bool retval = false;

            m_numretries = numretries;
            m_retrydelay = retrydelay;

            skype = new Skype();
            ((_ISkypeEvents_Event)skype).AttachmentStatus += new _ISkypeEvents_AttachmentStatusEventHandler(SkypeConnector_AttachmentStatus);

            // start thread and return true to indicate that we have at least commenced trying to connect...
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Starting background thread to Connect to Skype...");
            starterThread.Start();
            retval = true;

            return retval;
        }

        public override void ConnectAction()
        {
            int trynum = 0;
            bool aborting = false;
            while (trynum <= m_numretries && !IsConnected)
            {
                trynum++;
                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Try to connect to Skype, try: "+trynum+" of "+m_numretries);
                try
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": About to create Skype ApplicationClass...");

                    if (!skype.Client.IsRunning)
                    {
                        // start minimized with no splash screen
                        skype.Client.Start(false, true);
                    }

                    // wait for the client to be connected and ready
                    skype.Attach(9, false);

                    // access skype objects
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, "Missed message count: " + skype.MissedMessages.Count);

                    IsConnected = true;

                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": Let's clear out any old thumbnails from temp folder...");
                    CleanupContactPictures();

                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": SUCCESS Got Skype connection ok.");
                }
                catch (ThreadAbortException)
                {
                    aborting = true;
                }
                catch (System.Exception e)
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": INFO: Exception during Skype connect: " + e.ToString());
                    skype = null;
                    IsConnected = false;
                }
                // sleep before retrying...
                if (!aborting && (trynum <= m_numretries && !IsConnected))
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Will try Skype again in: " + m_retrydelay + " seconds!");
                    Thread.Sleep(m_retrydelay * 1000);
                }
            }
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Completed: " + trynum + " tries to connect to Skype. Connected? = " + IsConnected);
        }

        void SkypeConnector_AttachmentStatus(TAttachmentStatus status)
        {
            if (skype == null)
            {
                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": " +
                     "skype event but skype is null (currently disconected)");
                return;
            }

            // Always use try/catch with ANY Skype methods.
            try
            {
                // Write Attachment Status to Window, if it has changed.
                if ((((ISkype)skype).AttachmentStatus != TAttachmentStatus.apiAttachSuccess))
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": " +
                     "Attachment Status - Converted Status: " + skype.Convert.AttachmentStatusToText((((ISkype)skype).AttachmentStatus)) +
                     " - TAttachmentStatus: " + (((ISkype)skype).AttachmentStatus) +
                     "\r\n");
                    Disconnect(); // stop the starter thread (prevent more connection attempts)
                }

                // End user has denied the request, you may wish to send them a message
                // on how to change that if they did it accidentally.
                // More here: https://support.skype.com/en/faq/FA218/Can-I-contr​?ol-which-applications-connect-to-my-Skype-for-Wi...
                if (status == TAttachmentStatus.apiAttachRefused)
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": " +
                     "The end-user has denied the attach request");

                // End user could have changed users, try attach again.
                // Also maybe Skype was not running when we started and now is.
                if (status == TAttachmentStatus.apiAttachAvailable)
                    skype.Attach(9, false);

                // Show are now connected to the Skype client.
                if (status == TAttachmentStatus.apiAttachSuccess)
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": " +
                     "We Are Connected - Attachment Status - Converted Status: " + skype.Convert.AttachmentStatusToText((((ISkype)skype).AttachmentStatus)) +
                     " - TAttachmentStatus: " + (((ISkype)skype).AttachmentStatus) +
                     "\r\n");
                    IsConnected = true; // we are now connected!
                }
            }
            catch (Exception e)
            {
                // Write Attach Status Event Handler Failed to Window.
                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": " +
                 "Attachment Status Event Fired - Bad Result " +
                 " - Exception Source: " + e.Source + " - Exception Message: " + e.Message +
                 "\r\n");
            }
        }

        //void outlookApplication_ApplicationEvents_Event_Quit()
        //{
        //    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": INFO, Outlook client was DISCONNECTED!");
        //    Disconnect();
        //}

        public override bool Disconnect()
        {
            // note intentionally leaving skype object created (not null), and skype status event handler registered
            IsConnected = false;

            if (starterThread.IsAlive) starterThread.Abort();

            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Let's clear out any old thumbnails from temp folder...");
            CleanupContactPictures();

            return true;
        }

        public override CRMContact GetContact(string callerid)
        {
            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": About to search Skype for contact = " + callerid);
            CRMContact retval = new CRMContact();

            string callerid2 = "callerid2"; // pre-load with random value so it won't match on empty string
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

                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": Number of contacts to search = " + skype.Friends.Count+1); // will also search my user
                bool gotMatch = false;

                // search contacts
                try
                {
                    string handle, phonehome, phonemobile, phoneoffice, calleridtmp = Regex.Replace(callerid, @"\s", "").ToUpper(), callerid2tmp = Regex.Replace(callerid2, @"\s", "").ToUpper();

                    // first check my user record...
                    handle = Regex.Replace(skype.CurrentUser.Handle, @"\s", "").ToUpper();
                    phonehome = Regex.Replace(skype.CurrentUser.PhoneHome, @"\s", "").ToUpper();
                    phonemobile = Regex.Replace(skype.CurrentUser.PhoneMobile, @"\s", "").ToUpper();
                    phoneoffice = Regex.Replace(skype.CurrentUser.PhoneOffice, @"\s", "").ToUpper();

                    // EXTRA DEBUG WHEN NEEDED...
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": Searching contact: " + skype.CurrentUser.DisplayName);
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": handle: " + handle);
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": phonehome: " + phonehome);
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": phonemobile: " + phonemobile);
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": phoneoffice: " + phoneoffice);

                    if (handle.Contains(calleridtmp)
                        ||
                        handle.Contains(callerid2tmp)
                        ||
                        phonehome.Contains(calleridtmp)
                        ||
                        phonehome.Contains(callerid2tmp)
                        ||
                        phonemobile.Contains(calleridtmp)
                        ||
                        phonemobile.Contains(callerid2tmp)
                        ||
                        phoneoffice.Contains(calleridtmp)
                        ||
                        phoneoffice.Contains(callerid2tmp))
                    {
                        retval.LastName = "";
                        retval.FirstName = skype.CurrentUser.FullName;
                        retval.CompanyName = "";
                        retval.errorstate = SmartCRMConnectorErrorState.noerror;
                        gotMatch = true;

                        // lets extract the Skype avatar image...
                        Image tmpImage = ConvertSkypeImage(skype.CurrentUser.Handle);
                        if (tmpImage != null)
                        {
                            Image resizedImage = GraphicsUtility.FixedSize(tmpImage, MobileCallForm.PICTURE_SIZEX, MobileCallForm.PICTURE_SIZEY);

                            if (resizedImage != null)
                            {
                                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": Extracted picture OK!");
                                retval.ContactImage = resizedImage;
                            }
                        }
                    }
                    else
                    {
                        // now check all my friends...
                        // TODO this might only return first 100 found...
                        // TODO you might want to split it out into A*, B* etc to overcome that
                        foreach (User user in skype.Friends)
                        {
                            handle = Regex.Replace(user.Handle, @"\s", "").ToUpper();
                            phonehome = Regex.Replace(user.PhoneHome, @"\s", "").ToUpper();
                            phonemobile = Regex.Replace(user.PhoneMobile, @"\s", "").ToUpper();
                            phoneoffice = Regex.Replace(user.PhoneOffice, @"\s", "").ToUpper();

                            // EXTRA DEBUG WHEN NEEDED...
                            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": Searching contact: " + user.DisplayName);
                            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": handle: " + handle);
                            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": phonehome: " + phonehome);
                            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": phonemobile: " + phonemobile);
                            m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": phoneoffice: " + phoneoffice);

                            if (handle.Contains(calleridtmp)
                                ||
                                handle.Contains(callerid2tmp)
                                ||
                                phonehome.Contains(calleridtmp)
                                ||
                                phonehome.Contains(callerid2tmp)
                                ||
                                phonemobile.Contains(calleridtmp)
                                ||
                                phonemobile.Contains(callerid2tmp)
                                ||
                                phoneoffice.Contains(calleridtmp)
                                ||
                                phoneoffice.Contains(callerid2tmp))
                            {
                                retval.LastName = "";
                                retval.FirstName = user.FullName;
                                retval.CompanyName = "";
                                retval.errorstate = SmartCRMConnectorErrorState.noerror;
                                gotMatch = true;

                                // lets extract the Skype avatar image...
                                Image tmpImage = ConvertSkypeImage(user.Handle);
                                if (tmpImage != null)
                                {
                                    Image resizedImage = GraphicsUtility.FixedSize(tmpImage, MobileCallForm.PICTURE_SIZEX, MobileCallForm.PICTURE_SIZEY);

                                    if (resizedImage != null)
                                    {
                                        m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": Extracted picture OK!");
                                        retval.ContactImage = resizedImage;
                                    }
                                }
                                break;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName() + ": Exception caught searching Skype\r\n" + e.ToString());
                }

                m_debuglog.DebugPrint(MethodInfo.GetCurrentMethod().Name, GetAppName()+": Got match? = " + gotMatch);
            }
            else
            {
                retval.errorstate = SmartCRMConnectorErrorState.notconnected;
            }
            return retval;
        }

        public static string GetContactPicturePath(string userHandle)
        {
            return GetContactPicturePath(userHandle, System.IO.Path.GetTempPath());
        }

        public static string GetContactPicturePath(string userHandle, string rootedPathFileName)
        {
            string picturePath = "";

            try
            {
                if (!Path.IsPathRooted(rootedPathFileName))
                    throw new ArgumentException("Filename does not contain full path!", "rootedPathFileName");

                picturePath = System.IO.Path.GetDirectoryName(rootedPathFileName) + "\\SkypeContact_" + userHandle + ".jpg";
                if (!System.IO.File.Exists(picturePath))
                {
                    if (!".jpg".Equals(Path.GetExtension(picturePath)))
                        throw new ArgumentException("Filename does not represent jpg file!", "picturePath");

                    SKYPE4COMLib.Command command0 = new SKYPE4COMLib.Command();
                    command0.Command = string.Format("GET USER {0} AVATAR 1 {1}", userHandle, picturePath);
                    SKYPE4COMLib.Skype skype = new SKYPE4COMLib.Skype();
                    skype.SendCommand(command0);
                }
            }
            catch (Exception)
            {
                // snap, we got no picture
                picturePath = "";
            }

            return picturePath;
        }

        public static void CleanupContactPictures()
        {
            CleanupContactPictures(System.IO.Path.GetTempPath());
        }

        public static void CleanupContactPictures(string path)
        {
            foreach (string picturePath in System.IO.Directory.GetFiles(path, "SkypeContact_*.jpg"))
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

        public Image ConvertSkypeImage(string userHandle)
        {
            Bitmap bitmap = null;

            string picturePath = SkypeConnector.GetContactPicturePath(userHandle);

            if (picturePath.Length > 0)
            {
                // new, with Skype, wait experimentally for 100ms intervals until the avater image
                // exists (timeout after 1 second)
                for (int i = 0; i < 10; i++)
                {
                    if (!System.IO.File.Exists(picturePath))
                    {
                        Thread.Sleep(100);
                    }
                    else
                    {
                        // it exists, break out of for loop
                        break;
                    }
                }
            }

            if ((picturePath != "") && (System.IO.File.Exists(picturePath)))
                bitmap = new Bitmap(picturePath);

            return bitmap;
        }
    }
}
