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
 * \typedef SignedInStateDidChangeHandlerType
 * Function signature for SignedInStateDidChange handler
 *
 * \arg isSignedIn Indicates that the local player has just signed in if set to YES,
 *   or signed out if set to NO.
 */
typedef void (^AGSignedInStateDidChangeHandler)(BOOL isSignedIn);


/** 
 * \class AGPlayer
 * This class controls access to a player's profile.
 * \class GameCircle must be initialized before using this client.
 */
@interface AGPlayer : NSObject

@property (nonatomic, readonly, copy) NSString* alias;
@property (nonatomic, readonly, copy) NSString* playerID;
@property (nonatomic, readonly, copy) NSURL* avatarURL;

/** 
 * This asynchronously retrieves the current player's profile, which consists of an 
 * alias and player ID.
 *
 * \arg completionHandler A handle to poll for completion.  Must not be nil.
 */
+ (void) localPlayerWithCompletionHandler:(void (^)(AGPlayer* player, NSError* error)) completionHandler;

/**
 * Handler to call when the local player's signed in state changes.
 *
 * \arg handler A handle to call when the local player's signed in state changes.
 */
+ (void) setSignedInStateDidChangeHandler:(AGSignedInStateDidChangeHandler) handler;

+ (BOOL) isLocalPlayerSignedIn;

@end
