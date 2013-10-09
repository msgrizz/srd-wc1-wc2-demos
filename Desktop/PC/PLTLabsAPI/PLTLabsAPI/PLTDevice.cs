using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Interop.Plantronics;

namespace Plantronics.Innovation.PLTLabsAPI
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

        public PLTDevice(ICOMDevice aDevice)
        {
            m_ProductName = aDevice.ProductName;
        }
    }
}
