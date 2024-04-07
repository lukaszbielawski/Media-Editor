#import <Foundation/Foundation.h>

#import "googlemac/iPhone/Firebase/Analytics/AppMeasurement/Public/APMAnalytics.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *APMConsentType NS_TYPED_ENUM;
typedef NSString *APMConsentStatus NS_TYPED_ENUM;

/// Key @c ad_storage.
extern APMConsentType const APMConsentTypeAdStorage;

/// Key @c analytics_storage.
extern APMConsentType const APMConsentTypeAnalyticsStorage;

/// Key @c ad_user_data.
extern APMConsentType const APMConsentTypeAdUserData;

/// Key @c ad_personalization.
extern APMConsentType const APMConsentTypeAdPersonalization;

/// Consent status @c denied.
extern APMConsentStatus const APMConsentStatusDenied;

/// Consent status @c granted.
extern APMConsentStatus const APMConsentStatusGranted;

/// Exposes API to set consent settings for 1st party SDKs.
@interface APMAnalytics (Consent)

/// Sets user consent settings. Consent settings are specified in an NSDictionary that maps consent
/// type to consent status.
///
/// Supported consent type keys are @c ad_storage and @c analytics_storage. Both @c ad_storage and
/// @c analytics_storage are considered granted by default and will be treated as granted if they
/// are not set.
///
/// Consent status values must be one of @c denied or @c granted.
///
/// @param consentSettings An NSDictionary that maps consent type to consent status.
+ (void)setConsent:(nullable NSDictionary<NSString *, NSString *> *)consentSettings;

@end

NS_ASSUME_NONNULL_END
