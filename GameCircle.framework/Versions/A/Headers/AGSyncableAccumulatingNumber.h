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

/**
 * \protocol AGSyncableAccumulatingNumber
 * A syncable type that represents a number that can be incremented
 * and decremented.  This is typically used to represent a number that
 * is to be accumulated across multiple devices.  An example is gems
 * collected in Temple Run 2.  Note that metadata cannot be associated
 * with this syncable type.
 */
@protocol AGSyncableAccumulatingNumber <NSObject>

@property (nonatomic, readonly, strong) NSNumber* value;

/**
 * Increments this AGSyncableAccumulatingNumber by the given value.
 *
 * \arg delta how much to increase this AGSyncableAccumulatingNumber by.
 */
- (void) incrementValue:(NSNumber*)delta;

/**
 * Decrements this AGSyncableAccumulatingNumber by the given value.
 *
 * \arg delta how much to increase this AGSyncableAccumulatingNumber by.
 */
- (void) decrementValue:(NSNumber*)delta;

@end


@interface AGSyncableAccumulatingNumber <AGSyncableAccumulatingNumber>

@end
