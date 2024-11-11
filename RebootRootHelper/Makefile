TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = RebootRootHelper

RebootRootHelper_FILES = main.m
RebootRootHelper_CFLAGS = -fobjc-arc
RebootRootHelper_CODESIGN_FLAGS = -Sentitlements.plist
RebootRootHelper_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
