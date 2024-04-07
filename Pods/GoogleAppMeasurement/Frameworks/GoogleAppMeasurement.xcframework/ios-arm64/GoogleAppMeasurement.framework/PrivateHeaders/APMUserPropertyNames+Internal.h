#import <Foundation/Foundation.h>

/// Predefined (internal) user properties.
/// TODO(b/139159006): Convert static string constants to extern.

// LINT.IfChange

/// Returns a dictionary that maps full internal user property names to their respective abbreviated
/// name.
extern NSDictionary<NSString *, NSString *> *APMInternalUserPropertyNames(void);

/// Stores the first open timestamp in milliseconds since 1/1/1970.
static NSString *const kAPMUserPropertyFirstOpenTimestampMillis = @"_fot";

/// Stores the message_id of the last notification opened by the app.
static NSString *const kAPMUserPropertyLastNotification = @"_ln";

/// User ID.
static NSString *const kAPMUserPropertyUserID = @"_id";

/// User property to specify first open event occurrence after app install.
static NSString *const kAPMUserPropertyFirstOpenAfterInstall = @"_fi";

/// User property of the user engagement lifetime value in milliseconds.
static NSString *const kAPMUserPropertyLifetimeUserEngagement = @"_lte";

/// User property of the total engagement time in milliseconds since the beginning of the current
/// session.
static NSString *const kAPMUserPropertySessionUserEngagement = @"_se";

/// User property for the current session ID. This is the timestamp in seconds when a session
/// starts.
static NSString *const kAPMUserPropertySessionID = @"_sid";

/// User property for the current session number. This is a monotonically increasing integer that
/// starts at one and increments for each passing session.
static NSString *const kAPMUserPropertySessionNumber = @"_sno";

/// User property to disallow events from being used as signals for ad personalization.
static NSString *const kAPMUserPropertyNonPersonalizedAds = @"_npa";

/// User property to indicate that the resettable device ID (aka IDFA) has been reset.
static NSString *const kAPMUserPropertyLastAdvertisingIDReset = @"_lair";

/// Google Broad Ad ID.
static NSString *const kAPMUserPropertyGBRAID = @"_gbraid";

// When adding any user property name, update the Google Analytics for Firebase
// equivalent file.
// LINT.ThenChange(//depot/google3/googlemac/iPhone/Firebase/Analytics/InternalHeaders\
//      /FIRUserPropertyNames+Internal.h)

/// User property set to the value received from the PSM response if the user was found to be among
/// those who engaged with an ad.
static NSString *const kAPMUserPropertyPSMValue = @"_psmvalue";

/// User property for the number of times the PSM flow was initiated given a plain-text email
/// address (for monitoring purposes).
static NSString *const kAPMUserPropertyPSMCountEmail = @"_psmcount";

/// User property for the number of times the PSM flow was initiated given a plain-text phone number
/// (for monitoring purposes).
static NSString *const kAPMUserPropertyPSMCountPhone = @"_psmcountph";

#ifdef APM_FEATURE_FLAG_PSM_HASH
/// User property for the number of times the PSM flow was initiated given a hashed email address
/// (for monitoring purposes).
static NSString *const kAPMUserPropertyPSMCountHashedEmail = @"_psmcounth";

/// User property for the number of times the PSM flow was initiated given a hashed phone number
/// (for monitoring purposes).
static NSString *const kAPMUserPropertyPSMCountHashedPhone = @"_psmcounthph";
#endif  // APM_FEATURE_FLAG_PSM_HASH
