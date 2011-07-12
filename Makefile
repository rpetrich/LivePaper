TWEAK_NAME = LivePaper
LivePaper_FILES = Tweak.xm
LivePaper_FRAMEWORKS = UIKit

BUNDLE_NAME = Fader
Fader_FILES = Fader.m
Fader_FRAMEWORKS = UIKit QuartzCore
Fader_INSTALL_PATH = /Library/LivePaper/Plugins

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.0

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
include framework/makefiles/bundle.mk
