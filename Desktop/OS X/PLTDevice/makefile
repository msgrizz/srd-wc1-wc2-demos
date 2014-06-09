XBUILD=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
PROJECT_ROOT=.
PROJECT=$(PROJECT_ROOT)/PLTDevice.xcodeproj
TARGET_OSX=PLTDevice_OSX
TARGET_IOS=PLTDevice_iOS
PRODUCT_NAME=PLTDevice
BUILD=$(PROJECT_ROOT)/build
BUILD_OSX=$(BUILD)/osx
BUILD_IOS=$(BUILD)/ios
WORKING_IOS=$(BUILD)/Release-iphoneos

all: osx ios

#libi386.a:
#	$(XBUILD) -project $(PROJECT) -target $(TARGET_IOS) -sdk iphonesimulator -configuration Release clean build
#	-mv $(PROJECT_ROOT)/build/Release-iphonesimulator/lib$(PRODUCT_NAME).a $(BUILD_IOS)/$@

ios_armv7.a:
	$(XBUILD) -project $(PROJECT) -target $(TARGET_IOS) -sdk iphoneos -arch armv7 -configuration Release clean build
	-mv $(WORKING_IOS)/lib$(PRODUCT_NAME).a $(WORKING_IOS)/$@

ios_armv7s.a:
	$(XBUILD) -project $(PROJECT) -target $(TARGET_IOS) -sdk iphoneos -arch armv7s -configuration Release clean build
	-mv $(WORKING_IOS)/lib$(PRODUCT_NAME).a $(WORKING_IOS)/$@

ios_arm64.a:
	$(XBUILD) -project $(PROJECT) -target $(TARGET_IOS) -sdk iphoneos -arch arm64 -configuration Release clean build
	-mv $(WORKING_IOS)/lib$(PRODUCT_NAME).a $(WORKING_IOS)/$@

ios_headers:
	mkdir -p $(BUILD_IOS)/$(PRODUCT_NAME)/
	-mv $(WORKING_IOS)/usr/local/include $(BUILD_IOS)/$(PRODUCT_NAME)/

osx_64:
	mkdir -p $(BUILD_OSX)
	$(XBUILD) -project $(PROJECT) -target $(TARGET_OSX) -sdk macosx -arch x86_64 -configuration Release clean build
	-mv $(BUILD)/Release/$(PRODUCT_NAME).framework $(BUILD_OSX)/
	-mv $(BUILD)/Release/$(PRODUCT_NAME).framework.dSYM $(BUILD_OSX)/

ios_all: ios_armv7.a ios_armv7s.a ios_arm64.a ios_headers
	mkdir -p $(BUILD_IOS)/$(PRODUCT_NAME)/lib
	lipo -create -output $(BUILD_IOS)/$(PRODUCT_NAME)/lib/lib$(PRODUCT_NAME).a $(WORKING_IOS)/ios_armv7.a $(WORKING_IOS)/ios_armv7s.a $(WORKING_IOS)/ios_arm64.a

osx_all: osx_64

osx: osx_all clean_osx

ios: ios_all clean_ios

clean_osx:
	-rm -rf $(BUILD)/PLTDevice.build
	rm -rf $(BUILD)/Release

clean_ios:
	-rm -rf $(BUILD)/PLTDevice.build
	-rm -rf $(BUILD)/Release-iphoneos
	-rm -rf $(BUILD_IOS)/libarmv7.a
	-rm -rf $(BUILD_IOS)/libarmv7s.a
	-rm -rf $(BUILD_IOS)/libarm64.a

clean: clean_osx clean_ios

cleanAll: clean
	-rm -rf $(BUILD)