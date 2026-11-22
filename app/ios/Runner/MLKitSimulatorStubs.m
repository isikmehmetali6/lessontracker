// iOS simülatörü için ML Kit plugin yedekleri.
//
// Google ML Kit'in hazır framework'lerinde arm64-simülatör dilimi yok; iOS 26
// simülatörleri ise yalnızca arm64 çalıştırıyor. Podfile simülatör derlemesinde
// ML Kit framework'lerini bağlamıyor ve plugin kaynaklarını derlemiyor; bu
// dosya GeneratedPluginRegistrant'ın beklediği sınıfları sağlar ve OCR
// çağrılarına `UNAVAILABLE` hatası döner. Gerçek cihaz derlemesinde boştur.
#import <TargetConditionals.h>

#if TARGET_OS_SIMULATOR

#import <Flutter/Flutter.h>

static void LTRegisterUnavailableChannel(NSString *name,
                                         NSObject<FlutterPluginRegistrar> *registrar) {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:name
                                  binaryMessenger:[registrar messenger]];
  [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    result([FlutterError errorWithCode:@"UNAVAILABLE"
                               message:@"ML Kit is not available on the iOS simulator"
                               details:nil]);
  }];
}

@interface GoogleMlKitCommonsPlugin : NSObject <FlutterPlugin>
@end

@implementation GoogleMlKitCommonsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  LTRegisterUnavailableChannel(@"google_mlkit_commons", registrar);
}
@end

@interface GoogleMlKitTextRecognitionPlugin : NSObject <FlutterPlugin>
@end

@implementation GoogleMlKitTextRecognitionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  LTRegisterUnavailableChannel(@"google_mlkit_text_recognizer", registrar);
}
@end

#endif
