#import <Foundation/Foundation.h>

#import "APMEvent.h"

@class APMValue;

/// Encapsulates Conditional User Property attributes.
///
/// Conditional User Properties (CUPs) is mechanism to set an user property based on a condition
/// over incoming Analytics’ events. Each CUP has the following properties:
///   - User property and value to be set;
///   - Triggering event;
///   - CUP expiration time;
///   - User property expiration time;
///   - Event to be logged when a CUP is triggered;
///   - Event to be logged when a CUP is cleared.
///
/// This class also encapsulates some CUP metadata such as creation time, trigger time, and
/// whether the Conditional User Property is active or not.
@interface APMConditionalUserProperty : NSObject <NSCopying>

/// Name that identifies a Conditional User Property managed by
/// APMConditionalUserPropertyController.
@property(nonatomic, copy) NSString *name;

/// Origin that identifies the owner of the Conditional User Property.
///
/// Although this property won't be validated, it is recommended to use an origin constant defined
/// at APMEventOrigins.h.
@property(nonatomic, copy) NSString *origin;

/// The value of the user property to set.
@property(nonatomic, copy) APMValue *value;

/// The event name which triggers the Conditional User Property. This value is optional and if it is
/// not provided, the user property will be set right after the Conditional User Property is added
/// to the APMConditionalUserPropertyController.
@property(nonatomic, copy) NSString *triggerEventName;

/// An interval in seconds relative to #creationTimestamp indicating for how long a Conditional User
/// Property can be triggered. Valid timeout range is from 1 ms to 6 months.
@property(nonatomic) NSTimeInterval triggerTimeout;

/// An interval in seconds relative to #triggeredTimestamp indicating for how long the User Property
/// associated with this Conditional User Property will belong to Analytics' set of User Properties.
/// Valid timeout range is from 1 ms to 6 months.
@property(nonatomic) NSTimeInterval timeToLive;

/// The event which will be logged when the Conditional User Property triggers. A Conditional User
/// Property triggers when Analytics processes an event whose name is equal to triggerEventName.
/// Note that if a Conditional User Property doesn't have a triggerEventName, the
/// trigger event will happen right after the Conditional User Property is added to
/// APMConditionalUserPropertyController.
@property(nonatomic, copy) APMEvent *triggeredEvent;

/// The event which will be logged when the Conditional User Property times out. A Conditional User
/// Property times out after triggerTimeout period goes by.
@property(nonatomic, copy) APMEvent *timedOutEvent;

/// The event which will be logged when the Conditional User Property expires. A Conditional User
/// Property expires if the Conditional User Property has been triggered and timeToLive has gone by.
@property(nonatomic, copy) APMEvent *expiredEvent;

#pragma mark - Metadata

/// The creation timestamp in seconds relative to 00:00:00 UTC on 1 January 1970 of a Conditional
/// User Property.
@property(nonatomic, readonly) NSTimeInterval creationTimestamp;

/// Indicates whether the Conditional User Property is active. A Conditional User Property is
/// considered active if it hasn't expired and it hasn't been triggered.
@property(nonatomic, readonly, getter=isActive) BOOL active;

/// A timestamp in seconds relative to 00:00:00 UTC on 1 January 1970 indicating when the
/// Conditional User Property was triggered.
@property(nonatomic, readonly) NSTimeInterval triggeredTimestamp;

@end
