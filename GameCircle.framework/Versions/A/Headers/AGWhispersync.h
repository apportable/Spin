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
#import "AGGameDataMap.h"

/**
 * Notifications an application can listen to
 */
FOUNDATION_EXPORT NSString* const AGWhispersyncNotificationNewDataFromCloud;
FOUNDATION_EXPORT NSString* const AGWhispersyncNotificationDataUploadedToCloud;
FOUNDATION_EXPORT NSString* const AGWhispersyncNotificationThrottled;
FOUNDATION_EXPORT NSString* const AGWhispersyncNotificationDiskWriteComplete;
FOUNDATION_EXPORT NSString* const AGWhispersyncNotificationFirstSync;

/**
 * \class AGWhispersync
 * Interface for accessing Whispersync for games.
 *
 */
@interface AGWhispersync : NSObject

/**
 * \return the GameDataMap currently stored in memory.  If the game data has not yet been loaded from disk,
 *         this call may block on I/O.
 */
@property (nonatomic, readonly, strong) AGGameDataMap* gameData;

/**
 * Manually triggers a background thread to write in-memory game data to only the local storage.
 */
- (void)flush;

/**
 * \return a singleton instance of the Whispersync Client
 */
+ (instancetype) sharedInstance;

/**
 * Manually triggers a background thread to synchronize in-memory game data with local storage and the cloud.
 */
- (void)synchronize;

@end
