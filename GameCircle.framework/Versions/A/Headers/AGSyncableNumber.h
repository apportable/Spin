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
#import "AGSyncableNumberElement.h"

/**
 * \protocol AGSyncableNumber
 * A syncable type that represents a generic number.  This is typically used
 * to represent a highest number, lowest number, or latest number across
 * multiple devices.  Examples are a high score, fastest time, or current
 * level.  Note that metadata can be associated with this syncable type.
 *
 * \see AGSyncableNumberElement
 * \see AGSyncableElement
 */
@protocol AGSyncableNumber <AGSyncableNumberElement>

@property (nonatomic, readonly, assign) BOOL isSet;

/**
 * Sets the value of this AGSyncableNumber.
 *
 * \arg value The value to be set, must not be nil.
 */
- (void) setValue:(NSNumber*)value;

/**
 * Sets the value of this AGSyncableNumber along with optional metadata.
 *
 * \arg value The value to be set. It must not be nil.
 * \arg metadata The metadata associated with this AGSyncableNumber. It can be nil.
 */
- (void) setValue:(NSNumber*)value withMetadata:(NSDictionary*)metadata;

@end


@interface AGSyncableNumber <AGSyncableNumber>

@end
