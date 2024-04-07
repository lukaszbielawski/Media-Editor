#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The interface for retrieving static configurations.
@protocol APMStaticConfig <NSObject>
@optional

/// Returns YES if screen reporting is enabled. Returns NO if screen reporting is disabled. If
/// unimplemented, screen reporting is decided by the Info.plist.
@property(nonatomic, readonly) BOOL screenReportingEnabled;

@end

/// This class provides static configurations.
@interface APMAppStaticConfig : NSObject <APMStaticConfig>

/// Returns a shared instance.
+ (APMAppStaticConfig *)sharedInstance;

@end

NS_ASSUME_NONNULL_END
