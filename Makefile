TARGET = iOS
ARCHS := arm64
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = RebootTools

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = RebootTools

RebootTools_FILES = AppDelegate.swift RootViewController.swift SettingsViewController.swift DeviceController.m PlistManagerUtils.swift SettingsUtils.swift
RebootTools_FRAMEWORKS = UIKit CoreGraphics
RebootTools_RESOURCES = Resources/Assets.xcassets
$(APPLICATION_NAME)_SWIFT_BRIDGING_HEADER += $(APPLICATION_NAME)-Bridging-Header.h
include $(THEOS_MAKE_PATH)/application.mk

$(APPLICATION_NAME)_CODESIGN_FLAGS = -Sentitlements.plist

# SUBPROJECTS += RebootRootHelper
include $(THEOS_MAKE_PATH)/aggregate.mk

after-package::
	@echo "Renaming .ipa to .tipa..."
	@mv ./packages/com.developlab.RebootTools_1.1.ipa ./packages/com.developlab.RebootTools_1.1.tipa || echo "No .ipa file found."
