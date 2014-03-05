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

FOUNDATION_EXPORT NSString* const AGLeaderboardFilterFriendsAllTime;
FOUNDATION_EXPORT NSString* const AGLeaderboardFilterGlobalAllTime;
FOUNDATION_EXPORT NSString* const AGLeaderboardFilterGlobalDay;
FOUNDATION_EXPORT NSString* const AGLeaderboardFilterGlobalWeek;

FOUNDATION_EXPORT NSString* const AGScoreFormatDuration;
FOUNDATION_EXPORT NSString* const AGScoreFormatNumeric;
FOUNDATION_EXPORT NSString* const AGScoreFormatUnknown;

@class AGPlayer;

/** 
 * \class AGScore
 *  This class holds the metadata surrounding a player's score on a given leaderboard
 */
@interface AGScore : NSObject

@property (nonatomic, readonly, copy) NSString* leaderboardID;
@property (nonatomic, readonly, copy) AGPlayer* player;
@property (nonatomic, readonly, assign) int rank;
@property (nonatomic, readonly, assign) int64_t score;
@property (nonatomic, readonly, copy) NSString* scoreString;
@property (nonatomic, readonly, copy) NSString* filter;

@end


/** 
 * \class AGLeaderboardDescription
 * This class holds the metadata surrounding a specified leaderboard
 */
@interface AGLeaderboardDescription : NSObject

@property (nonatomic, readonly, copy) NSString* leaderboardID;
@property (nonatomic, readonly, copy) NSString* title;
@property (nonatomic, readonly, copy) NSString* scoreUnit;
@property (nonatomic, readonly, copy) NSString* scoreFormat;
@property (nonatomic, readonly, copy) NSURL* imageURL;

@end


/**
 * \class AGLeaderboardPercentileItem
 * This class represents a player's percentile entry in a leaderboard
 */
@interface AGLeaderboardPercentileItem : NSObject

@property (nonatomic, readonly, assign) int percentile;
@property (nonatomic, readonly, copy) AGPlayer* player;
@property (nonatomic, readonly, assign) int64_t score;

@end


/**
 * \class AGLeaderboard 
 * This class controls access to a game's leaderboards
 * \class GameCircle must be initialized before using this client.
 */
@interface AGLeaderboard : NSObject

@property (nonatomic, readonly, copy) NSString* leaderboardID;

/** 
 * \return the specified leaderboard object.
 *
 * \arg leaderboardID Specifies the leaderboard id to query for.
 */
+ (instancetype) leaderboardWithID:(NSString*)leaderboardID;

/**
 * Returns a list of Leaderboard object descriptions to the returned handle.
 * The list returned in the response includes all visible leaderboards for the game.
 *
 * This is an asynchronous operation.
 *
 * \arg completionHandler A handle to poll for completion.  Must not be nil.
 */
+ (void) allDescriptionsWithCompletionHandler:(void (^)(NSArray* descriptions, NSError* error)) completionHandler;

/**
 * Returns the top 100 scores from a leaderboard based on the filter selected.
 *
 * This is an asynchronous operation.
 *
 * \arg leaderboardFilter Filter to apply to the request.  Must not be nil.
 * \arg completionHandler A handle to poll for completion.  Must not be nil.
 */
- (void) scoresWithFilter:(NSString*)leaderboardFilter
        completionHandler:(void (^)(NSArray* scores, AGLeaderboardDescription* description, NSError* error)) completionHandler;

/**
 * Requests the current user's top ranked score for the leaderboard. The passed callback will
 * be called when the operation is complete.
 *
 * This is an asynchronous operation.
 *
 * \arg leaderboardFilter Filter to apply to the request.  Must not be nil.
 * \arg completionHandler A handle to poll for completion.  Must not be nil.
 */
- (void) localPlayerScoreWithFilter:(NSString*)leaderboardFilter
                  completionHandler:(void (^)(AGScore* score, NSError* error)) completionHandler;

/**
 * Requests the percentile ranks for the passed leaderboard.
 *
 * This is an asynchronous operation.
 *
 * \arg leaderboardFilter Filter to apply to the request.  Must not be nil.
 * \arg completionHandler A handle to poll for completion.  Must not be nil.
 */
- (void) percentileRanksWithFilter:(NSString*)leaderboardFilter
                 completionHandler:(void (^)(NSArray* percentiles, int playerIndex, AGLeaderboardDescription* description, NSError* error)) completionHandler;

/**
 * Submit a score the leaderboard. The passed callback will be called when the
 * operation is complete.
 *
 * This is an asynchronous operation.
 *
 * \arg score Score to submit.
 * \arg completionHandler A handle to poll for completion.  Can be nil.
 */
- (void) submitWithScore:(int64_t)score
       completionHandler:(void (^)(NSDictionary* rank, NSDictionary* rankImproved, NSError* error)) completionHandler;

@end
