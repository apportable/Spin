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

/**
 * ProfilesClientInterface.h
 *
 * Client interface class for requesting information from the Amazon Games Profiles service.
 */

#ifndef __PROFILES_CLIENT_INTERFACE_H_INCLUDED__
#define __PROFILES_CLIENT_INTERFACE_H_INCLUDED__

#include "AGSClientCommonInterface.h"

namespace AmazonGames {

    //************************************
    // Data access structures
    //************************************
    struct PlayerInfo {
        const char* playerId;
        const char* alias;
        const char* avatarURL;

        PlayerInfo()
            : alias(0), playerId(0), avatarURL(0)
        {}
    };

    //************************************
    // Callback classes
    //************************************
    class IProfileGetLocalPlayerProfileCb : public ICallback {
    public:
        virtual void onGetLocalPlayerProfileCb(
                    ErrorCode errorCode,
                    const PlayerInfo* responseStruct,
                    int developerTag) = 0;
    };

    //************************************
    // Handle classes
    //************************************

    // All Handle classes have these functions:
    //    HandleStatus getHandleStatus();
    //    ErrorCode getErrorCode();
    //    int getDeveloperTag();

    class ILocalPlayerProfileHandle : public IHandle {
    public:
        virtual const AmazonGames::PlayerInfo* getResponseData() = 0;

        virtual ILocalPlayerProfileHandle* clone() const = 0;
    };

    //************************************
    // Listener classes
    //************************************

    class SignedInStateChangedListener : public ICallback {
    public:
        virtual void onSignedInStateChanged(bool isSignedIn) = 0;
    };

    //************************************
    // Profiles Client Interface
    //************************************

    class ProfilesClientInterface {

    public:
        //************************************
        // Callbacks
        //************************************
        static void getLocalPlayerProfile(
                IProfileGetLocalPlayerProfileCb* const callback,
                int developerTag = 0);

        //************************************
        // Handles
        //************************************
        static HandleWrapper<ILocalPlayerProfileHandle> getLocalPlayerProfile(
                int developerTag = 0);

        static void setSignedInStateChangedListener(SignedInStateChangedListener* signedInStateChangedListener);

        //************************************
        // Poll function for signed in
        //************************************
        static bool isSignedIn();
    };
}

#endif
