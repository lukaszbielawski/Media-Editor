// For compatibility with the cocoapod build script, the following imports should NOT use the full
// "googlemac/iPhone/..." path.
#import "APMAnalytics.h"

@class APMEvent;

/// Interceptor block signature used to intercept public events. APMAnalytics expects any
/// interceptor to complete quickly, executing any processing on its own thread or dispatch queue.
typedef void (^APMAnalyticsLogEventInterceptor)(NSString *origin, NSString *name,
                                                NSDictionary<NSString *, id> *parameters,
                                                NSTimeInterval timestamp);

/// Listener block signature used to listen for non-private events. APMAnalytics expects any
/// listener to complete quickly, executing any processing on its own thread or dispatch queue.
typedef void (^APMAnalyticsLogEventListener)(APMEvent *event);

/// Listener block signature used to listen for openURL events. APMAnalytics expects a listener to
/// handle any extended processing on its own thread or dispatch queue.
typedef void (^APMAnalyticsOpenURLListener)(NSURL *url);

/// Callback block signature used for calling back when all user properties are retrieved from the
/// database.
typedef void (^APMUserPropertiesCallback)(NSDictionary<NSString *, id> *userProperties);

/// Callback block signature used for calling back when all user properties are retrieved from the
/// database.
typedef void (^APMMaxUserPropertiesForOriginCallback)(int32_t maxUserProperties);

/// Notification which fires one time just before Analytics initializes. This is useful for setting
/// an event interceptor, adding event listeners, or asynchronously triggering any other
/// initialization tasks your SDK requires prior to receiving Analytics event notifications.
///
/// You can subscribe to this notification in +load of one of your classes. The notification occurs
/// on the main thread, so any work done in response to it must be minimal and not involve any disk
/// or network IO.
static NSString *const kAPMAnalyticsWillStartNotification = @"kFIRAnalyticsWillStartNotification";

/// Exposes custom logging of events.
@interface APMAnalytics (Internal)

/// Returns a shared instance.
+ (APMAnalytics *)sharedInstance;

/// Sets an interceptor for log events. All modifiable events logged with any logEvent* method will
/// be routed to the interceptor, unless ignored via the logEventWithOrigin overload that accepts an
/// ignoreInterceptor parameter.
+ (void)setLogEventInterceptor:(APMAnalyticsLogEventInterceptor)logEventInterceptor;

/// Adds a log event listener, used to monitor any non-internal (public and automatic) events. The
/// return value is an opaque token retained by APMAnalytics and should be held onto by the caller
/// in order to unregister the listener.
+ (id)addLogEventListener:(APMAnalyticsLogEventListener)logEventListener;

/// Removes a log event listener, used to monitor any non-internal (public and automatic) events.
+ (void)removeLogEventListener:(id)listenerToken;

/// Notifies all registered event listeners of the event.
+ (void)notifyEventListeners:(APMEvent *)event;

/// Sets a listener for URL open events.
+ (void)setOpenURLListener:(APMAnalyticsOpenURLListener)listener;

/// Logs a public event with the given origin, name, and parameters. Internally, events are not
/// rate-limited.
///
/// The event parameters are name-value pairs, where values can be of type NSString or NSNumber.
/// Integer NSNumber values will be logged as signed 64-bit integers. Floating point NSNumber values
/// will be logged as doubles. Parameters may be of mixed type (string or numeric) for a given
/// event.
+ (void)logEventWithOrigin:(NSString *)origin
                      name:(NSString *)name
                parameters:(NSDictionary<NSString *, id> *)parameters;

/// Logs a internal event with the given origin, name, and parameters ignoring any field validation.
/// Internally, events are not rate-limited.
///
/// The event parameters are name-value pairs, where values can be of type NSString or NSNumber.
/// Integer NSNumber values will be logged as signed 64-bit integers. Floating point NSNumber values
/// will be logged as doubles. Parameters may be of mixed type (string or numeric) for a given
/// event.
+ (void)logInternalEventWithOrigin:(NSString *)origin
                              name:(NSString *)name
                        parameters:(NSDictionary<NSString *, id> *)parameters;

/// Logs a internal event with the given origin, name, timestamp, and parameters ignoring any field
/// validation. Internally, events are not rate-limited.
///
/// The event parameters are name-value pairs, where values can be of type NSString or NSNumber.
/// Integer NSNumber values will be logged as signed 64-bit integers. Floating point NSNumber values
/// will be logged as doubles. Parameters may be of mixed type (string or numeric) for a given
/// event.
+ (void)logInternalEventWithOrigin:(NSString *)origin
                              name:(NSString *)name
                         timestamp:(NSTimeInterval)timestamp
                        parameters:(NSDictionary<NSString *, id> *)parameters;

/// Logs an event with the given origin, name, parameters and timestamp, with options to ignore the
/// state of the enable flag, and to bypass the interceptor.
///
/// The event parameters are name-value pairs, where values can be of type NSString or NSNumber.
/// Integer NSNumber values will be logged as signed 64-bit integers. Floating point NSNumber values
/// will be logged as doubles. Parameters may be of mixed type (string or numeric) for a given
/// event.
+ (void)logEventWithOrigin:(NSString *)origin
             isPublicEvent:(BOOL)isPublic
                      name:(NSString *)name
                parameters:(NSDictionary<NSString *, id> *)parameters
                 timestamp:(NSTimeInterval)timestamp
             ignoreEnabled:(BOOL)ignoreEnabled
         ignoreInterceptor:(BOOL)ignoreInterceptor;

/// Returns a dictionary { String, Object } of user properties, with user property name as
/// key and user property value as value.
///
/// @param includingInternal Indicates whether internal properties will be included in the list.
/// @param queue The queue to that the callback will be dispatched on. Queue cannot be nil.
/// @param callback The callback that is called once all user properties are retrieved. The
///     callback cannot be nil. Its parameter is a dictionary of user properties with user property
///     name as key and user property value as dictionary value.
+ (void)userPropertiesIncludingInternal:(BOOL)includingInternal
                                  queue:(dispatch_queue_t)queue
                               callback:(APMUserPropertiesCallback)callback;

/// Logs an internal event with the given origin, name, and parameters ignoring any field
/// validation. Internally, events are not rate-limited.
///
/// The event parameters are name-value pairs, where values can be of type NSString or NSNumber.
/// Integer NSNumber values will be logged as signed 64-bit integers. Floating point NSNumber values
/// will be logged as doubles. Parameters may be of mixed type (string or numeric) for a given
/// event.
- (void)logInternalEventWithOrigin:(NSString *)origin
                              name:(NSString *)name
                        parameters:(NSDictionary<NSString *, id> *)parameters;

/// Sets an internal user property to a given value. This method skips the public validation applied
/// to the user properties.
///
/// @param value The value of the user property. User property values must be nil or an instance of
///     NSString, NSNumber, or APMValue. If value is a NSString, it can be up to 36 characters
///     long. Setting the value to nil removes the user property.
/// @param name The name of the user property to set. Should contain 1 to 24 alphanumeric characters
///     or underscores.
/// @param origin The origin of the user property to set. Origin must be a non-empty string.
- (void)setInternalUserProperty:(id)value forName:(NSString *)name withOrigin:(NSString *)origin;

/// Returns the max number of User Properties for the given origin.
///
/// @param origin The origin that will be used to retrieve the user property quota. Origin must be a
///     non-empty string.
/// @param queue The queue to that the callback will be dispatched on. Queue cannot be nil.
/// @param callback The callback that is called once the max amount user properties for an origin is
///     retrieved. Callback cannot be nil.
- (void)maxUserPropertiesForOrigin:(NSString *)origin
                             queue:(dispatch_queue_t)queue
                          callback:(APMMaxUserPropertiesForOriginCallback)callback;

@end
