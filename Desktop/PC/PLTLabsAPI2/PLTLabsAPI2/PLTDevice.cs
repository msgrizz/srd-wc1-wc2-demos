using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Plantronics.Innovation.BRLibrary;

namespace Plantronics.Innovation.PLTLabsAPI2
{
    /// <summary>
    /// The PLTDevice object abstraction describes a device object
    /// that is available for connecting to with the PLTLabsAPI
    /// and ultimately subscribing for its services once the connection
    /// is established.
    /// </summary>
    public class PLTDevice
    {
        /// <summary>
        /// The Product Name of the device
        /// </summary>
        public string m_ProductName = "";
        private HIDDevice m_HIDDevice;

        // NOTE: commenting out below, because this is not currently available in
        // Spokes 3.0 SDK / Spokes Wrapper
        ///// <summary>
        ///// The product base serial number
        ///// </summary>
        //public string m_ProductBaseSerial = "";
        ///// <summary>
        ///// The product headset serial number
        ///// </summary>
        //public string m_ProductHeadsetSerial = "";

        public PLTDevice(HIDDevice aDevice)
        {
            m_ProductName = "";
            m_HIDDevice = aDevice;
        }
    }
}
