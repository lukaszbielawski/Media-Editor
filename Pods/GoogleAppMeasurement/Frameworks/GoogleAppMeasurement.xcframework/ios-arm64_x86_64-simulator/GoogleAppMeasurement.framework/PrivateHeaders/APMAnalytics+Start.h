#import "APMAnalytics.h"

/// Exposes API to start App Measurement for 1st party SDKs.
@interface APMAnalytics (Start)

/// Starts App Measurement. This must be called before any other App Measurement methods.
///
/// @param appID The app ID, such as Google App ID or AdMob App ID.
/// @param origin The string that represents which component starts App Measurement.
/// @param options The dictionary of options to configure Analytics.
+ (void)startWithAppID:(nonnull NSString *)appID
                origin:(nonnull NSString *)origin
               options:(nullable NSDictionary<NSString *, id> *)options;

@end
