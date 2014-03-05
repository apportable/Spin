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
 * AGError defines the error domain and enumeration of error codes for
 * errors originating from the GameCircle SDK.  All GameCircle errors are
 * represented as \class NSError objects whose user info dictionary 
 * contains information about whether the associated failed operation is 
 * retryable, as well as a localized description to help troubleshoot the 
 * particular error.
 *
 * For example, given an \class NSError object called "error":
 *
 * NSInteger code = error.code;
 * BOOL isRetryable = error.userInfo[AGRetryableKey];
 * NSString* description = [error localizedDescription];
 */

// GameCircle's error domain
FOUNDATION_EXPORT NSString* const AGErrorDomain;

// User info dictionary keys
FOUNDATION_EXPORT NSString* const AGRetryableKey;
FOUNDATION_EXPORT NSString* const AGLocalizedDescriptionKey;

typedef enum {
    /**
     * An unexpected error occurred, and is generally unrecoverable.
     * See userInfo for additional troubleshooting details.
     */
    AGErrorUnknown = 1,
    
    /**
     * An error that occurs if the format of an input parameter is
     * invalid.  For example, if an input is unexpectedly nil, or if
     * a percent is not within [0, 100].  This error is not retryable,
     * and can be fixed by verifying the format of the input.
     */
    AGErrorInvalidInputFormat = 2,
    
    /**
     * An error that occurs if a given entity (player, game, leaderboard,
     * achievement, etc.) does not exist.  This error is not retryable,
     * and can be fixed by verifying the existence of the given entity.
     */
    AGErrorUnknownEntity = 3,

    /**
     * An error that occurs if there is a failure accessing a resource,
     * whether that be a database, a file on disk, or URL.  This error
     * is not retryable, and can be addressed by verifying the existence
     * or permissions of the given resource.  See userInfo for details.
     */
    AGErrorFailedResourceAccess = 4,

    /**
     * An error that occurs if there is not enough disk space to conduct
     * normal GameCircle SDK operations.  This error is not retryable and
     * may result in incorrect behavior.  
     */
    AGErrorOutOfDiskSpace = 5,
    
    /**
     * A retryable error resulting from a failed GameCircle initialization.
     */
    AGErrorInitialization = 6,
    
    /**
     * A retryable error resulting from a failed GameCircle user Authentication.
     */
    AGErrorAuthentication = 7,

    /**
     * A retryable error resulting from a failed Game Center user Authentication.
     */
    AGErrorGameCenterAuthentication = 8,
    
    /**
     * A retryable error resulting from a failed network communication.
     * In this case, network connectivity is known to be on, but a network 
     * request resulted in an http error code.
     */
    AGErrorNetwork = 9,
    
    /**
     * A retryable error resulting from a failed submission of data to the cloud.
     */
    AGErrorCloudSubmission = 10,
    
    /**
     * A retryable error resulting from a failed retrieval of data from the cloud.
     */
    AGErrorCloudRetrieval = 11,
    
    /**
     * A retryable error resulting from a failed submission of data to Game Center.
     */
    AGErrorGameCenterSubmission = 12,

} AGErrorCode;

