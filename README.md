Spin
====

A simple OpenGL ES 1 spinning cube.  But with Achievements!  And Leaderboards!  Demonstrates using iOS GameKit API backed by Google Play Games Services or Amazon GameCircle on the Apportable platform.

To get this running:
-------------------

* Set the proper value of CFBundleIdentifier in Spin/Spin-Info.plist

* For Google Play Games : Set up your app in the [Google developer console](https://play.google.com/apps/publish/) according to the [directions](http://docs.apportable.com/publishing.html#google-games-services).  Set the value of GOOGLE\_PLAY\_CLIENT\_ID in configuration.json

* For Amazon GameCircle : Set up your app in the [Amazon developer console](https://developer.amazon.com/public/apis/engage/gamecircle).  Set the proper API Key value in Spin.approj/assets/api\_key.txt

* Specify the TARGET\_APP\_STORE when building:

    TARGET_APP_STORE=google BUILD_TIMESTAMP=... SIGNING_PUBKEY=... ANDROID_KEYSTORE=... ANDROID_KEY_NAME=... ANDROID_KEYSTORE_PASS=... apportable load

    TARGET_APP_STORE=amazon BUILD_TIMESTAMP=... SIGNING_PUBKEY=... ANDROID_KEYSTORE=... ANDROID_KEY_NAME=... ANDROID_KEYSTORE_PASS=... apportable load

Links:
-----

* [Apportable documentation](http://docs.apportable.com/publishing.html#google-games-services) -- specifically see the
  Google Games Services section and Amazon GameCircle

* [Amazon GameCircle developer console setup instructions](https://developer.amazon.com/public/apis/engage/gamecircle)

* [Google developer console](https://play.google.com/apps/publish/)

