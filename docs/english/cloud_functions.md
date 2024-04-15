# Cloud Functions

To get better performance, Firefluttter uses Cloud Functions.

## Push Notifications

The `sendPushNotifications` cloud function can be used to send push notifications to users.

### Sending push notification on each chat message

The cloud function for sending push notification on each chat message is named `sendMessagesToChatRoomSubscribers`. It sends push notification to all the users who have joined the chat room.

### Sending push notification to Forum Category Subscribers

The cloud function for sending push notification on each chat message is named `sendMessagesToCategorySubbscribers`. It sends push notification to all the users who have subscribed to the forum category.

## Typesense Cloud Functions

To add Typesense, must have a Typesense Server running. Make sure to include the schema. Refer to [typesense.md](typesense.md#schema)

### Indexing User Data into typesense

The cloud function to index user data into typesense is named `typesenseUserIndexing`. It indexes user data into typesense upon create, update or delete of user data.

### Indexing Post Data into typesense

The cloud function to index post data into typesense is named `typesensePostIndexing`. It indexes user data into typesense upon create, update or delete of post data.

### Indexing Comment Data into typesense

The cloud function to index comment data into typesense is named `typesenseCommentIndexing`. It indexes user data into typesense upon create, update or delete of comment data.

## Post Summaries upon Post Create/Update/Delete

- We have cloud functions that whenever a post is created/updated/deleted in `posts`, it updates `post-all-summaries` and `post-summaries`.

### managePostsAllSummary

This cloud function updates `post-all-summaries` and `post-summaries` based on `posts`.

Be informed that we are only saving the first url of the post in summaries.

## User Cloud Functions

Refer to the [user documentation](user.md) for details.

Also, take a look at `user.functions.ts`.

Cloud functions provide various functions to enhance user functionality, and you can install only what you need.

- The `userLike` handles tasks such as notifying when A likes B and updating the total number of likes. This function takes care of these miscellaneous tasks.
- The `userMirror` moves the `/users` node in the Realtime Database to the `/users` collection in Firestore. By doing this, if you need to perform more complex user searches, you can filter them through Firestore and display them on the screen. One thing to note is that the `noOfLikes` field is not mirrored. The reason for this is that when a like/unlike occurs in the user list, the `/users/<uid>/noOfLikes` in the Realtime Database increases/decreases, which changes the data value in Firestore's `/users`. If you are filtering users through queries like FirestoreListView, whenever a user document changes, all lists (searched items) need to be redrawn, leading to screen flickering.

## Phone Number Sign-Up

The cloud function for Phone Number Sign-Up is named `phoneNumberRegister`. The function for phone number sign-up was created for the following reasons:

- When developing an app for seniors, signing up can be very challenging for them. Seniors often struggle to verify their phone number through text messages, and they may have difficulty creating and remembering passwords, leading to forgetfulness later on. Therefore, the idea is to allow sign-up with just a phone number. If the phone number is already registered, then verification via text message is required to sign up. In other words, for the first login, registration can be done without text message verification. For subsequent logins, verification via text message is required for registration.

When making the request, simply input the phone number you wish to sign up with into the phoneNumber field. If the phone number is not provided, or if it is too short or too long, the function will throw an error. Otherwise, Firebase will handle the error.

- Request: `?phoneNumber=12345`
  - Result: `{ code: 'auth/invalid-phone-number', message: '...' }`
- Request: `?phoneNumber=1234567890123456`
  - Result: `{ code: 'auth/invalid-phone-number', message: '...' }`
- Request: `/?phoneNumber=1234567890`
  - Result: `{ code: 'auth/invalid-phone-number', message: '...' }`
- If the phone number already exists, an error will be returned, such as `{ code: 'auth/phone-number-already-exists', message: '...' }`.
- Upon successful sign-up:
  - Result: `{ uid: 'YSr8fJwQASSF4QApILkaAEjbfCd2' }`

## Mirror Functions

<!-- TODO -->

## Function Testing

Refer to the [testing document](./test.md).
