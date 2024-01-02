#import "ShareLinkPlugin.h"
#if __has_include(<share_link/share_link-Swift.h>)
#import <share_link/share_link-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "share_link-Swift.h"
#endif

@implementation ShareLinkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftShareLinkPlugin registerWithRegistrar:registrar];
}
@end
