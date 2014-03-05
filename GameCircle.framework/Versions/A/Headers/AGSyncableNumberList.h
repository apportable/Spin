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
#import "AGSyncableList.h"

/**
 * \protocol AGSyncableNumberList
 * A syncable type that represents a list of fixed numbers.  The list has
 * a configurable max size, and is typically used to represent a top N list
 * of highest numbers or lowest numbers across multiple devices.  Examples
 * are top 10 scores and top 10 fastest times.  Note that metadata cannot
 * be associated with this type, but metadata can be associated with its
 * elements.
 *
 * \see AGSyncableNumberElement
 */
@protocol AGSyncableNumberList <AGSyncableList>

/**
 * Adds a AGSyncableNumberElement to this list with the given value.
 *
 * \arg value The value to be added to this list.
 *
 * \see AGSyncableNumberElement
 */
- (void) addValue:(NSNumber*)value;

/**
 * Adds a AGSyncableNumberElement to this list with the
 * given value and optional metadata.
 *
 * \arg value The value to be added to this list.
 * \arg metadata The metadata associated with the value. It can be nil.
 *
 * \see AGSyncableNumberElement
 */
- (void) addValue:(NSNumber*)value withMetadata:(NSDictionary*)metadata;

@end


@interface AGSyncableNumberList <AGSyncableNumberList>

@end
