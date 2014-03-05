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
 * \protocol AGSyncableNumberElement
 * Represents an element in a \link AGSyncableNumberList \endlink.  This
 * type is immutable and can have metadata associated with it.  An example 
 * is a score in a list of top 10 scores.
 *
 * \see SyncableNumberList
 */
@protocol AGSyncableNumberElement <AGSyncableElement>

@property (nonatomic, readonly, strong) NSNumber* value;

@end


@interface AGSyncableNumberElement <AGSyncableNumberElement>

@end
