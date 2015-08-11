 * OfficeAutomationServer - OAS
 * 
 * This server program Office Automation Server OAS is the key
 * component of the Plantronics Decawave solution.
 * The server itself connects to a master OpenRTLS Decawave node
 * to receive updates of tag positions (id, x, y, z).
 * OAS will also connect to a database (e.g. MySQL) to manage
 * persistent storage of the entities described in the specification:
 * "Maruader TAG Use cases_draft_1.docx".
 *
 * Usage:
 *    OfficeAutomationServer.exe <master node ip> <master node port> [<debugon|testmode>]
 * 
 * Example #1:
 *    OfficeAutomationServer.exe 10.64.10.56 8784 debugon
 * This starts the OAS looking at master node on 10.64.10.56 port 8784
 * with debug on (meaning more console debug output on server).
 * OAS will be listening for inbound connections from Marauder Map clients
 * on all the OAS machine's network interfaces on port 9050.
 * (You can also test this using telnet oas 9050)
 * (note, requires oas is a dns lookup to the actual IP address of the OAS machine)
 *
 * Example #2:
 *    OfficeAutomationServer.exe 10.64.10.56 8784 testmode
 * This starts the OAS in testmode - this will simulate 3 tags in the system
 * and will not actually connect to OpenRTLS master node at all (the 10.64.10.56 and 
 * 8784 parameters are ignored).
 * OAS will be listening for inbound connections from Marauder Map clients
 * on all the OAS machine's network interfaces on port 9050.
 * (You can also test this using telnet oas 9050)
 * (note, requires oas is a dns lookup to the actual IP address of the OAS machine)
 *
 * Lewis Collins, 11th August 2015