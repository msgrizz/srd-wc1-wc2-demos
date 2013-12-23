using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Plantronics.Innovation.PLTLabsAPI2
{
    /// <summary>
    /// The PLTInfo object abstration is used to pass data back to applications
    /// for the various services that the app can subcribe to.
    /// </summary>
    public class PLTInfo
    {
        /// <summary>
        /// This member holds the service type as PLTService enum value.
        /// </summary>
        public PLTService m_serviceType;

        /// <summary>
        /// This member is a object pointer that can be recast the appropriate
        /// data type depending on the service type.
        /// </summary>
        public object m_data = null;

        /// <summary>
        /// The PLT default constructor
        /// </summary>
        /// <param name="serviceType">PLTService enum value</param>
        /// <param name="data">object pointer to returned data</param>
        public PLTInfo(PLTService serviceType, object data)
        {
            m_serviceType = serviceType;
            m_data = data;
        }
    }
}
