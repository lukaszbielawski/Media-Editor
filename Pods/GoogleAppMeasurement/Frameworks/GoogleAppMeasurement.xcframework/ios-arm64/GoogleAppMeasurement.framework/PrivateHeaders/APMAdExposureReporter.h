#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Measures and reports exposure times of ad units and ads in general. The ad unit will be
/// considered exposed after the first call to @ref beginAdUnitExposure: and until the last call to
/// @ref endAdUnitExposure:. The same ad unit can be exposed multiple times on the screen. Each call
/// to @ref beginAdUnitExposure: must be balanced with a call to @ref endAdUnitExposure:. Nested ad
/// unit exposure calls are supported. When at least one ad unit is exposed, the app is considered
/// exposed to ads in general. When the current view controller resigns its active state, general ad
/// exposure and ad unit exposure pauses. There is no need to explicitly call
/// @ref endAdUnitExposure: when the current view controller is inactive. General ad exposure and ad
/// unit exposure resume when the view controller becomes active again.
///
/// Example usage:
/// @code
/// [[APMAdExposureReporter sharedInstance] beginAdUnitExposure:adUnitID1];
/// [[APMAdExposureReporter sharedInstance] beginAdUnitExposure:adUnitID2];
/// // ...
/// [[APMAdExposureReporter sharedInstance] endAdUnitExposure:adUnitID1];
/// [[APMAdExposureReporter sharedInstance] endAdUnitExposure:adUnitID2];
/// @endcode
@interface APMAdExposureReporter : NSObject

/// Indicates if reporting is enabled. If NO, prevents all exposure events from being logged.
/// Default is YES.
@property(nonatomic, assign, getter=isReportingEnabled) BOOL reportingEnabled;

/// Returns the shared instance.
+ (APMAdExposureReporter *)sharedInstance;

/// Starts measuring exposure time of an ad unit on the current screen.
///
/// @param adUnitID The ad unit ID.
- (void)beginAdUnitExposure:(NSString *)adUnitID;

/// Stops measuring exposure time of an ad unit on the current screen.
///
/// @param adUnitID The ad unit ID.
- (void)endAdUnitExposure:(NSString *)adUnitID;

@end

NS_ASSUME_NONNULL_END
