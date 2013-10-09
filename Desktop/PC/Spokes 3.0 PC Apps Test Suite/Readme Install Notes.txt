Spokes 3.0 test suite - Readme Install Notes
Lewis Collins, 20th Sept 2013

The Spokes 3.0 software included is a recent nightly.

If you want a newer nightly, take latest from here (always choose 
Release installer, i.e. under Installers\bin\Release):
\\USSCFS02\Groups\Engineering\Software\Shared\Archive\SPOKES3Gclient-main

Or latest beta from here (always choose 
Release installer, i.e. under Installers\bin\Release):
\\USSCFS02\Groups\Engineering\Software\Shared\Archive\SPOKES3Gclient-3.0.0-Beta


Screen shot: Spokes 3.0 Test Suite.png

Install in this order:
- PlantronicsSpokesSDKInstaller.exe
- PlantronicsSpokesInstaller.exe
- PlantronicsSpokesLyncInstaller.exe
- HeadTrackingDiagnostics v1.0.0.1 Installer.zip (requires Concept 1 headset from Innovation team)
- SmartLock for Spokes 3.0 v1.5.0.0.zip
- Spokes Easy Demo for Spokes 3.0.zip

Known issues:
- SmartLock for Spokes 3.0 has known issue - after start window you need to exit and restart 
SmartLock to get it to connect to Spokes
- Exitting Easy Demo and HeadTracking Diagnostics triggers SmartLock to lock screen
- If you get head tracking angles creeping
  turn off headset - then turn on, place on desk and keep still, until Sensor tab 
  of headtracking diagnostics shows Calibrated = Yes (and then wait tiny bit longer til angles
  stop changing).
- If your login to myanywear.com doesn't work (because it was for old alpha server), 
  I found it convenient to use my google login. May also be possible to create a new login.
- Finally if you get any failures of these demos, try killing PLTSpokes.exe from Task Manager
  Then re-run Spokes from Start > All Programs > Plantronics > Plantronics Spokes