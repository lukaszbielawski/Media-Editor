#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#if __has_include(<UIKit/UIKit.h>) && !TARGET_OS_WATCH
@class UIViewController;

/// Conform to this protocol and set an object as the delegate of the
/// [APMScreenViewReporter sharedInstance] to receive viewDidAppear: and viewDidDisappear: events.
@protocol APMScreenViewReporterDelegate <NSObject>

/// Tells the delegate that the given viewController appeared. This will be called on the main
/// thread.
///
/// @param viewController The UIViewController instance that appeared.
/// @param trackedByAnalytics YES if APMScreenViewReporter records a screen view event for this
///     UIViewController, NO otherwise.
- (void)viewControllerDidAppear:(UIViewController *)viewController
             trackedByAnalytics:(BOOL)trackedByAnalytics;

/// Tells the delegate that the given viewController disappeared. This will be called on the main
/// thread.
///
/// @param viewController The UIViewController instance that disappeared.
- (void)viewControllerDidDisappear:(UIViewController *)viewController;

@end
#endif  // __has_include(<UIKit/UIKit.h>) && !TARGET_OS_WATCH

@interface APMScreenViewReporter : NSObject

/// Returns the sharedInstance.
+ (APMScreenViewReporter *)sharedInstance;

#if __has_include(<UIKit/UIKit.h>) && !TARGET_OS_WATCH
/// Registers the Firebase Perf delegate if it doesn't exist. Ignores a new delegate if one
/// previously exists. If nil is passed to this method, the existing delegate is de-registered.
/// Only supports having a single delegate at a time.
///
/// Note: This method is NOT thread safe. Only call this on the main thread.
- (void)setFirebasePerfDelegate:(nullable id<APMScreenViewReporterDelegate>)firebasePerfDelegate;

/// Populates any non-NULL parameters with the current screen name and screen class.
- (void)getScreenName:(NSString* _Nullable* _Nullable)screenName
          screenClass:(NSString* _Nullable* _Nullable)screenClass;

/// Sets the current screen name. The name is in effect until the current view controller changes or
/// a new call to setCurrentScreen is made. Must be called on the main thread.
///
/// @param screenName The name of the current screen. Should contain 1 to 100 characters. Set to nil
///     to clear the current screen name.
/// @param screenClass The name of the screen class. Should contain 1 to 100 characters. By default
///     this is the class name of the current UIViewController. Set to nil to revert to the default
///     class name.
- (void)setScreenName:(nullable NSString *)screenName
          screenClass:(nullable NSString *)screenClass
    DEPRECATED_MSG_ATTRIBUTE(
        "Use +[APMAnalytics logEventWithName:kAPMEventScreenView parameters:] instead.");
#endif  // __has_include(<UIKit/UIKit.h>) && !TARGET_OS_WATCH

/// Tracks the screen. Calling this method will log a screen view event and change the currently set
/// screen. This is in effect until the current view controller changes or a new call to
/// setCurrentScreen or trackScreen is made.
/// @param parameters The parameters of the screen view event. Should contain the parameter
/// kAPMParameterScreenClass. This may contain custom parameters set by the developers.
/// @param timestamp The timestamp the screen view event should use.
- (void)trackScreenWithParameters:(NSDictionary<NSString *, id> *)parameters
                        timestamp:(NSTimeInterval)timestamp;

@end

NS_ASSUME_NONNULL_END
