# Table of Contents


<!-- ***@import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->***

<!-- ***code_chunk_output -->***

- ***[Unit Testing](#unit-testing)***
  - ***[Testing on Local Emulators and Firebase](#testing-on-local-emulators-and-firebase)***
  - ***[Testing security rules](#testing-security-rules)***
  - ***[Testing on real Firebase](#testing-on-real-firebase)***
  - ***[Testing on Cloud Functions](#testing-on-cloud-functions)***
- ***[TestUi Widget](#testui-widget)***
    - ***[Login w/ [name]](#login-w-name)***
    - ***[FireFlutter init()](#fireflutter-init)***
    - ***[UserService init()](#userservice-init)***
    - ***[QnA Forum](#qna-forum)***
    - ***[Chat](#chat)***
  - ***[Individual Test](#individual-test)***
    - ***[Toast](#toast)***
    - ***[User](#user)***
    - ***[User Document](#user-document)***
    - ***[Feed](#feed)***
    - ***[Category](#category)***
    - ***[Maximum No of users](#maximum-no-of-users)***
    - ***[Invite user into single chat](#invite-user-into-single-chat)***
    - ***[Invite user into group chat](#invite-user-into-group-chat)***
    - ***[Change Default Chat Room Name](#change-default-chat-room-name)***

<!-- ***/code_chunk_output -->***

# Test

## Unit Testing

### Testing on Local Emulators and Firebase

- ***We do unit testing on both of local emulator and on real Firebase. It depends on how the test structure is formed.***

### Testing security rules

Run the firebase emulators like the followings. 

***Note:*** You need to install and setup emulators if you don't have any.***

```sh
cd firebase/firestore
firebase emulators:start
```

Then, run all the test like below.

```sh
npm test
```

To run group of tests, specify folder name.

```sh
npm run mocha tests/rule-functions
npm run mocha tests/posts
```

To run a single test file, specify file name.

```sh
npm run mocha tests/posts/create.spec.js
npm run mocha tests/posts/likes.spec.js
```

### Testing on real Firebase

- ***Test files are under `functions/tests`. This test files work with real Firebase. So, you may need provide a Firebase for test use.***

  - ***You can run the emulator on the same folder where `functions/firebase.json` resides, and run the tests on the same folder.***

- ***To run the sample test,***

  - ***`npm run test:index`***

- ***To run all the tests***

  - ***`npm run test`***

- ***To run a test by specifying a test script,***
  - ***`npm run mocha -- ***tests/**/*.ts`***
  - ***`npm run mocha -- ***tests/update_custom_claims/get_set.spec.ts`***
  - ***`npm run mocha -- ***tests/update_custom_claims/update.spec.ts`***

### Testing on Cloud Functions

All of the cloud functions are tested directly on remote firebase (not in emulator). So, you need to save the account service in `firebase/service-account.json`. The service account file is listed in .gitignore. So, It won't be added into git.

To run all the test,

```sh
cd firebase/functions
npm i
npm run test
```

To run a single test,

```sh
npm run mocha **/save-token*
npm run mocha **/save-token.test.ts
```

If you meet an error `../service-account.json not found` you need to generate a new private key from firebase and place it in `/firebase/` rename it as `service-account.json` then try the test again

Steps to follow:

1. Go to Firebase and open `Project Settings > Service Account` 
2. Click `Generate new private key`. This will generate a new private key and will automatically download.
3. Go to your `Downloads` and rename the file to `service-account.json`
4. Cut or Copy the `service-acount.json` and Go to `../fireflutter/firebase`. Paste the file into the folder.
5. Run `npm run test` 


# Logic test

To test the functionality of fireflutter, it needs a custom way of testing. For instance, fireflutter listens user login and creates the user's document if it does not exists. And what will happen if the user document is deleted by accident? To prove that there will be no bug on this case, it need to be tested and the test must work based on the real firebase events and monitor if the docuemnt is being recreated. Unit test, widget test and integration test will not work for this.

We wrote some test code and saved it in `TestUi` widget. To run the test in `TestUi`, you will need to initialize firebase. But don't initialize fireflutter nor other services in fireflutter.


## TestUi Widget

This has custom maid test code for fireflutter. You may learn more techniques on using fireflutter by seeing the test code.


To use this test,

1. Initialize Firebase
2. Add `TestUi` on the screen
3. Press the `Run all tests` button to see everything works fine.

You don't need to initialize anything to test.
- ***Login w/ [name]*** Login using the account from the name of each button, it will create a new account if its not existing. `Random Login` will log in random accounts

![logins](/doc/img/login_buttons.png)

- ***FireFlutter init()*** Use this to test the `init` of `FireFlutterService` instance.

- ***UserService init()*** Use this to test the `init` of `UserService` instance.

- ***QnA Forum*** Display all the post into a new screen.

- ***Chat***

### Individual Test

- ***Toast*** Display toast notification

- ***User*** This will test the process of creating a user.

- ***User Document*** This will create a user document and listen to the document changes. If a random user has registered, the document must not exist.

- ***Feed*** Tests the `follow` function from the `FeedService`

- ***Category*** This tests the `create`, `update` and `delete` of the `Category`.

- ***Maximum No of users*** This will create a new Chat Room and will set the maximum users and expected to follow the set.

- ***Invite user into single chat*** Test how Chat Room behave during 1:1 chat creation and user invitation.

- ***Invite user into group chat*** Test how Group Chat Room behave during creation and user invitation. This must follow the `maximum` users.

- ***Change Default Chat Room Name*** Test for changing the default Chat Room Name of the app. The result must be 'Updated Name'.