# Table of Contents
<!-- vscode-markdown-toc -->
* [Admin Service](#AdminService)
* [Admin Widgets](#AdminWidgets)
	* [Opening admin dashbard](#Openingadmindashbard)
	* [AdminUserListView](#AdminUserListView)
	* [Updating auth custom claims](#Updatingauthcustomclaims)
	* [Disable user](#Disableuser)
* [Testing on Local Emulators and Firebase](#TestingonLocalEmulatorsandFirebase)
* [Testing security rules](#Testingsecurityrules)
* [Testing on real Firebase](#TestingonrealFirebase)
* [Testing on Cloud Functions](#TestingonCloudFunctions)
* [TestUi Widget](#TestUiWidget)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## <a name='AdminService'></a>Admin Service

<!-- TODO: learn admin service -->

## <a name='AdminWidgets'></a>Admin Widgets

### <a name='Openingadmindashbard'></a>Opening admin dashbard

To open admin dashboard, call `AdminService.instance.showDashboard()`.

```dart
AdminService.instance.showDashboard(context);
```

Or you may want to open with your own code like below

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (c) => const AdminDashboardScreen()),
);
```

### <a name='AdminUserListView'></a>AdminUserListView

### <a name='Updatingauthcustomclaims'></a>Updating auth custom claims

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

### <a name='Disableuser'></a>Disable user

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

<!-- - Warning! Once a user changes his displayName and photoUrl, `EasyChat.instance.updateUser()` must be called to update user information in easychat. -->

# Translation

The text translation for i18n is in `lib/i18n/i18nt.dart`.

By default, it supports English and you can overwrite the texts to whatever language.

Below show you how to customize texts in your language. If you want to support multi-languages, you may overwrite the texts on device language.

```dart
TextService.instance.texts = I18nTexts(
  reply: "답변",
  loginFirstTitle: '로그인 필요',
  loginFirstMessage: '로그인을 해 주세요.',
  roomMenu: '채팅방 설정',
  noChatRooms: '채팅방이 없습니다. 채팅방을 만들어 보세요.',
  chooseUploadFrom: "업로드할 파일(또는 사진)을 선택하세요.",
  dismiss: "닫기",
  like: '좋아요',
  likes: '좋아요(#no)',
  favorite: "즐겨찾기",
  unfavorite: "즐겨찾기해제",
  favoriteMessage: "즐겨찾기를 하였습니다.",
  unfavoriteMessage: "즐겨찾기를 해제하였습니다.",
  chat: "채팅",
  report: "신고",
  block: "차단",
  unblock: "차단해제",
  blockMessage: "차단 하였습니다.",
  unblockMessage: "차단 해제 하였습니다.",
  alreadyReportedTitle: "신고",
  alreadyReportedMessage: "회원님께서는 본 #type을 이미 신고하셨습니다.",
);
```

You can use the language like below,

```dart
 Text(
  noOfLikes == null
      ? tr.like
      : tr.likes.replaceAll(
          '#no', noOfLikes.length.toString()),
```

# Unit Testing

## <a name='TestingonLocalEmulatorsandFirebase'></a>Testing on Local Emulators and Firebase

- We do unit testing on both of local emulator and on real Firebase. It depends on how the test structure is formed.

## <a name='Testingsecurityrules'></a>Testing security rules

Run the firebase emulators like the followings. Note that you will need to install and setup emulators if you didn't.

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

## <a name='TestingonrealFirebase'></a>Testing on real Firebase

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

## <a name='TestingonCloudFunctions'></a>Testing on Cloud Functions

All of the cloud functions are tested directly on remote firebase (not in emulator). So, you need to save the account service in `firebase/service-account.json`. The service account file is listed in .gitignore. So, It won't be added into git.

To run all the test,

```sh
cd firebase/functions
npm i
run test
```

To run a single test,

```sh
npm run mocha **/save-token*
npm run mocha **/save-token.test.ts
```

# Logic test

To test the functionality of fireflutter, it needs a custom way of testing. For instance, fireflutter listens user login and creates the user's document if it does not exists. And what will happen if the user document is deleted by accident? To prove that there will be no bug on this case, it need to be tested and the test must work based on the real firebase events and monitor if the docuemnt is being recreated. Unit test, widget test and integration test will not work for this.

We wrote some test code and saved it in `TestUi` widget. To run the test in `TestUi`, you will need to initialize firebase. But don't initialize fireflutter nor other services in fireflutter.


## <a name='TestUiWidget'></a>TestUi Widget

This has custom maid test code for fireflutter. You may learn more teachniques on using fireflutter by seeing the test code.



