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
 * \protocol AGSyncableElement
 * A protocol for syncable elements which have metadata and a timestamp
 * associated with it.
 *
 * \see AGSyncableNumberElement
 * \see AGSyncableStringElement
 */
@protocol AGSyncableElement <NSObject>

@property (nonatomic, readonly, strong) NSDate* timestamp;
@property (nonatomic, readonly, strong) NSDictionary* metadata;

@end
