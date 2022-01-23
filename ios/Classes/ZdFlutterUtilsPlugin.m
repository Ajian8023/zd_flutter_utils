#import "ZdFlutterUtilsPlugin.h"
#if __has_include(<zd_flutter_utils/zd_flutter_utils-Swift.h>)
#import <zd_flutter_utils/zd_flutter_utils-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "zd_flutter_utils-Swift.h"
#endif

@implementation ZdFlutterUtilsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftZdFlutterUtilsPlugin registerWithRegistrar:registrar];
}
@end
