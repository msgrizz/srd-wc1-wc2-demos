XBUILD=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
PROJECT_ROOT=.
PROJECT=$(PROJECT_ROOT)/PLTDevice.xcodeproj

TARGET_OSX=PLTDevice_OSX
TARGET_IOS=PLTDevice_iOS

BUILD=$(PROJECT_ROOT)/build

PRODUCT_NAME_OSX=PLTDevice_OSX.framework
PRODUCT_NAME_IOS=PLTDevice_iOS.framework

BIN_OSX=$(TARGET_OSX)
BIN_IOS=$(TARGET_IOS)

XC_BUILD_OSX=$(BUILD)/Release
XC_BUILD_IOS_DEVICE=$(BUILD)/Release-iphoneos
XC_BUILD_IOS_SIMULATOR=$(BUILD)/Release-iphonesimulator

XC_PRODUCT_OSX=$(XC_BUILD_OSX)/$(PRODUCT_NAME_OSX)
XC_PRODUCT_IOS_DEVICE=$(XC_BUILD_IOS_DEVICE)/$(PRODUCT_NAME_IOS)
XC_PRODUCT_IOS_SIMULATOR=$(XC_BUILD_IOS_SIMULATOR)/$(PRODUCT_NAME_IOS)

TEMP=$(BUILD)/temp

all: osx ios

osx_64:
	$(XBUILD) -project $(PROJECT) -target $(TARGET_OSX) -sdk macosx -arch x86_64 -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO clean build
	-mv -f $(XC_PRODUCT_OSX) $(BUILD)/$(PRODUCT_NAME_OSX)/
	-rm -rf $(XC_BUILD_OSX)

ios_i386:
	$(XBUILD) -project $(PROJECT) -target $(TARGET_IOS) -sdk iphonesimulator -arch i386 -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO clean build
	-mv -f $(XC_PRODUCT_IOS_SIMULATOR) $(TEMP)/$(PRODUCT_NAME_IOS).i386
	-rm -rf $(XC_BUILD_IOS_SIMULATOR)

ios_armv7:
	$(XBUILD) -project $(PROJECT) -target $(TARGET_IOS) -sdk iphoneos -arch armv7 -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO clean build
	-mv -f $(XC_PRODUCT_IOS_DEVICE) $(TEMP)/$(PRODUCT_NAME_IOS).armv7
	-rm -rf $(XC_BUILD_IOS_DEVICE)

ios_armv7s:
	$(XBUILD) -project $(PROJECT) -target $(TARGET_IOS) -sdk iphoneos -arch armv7s -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO clean build
	-mv -f $(XC_PRODUCT_IOS_DEVICE) $(TEMP)/$(PRODUCT_NAME_IOS).armv7s
	-rm -rf $(XC_BUILD_IOS_DEVICE)

ios_arm64:
	$(XBUILD) -project $(PROJECT) -target $(TARGET_IOS) -sdk iphoneos -arch arm64 -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO clean build
	-mv -f $(XC_PRODUCT_IOS_DEVICE) $(TEMP)/$(PRODUCT_NAME_IOS).arm64
	-rm -rf $(XC_BUILD_IOS_DEVICE)

ios_combine:
	# start with arm64 as a template
	-cp -r $(TEMP)/$(PRODUCT_NAME_IOS).arm64 $(BUILD)/$(PRODUCT_NAME_IOS)
	# remove binary
	-rm $(BUILD)/$(PRODUCT_NAME_IOS)/$(BIN_IOS)
	# create fat binary with lipo
	lipo -create -output $(BUILD)/$(PRODUCT_NAME_IOS)/$(BIN_IOS) $(TEMP)/$(PRODUCT_NAME_IOS).i386/$(BIN_IOS) $(TEMP)/$(PRODUCT_NAME_IOS).armv7/$(BIN_IOS) $(TEMP)/$(PRODUCT_NAME_IOS).armv7s/$(BIN_IOS) $(TEMP)/$(PRODUCT_NAME_IOS).arm64/$(BIN_IOS)

setup:
	mkdir -p $(TEMP)

osx: setup osx_64 clean

ios: setup ios_i386 ios_armv7 ios_armv7s ios_arm64 ios_combine clean

clean:
	-rm -rf $(BUILD)/PLTDevice.build
	-rm -rf $(XC_BUILD_OSX)
	-rm -rf $(XC_BUILD_IOS_DEVICE)
	-rm -rf $(XC_BUILD_IOS_SIMULATOR)
	-rm -rf $(TEMP)
