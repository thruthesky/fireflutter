# Easy Extension


- [Easy Extension](#easy-extension)
- [Overview](#overview)
- [TODO](#todo)
- [Installation](#installation)
  - [Installation Options](#installation-options)
- [Setting admin](#setting-admin)
- [Command list](#command-list)
  - [Updating auth custom claims](#updating-auth-custom-claims)
  - [Disable user](#disable-user)
  - [Enable user](#enable-user)
  - [Delete user](#delete-user)
  - [Get user](#get-user)
- [User management](#user-management)
  - [User document creation](#user-document-creation)
  - [User Sync](#user-sync)
  - [User Sync Backfill](#user-sync-backfill)
- [Forum management](#forum-management)
- [Error handling](#error-handling)
- [Deploy](#deploy)
- [Unit Testing](#unit-testing)
  - [Testing on Local Emulators](#testing-on-local-emulators)
  - [Testing on real Firebase](#testing-on-real-firebase)
- [Tips](#tips)
- [Security rules](#security-rules)
- [Developer installation](#developer-installation)


# Overview

The easy extension helps you to manage your firebase easily. It supports some features that client SDK does not. For instance, you can do the custom claims management with this easy extension where you cannot do it with the client SDK.

It supports some work that is not easy to achieve. Like the count of posts. It should be incremented when there is new post. But the permission must be locked to users since a hacker and fix this value if it's open.

It also supports some features to simplify the client end work.

The principle of using this extension is that you should only use this extension if you cannot make the same feature on client-end.


# TODO

- update user password
- delete `userSync` because it can be by client end.

# Installation

 Install Link


To install the easy extension, click one of the version linke below. See the change logs for the change of each version.
- [Beta 0.1.10-beta.3](https://console.firebase.google.com/project/_/extensions/install?ref=jaehosong/easy-extension@0.1.10-beta.3)
- [Beta (0.1.8-beta.2)](https://console.firebase.google.com/project/_/extensions/install?ref=jaehosong/easy-extension@0.1.8-beta.2)
- [Beta (0.1.5-beta.0)](https://console.firebase.google.com/project/_/extensions/install?ref=jaehosong/easy-extension@0.1.5-beta.0)
- [Beta (0.1.4-beta.0)](https://console.firebase.google.com/project/_/extensions/install?ref=jaehosong/easy-extension@0.1.4-beta.0)
- [Beta (0.1.0-beta.0)](https://console.firebase.google.com/project/_/extensions/install?ref=jaehosong/easy-extension@0.1.0-beta.0)
- [Alpha (0.0.21-alpha.1)](https://console.firebase.google.com/u/0/project/_/extensions/install?ref=jaehosong%2Feasy-extension@0.0.22-alpha.0)


## Installation Options

* `User collection path` is the user collectin path in firestore.
* `Create user document on user create` If set to "Yes", the extension will automatically create the Firestore user document when the user is created on Firebase Authentication.
* `Delete user document on user delete` If set to "Yes", the extension will automatically delete the Firestore user document when the user is deleted from Firebase Authentication.
* `Sync back to user document when custom claims are updated` If set to "Yes", custom claims will be sync back to user's document after updating the user's custom claims.
* `Set back the disabled field to user document` If set to \"Yes\", the disabled field will be set if the user is disabled or enabled.


Note that, the document id under `/users` collection must be the same string as user's uid. The document will be created if it does not exist.
Note that, the custom claims and the disabled field will be sync back only after the `easy comamnd` runs. If you change the properties with your hand or by other means, it will not update on the user's document.


# Setting admin

* If the `/settings/admins` document does not exists, it means that the there is no admin yet.
  * You can set it with `setAdmin` api call.
    * This is only onetime call and once set, it cannot be called(re-used) again.
    * If you want to have more admins with different roles, you can go for your own way.
      * For instance, you want to add more admins, then add more admins simply the way how firestore work. (1) secure the `/settings/admins` document with admin permission. (2) then, add more uid (with that admin login)
      * Or if you want to add sub-admins, then just do as the firestore ways with your client. No need to get help from backend once you have set an admin. (And from that admin, you can do whatever you want.)





# Command list


When a document is created under the `easy-commands` collection, the firebase background function will execute the comamnd specified in `{ command: ... }`.

The `easy-commands` collection must be secured by the security rules with the admins listed in `/settings/admins` document.


* Currently supported commands are
  * `update_custom_claims`
  * `disable_user`
  * `enable_user`
  * `get_user`
  * `delete_user`


## Updating auth custom claims

- Required properties
  - `{ command: 'update_custom_claims' }` - the command.
  - `{ uid: 'xxx' }` - the user's uid that the claims will be applied to.
  - `{ claims: { key: value, xxx: xxx, ... } }` - other keys and values for the claims.

- example of document creation for update_custom claims


![Image Link](https://github.com/thruthesky/easy-extension/blob/main/docs/command-update_custom_claims_input.jpg?raw=true "This is image title")


- Response
  - `{ config: ... }` - the configuration of the extension
  - `{ response: { status: 'success' } }` - success respones
  - `{ response: { timestamp: xxxx } }` - the time that the executino had finished.
  - `{ response: { claims: { ..., ... } } }` - the claims that the user currently has. Not the claims that were requested for updating.


![Image Link](https://github.com/thruthesky/easy-extension/blob/main/docs/command-update_custom_claims_output.jpg?raw=true "This is image title")



- `SYNC_CUSTOM_CLAIMS` option only works with `update_custom_claims` command.
  - When it is set to `yes`, the claims of the user will be set to user's document.
  - By knowing user's custom claims,
    - the app can know that if the user is admin or not.
      - If the user is admin, then the app can show admin menu to the user.
    - Security rules can work better.




## Disable user

- Disabling a user means that they can't sign in anymore, nor refresh their ID token. In practice this means that within an hour of disabling the user they can no longer have a request.auth.uid in your security rules.
  - If you wish to block the user immediately, I recommend to run another command. Running `update_custom_claims` comand with `{ disabled: true }` and you can add it on security rules.
  - Additionally, you can enable `set enable field on user document` to yes. This will add `disabled` field on user documents and you can search(list) users who are disabled.



- `SYNC_USER_DISABLED_FIELD` option only works with `disable_user` command.
  - When it is set to yes, the `disabled` field with `true` will be set to user document.
  - Use this to know if the user is disabled.


- Request

```ts
{
  command: 'delete_user',
  uid: '--user-uid--',
}
```


## Enable user

- If the user is enabled, the `disabled` field will be deleted from user doc.

- Request

```ts
{
  command: 'enable_user',
  uid: '--user-uid--',
}
```


## Delete user

- This will delete the user account.
- If the `DELETE_USER_DOCUMENT` options is set to yes, then when the user is being deleted, the user document will be deleted also.


- Request

```ts
{
  command: 'delete_user',
  uid: '--user-uid--',
}
```


## Get user

- You can get the user by uid, email, phone number.
- You can use it for checking if the user exsits or not.

- Request
```ts
{
  command: 'get_user',
  by: 'uid',
  value: '--user-uid--'
}
```
```ts
{
  command: 'get_user',
  by: 'email',
  value: 'thruthesky@gmail.com'
}
```
```ts
{
  command: 'get_user',
  by: 'phoneNumber',
  value: '+821012345678'
}
```

- Result

```ts
{
  command: 'get_user',
  by: '...request-field....',
  value: '...request-value...',
  claims: { level: 13 },
  response: {
    status: 'success',
    data: {
      ...possible user fields like uid, email, phoneNumber, photoURL, creationTime, disabled...
    }
    timestamp: Timestamp { _seconds: 1690096498, _nanoseconds: 507000000 }
  }
}
```

- Example of real success result

```ts
{
  by: 'email',
  value: 'zv6ffg@gmail.com',
  command: 'get_user',
  response: {
    data: { uid: 'npwpG9xdbYVtaCJBwvMfRRjopgi1', email: 'zv6ffg@gmail.com' },
    status: 'success',
    timestamp: Timestamp { _seconds: 1690293479, _nanoseconds: 676000000 }
  },
  config: {
    setDisabledUserField: false,
    createUserDocument: false,
    syncCustomClaimsToUserDocument: false,
    userCollectionName: 'users',
    deleteUserDocument: false
  }
}
```

If user not exists, the status will be error.
```ts
{
  command: 'get_user',
  by: '...request-field....',
  value: '...request-value...',
  claims: { level: 13 },
  response: {
    status: 'success',
    data: {
      ...possible user fields like uid, email, phoneNumber, photoURL, creationTime, disabled...
    }
    timestamp: Timestamp { _seconds: 1690096498, _nanoseconds: 507000000 }
  }
}
```

- Example of real error result

```ts
{
  by: '---xxx---',
  value: 'q6uavr@gmail.com',
  command: 'get_user',
  response: {
    code: 'get_user/invalid-field',
    message: 'command execution error.',
    status: 'error',
    timestamp: Timestamp { _seconds: 1690293590, _nanoseconds: 313000000 }
  },
  config: {
    setDisabledUserField: false,
    createUserDocument: false,
    syncCustomClaimsToUserDocument: false,
    userCollectionName: 'users',
    deleteUserDocument: false
  }
}
```


- Firebase error code and message will be stored in the result like below if there is error on firebase auth.

```ts
{
  by: 'email',
  value: 'xxxxxxxxx@email.com',
  command: 'get_user',
  response: {
    code: 'auth/user-not-found',
    message: 'There is no user record corresponding to the provided identifier.',
    status: 'error',
    timestamp: Timestamp { _seconds: 1690293808, _nanoseconds: 736000000 }
  },
  config: {
    setDisabledUserField: false,
    createUserDocument: false,
    syncCustomClaimsToUserDocument: false,
    userCollectionName: 'users',
    deleteUserDocument: false
  }
}
```


```ts
{
  by: 'email',
  value: '......',
  command: 'get_user',
  response: {
    code: 'auth/invalid-email',
    message: 'The email address is improperly formatted.',
    status: 'error',
    timestamp: Timestamp { _seconds: 1690293767, _nanoseconds: 42000000 }
  },
  config: {
    setDisabledUserField: false,
    createUserDocument: false,
    syncCustomClaimsToUserDocument: false,
    userCollectionName: 'users',
    deleteUserDocument: false
  }
}
```




# User management


## User document creation

When the `Create the user document on user account creation` is set to "yes", the user document will be created under the `User collection path` on registration(account creation).

You can set default fields in `Default fields on your user document creation` box. For example, you may set `{ "isVerified": false, "createdBy": "easy-extension" }` and these fields will be set to the user document. This JSON object will overwrite the default fields from Firebase Auth. If you add fields like `{"email": "", "phone_number": ""}`, then the user's email and phone number will be set to empty string instead of saving it from firebase auth.

Be sure you input the complete JSON formatted text in `Default fields on your user document creation` box or it would not work. If it's not working, see the function log.

The `createdAt` will be added to the user document and you cannot remove it.



## User Sync

User information is very important. And unfortunately most of apps don't seem to care about it. If you save the email or phone number or any critical user information in a document that is in publicly opened (without proper security rules), that is a huge mistake.

You may save all of user information in `/users` documents. And the easy extension will sync the searchable fields in `/user_search_data` collection. And only open the security rules for the documents in `/user_search_data` to public.
Note that, the easy extension will not only sync the searchable fields into `/user_search_data` in firestore but also sync to `/users/{uid}` node in realtime database.

When the documents under `/users` collection had created or updated, it will sync the searchable fields into `/user_search_data` in firestore. And when it is deleted in `/users`, it will also delete the same (synced) document from `/user_search_data` field.

You can choose what fields to sync in the extension option. If you leave it blank, then no document will be synced. And don't forget to include `uid` and `photoUrl` even if these fields are not used for direct search. These fields will give you benefits on search.
You can search `hasPhotoUrl` if you sync the `photoUrl` field. Or `hasPhotoUrl` will always be false.

Note that, even if the searchable field is set to blank, the `userSync` function will be called. The function may not do anything but costs. As you may know it costs $0.4 USD per each 2 million time call with the free tier of 2 million call every month. We are in the way of finding a way for not wasting any single dime.

It is recommended to cache in the memory with the documents under `/user_search_data` collection in the client end to prevent the extra pulling from Firestore. If you wish, you can use `/users` in realtime database to observe or to display since it costs less than firestore.


## User Sync Backfill

To re-sync existing user documents when you install/update/re-configure the easy-extension, set the backfill option to 'yes'. If the option is set to 'yes', it will delete all the synced data and re-sync.




# Forum management



# Error handling

- When there is an error, the `status` will be `error` and `errorInfo` has Firebase error information like below.

```ts
{
  command: 'update_custom_claims',
  uid: '--wrong-uid--',
  claims: { level: 13 },
  response: {
    code: 'auth/user-not-found',
    message: 'There is no user record corresponding to the provided identifier.',
    status: 'error',
    timestamp: Timestamp { _seconds: 1690096498, _nanoseconds: 507000000 }
  }
}
```

- For wrong command, error like below will happen

```ts
{
  command: 'wrong-command',
  response: {
    code: 'execution/command-not-found',
    message: 'command execution error',
    status: 'error',
    timestamp: Timestamp { _seconds: 1690097695, _nanoseconds: 194000000 }
  }
}
```


# Deploy


- To deploy to functions, run the command below.
  - `npm run deploy`


# Unit Testing


- We do unit testing on both of local emulator and on real Firebase.

## Testing on Local Emulators


- To test the input of the configuration based on extension.yaml, run the following
`cd functions`
`cd integration-tests`
`firebase emulators:start`

- You can open `http://127.0.0.1:4000/` to see everything works fine especially with the configuration of `*.env` based on the `extension.yaml` settings.

- Check points on how to test the result.
  - See if all the functions are loaded in `functions: Loaded functions definitions from source:...`.
  - See the extension options in the `Extension` tab. See all the settings in `easy-extention.env` has applied.
  - Manually create a user account on the `Authentication` tap in Local Emulator UI.
    - Then, based on the option, the firestore `/users` document would be created.
  - Manually create a user document under `/users` in Firestore
    - Then, based on the user sync option, there will be a document to be created or updated under `/user_search_data` firestore and `/users` in RTDB.

## Testing on real Firebase

- Test files are under `functions/tests`. This test files work with real Firebase. So, you may need provide a Firebase for test use.
  - You can run the emulator on the same folder where `functions/firebase.json` resides, and run the tests on the same folder.

- You may need to add the service account into your environment. See the [Deeloper Installation](#developer-installation)

- To run the sample test,
  - `npm run test:index`


- To run all the tests
  - `npm run test`


- To run a test by specifying a test script,
  - `npm run mocha -- tests/**/*.ts`
  - `npm run mocha -- tests/update_custom_claims/get_set.spec.ts`
  - `npm run mocha -- tests/update_custom_claims/update.spec.ts`



# Tips

- If you want, you can add `timestamp` field for listing.



# Security rules

- The `/easy-commands` collection should be protected by the admin users.
- See the [sample security rules](https://github.com/easy-extension/firestore.rules) that you may copy and use for the seurity rules of easy-extension.





# Developer installation

For developers, to run the unit test do the following.

- Download the service account and save it as `service-account.json` under the project root folder. Note that, `service-account.json` is added into .gitignore
- Apply it into environemnt
  - `export GOOGLE_APPLICATION_CREDENTIALS=../service-account.json`
- Run the function builder with `cd functions; npm run build:watch`
- Then, run the emulators with `firebase emulators:start`

