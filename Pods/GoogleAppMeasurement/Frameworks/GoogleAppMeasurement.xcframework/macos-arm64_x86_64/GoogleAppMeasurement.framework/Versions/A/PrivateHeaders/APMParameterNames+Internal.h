#import <Foundation/Foundation.h>

/// Prefined (internal) parameter names.
// LINT.IfChange
/// Returns a dictionary that maps full internal parameter names to their respective abbreviated
/// name.
extern NSDictionary<NSString *, NSString *> *APMInternalParameterNames(void);

/// Conversion event parameter.
static NSString *const kAPMParameterGAConversion = @"_c";

/// Engagement time in milliseconds event parameter.
static NSString *const kAPMParameterEngagementTimeMillis = @"_et";

/// Freeride parameter that indicates which engagement events are redundant (i.e. whose engagement
/// time is already attached to temporally-adjacent events like first_open or screen_view).
static NSString *const kAPMParameterFreeride = @"_fr";

/// Error parameter containing an error code which represents the cause of the data loss in the
/// current event.
static NSString *const kAPMParameterGAError = @"_err";

/// Length of rejected string due to exceeding set maximum length.
static NSString *const kAPMParameterGAErrorLength = @"_el";

/// Error value parameter containing the string that triggered the error event.
static NSString *const kAPMParameterGAErrorValue = @"_ev";

/// Origin event parameter.
static NSString *const kAPMParameterGAEventOrigin = @"_o";

/// Indicates whether a crash is fatal or not (int as NSNumber): @(1) indicates a fatal crash, @(0)
/// indicates a non-fatal crash.
static NSString *const kAPMParameterFatal = @"fatal";

/// Previous app version event parameter.
static NSString *const kAPMParameterPreviousAppVersion = @"_pv";

/// Number of previous first open events (int64_t as NSNumber). For the initial first open event,
/// the count should be 0.
static NSString *const kAPMParameterPreviousFirstOpenCount = @"_pfo";

/// Previous GMP app ID event parameter.
static NSString *const kAPMParameterPreviousGMPAppID = @"_pgmp";

/// Previous OS version event parameter.
static NSString *const kAPMParameterPreviousOSVersion = @"_po";

/// Message tracking ID.
static NSString *const kAPMParameterMessageTrackingIdentifier = @"_nmtid";

/// Message identifier.
static NSString *const kAPMParameterMessageIdentifier = @"_nmid";

/// Message name.
static NSString *const kAPMParameterMessageName = @"_nmn";

/// Message send time.
static NSString *const kAPMParameterMessageTime = @"_nmt";

/// Message type. See: http://go/notification-message-type.
static NSString *const kAPMParameterMessageType = @"_nmc";

/// Message device time.
static NSString *const kAPMParameterMessageDeviceTime = @"_ndt";

/// Timestamp.
static NSString *const kAPMParameterTimestamp = @"timestamp";

/// Topic message.
static NSString *const kAPMParameterTopic = @"_nt";

/// Indicates (int64_t as NSNumber) whether the first open event is due to an update from a version
/// of the app without analytics to a version of the app that now has analytics integrated: @(1)
/// indicates that the app is now updated with analytics, @(0) indicates that the first open event
/// is a fresh install.
static NSString *const kAPMParameterUpdateWithAnalytics = @"_uwa";

/// Indicates (int64_t as NSNumber) whether first open was delayed because collection was initially
/// disabled.
static NSString *const kAPMParameterDeferredAnalyticsCollection = @"_dac";

/// Campaign info source to identify where the campaign originated from.
static NSString *const kAPMParameterCampaignInfoSource = @"_cis";

/// The value that is provided by the event _ssr that represents the active rollout IDs.
static NSString *const kAPMParameterFirebaseFeatureRollouts = @"_ffr";

#pragma mark - Product Parameters for In-App Purchase

/// Purchase product ID (NSString).
static NSString *const kAPMParameterProductID = @"product_id";

/// Purchase product name (NSString).
static NSString *const kAPMParameterProductName = @"product_name";

/// Purchase receipt validation state (integer 0/1).
static NSString *const kAPMParameterValidated = @"validated";

/// Purchase receipt sandbox flag (integer 0/1).
static NSString *const kAPMParameterSandbox = @"sandbox";

/// Free-trial subscription purchase (integer 0/1).
static NSString *const kAPMParameterIsFreeTrialSubscription = @"free_trial";

/// Introductory price of a subscription purchase (integer 0/1).
static NSString *const kAPMParameterPriceIsDiscounted = @"price_is_discounted";

/// Original price of an introductory offer transaction.
static NSString *const kAPMParameterOriginalPrice = @"original_price";

/// Subscription purchase (integer 0/1).
static NSString *const kAPMParameterSubscription = @"subscription";

/// The 64 least significant bits of the MD5 hash integer (int64_t as NSNumber) of:
/// 1. (original_transaction_id + web_order_line_item_id + product_id) for auto-renewable
/// subscriptions
/// 2. (original_transaction_id + product_id) for all other purchase types
/// See http://go/scion-subscription-transaction-id for details.
static NSString *const kAPMParameterDedupeID = @"_did";

#pragma mark - Firebase Campaign Parameters

/// Ad Network ID (NSString).
static NSString *const kAPMParameterAdNetworkID = @"anid";

/// Click timestamp when the user clicked on the ad or other source that led to installing the
/// app. Timestamp in UTC milliseconds (long).
static NSString *const kAPMParameterClickTimestamp = @"click_timestamp";

/// Google Click ID (NSString).
static NSString *const kAPMParameterGoogleClickID = @"gclid";

/// Google Broad Ad ID (NSString).
static NSString *const kAPMParameterGBRAID = @"gbraid";

/// Identifies that the campaign data was previously cached. Value set to 1 if the attribution cache
/// expired. Otherwise, value set to the attribution timestamp in UTC milliseconds (long) rounded
/// down to the nearest hour.
static NSString *const kAPMParameterCachedCampaign = @"_cc";

/// Double Click ID (NSString).
static NSString *const kAPMParameterDoubleClickID = @"dclid";

/// Store Result ID (NSString).
static NSString *const kAPMParameterStoreResultID = @"srsltid";

/// Salesforce Subscriber ID (NSString).
static NSString *const kAPMParameterSalesforceSubscriberID = @"sfmc_id";

#pragma mark - Debug mode params

/// Debug mode.
static NSString *const kAPMParameterDebugMode = @"_dbg";

/// Real-time.
static NSString *const kAPMParameterRealtime = @"_r";

#pragma mark - Screen params

/// Screen class name (NSString).
static NSString *const kAPMParameterInternalScreenClass = @"_sc";

/// Screen instance ID (int64_t as NSNumber).
static NSString *const kAPMParameterScreenInstanceID = @"_si";

/// Screen name (NSString).
static NSString *const kAPMParameterInternalScreenName = @"_sn";

/// Previous screen class name (NSString).
static NSString *const kAPMParameterPreviousScreenClass = @"_pc";

/// Previous screen instance ID (int64_t as NSNumber).
static NSString *const kAPMParameterPreviousScreenInstanceID = @"_pi";

/// Previous screen name (NSString).
static NSString *const kAPMParameterPreviousScreenName = @"_pn";

/// Indicates that automatic screen reporting is disabled.
static NSString *const kAPMParameterManuallyTrackedScreen = @"_mst";

#pragma mark - Ad Exposure params

/// Ad unit ID (NSString).
static NSString *const kAPMParameterAdUnitID = @"_ai";

/// Ad exposure time in ms (int64_t as NSNumber).
static NSString *const kAPMParameterAdExposureTime = @"_xt";

#pragma mark - AdMob

/// Ad event ID (NSString).
static NSString *const kAPMParameterAdEventID = @"_aeid";

/// AdMob rewarded ads reward type (NSString).
static NSString *const kAPMParameterRewardType = @"reward_type";

/// AdMob rewarded ads reward value (int64_t as NSNumber).
static NSString *const kAPMParameterRewardValue = @"reward_value";

#pragma mark - Complex Event Params

/// Event ID used to join kAPMEventExtraParameter with its parent event. Both the parent and
/// child events have this parameter with the same ID.
static NSString *const kAPMParameterEventID = @"_eid";

/// The name of the parent entry of the kAPMEventExtraParameter event.
static NSString *const kAPMParameterEventName = @"_en";

/// Name of the parameter the kAPMEventExtraParameter event belongs to in its parent event.
static NSString *const kAPMParameterGroupName = @"_gn";

/// Count of entries the parent event of the kAPMEventExtraParameter event has for the parameter
/// the child event is attached to.
///
/// For example, the parent event has 10 bundles under the "test" parameter. This value would be
/// set to 10.
static NSString *const kAPMParameterListLength = @"_ll";

/// The total number of child events. This is added across all included bundles and attached to
/// the parent event.
static NSString *const kAPMParameterExtraParamEventCount = @"_epc";

/// The index of the bundle the kAPMEventExtraParameter event represents in the parameter of the
/// parent event. Zero-indexed.
///
/// For example, the parent event has 10 bundles under the "test" parameter, and this bundle is
/// the 5th. This value would be set to 4.
static NSString *const kAPMParameterExtraParamIndex = @"_i";

#pragma mark - Sampling Params

/// Indicates that the event was exempt from sampling because it has been 24
/// hours or more since that event was last bundled.
static NSString *const kAPMParameterExemptFromSampling = @"_efs";

/// Indicates the sampling rate at the time when this event was bundled.
static NSString *const kAPMParameterSamplingRate = @"_sr";

#pragma mark - Sessionization

/// The current session ID. This is the timestamp in seconds when a session starts.
static NSString *const kAPMParameterSessionID = @"_sid";

/// The current session number. This is a monotonically increasing integer that starts at one and
/// increments for each passing session.
static NSString *const kAPMParameterSessionNumber = @"_sno";

/// Indicates that the current session was started while the app is in the background.
static NSString *const kAPMParameterAppInBackground = @"_aib";

#pragma mark - Safelisted events

/// Indicates the event has been manually safelisted by 1P app developer.
static NSString *const kAPMParameterEventSafelisted = @"ga_safelisted";

// When adding any parameter, update the Google Analytics for Firebase equivalent file.
// LINT.ThenChange(//depot/google3/googlemac/iPhone/Firebase/Analytics/InternalHeaders\
//    /FIRParameterNames+Internal.h)

/// Source of first open consented event (aka deferred first open) (NSString). Set to "psm" if event
/// was triggered due to receiving a PSM-sourced GBRAID value.
static NSString *const kAPMParameterFirstOpenConsentedSource = @"_fxs";

#pragma mark - Deprecated names removed in M115

/// (Deprecated) Some option on a step in an ecommerce flow (NSString). Kept internally to maintain
/// backward compatibility as an allowed ecommerce item param name.
static NSString *const kAPMParameterCheckoutOption = @"checkout_option";

/// (Deprecated) The checkout step (1..N) (unsigned 64-bit integer as NSNumber). Kept internally to
/// maintain backward compatibility as an allowed ecommerce item param name.
static NSString *const kAPMParameterCheckoutStep = @"checkout_step";

/// (Deprecated) The list in which the item was presented to the user (NSString). Kept internally
/// to maintain backward compatibility as an allowed ecommerce item param name and in case
/// developers are renaming the parameter to the recommended name "item_list_name" with
/// event-editing.
static NSString *const kAPMParameterItemList = @"item_list";

/// (Deprecated) Item location ID (NSString). Kept internally to maintain backward compatibility as
/// an allowed ecommerce item param name and in case developers are renaming the parameter to the
/// recommended name "location_id" with event-editing.
static NSString *const kAPMParameterItemLocationID = @"item_location_id";

#pragma mark - SKAN

/// Evaluation metadata.
static NSString *const kAPMParameterSKANEvaluationMetadata = @"_skanm";

/// Fine conversion value.
static NSString *const kAPMParameterSKANFineConversionValue = @"_skanf";

/// Coarse conversion value.
static NSString *const kAPMParameterSKANCoarseConversionValue = @"_skanc";

/// Lock window.
static NSString *const kAPMParameterSKANLockWindow = @"_skanl";

/// Evaluation timestamp.
static NSString *const kAPMParameterSKANEvaluationTimestamp = @"_skane";

#pragma mark - TCF Data

#ifdef APM_FEATURE_FLAG_TCF

/// The name of the event parameter that is logged with the kAPMEventTCFDataChanged event.
static NSString *const kAPMParameterTCFData = @"_tcfd";

#endif  // APM_FEATURE_FLAG_TCF
