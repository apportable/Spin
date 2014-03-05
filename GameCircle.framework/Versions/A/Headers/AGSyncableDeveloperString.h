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
 * \protocol AGSyncableDeveloperString
 * A syncable type that represents a string whose conflict resolution
 * is handled by the developer. This type is typically used to represent
 * a combination of associated values across multiple devices. The values
 * should typically be serializable. An example is a player's basket that
 * holds both coins and items purchased. Note that metadata cannot be
 * associated with this type.
 */
@protocol AGSyncableDeveloperString <NSObject>

@property (nonatomic, readonly, assign) BOOL inConflict;
@property (nonatomic, readonly, assign) BOOL isSet;

/**
 * \property cloudValue
 * This property stores the value stored in the cloud of this SyncableDeveloperString.
 * This value is only available when there is a conflict.
 */
@property (nonatomic, readonly, copy) NSString* cloudValue;
@property (nonatomic, copy) NSString* value;


/**
 * \property cloudTimestamp
 * The time in which the cloud value of this element was set as the number of seconds
 * elapsed since January 1, 1970, 00:00:00 GMT.
 */
@property (nonatomic, readonly, assign) NSTimeInterval cloudTimestamp;

/**
 * \property timestamp
 * The time in which this element was set as the number of seconds
 * elapsed since January 1, 1970, 00:00:00 GMT.
 */
@property (nonatomic, readonly, assign) NSTimeInterval timestamp;

/**
 * Performs the conflict resolution once the developer has set the desired value.
 */
- (void) markAsResolved;

@end


@interface AGSyncableDeveloperString <AGSyncableDeveloperString>

@end
