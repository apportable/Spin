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

static const int AGSyncableListMaximumCapacity = 1000;
static const int AGSyncableListDefaultCapacity = 5;

/**
 * \protocol AGSyncableList
 * A syncable type that represents a list of fixed numbers.  The list has
 * a configurable max size, and is typically used to represent a top N list
 * of highest numbers or lowest numbers across multiple devices. The 
 * aforementioned N can be set by setting the capacity of the list. This
 * capacity cannot exceed AGSyncableListMaximumCapacity. AGSyncableLists 
 * start with a default capacity of AGSyncableListDefaultCapacity. Examples
 * are top 10 scores and top 10 fastest times.  Note that metadata cannot
 * be associated with this type, but metadata can be associated with each of
 * its elements.
 *
 * \see AGSyncableNumberList
 * \see AGSyncableStringList
 */
@protocol AGSyncableList <NSObject>

@property (nonatomic, readonly, assign) BOOL isSet;
@property (nonatomic, assign) int capacity;

/**
 * \return a non-nil immutable copy of the elements of this list as an NSArray.
 */
- (NSArray*) values;

@end
