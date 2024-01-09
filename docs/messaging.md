# Messaging


## Overview

### FCM and tokens

Fireship uses FCM to send messages to devices.

The tokens are saved under `/user-fcm-tokens/<token> { uid: [user uid], platform: [android or ios]}`


## Send a message to a user

One user may use multiple devices and one device may have multiple tokens. So, if the app sends a message to A, the app must query to get the tokens of A in `/user-fcm-tokens`



## Backend

To send push notifications, The firebase cloud function named `sendPushNotifications` in `firebase/functions/src/index.ts` must be installed. See installation on how to install firebsae functions.

