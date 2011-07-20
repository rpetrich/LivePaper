#import <Preferences/Preferences.h>
#import <CaptainHook/CaptainHook.h>

#define kPluginPath @"/Library/LivePaper/Plugins"

@interface LivePaperSettingsController : PSListController
@end

@implementation LivePaperSettingsController

- (NSArray *)specifiers
{
	if (!_specifiers) {
		// Load specifiers
		NSMutableArray *specifiers = [[super specifiers] mutableCopy];
		// Load Plugins
		NSInteger groupIndex = [self indexOfSpecifierID:@"PluginsGroup"];
		NSInteger index = groupIndex;
		for (NSString *path in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kPluginPath error:NULL]) {
			if (![path hasPrefix:@"."] && [path hasSuffix:@".bundle"]) {
				NSString *bundlePath = [kPluginPath stringByAppendingPathComponent:path];
				if ([[NSBundle bundleWithPath:bundlePath] objectForInfoDictionaryKey:@"NSPrincipalClass"]) {
					index++;
					PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:[path stringByDeletingPathExtension] target:self set:NULL get:NULL detail:Nil cell:PSLinkCell edit:Nil];
					CHIvar(specifier, action, SEL) = @selector(lazyLoadBundle:);
					[specifier setProperty:bundlePath forKey:@"lazy-bundle"];
					[specifiers insertObject:specifier atIndex:index];
				}
			}
		}
		// If have no configurable plugins, remove plugin settings
		if (groupIndex == index) {
			[specifiers removeObjectAtIndex:index];
		}
		[_specifiers release];
		_specifiers = specifiers;
	}
	return _specifiers;
}

@end

@implementation NSObject (LivePaper)

- (NSArray *)livePaperBundleNames
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	[array addObject:@"(none)"];
	for (NSString *path in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/LivePaper/Plugins" error:NULL]) {
		if (![path hasPrefix:@"."] && [path hasSuffix:@".bundle"]) {
			[array addObject:[path stringByDeletingPathExtension]];
		}
	}
	NSArray *result = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	[array release];
	return result;
}

@end
