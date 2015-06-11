#Author: Jiri Hanousek (jiri.hanousek[at]mactechcity.cz)

import socket
import select
import threading
import json

#minor fix by Lewis spring 2015
#USAGE: don't forget to update the Hard-coded master anchor DNS below
#starting with 10.64... etc. You can find it out by using rtls-manager

class SvcClient:

    def __init__(self):
        self.svcSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # self.svcSocket.connect(("10.64.10.76", 8784))        
        self.svcSocket.connect(("10.64.10.56", 8784))
        self.svcSocket.setblocking(0)

    def request(self, jsonStr, timeout = 20):
        try:
            msgToSend = jsonStr.encode(encoding = "utf-8");
            bytesSent = 0
            while bytesSent < len(msgToSend):
                bytesSent += self.svcSocket.send(msgToSend[bytesSent:])

            recvMessage = ""
            while True:
                ready = select.select([self.svcSocket], [], [], timeout)
                if ready[0]:
                    recvMessage += self.svcSocket.recv(1024 * 1024).decode(encoding = "utf-8")
                    if "\n" in recvMessage: #Complete message ends with \n
                        break
                else:
                    #timeout...
                    break
                
        except Exception as e:
            print(e)
            #handle exceptions...

        if not "\n" in recvMessage:
            print("SVC: Empty or partial message received: {0}".format(recvMessage))
            return None
        else:
            print("SVC: Complete message received: {0}".format(recvMessage))
            return recvMessage

    def close(self):
        self.svcSocket.close()

        
print("RTLS example start.\n")

svcClient = SvcClient()
listener = svcClient.request('{"command":"getLsListener"}')

print("DEBUGLEW",listener)

lsAddress = json.loads(listener)
print("DEBUGLEW",lsAddress)
if lsAddress["mode"]=="unicast":
    print("Received LS listener: {0}\n".format(lsAddress["mode"]))

    lsSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    lsSocket.bind((lsAddress["ip"], 8787))
    lsSocket.setblocking(0)

    try:
        while True:
            ready = select.select([lsSocket], [], [], 1)
            if ready[0]:
                recvData = lsSocket.recv(16384)

                if len(recvData) != 0:
                    recv = recvData[0:len(recvData)].decode("utf-8")
                    print("LS: Received: " + recv)

                else:
                    print("LS: Received empty")
            
            else:
                print("LS: No data, timeout")
    except Exception as e:
        print(e)
        #handle exceptions...
        svcClient.close()  
    
else:
    print("No listener received")
    svcClient.close()

