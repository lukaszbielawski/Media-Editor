#import <Foundation/Foundation.h>

#import "APMConditionalUserProperty.h"

/// Conditional user properties (CUPs) is a mechanism to set a Analytics' user property based on
/// conditions over incoming Analytics' events.
///
/// This controller manages Analytics' conditional user properties. Its responsibilities include
/// persisting CUPs on disk and controlling the amount of CUP based on their origin to avoid
/// abuse.
///
/// Using APMConditionalUserPropertyController:
///
/// - Adding a conditional user property:
///
/// You have to create an instance of APMConditionalUserProperty and populate it properly. After
/// creating an instance, you have to call #setConditionalUserProperty:forName: to actually add the
/// CUP to Analytics. #setConditionalUserProperty:forName: persists the given CUP on disk to
/// guarantee that the given CUP will exist across multiple runs of the app.
///
/// - Clearing a conditional user property:
///
/// Clearing a conditional user property removes the conditional user property from the system. See
/// #clearConditionalUserPropertyWithClearEvent:forName: for more details.
///
/// - Retrieving conditional user properties:
///
/// You can query this controller anytime to retrieve conditional user properties that have been
/// registered.
///
/// All CUPs that fulfill the query requirements will be returned as an instance of
/// APMConditionalUserProperty. Note that the APMConditionalUserProperty metadata properties will
/// have values.
///
/// - Checking the conditional user property quota:
///
/// In order to avoid abuse, APMConditionalUserPropertyController controls how many CUPs each
/// origin is allowed to set. To retrieve the maximum amount of CUPs, you should call
/// #maxUserPropertiesForOrigin:.
@interface APMConditionalUserPropertyController : NSObject

/// Returns the APMConditionalUserPropertyController singleton.
+ (instancetype)sharedInstance;

/// Sets a Conditional User Property.
///
/// If a Conditional User Property with the same already exists, this method updates the Conditional
/// User Property. If the intent is to update the name of an existing Conditional User Property, the
/// caller should call #clearConditionalUserPropertyWithClearEvent:forName: to remove the
/// Conditional User Property before setting a new one.
///
/// @param conditionalUserProperty APMConditionalUserProperty instance containing the required
///     information for the Conditional User Property that will be added to the system.
/// @param conditionalUserPropertyName The name of the Conditional User Property to be added. This
///     name must be non-empty and this will override the @b name property of the
///     @b conditionalUserProperty param.
- (void)setConditionalUserProperty:(APMConditionalUserProperty *)conditionalUserProperty
                           forName:(NSString *)conditionalUserPropertyName;

/// Clears a Conditional User Property if set.
///
/// @param clearEvent The event that will be logged upon clearing the conditional user property.
/// @param conditionalUserPropertyName The name of the Conditional User Property to be removed. If
///     the name is empty this method is no-op.
- (void)clearConditionalUserPropertyWithClearEvent:(APMEvent *)clearEvent
                                           forName:(NSString *)conditionalUserPropertyName;

/// Returns a list of conditional user properties filtered by Conditional User Property name prefix
/// and/or origin. Returns nil if Analytics is disabled or there is error in database.
///
/// @param namePrefix Optional parameter representing the Conditional User Property name prefix to
///     search for. If namePrefix is non-empty, returns only conditional user properties whose names
///     start with the given prefix.
/// @param origin Optional parameter representing the Conditional User Property origin to search
///     for. If origin is non-empty, returns only conditional user properties whose origins match
///     exactly with the given origin.
- (NSArray<APMConditionalUserProperty *> *)
    conditionalUserPropertiesWithNamePrefix:(NSString *)namePrefix
                             filterByOrigin:(NSString *)origin;

@end
