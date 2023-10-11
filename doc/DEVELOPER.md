# Developer

In this chapter, you will learn how to develop fireflutter. You would also continue developing your app while developing(fixing) the fireflutter.

## Installing your app with fireflutter

- Fork the fireflutter
  - Go to `https://github.com/thruthesky/fireflutter` and fork it.
- Then, clone it
  - `git clone https://github.com/your-account/fireflutter`.
- Create a branch in fireflutter local repository
  - `cd fireflutter`
  - `git checkout -b work`
- For `Pull Request`, update any file, commit, push and request for pulling your code.
  - `echo "Hi" >> README.md`
  - `git commit -a -m "updating README.md"`
  - `git push --set-upstream origin work`
- Create `apps` folder and create your app inside `apps` folder.

  - `cd apps`
  - `flutter create your_porject`

- Since your project add the fireflutter from your computer folder, you need to add the path of the dependency as `../..`. Add the firefluter dependenicy like below.

```yaml
dependencies:
  fireflutter:
    path: ../..
```

- Then, follow the step of the [fireflutter Installation](#installation) chapter.

## Development Tips

Most often, you would click, and click, and click over, and over again, and again to see what you have changed on the UI. Then, you change the UI again. And you would click, and click over again, and again, ...
Yes, this is the reality.

To avoid this, you can display the UI part immediately after hot-restart (with keyboard shortcut) like below. This is merely a sample code. You can test any part of the app like below.

Below is an example of openning a chat room

```dart
ChatService.instance.showChatRoom(
  context: context,
  room: await Room.get('hQnhAosriiewigr4vWFx'),
);
```

Below is an example of openning a group chat room menu dialog.
I copied the `Room` properties manually from the Firestore document and I edited some of the values of the properties for test purpose. You may code a line to get the real room model data.

```dart
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 200), () {
      ChatService.instance.openChatRoomMenuDialog(
        context: context,
        room: Room(
          id: 'DHZWDyeuAlgmKxFxbMbF',
          name: 'Here we are in Manila. Lets celebrate this beautiful day.',
          group: true,
          open: true,
          master: 'ojxsBLMSS6UIegzixHyP4zWaVm13',
          users: [
            '15ZXRtt5I2Vr2xo5SJBjAVWaZ0V2',
            '23TE0SWd8Mejv0Icv6vhSDRHe183',
            'JAekM4AyPTW1fD9NCwqyLuBCTrI3',
            'X5ps2UhgbbfUd7UH1JBoUedBzim2',
            'lyCxEC0oGtUcGi0KKMAs8Y7ihSl2',
            'ojxsBLMSS6UIegzixHyP4zWaVm13',
            'aaa', // not existing user
            't1fAVTeN5oMshEPYn9VvB8TuZUy2',
            'bbb', // not existing user
            'ccc', // not existing user
            'ddd', // not existing user
            'eee', // not existing user
          ],
          moderators: ['lyCxEC0oGtUcGi0KKMAs8Y7ihSl2', '15ZXRtt5I2Vr2xo5SJBjAVWaZ0V2'],
          blockedUsers: [],
          noOfNewMessages: {},
          maximumNoOfUsers: 3,
          rename: {
            FirebaseAuth.instance.currentUser!.uid: 'I renamed this chat room',
          },
          createdAt: Timestamp.now(),
        ),
      );
```

Below is an example of opening a single chat room. I got the room data by calling `print` on a chat room.

```dart
ChatService.instance.showChatRoom(
  context: context,
  room: Room(
    id: '23TE0SWd8Mejv0Icv6vhSDRHe183-ojxsBLMSS6UIegzixHyP4zWaVm13',
    name: '',
    group: false,
    open: false,
    master: '23TE0SWd8Mejv0Icv6vhSDRHe183',
    users: ['23TE0SWd8Mejv0Icv6vhSDRHe183', 'ojxsBLMSS6UIegzixHyP4zWaVm13'],
    rename: {},
    moderators: [],
    maximumNoOfUsers: 2,
    createdAt: Timestamp.now(),
    blockedUsers: [],
  ),
);
```

Below is to show post view screen. Since apps do routings differently, we can use onPressedBackButton to go to the proper screen.

```dart
/// Example 1
Post.get('Uc2TKInQ9oBJeKtSJpBq').then((p) => PostService.instance.showPostViewScreen(context: context, post: post, onPressedBackButton: () {
  context.go(RouterLogic.go('My Home'));
}));
```

Below is to show post edit dialog.

```dart
Post.get('Uc2TKInQ9oBJeKtSJpBq').then((p) => PostService.instance.showPostEditDialog(context, post: p));
```

The code below shows how to open a post create dialog.

```dart
PostService.instance.showCreateDialog(
  context,
  categoryId: 'buyandsell',
  success: (p) => print(p),
);
```

The code below shows how to open a 1:1 chat room and send a message to the other user.

```dart
UserService.instance.get(UserService.instance.adminUid).then(
  (user) async {
    ChatService.instance.showChatRoom(context: context, user: user);
    ChatService.instance.sendMessage(
      room: await ChatService.instance.getSingleChatRoom(UserService.instance.adminUid),
      text: "https://naver.com",
    );
  },
);
```

The code below shows how to open a comment edit bottom sheet. Use this for commet edit bottom sheet UI.

```dart
PostService.instance.showPostViewScreen(context, await Post.get('PoxnpxpcC2lnYv0jqI4f'));
if (mounted) {
  CommentService.instance.showCommentEditBottomSheet(
    context,
    comment: await Comment.get('bvCJk4RFK79yexAKfAYs'),
  );
}
```

# Contribution

Fork the fireflutter and create your own branch. Then update code and push, then pull request.

## Install FireFlutter and Example Project

```sh
git clone https://github.com/thruthesky/fireflutter
cd fireflutter
mkdir apps
cd apps
git clone https://github.com/thruthesky/example
cd example
flutter run
```

## Coding Guideline

fireflutter uses sigular form in its file name and variable name, class name. For instance, it alwasy `user` over `users` unless there is good reason.



# Unit Testing

## Testing on Local Emulators and Firebase

- We do unit testing on both of local emulator and on real Firebase. It depends on how the test structure is formed.

## Testing security rules

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

## Testing on real Firebase

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

## Testing on Cloud Functions

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


## TestUi Widget

This has custom maid test code for fireflutter. You may learn more teachniques on using fireflutter by seeing the test code.
