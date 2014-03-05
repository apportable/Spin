/**
 * © 2012-2013 Amazon Digital Services, Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy
 * of the License is located at
 *
 * http://aws.amazon.com/apache2.0/
 *
 * or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "AGSyncableStringElement.h"

/**
 * \protocol SyncableStringSet
 * A syncable type that represents a set of fixed strings.  The set is
 * typically used to represent a set of strings across multiple devices.
 * An example is the names of items a player has collected in a game.
 * Note that metadata cannot be associated with this type, but metadata
 * can be associated with its elements.
 *
 * \see SyncableStringElement
 */
@protocol AGSyncableStringSet <NSObject>

@property (nonatomic, readonly, assign) BOOL isSet;

/**
 * Adds a AGSyncableStringElement to this set with the given value.
 *
 * \arg value The value to be added to this set.
 *
 * \see AGSyncableStringElement
 */
- (void) addValue:(NSString*)value;

/**
 * Adds a AGSyncableStringElement to this set with the given value and
 * optional metadata.
 *
 * \arg value The value to be added to this set. It can be nil.
 * \arg metadata The metadata associated with the value. It can be nil.
 *
 * \see AGSyncableStringElement
 */
- (void) addValue:(NSString*)value withMetadata:(NSMutableDictionary*)metadata;

/**
 * Returns whether or not this set contains a AGSyncableStringElement of the given value.
 *
 * \arg value the String value to query, which can be nil.
 * \return whether or not this set contains a AGSyncableStringElement of the given value.
 */
- (BOOL) contains:(NSString*)value;

/**
 * Retrieves the AGSyncableStringElement for the given string value
 * in this set.
 *
 * \arg value the non-nil string value to query.
 * \return the SyncableStringElement associated with the given string value, or nil if none exists.
 */
- (AGSyncableStringElement*) valueWithName:(NSString*)name;

/**
 * \return a non-nil immutable copy of the elements of this set as an NSArray.
 */
- (NSArray*) values;

@end


@interface AGSyncableStringSet <AGSyncableStringSet>

@end
