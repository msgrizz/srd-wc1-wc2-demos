/*******
 * 
 * Head Tracking Diagnostics
 * 
 * A headtracking diagnostic demo app created for the Plantronics innovation
 * Concept 1 product for use with http://pltlabs.com/
 * 
 * This application shows the following:
 * 
 *   - An app that integrates support for Plantronics innovation head tracking
 *     
 *   - Displays headtracking sensor status and diagnostic info
 *   
 *   - Ability to Calibrate headtracking (zero the angles)
 *   
 *   - Show the headtracking with an animated skull! (halloween version pending!)
 *   
 *   - Edit and recognise a variety of head movements and assign these to
 *     certain PC actions such as Minimise all windows, restore all windows,
 *     Lock PC, Suspend PC, Hibernate PC
 *   
 * PRE-REQUISITES for building this demo app:
 *  - Plantronics Spokes 3.0 Client or SDK - install PlantronicsSpokesInstaller.exe or PlantronicsSpokesSDKInstaller.exe
 *  - Microsoft Visual Studio 2013 Preview - obtain from http://www.microsoft.com/
 *
 * PRE-REQUISITES for testing this demo app: 
 *  - Current pre-release head-tracking headset with appropriate firmware pre-loaded
 * 
 * INSTRUCTIONS FOR USE
 * 
 *   - If you put headset on and leave it still on the desk.
 *     Watch the Sensors tab until is says Calibrated - BUT leave headset
 *     a bit longer until angles stop creeping.
 *   - Now put headset on and look at center of screen, after 2 second delay the
 *     head tracking will "auto-calibrate" to 0 degrees heading/pitch/roll.
 *     
 *   - From that point on your head movements will control the Skull avatar
 *     in the Skull Tab, and also gestures specified in the Gestures tab
 *     will be recognised.
 *     
 *   - Gestures are loaded and saved automatically to a file called
 *     Gestures.txt
 *     
 * Lewis Collins
 * 
 * VERSION HISTORY:
 * ********************************************************************************
 * Version 1.0.0.0:
 * Date: 23rd August 2013
 * Changed by: Lewis Collins
 * Changes:
 *   - Initial version.
 * ********************************************************************************
 *
 **/