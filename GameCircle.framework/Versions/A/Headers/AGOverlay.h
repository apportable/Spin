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
#import <UIKit/UIKit.h>

/**
 * \typedef AGOverlayState
 * Possible views to display
 */
typedef NS_OPTIONS(NSUInteger, AGOverlayState) {
    AGOverlaySummary,
    AGOverlayLeaderboards,
    AGOverlayAchievements,
    AGOverlaySignIn
};


/**
 * \class AGOverlay
 * This class controls access to GameCircle related overlays
 */
@interface AGOverlay : NSObject

/**
 * Handler to call when the overlay is about to show
 */
@property (nonatomic, copy) void (^willShowHandler) ();

/**
 * Handler to call after the overlay has been dismissed
 */
@property (nonatomic, copy) void (^didDismissHandler) ();


/**
 * \return The overlay object.
 */
+ (AGOverlay*) sharedOverlay;

/**
 * Displays the GameCircle overlay
 *
 * \arg animated Whether or not the transition should be animated
 */
- (void) showGameCircle:(BOOL)animated;

/**
 * Displays the GameCircle overlay with a specific state
 *
 * \arg state This specifies the view that should be displayed
 * \arg animated Whether or not the transition should be animated
 */
- (void) showWithState:(AGOverlayState)state animated:(BOOL)animated;

/**
 * Displays the GameCircle overlay with a specific leaderboard
 *
 * \arg leaderboardID Specifies the leaderboard id to show the overlay for.
 * \arg animated Whether or not the transition should be animated
 */
- (void) showWithLeaderboardID:(NSString*)leaderboardID animated:(BOOL)animated;

/**
 * Dismisses the GameCircle overlay
 *
 * \arg animated Whether or not the transition should be animated
 */
- (void) dismiss:(BOOL)animated;

@end
