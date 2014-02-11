//
//  BladeRunnerDevice.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 6/13/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef bladerunner_ios_sdk_BladeRunnerDevice_h
#define bladerunner_ios_sdk_BladeRunnerDevice_h

#include <set>
#include <vector>
#include <mutex>
#include <map>
#include <unordered_map>
#include "CommonTypes.h"
#include "BRError.h"
#include "PacketType.h"
#include "ProtocolRange.h"
#include "DeviceCommandType.h"
#include "DeviceEventType.h"
#include "DeviceSettingType.h"
#include "DeviceEvent.h"
#include "DeviceCommand.h"
#include "DeviceSetting.h"
#include "BRProtocolElement.h"
#include "SignatureDescription.h"
#include "BlockingQueue.h"

namespace bladerunner
{
    class DeviceOpenListener;
    class DeviceSessionListener;
    class DeviceMetadataListener;
    class DeviceEventListener;
    class DeviceListener;
    class MetadataPacket;
    class EventPacket;
    class InputPacket;

    typedef std::shared_ptr<BladeRunnerDevice> BladeRunnerDevicePtr;
    typedef std::shared_ptr<InputPacket> InputPacketPtr;

    class BladeRunnerDevice
    {

    public:
        ProtocolRange getProtocolRange() { return mProtocolRange; }
        void setProtocolRange(byte minVersion, byte maxVersion);
        ProtocolRange getDeviceProtocolRange() { return mDeviceProtocolRange; }
        void setDeviceProtocolRange(byte minVersion, byte maxVersion);
        bool determineProtocolVersionToUse(ProtocolRange deviceRange);
        void setConnectionPacketType(PacketType packetType) { mPacketType = packetType; }
        PacketType getConnectionPacketType() { return mPacketType; }
        void setDeviceMetadata(MetadataPacket& metadata);

        virtual std::string& getBladeRunnerDeviceAddress() = 0;
        virtual BRError open(byte& port) = 0;
        virtual BRError open(PacketType packetType, byte& port) = 0;
        virtual BRError close() = 0;
        virtual bool isOpen();
        virtual BRError checkOpen();
        virtual bool checkRemotePortExist(byte port);
        virtual bool checkRemoteConnectedPortExist(byte port);
        virtual void addPort(byte port);
        virtual BRError removePort(byte port);
        virtual void addPortMapping(byte port, BladeRunnerDevicePtr device);
        virtual BRError getPortMappedDevice(byte port, BladeRunnerDevice* device);
        virtual std::set<byte>& getConnectedPorts() { return mRemoteConnectedPorts; }
        virtual void addResponseQueuePortMapping(byte port, BlockingQueue<InputPacketPtr>* queue);
        virtual void* getDeviceSession() = 0;

        virtual BRError registerExceptionSignatures(std::set<SignatureDescription>& signatures);
        virtual BRError registerSettingInputSignatures(std::set<SignatureDescription>& signatures);
        virtual BRError registerSettingOutputSignatures(std::set<SignatureDescription>& signatures);
        virtual BRError registerEventSignatures(std::set<SignatureDescription>& signatures);

        virtual BRError addOpenListener(DeviceOpenListener* openListener);
        virtual void removeOpenListener(DeviceOpenListener* openListener);
        virtual BRError addSessionListener(DeviceSessionListener* sessionListener);
        virtual void removeSessionListener(DeviceSessionListener* sessionListener);
        virtual BRError addMetadataListener(DeviceMetadataListener* metadataListener);
        virtual void removeMetadataListener(DeviceMetadataListener* metadataListener);
        virtual BRError addEventListener(DeviceEventListener* eventListener);
        virtual void removeEventListener(DeviceEventListener* eventListener);
        
        virtual BRError getSupportedEvents(std::set<DeviceEventType>& values);
        virtual BRError getEventType(int16_t id, DeviceEventType& type);
        virtual BRError getSupportedCommands(std::set<DeviceCommandType>& values);
        virtual BRError getCommandType(int16_t id, DeviceCommandType& type);
        virtual DeviceCommand* getCommand(const DeviceCommandType& type);
        virtual BRError getSupportedSettings(std::set<DeviceSettingType>& values);
        virtual BRError getSettingType(int16_t id, DeviceSettingType& type);
        virtual DeviceSetting* getSetting(const DeviceSettingType& type);

        virtual void notifyOpen(BRError error);
        virtual void notifyMetadata();
        virtual void notifyEvent(EventPacket& packet);
        virtual void notifySessionClose(BRError error);

        virtual BRError perform(DeviceCommand& command, std::vector<BRProtocolElement> args) = 0;
        virtual BRError fetch(DeviceSetting& setting) = 0;
        virtual bool discoverBladeRunnerDevices(DeviceListener* listener) = 0;
        virtual std::set<BladeRunnerDevice*> getBladeRunnerDevices() = 0;
        virtual int hashCode() = 0;


    protected:
        BladeRunnerDevice();
        int protocolVersionToUse(ProtocolRange deviceRange, ProtocolRange host);
        void notifyDeviceOpen();
        void notifyOpenFailed(BRError error);


        static std::recursive_mutex sLock;
        ProtocolRange mProtocolRange;
        ProtocolRange mDeviceProtocolRange;
        PacketType mPacketType;
        bool mOpen;

        std::set<DeviceOpenListener*> mOpenListeners;
        std::set<DeviceSessionListener*> mSessionListeners;
        std::set<DeviceMetadataListener*> mMetadataListeners;
        std::set<DeviceEventListener*> mEventListeners;

        std::unordered_map<int16_t, DeviceEventType> mEventTypeMap;
        std::unordered_map<int16_t, DeviceSettingType> mSettingTypeMap;
        std::unordered_map<int16_t, DeviceCommandType> mCommandTypeMap;

        std::unordered_map<int16_t, std::vector<BRType>> mEventIdToOutputSignatureMap;
        std::unordered_map<int16_t, std::vector<BRType>> mSettingIdToInputSignatureMap;
        std::unordered_map<int16_t, std::vector<BRType>> mSettingIdToOutputSignatureMap;
        std::unordered_map<int16_t, std::vector<BRType>> mExceptionIdToOutputSignatureMap;

        std::set<byte> mRemoteAvailablePorts;
        std::set<byte> mRemoteConnectedPorts;
        std::map<byte, BladeRunnerDevicePtr> mRemotePortSessions;
        std::map<byte, BlockingQueue<InputPacketPtr>*> mRemoteResponseQueues;
    };
}

#endif
