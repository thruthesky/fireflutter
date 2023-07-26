# Easy Extension

## Overview

- This firebase extension helps to manage your firebase.

- When a document is created under the `easy-commands` collection,
  - The firebase background function will execute the comamnd specified in `{ command: ... }`.

- The `easy-commands` collection should be protected by security rules for the adming-create-only permission.

## Installation

See the change logs for the change of each version.

- [Beta (0.1.0-beta.0)](https://console.firebase.google.com/project/_/extensions/install?ref=jaehosong/easy-extension@0.1.0-beta.0)
- [Alpha (0.0.21-alpha.1)](https://console.firebase.google.com/u/0/project/_/extensions/install?ref=jaehosong%2Feasy-extension@0.0.22-alpha.0)


## Options

* `CREATE_USER_DOCUMENT` will create user's document when a user is registering(first login).
* `DELETE_USER_DOCUMENT` will delete user's document when a user is deleted from Firebase Auth.

## Command list

* Currently supported commands are
  * `update_custom_claims`
  * `disable_user`
  * `enable_user`
  * `get_user`
  * `delete_user`




* listen `eventarc` and update it into a document. For instance, after image processing, listen the event and update it on a document.

### Updating auth custom claims

- Required properties
  - `{ command: 'update_custom_claims' }` - the command.
  - `{ uid: 'xxx' }` - the user's uid that the claims will be applied to.
  - `{ claims: { key: value, xxx: xxx, ... } }` - other keys and values for the claims.

- example of document creation for update_custom claims


![Image Link](https://github.com/thruthesky/easy/blob/main/firebase/extensions/easy-extension/docs/command-update_custom_claims_input.jpg?raw=true "This is image title")


- Response
  - `{ config: ... }` - the configuration of the extension
  - `{ response: { status: 'success' } }` - success respones
  - `{ response: { timestamp: xxxx } }` - the time that the executino had finished.
  - `{ response: { claims: { ..., ... } } }` - the claims that the user currently has. Not the claims that were requested for updating.


![Image Link](https://github.com/thruthesky/easy/blob/main/firebase/extensions/easy-extension/docs/command-update_custom_claims_output.jpg?raw=true "This is image title")



- `SYNC_CUSTOM_CLAIMS_TO_USER_DOCUMENT` option only works with `update_custom_claims` command.
  - When it is set to `yes`, the claims of the user will be set to user's document.
  - By knowing user's custom claims,
    - the app can know that if the user is admin or not.
      - If the user is admin, then the app can show admin menu to the user.
    - Security rules can work better.




### Disable user

- Disabling a user means that they can't sign in anymore, nor refresh their ID token. In practice this means that within an hour of disabling the user they can no longer have a request.auth.uid in your security rules.
  - If you wish to block the user immediately, I recommend to run another command. Running `update_custom_claims` comand with `{ disabled: true }` and you can add it on security rules.
  - Additionally, you can enable `set enable field on user document` to yes. This will add `disabled` field on user documents and you can search(list) users who are disabled.



- `SET_DISABLED_USER_FIELD` option only works with `disable_user` command.
  - When it is set to yes, the `disabled` field with `true` will be set to user document.
  - Use this to know if the user is disabled.


- Request

```ts
{
  command: 'delete_user',
  uid: '--user-uid--',
}
```


### Enable user

- If the user is enabled, the `disabled` field will be deleted from user doc.

- Request

```ts
{
  command: 'enable_user',
  uid: '--user-uid--',
}
```


### Delete user

- This will delete the user account.
- If the `DELETE_USER_DOCUMENT` options is set to yes, then when the user is being deleted, the user document will be deleted also.


- Request

```ts
{
  command: 'delete_user',
  uid: '--user-uid--',
}
```


### Get user

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

## Error handling

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


## Deploy


- To deploy to functions, run the command below.
  - `npm run deploy`


## Unit Testing


### Testing on Local Emulators

- We do unit testing on local emulator and on real Firebase.

- To test the input of the configuration based on extension.yaml, run the following
  - `cd functions/integration_tests && firebase emulators:start`
  - You can open `https://localhost:4000` to see everything works fine especially with the configuration of `*.env` based on the `extension.yaml` settings.


### Testing on real Firebase

- Test files are under `functions/tests`. This test files work with real Firebase. So, you may need provide a Firebase for test use.
  - You can run the emulator on the same folder where `functions/firebase.json` resides, and run the tests on the same folder.

- To run the sample test,
  - `npm run test:index`


- To run all the tests
  - `npm run test`


- To run a test by specifying a test script,
  - `npm run mocha -- tests/**/*.ts`
  - `npm run mocha -- tests/update_custom_claims/get_set.spec.ts`
  - `npm run mocha -- tests/update_custom_claims/update.spec.ts`



## Tips

- If you want, you can add `timestamp` field for listing.



## Security rules

- The `/easy-commands` collection should be protected by the admin users.
- See the [sample security rules](https://github.com/thruthesky/easy/blob/main/firebase/extensions/easy-extension/firestore.rules) that you may copy and use for the seurity rules of easy-extension
# easy-extension
