#import <Foundation/Foundation.h>

/// An application event.
@interface APMEvent : NSObject <NSCopying>

/// Origin of this event (eg "app" or "auto").
@property(nonatomic, readonly) NSString *origin;

/// Name of this event.
@property(nonatomic, readonly) NSString *name;

/// Timestamp of when this event was fired.
@property(nonatomic, readonly) NSTimeInterval timestamp;

/// Timestamp of the previous time an event with this name was fired, if any.
@property(nonatomic, readonly) NSTimeInterval previousTimestamp;

/// The event's parameters as {NSString : NSString} or {NSString : NSNumber} or {NSString :
/// NSArray}.
@property(nonatomic, readonly) NSDictionary<NSString *, id> *parameters;

/// Indicates whether the event has the conversion parameter. Setting to YES first validates the
/// event parameters, and (if the validation passes) adds the conversion parameter if not already
/// present. Setting to YES for invalid conversion events (i.e., events with non-numeric value
/// parameter, or with missing/invalid currency code) causes the validation to fail and adds error
/// code and value into the event parameters map. Setting to NO removes the conversion parameter and
/// adds an error.
@property(nonatomic, getter=isConversion) BOOL conversion;

/// Indicates whether the event has the real-time parameter. Setting to YES adds the real-time
/// parameter if not already present. Setting to NO removes the real-time parameter.
@property(nonatomic, getter=isRealtime) BOOL realtime;

/// Indicates whether the event has debug parameter. Setting to YES adds the debug parameter if
/// not already present. Setting to NO removes the debug parameter.
@property(nonatomic, getter=isDebug) BOOL debug;

/// Creates an event with the given parameters. Parameters will be copied and normalized. Returns
/// nil if the name does not meet length requirements.
/// If |parameters| contains the "_o" parameter, its value will be overwritten with the value of
/// |origin|.
- (instancetype)initWithOrigin:(NSString *)origin
                      isPublic:(BOOL)isPublic
                          name:(NSString *)name
                     timestamp:(NSTimeInterval)timestamp
             previousTimestamp:(NSTimeInterval)previousTimestamp
                    parameters:(NSDictionary<NSString *, id> *)parameters NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// Returns a new event object with the given previousTimestamp.
- (instancetype)copyWithPreviousTimestamp:(NSTimeInterval)previousTimestamp;

/// Returns a new event object with the new parameters.
- (instancetype)copyWithParameters:(NSDictionary<NSString *, id> *)parameters;

/// Adds parameters to an event. If an event has a parameter defined already, it will not overwrite
/// the existing parameter.
- (void)applyParameters:(NSDictionary<NSString *, id> *)parameters;

/// Returns YES if all parameters in screenParameters were added to the event object. Returns NO if
/// screenParameters is nil/empty or the event already contains any of the screen parameter keys.
/// Performs internal validation on the screen parameter values and converts them to APMValue
/// objects if they aren't already. screenParameters should be a dictionary of
/// { NSString : NSString | NSNumber } or { NSString : APMValue }.
- (BOOL)addScreenParameters:(NSDictionary<NSString *, id> *)screenParameters;

@end
