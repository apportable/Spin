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
 * \class AGAchievementDescription
 * Represents the metadata for a single achievement
 */
@interface AGAchievementDescription : NSObject

@property (nonatomic, readonly, copy) NSString* achievementID;
@property (nonatomic, readonly, copy) NSString* title;
@property (nonatomic, readonly, copy) NSString* detailText;
@property (nonatomic, readonly, assign) int index;

@property (nonatomic, readonly, assign) int points;
@property (nonatomic, readonly, assign) BOOL hidden;

@property (nonatomic, readonly, assign) float progress;
@property (nonatomic, readonly, assign, getter=isUnlocked) BOOL unlocked;
@property (nonatomic, readonly, strong) NSDate* unlockedDate;
@property (nonatomic, readonly, copy) NSURL* imageURL;

@end


/** 
 * \class AGAchievement
 * This class controls access to a game's achievements
 * \class GameCircle must be initialized before using this client.
 */
@interface AGAchievement : NSObject

@property (nonatomic, readonly, copy) NSString* achievementID;

/** 
 * Returns the specified achievement object for a given ID.
 *
 * \arg achievementId The ID of the achievement to retrieve.
 * \return Achievement object corresponding to the achievement ID
 */
+ (instancetype) achievementWithID:(NSString*) achievementID;

/**
 * Returns a list of achievement object descriptions to the provided handle.
 * The list returned in the response includes all visible achievements for the game.
 * Visible achievements include those that were never hidden, and those that were once hidden
 * but since made visible.  Each achievement object in the list includes the current player's
 * progress toward the achievement.
 *
 * \arg completionHandler A handle to poll for completion.  Must not be nil.
 */
+ (void) allDescriptionsWithCompletionHandler:(void (^)(NSArray* descriptions, NSError* error)) completionHandler;

/** 
 * Returns the achievement description for a specific achievement object through a provided handle.
 *
 * \arg completionHandler A handle to poll for completion.  Must not be nil.
 */
- (void) descriptionWithCompletionHandler:(void (^)(AGAchievementDescription* description, NSError* error)) completionHandler;

/**
 * Updates progress toward the specified achievement by the specified amount.
 * If a value outside of range is submitted, it is capped at 100 or 0.
 * If the submitted value is less than the stored value, the update is ignored.
 *
 * \arg percentComplete A float between 0.0f and 100.0f, inclusive
 * \arg completionHandler A handle to poll for completion.  Can be nil.
 */
- (void) updateWithProgress:(float) percentComplete
          completionHandler:(void (^)(BOOL newlyUnlocked, NSError* error)) completionHandler;

@end
