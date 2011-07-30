TWEAK_NAME = LivePaper
BUNDLE_NAME = LivePaperSettings Fader MosaicPaper

LivePaper_FILES = Tweak.xm
LivePaper_FRAMEWORKS = UIKit

LivePaperSettings_FILES = Prefs.m
LivePaperSettings_PRIVATE_FRAMEWORKS = Preferences
LivePaperSettings_INSTALL_PATH = /Library/PreferenceBundles

Fader_FILES = Fader.m
Fader_FRAMEWORKS = UIKit QuartzCore
Fader_INSTALL_PATH = /Library/LivePaper/Plugins

MosaicPaper_FILES = Mosaic.m MosaicPrefs.m
MosaicPaper_FRAMEWORKS = UIKit QuartzCore CoreGraphics
MosaicPaper_PRIVATE_FRAMEWORKS = Preferences
MosaicPaper_INSTALL_PATH = /Library/LivePaper/Plugins

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.0

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
include framework/makefiles/bundle.mk
