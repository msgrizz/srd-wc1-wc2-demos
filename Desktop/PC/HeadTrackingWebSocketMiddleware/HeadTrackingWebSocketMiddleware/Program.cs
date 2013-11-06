using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

/*******
 * 
 * HeadTrackingWebSocketMiddleware
 * 
 * A command line app offering a websocket for JavaScript apps to 
 * connect to and receive head tracking angles on PC.
 * 
 * Lewis Collins, http://developer.plantronics.com/people/lcollins/
 * 
 * VERSION HISTORY:
 * ********************************************************************************
 * Version 1.0.0.1:
 * Date: 1st November 2013
 * Changed by: Lewis Collins
 * Changes:
 *   - Updated project to remove local copy of PLTLabsAPI.dll
 *     (user should obtain and deploy the DLL from single location on PDC)
 *   - Change target .NET framework from 4.5 to 4
 *
 * Version 1.0.0.0:
 * Date: 
 * Changed by: Lewis Collins
 *   Initial version.
 * ********************************************************************************
 *
 **/

namespace HeadTrackingWebSocketMiddleware
{
    class Program
    {
        private static SpokesIntegration spokesint;
        static void Main(string[] args)
        {
            System.Console.WriteLine("Head tracking web socket middleware starting...");

            spokesint = new SpokesIntegration();

            System.Console.WriteLine("Press enter to quit...");
            string text = System.Console.ReadLine();

            spokesint.ShutDown();
            System.Console.WriteLine("Bye bye");
        }
    }
}
