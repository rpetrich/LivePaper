#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <Preferences/Preferences.h>

static const char *LivePaperKey = "LivePaperKey";
static CFMutableSetRef liveWallpaperViews;
static Class livePaperClass;

static inline UIView *GetLivePaperView(SBWallpaperView *wallpaperView)
{
	return objc_getAssociatedObject(wallpaperView, (void *)LivePaperKey);
}

static inline void SetLivePaperView(SBWallpaperView *wallpaperView, UIView *value)
{
	objc_setAssociatedObject(wallpaperView, (void *)LivePaperKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static inline UIView *CreateLivePaperView(SBWallpaperView *wallpaperView)
{
	UIView *livePaperView = [[[livePaperClass alloc] initWithFrame:wallpaperView.bounds] autorelease];
	if (![livePaperView isKindOfClass:[UIView class]])
		return nil;
	livePaperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[wallpaperView addSubview:livePaperView];
	SetLivePaperView(wallpaperView, livePaperView);
	return livePaperView;
}

static void LoadLivePaperClass()
{
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.collab.livepaper.plist"];
	NSString *bundlePath = [NSString stringWithFormat:@"/Library/LivePaper/Plugins/%@.bundle", [settings objectForKey:@"LPActivePlugin"]];
	NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
	[bundle load];
	livePaperClass = NSClassFromString([bundle objectForInfoDictionaryKey:@"LPViewClass"]);
}

%hook SBWallpaperView

- (void)didMoveToWindow
{
	%orig;
	UIView *livePaperView = GetLivePaperView(self);
	if (self.window) {
		CFSetAddValue(liveWallpaperViews, self);
		if (livePaperView) {
			livePaperView.frame = self.bounds;
			[self addSubview:livePaperView];
		} else {
			CreateLivePaperView(self);
		}
	} else {
		[livePaperView removeFromSuperview];
	}
}

- (void)dealloc
{
	CFSetRemoveValue(liveWallpaperViews, self);
	%orig;
}

%end

static void DidReceiveMemoryWarning(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	for (SBWallpaperView *wallpaperView in (NSSet *)liveWallpaperViews) {
		if (!wallpaperView.window) {
			[GetLivePaperView(wallpaperView) removeFromSuperview];
			SetLivePaperView(wallpaperView, nil);
		}
	}
}

static void DidChangeSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	LoadLivePaperClass();
	for (SBWallpaperView *wallpaperView in (NSSet *)liveWallpaperViews) {
		[GetLivePaperView(wallpaperView) removeFromSuperview];
		if (wallpaperView.window)
			CreateLivePaperView(wallpaperView);
		else
			SetLivePaperView(wallpaperView, nil);
	}
}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	liveWallpaperViews = CFSetCreateMutable(kCFAllocatorDefault, 0, NULL);
	LoadLivePaperClass();
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &DidReceiveMemoryWarning, (CFStringRef)UIApplicationDidReceiveMemoryWarningNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &DidChangeSettings, CFSTR("com.collab.livepaper/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	%init;
	[pool drain];
}
