#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Exposes Analytics IDs for first-party use.
@interface APMIdentifiers : NSObject

/// Returns the sharedInstance.
+ (APMIdentifiers *)sharedInstance;

/// The Google App ID.
@property(nonatomic, readonly, copy) NSString *googleAppID;

/// The App ID that is driving AppMeasurement. Returns the Google App ID in case of Firebase or
/// the AdMob App ID in case of AdMob+ only.
@property(nonatomic, readonly, copy) NSString *analyticsAppID;

/// The app instance ID.
@property(nonatomic, readonly, copy) NSString *appInstanceID;

/// A random event ID as a string. The event ID is a 64-bit integer. The ID is not stored by
/// Analytics and must be explicitly passed to any event that needs it.
@property(nonatomic, readonly, copy) NSString *adEventID;

/// The Analytics library version.
@property(nonatomic, readonly, copy) NSString *libraryVersion;

/// The string that represents the component that starts App Measurement.
@property(nonatomic, readonly, copy) NSString *origin;

@end

NS_ASSUME_NONNULL_END
