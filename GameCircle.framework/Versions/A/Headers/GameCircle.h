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

#import "AGAchievement.h"
#import "AGLeaderboard.h"
#import "AGOverlay.h"
#import "AGPlayer.h"
#import "AGWhispersync.h"


/**
 * Enumeration of GameCircle features.
 */
FOUNDATION_EXPORT NSString* const AGFeatureAchievements;
FOUNDATION_EXPORT NSString* const AGFeatureLeaderboards;
FOUNDATION_EXPORT NSString* const AGFeatureWhispersync;


/**
 * Enumeration for the placement of toasts.
 */
typedef NS_OPTIONS(NSUInteger, AGToastLocation) {
    AGToastLocationTopLeft = 0,
    AGToastLocationTopRight,
    AGToastLocationBottomLeft,
    AGToastLocationBottomRight,
    AGToastLocationTopCenter,
    AGToastLocationBottomCenter
};

static const AGToastLocation AGToastLocationDefault = AGToastLocationTopRight;


/**
 * Enumeration for configuring the logging level.
 */
typedef enum {
    AGLogOff,
    AGLogCritical,
    AGLogError,
    AGLogWarning
} AGLogLevel;


/**
 * \class GameCircle
 * The top level client for all Amazon Games functionality.
 */
@interface GameCircle : NSObject

/**
 * Set the location for toast notifications
 *
 * \arg location
 */
+ (void) setToastLocation:(AGToastLocation)location;

/**
 * Set whether toasts notifications are shown. Default is YES.
 *
 * \arg enabled
 */
+ (void) setToastsEnabled:(BOOL)enabled;

/**
 * Asynchronously initializes the GameCircle client, with the given completion handler.
 * 
 * \arg features An array of GameCircle features (as defined by the AGFeature* strings) the game uses.
 * \arg completionHandler A handler to specify successful or failed initialization behavior.  Must not be nil.
 */
+ (void) beginWithFeatures:(NSArray*)features completionHandler:(void (^)(NSError* error)) completionHandler;

/**
 * \return Whether or not this GameCircle client has been initialized and is ready.
 */
+ (BOOL) isInitialized;

/**
 * Handles behavior for when the game's application delegate class receives a URL call
 * from Login With Amazon's authentication page.  Call this to ensure the GameCircle client 
 * is able to sign the customer in successfully.
 *
 * \arg url The custom URL call received by application delegate
 * \arg sourceApplication The application making this custom URL call
 */
+ (BOOL) handleOpenURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication;

/**
 * Enables Game Center support for leaderboards and achievements. Whenever a GameCircle
 * achievement is submitted, the game's equivalent Game Center achievement is also submitted.
 * Likewise with leaderboard scores.  Make sure to register your game on the iOS Dev Portal.
 * Also make sure achievements and leaderboards are registered on iTunes Connect.  
 *
 * \arg achievementIDMappings A dictionary of Game Center achievement IDs to GameCircle achievement IDs.
 *                            Pass nil if mapping is one-to-one
 * \arg leaderboardIDMappings A dictionary of Game Center leaderboard IDs to GameCircle leaderboard IDs.
 *                            Pass nil if mapping is one-to-one
 * \arg completionHandler Used to propogate back error if any during sign in
 */
+ (void) enableGameCenterWithAchievementIDMappings:(NSDictionary*)achievementIDMappings leaderboardIDMappings:(NSDictionary*)leaderboardIDMappings
                                 completionHandler:(void (^)(NSError* error)) completionHandler;

/**
 * Used for configuring logging level. See enum AGLogLevel above. By default, logging level is set to Warning
 * 
 * \arg logLevel The desired logging level
 */
+ (void) configureLoggingWithLevel:(AGLogLevel)logLevel;

@end
