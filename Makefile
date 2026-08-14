TARGET := iphone:clang:16.5:17.0
ARCHS := arm64
INSTALL_TARGET_PROCESSES := pkd

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := CranePKDServerFix

CranePKDServerFix_FILES := CranePKDServerFix.xm
CranePKDServerFix_CFLAGS := -fobjc-arc -Wall -Wextra -Werror
CranePKDServerFix_FRAMEWORKS := Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
