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
#import "AGSyncableElement.h"

/**
 * \protocol AGSyncableStringElement
 * Represents an element in a \link SyncableStringList \endlink.  This 
 * type isimmutable and can have metadata associated with it.  An example
 * is the name of an item in a player's list of last accessed items in their
 * inventory.
 *
 * \see SyncableStringList
 */
@protocol AGSyncableStringElement <AGSyncableElement>

@property (nonatomic, readonly, copy) NSString* value;

@end


@interface AGSyncableStringElement <AGSyncableStringElement>

@end
