TARGET = iOS
ARCHS := arm64
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = RebootTools

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = RebootTools

RebootTools_FILES = AppDelegate.swift RootViewController.swift
RebootTools_FRAMEWORKS = UIKit CoreGraphics
RebootTools_RESOURCES = Resources/Assets.xcassets

include $(THEOS_MAKE_PATH)/application.mk

$(APPLICATION_NAME)_CODESIGN_FLAGS = -Sentitlements.plist

SUBPROJECTS += RebootRootHelper
include $(THEOS_MAKE_PATH)/aggregate.mk

after-package::
	@echo "Renaming .ipa to .tipa..."
	@mv ./packages/com.developlab.RebootTools_1.0.ipa ./packages/com.developlab.RebootTools_1.0.tipa || echo "No .ipa file found."
