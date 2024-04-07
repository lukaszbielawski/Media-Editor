#import <Foundation/Foundation.h>

#import "googlemac/iPhone/Firebase/Analytics/AppMeasurement/Experimentation/Public/APMEManager.h"

/// Exposes API to get experiment IDs for Analytics.
@interface APMEManager (Internal)

/// Returns the list of experiment IDs of the activated snapshots, whose diversion keys are derived
/// from the Analytics app instance ID.
- (NSArray<NSNumber *> *)experimentIDs;

@end
