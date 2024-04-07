#import <Foundation/Foundation.h>

#import "googlemac/iPhone/Firebase/Analytics/AppMeasurement/Public/APMAnalytics.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *APMUserDataField NS_TYPED_ENUM NS_SWIFT_NAME(UserDataField);

/// User email address (NSString). Include a domain name for all email addresses (e.g. gmail.com
/// or hotmail.co.jp). Remove any spaces in between the email address.
/// Ex. "example@gmail.com"
extern APMUserDataField const APMUserDataFieldEmailAddress;

/// Phone number (NSString).
extern APMUserDataField const APMUserDataFieldPhoneNumber;

#ifdef APM_FEATURE_FLAG_PSM_HASH
/// SHA-256 hashed email address (NSData).
extern APMUserDataField const APMUserDataFieldHashedEmailAddress;

/// SHA-256 hashed phone number (NSData).
extern APMUserDataField const APMUserDataFieldHashedPhoneNumber;
#endif  // APM_FEATURE_FLAG_PSM_HASH

@interface APMAnalytics (UserData)

+ (void)setUserData:(nullable NSDictionary<APMUserDataField, id> *)userData;

@end

NS_ASSUME_NONNULL_END
