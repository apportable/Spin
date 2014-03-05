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

#import "AGSyncableAccumulatingNumber.h"
#import "AGSyncableDeveloperString.h"
#import "AGSyncableNumber.h"
#import "AGSyncableNumberList.h"
#import "AGSyncableString.h"
#import "AGSyncableStringList.h"
#import "AGSyncableStringSet.h"

/**
 * \class AGGameDataMap
 * An in-memory representation of the current state of a game's
 * Whispersync data. This data structure is organized as a map of strings
 * to containers where each container is a specific syncable type. The
 * syncable types that are supported are: highest number, lowest number,
 * latest number, highest number list, lowest number list, accumulating
 * number, latest string, latest string list, string set, and game data
 * maps (for nested maps). When the GameDataMap is populated or updated
 * with a new value of each syncable type, that value is automatically
 * synchronized with data stored locally on the device and in the cloud.
 */
@interface AGGameDataMap : NSObject

/**
 * Retrieves the highest number associated with the given key.
 * If such a number does not exist, an empty AGSyncableNumber
 * container is returned which can be set. Once set, that value is
 * inserted into the map and automatically synchronized.
 *
 * \arg key
 *            The name of the highest number to return.  This
 *            cannot be nil or empty.
 * \return The highest number associated with the given key.
 *            Nil is never returned
 */
- (AGSyncableNumber*) highestNumberForKey:(NSString*)key;

/**
 * Retrieves a collection of keys associated with a highest number.
 *
 * \return a collection of keys associated with a highest number.
 *             Nil is never returned.
 */
- (NSArray*) allHighestNumberKeys;

/**
 * Retrieves the lowest number associated with the given key.
 * If such a number does not exist, an empty AGSyncableNumber
 * container is returned which can be set. Once set, that value is
 * inserted into the map and automatically synchronized.
 *
 * \arg key
 *            The name of the lowest number to return.  This
 *            cannot be nil or empty.
 * \return The lowest number associated with the given key.
 *            Nil is never returned
 */
- (AGSyncableNumber*) lowestNumberForKey:(NSString*)key;

/**
 * Retrieves a collection of keys associated with a lowest number.
 *
 * \return a collection of keys associated with a lowest number.
 *             Nil is never returned.
 */
- (NSArray*) allLowestNumberKeys;

/**
 * Retrieves the latest number associated with the given key.
 * If such a number does not exist, an empty AGSyncableNumber
 * container is returned which can be set. Once set, that value is
 * inserted into the map and automatically synchronized.
 *
 * \arg key
 *            The name of the latest number to return.  This
 *            cannot be nil or empty.
 * \return The latest number associated with the given key.
 *            Nil is never returned
 */
- (AGSyncableNumber*) latestNumberForKey:(NSString*)key;

/**
 * Retrieves a collection of keys associated with a latest number.
 *
 * \return a collection of keys associated with a latest number.
 *             Nil is never returned.
 */
- (NSArray*) allLatestNumberKeys;

/**
 * Retrieves the high number list associated with the given key.
 * High number lists are sorted in decreasing order by value.
 * If such a list does not exist, an empty AGSyncableNumberList
 * container is returned which can be set. Once set, that list is
 * inserted into the map and automatically synchronized.
 *
 * \arg key
 *            The name of the high number list to return.  This
 *            cannot be nil or empty.
 * \return The high number list associated with the given key.
 *            Nil is never returned
 */
- (AGSyncableNumberList*) highNumberListForKey:(NSString*) key;

/**
 * Retrieves a collection of keys associated with a high number list.
 *
 * \return a collection of keys associated with a high number list.
 *             Nil is never returned.
 */
- (NSArray*) allHighNumberListKeys;

/**
 * Retrieves the low number list associated with the given key.
 * Low number lists are sorted in increasing order by value.
 * If such a list does not exist, an empty AGSyncableNumberList
 * container is returned which can be set. Once set, that list is
 * inserted into the map and automatically synchronized.
 *
 * \arg key
 *            The name of the low number list to return.  This
 *            cannot be nil or empty.
 * \return The low number list associated with the given key.
 *            Nil is never returned
 */
- (AGSyncableNumberList*) lowNumberListForKey:(NSString*) key;

/**
 * Retrieves a collection of keys associated with a low number list.
 *
 * \return a collection of keys associated with a low number list.
 *             Nil is never returned.
 */
- (NSArray*) allLowNumberListKeys;

/**
 * Retrieves the latest number list associated with the given key.
 * Latest number lists are sorted in order of the most recently set
 * values first, where ties resolve in order of increasing value.  If
 * such a list does not exist, an empty AGSyncableNumberList container
 * is returned which can be set. Once set, that list is inserted into
 * the map and automatically synchronized.
 *
 * \arg key
 *            The name of the latest number list to return.  This
 *            cannot be nil or empty.
 * \return The latest number list associated with the given key.
 *            Nil is never returned
 */
- (AGSyncableNumberList*) latestNumberListForKey:(NSString*) key;

/**
 * Retrieves a collection of keys associated with a latest number list.
 *
 * \return a collection of keys associated with a latest number list.
 *             Nil is never returned.
 */
- (NSArray*) allLatestNumberListKeys;

/**
 * Retrieves the accumulating number associated with the given key.
 * If such a number does not exist, an empty AGSyncableAccumulatingNumber
 * container is returned which can be set. Once set, that value is
 * inserted into the map and automatically synchronized.
 *
 * \arg key
 *            The name of the accumulating number to return.  This
 *            cannot be nil or empty.
 * \return The accumulating number associated with the given key.
 *            Nil is never returned
 */
- (AGSyncableAccumulatingNumber*) accumulatingNumberForKey:(NSString*) key;

/**
 * Retrieves a collection of keys associated with an accumulating number.
 *
 * \return a collection of keys associated with an accumulating number.
 *             Nil is never returned.
 */
- (NSArray*) allAccumulatingNumberKeys;

/**
 * Retrieves the latest string associated with the given key.
 * If such a string does not exist, an empty AGSyncableNumber
 * container is returned which can be set. Once set, that value is
 * inserted into the map and automatically synchronized.
 *
 * \arg key
 *            The name of the latest string to return.  This
 *            cannot be nil or empty.
 * \return The latest string associated with the given key.
 *            Nil is never returned
 */
- (AGSyncableString*) latestStringForKey:(NSString*)key;

/**
 * Retrieves a collection of keys associated with a latest string.
 *
 * \return a collection of keys associated with a latest string.
 *             Nil is never returned.
 */
- (NSArray*) allLatestStringKeys;

/**
 * Retrieves the developer string associated with the given key.
 * If such a string does not exist, an empty SyncableDeveloperString
 * container is returned which can be set. Once set, that value is
 * inserted into the map and automatically synchronized.
 *
 * \arg key
 *            The name of the latest string to return.  This
 *            cannot be nil or empty.
 * \return The developer string associated with the given key.
 *            Nil is never returned
 *
 */
- (AGSyncableDeveloperString*) developerStringForKey:(NSString*)key;

/**
 * Retrieves a collection of keys associated with developer strings.
 *
 * \return a collection of keys associated with developer strings.
 *             Nil is never returned.
 */
- (NSArray*) allDeveloperStringKeys;

/**
 * Retrieves the latest string list associated with the given key.
 * Latest string lists are sorted in order of the most recently set
 * values first, where ties resolve in alphabetical order by value.
 * If such a list does not exist, an empty AGSyncableStringList container
 * is returned which can be set. Once set, that list is inserted into
 * the map and automatically synchronized.
 *
 * \arg key
 *            The name of the latest string list to return.  This
 *            cannot be nil or empty.
 * \return The latest string list associated with the given key.
 *            Nil is never returned
 */
- (AGSyncableStringList*) latestStringListForKey:(NSString*)key;

/**
 * Retrieves a collection of keys associated with a latest string list.
 *
 * \return a collection of keys associated with a latest string list.
 *             Nil is never returned.
 */
- (NSArray*) allLatestStringListKeys;

/**
 * Retrieves the string set associated with the given key.
 * If such a set does not exist, an empty AGSyncableStringSet
 * container is returned which can be set. Once set, that set is
 * inserted into the map and automatically synchronized.
 *
 * \arg key
 *            The name of the latest string set to return.  This
 *            cannot be nil or empty.
 * \return The latest string set associated with the given key.
 *            Nil is never returned
 */
- (AGSyncableStringSet*) stringSetForKey:(NSString*)key;

/**
 * Retrieves a collection of keys associated with a latest string set.
 *
 * \return a collection of keys associated with a latest string set.
 *             Nil is never returned.
 */
- (NSArray*) allStringSetKeys;

/**
 * Retrieves the nested-map associated with the given key.
 * If such a map does not exist, an empty GameDataMap
 * container is returned which can be set. Once set, that nested-map is
 * inserted into the map and automatically synchronized.
 *
 * \arg key
 *            The name of the nested-map to return.  This
 *            cannot be nil or empty.
 * \return The nested-map associated with the given key.
 *            Nil is never returned
 */
- (AGGameDataMap*) mapForKey:(NSString*)key;

/**
 * Retrieves a collection of keys associated with a nested-map.
 *
 * \return a collection of keys associated with a nested-map.
 *             Nil is never returned.
 */
- (NSArray*) allMapKeys;

@end
