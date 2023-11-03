import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// TestUi
///
/// This is a test screen for testing all the features of FireFlutter.
///
/// You can run all the tests by pressing the [Run all tests] button.
/// Or you can run each test by pressing each test button.
///
/// See README.md for details of TestUi widget.
///
///
class TestUi extends StatefulWidget {
  const TestUi({super.key});

  @override
  State<TestUi> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestUi> {
  @override
  void initState() {
    super.initState();

    initTest();
  }

  /// Initialize the test
  ///
  initTest() async {
    await Test.generateTestAccounts();

    // await User.fromUid(Test.banana.uid).update(field: 'uid', value: Test.banana.uid);

    // await testAll();
    // await testSingle(testUser);
    // await testSingle(testCategory);
    // await testSingle(testMaximumNoOfUsers);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('''See README for TestUi widget.'''),
        const Divider(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: StreamBuilder<fa.User?>(
            stream: fa.FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final user = snapshot.data as fa.User;
                return Text(
                    'Firebase Auth User - logged in.\nDisplay name: ${user.displayName}, Email: ${user.email},  UID: ${user.uid}');
              } else {
                return const Text('User is logged out');
              }
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: Column(
            children: [
              MyDoc(
                builder: (my) {
                  if (my.exists) {
                    return Text(
                        'MyDoc() - User document exists.\nUID: ${my.uid}, displayName: ${my.displayName}, email: ${my.email}, createdAt: ${my.createdAt}');
                  } else {
                    return const Text('MyDoc() - User document does NOT exist Or the user is in the middle of login');
                  }
                },
              ),
            ],
          ),
        ),
        Wrap(
          children: [
            for (final user in Test.users)
              ElevatedButton(
                onPressed: () async {
                  // final login =
                  await Test.loginOrRegister(user);
                  // print(login);
                },
                child: Text('Login w/ ${user.displayName}'),
              ),
            ElevatedButton(
                onPressed: () async {
                  await testRandomLogin();
                },
                child: const Text("Random Login")),
            ElevatedButton(
                onPressed: () async {
                  await UserService.instance.signOut();
                },
                child: const Text("Logout")),
          ],
        ),
        const Divider(),
        Wrap(
          children: [
            ElevatedButton(
              onPressed: () {
                FireFlutterService.instance.init(
                  context: () => context,
                );
              },
              child: const Text("FireFlutter Init()"),
            ),
            ElevatedButton(
              onPressed: () async {
                await UserService.instance.init();
              },
              child: const Text("UserService init()"),
            ),
            ElevatedButton(
                onPressed: () {
                  PostService.instance.showPostListScreen(context, 'qna');
                },
                child: const Text('QnA Forum')),
            ElevatedButton(
                onPressed: () {
                  PostService.instance.showPostListScreen(context, 'qna');
                },
                child: const Text('Chat')),
          ],
        ),
        const Divider(),
        ElevatedButton(
          onPressed: testAll,
          child: Text('Run all tests', style: TextStyle(color: Colors.red.shade800)),
        ),
        const Text('Individual tests', style: TextStyle(color: Color.fromARGB(255, 83, 4, 4))),
        Wrap(
          children: [
            // ElevatedButton(
            //   onPressed: () => testToast(context),
            //   child: const Text('Toast'),
            // ),
            ElevatedButton(
              onPressed: testUser,
              child: const Text('User'),
            ),
            ElevatedButton(onPressed: testUserDocument, child: const Text('User Document')),
            ElevatedButton(
              onPressed: () => testSingle(testFeed),
              child: const Text('Feed'),
            ),
            ElevatedButton(
              onPressed: testCategory,
              child: const Text('Category'),
            ),
            ElevatedButton(
              onPressed: testMaximumNoOfUsers,
              child: const Text('Maximum no of users'),
            ),
            ElevatedButton(
              onPressed: testCreateGroupChatRoom,
              child: const Text('Create group chat room'),
            ),
            ElevatedButton(
              onPressed: testCreateSingleChatRoom,
              child: const Text('Create single chat room'),
            ),
            ElevatedButton(
              onPressed: testInviteUserIntoSingleChat,
              child: const Text('Invite user into single chat'),
            ),
            ElevatedButton(
              onPressed: testInviteUserIntoGroupChat,
              child: const Text('Invite user into group chat'),
            ),
            ElevatedButton(
              onPressed: testChangeDefaultChatRoomName,
              child: const Text('Change Default Chat Room Name'),
            ),
            ElevatedButton(
              onPressed: testRenameChatRoomOwnSide,
              child: const Text('Rename Chat Room Name'),
            ),
          ],
        ),
      ],
    );
  }

  testSingle(func) async {
    Test.start();
    await func();
    Test.report();
  }

  testAll() async {
    Test.start();
    await testUser();
    await testCategory();
    await testFeed();
    await testCreateGroupChatRoom();
    // await testNoOfNewMessageBadge();
    await testCreateSingleChatRoom();
    await testMaximumNoOfUsers();
    await testInviteUserIntoSingleChat();
    await testInviteUserIntoGroupChat();
    await testChangeDefaultChatRoomName();
    await testRenameChatRoomOwnSide();
    Test.report();
  }

  Future createTestUser(User user) async {
    final data = user.toMap();
    data.remove('isAdmin');
    data.remove('disabled');
    data.remove('isVerified');
    data.remove('data');
    data.remove('exists');
    data.remove('cached');
    data['createdAt'] = FieldValue.serverTimestamp();
    // print(data);

    // print(User.doc(user.uid).path);
    return await User.doc(user.uid).set(data);
  }

  Future testUser() async {
    // create empty object
    final user = User.fromUid('uid');
    test(user.uid == 'uid', 'uid must be uid');

    // create object from json
    final fromJsonUser = User.fromJson({'uid': 'uid', 'id': 'id'});
    test(fromJsonUser.createdAt.millisecondsSinceEpoch >= 0, 'createdAt is: ${fromJsonUser.createdAt}');

    String uid = fa.FirebaseAuth.instance.currentUser!.uid;
    // log('uid; $uid');
    await User.doc(uid).delete();
    await createTestUser(
        User(uid: uid, displayName: 'displayName$uid', email: '$uid@email.com', createdAt: DateTime.now()));
    final user2 = await User.get(uid) as User;
    test(user2.uid == uid, 'uid must be $uid');
    test(user2.displayName == 'displayName$uid', 'displayName must be displayName$uid');
    test(user2.email == '$uid@email.com', 'email must be $uid@email.com');

    await Future.delayed(const Duration(milliseconds: 10));
    return;
  }

  Future testPost() async {
    // post crud test
    await Post.create(categoryId: 'categoryId', title: 'title', content: 'content');
  }

  Future testComment() async {
    // comment crud test
    await Post.create(categoryId: 'categoryId', title: 'title', content: 'content');
  }

  Future testCategory() async {
    await Test.login(Test.durian);
    // Create a category
    await Category.create(categoryId: 'categoryId', name: 'name');
    final created = await Category.get('categoryId');
    test(created.id == 'categoryId', 'id must be categoryId');
    test(created.name == 'name', 'name must be name');

    // Update a category
    await created.update(name: 'name2');
    final updated = await Category.get('categoryId');
    test(updated.name == 'name2', 'name must be name2');

    // Delete a category
    await updated.delete();
    try {
      await Category.get('categoryId');
      test(false, 'must throw exception');
    } catch (e) {
      test(e.toString().contains('does not exist'), 'must throw exception. <$e>');
    }
  }

  ///
  Future testFeed() async {
    ///
    await Test.login(Test.apple);

    /// Get my user object. Don't use global [my] immediately after login.
    User me = await User.get() as User;

    /// delete all my followings.
    await me.update(followings: FieldValue.delete());

    /// follow banana
    test(await FeedService.instance.follow(Test.banana.uid) == true, 'a follows b');

    /// get my data again
    me = await User.get() as User;

    /// check
    test(me.followings.contains(Test.banana.uid), "a followed b");
    test(me.followings.length == 1, "there must be only 1 followings");

    /// follow again -> un-following
    test(await FeedService.instance.follow(Test.banana.uid) == false, "a un-follows b");
    final User afterFollow = (await User.get())!;
    test(afterFollow.followings.contains(Test.banana.uid) == false, "a un-followed b");
    test(afterFollow.followings.isEmpty, "there must be no followings");

    /// Have 3 followers and create a new post
    /// Check all of them has my new post
    /// One unfollow me and check if he has no posts of me.
    ///
  }

  Future testCreateGroupChatRoom() async {
    await Test.login(Test.apple);
    final groupRoom = await Room.create(name: 'Group Room 1');
    await test(groupRoom.name == 'Group Room 1', 'Must be Group Room 1');
    await test(groupRoom.group == true, 'Must be a group chat room');
    await test(groupRoom.open == false, 'Must be a private group chat room');
    await test(groupRoom.master == Test.apple.uid, 'Must be apple');
    await test(groupRoom.moderators.isEmpty, 'Must have no moderators');
    await test(groupRoom.users.length == 1, 'Must have only one user');
    await test(groupRoom.users.first == Test.apple.uid, 'Must have only one user');
    await test(groupRoom.maximumNoOfUsers == ChatService.instance.maximumNoOfUsers, 'Must have maximumNoOfUsers 100');
    await test(groupRoom.blockedUsers.isEmpty, 'Must have no blockedUsers');
    // test(groupRoom.noOfNewMessages.isEmpty, 'Must have no noOfNewMessages');
  }

  Future testCreateSingleChatRoom() async {
    await Test.login(Test.apple);
    final room = await Room.create(name: 'Single Room 2', otherUserUid: Test.banana.uid);
    test(room.name == 'Single Room 2', 'Must be Single Room 2');
    test(room.group == false, 'Must be a single chat room');
    test(room.open == false, 'Must be a private a chat room');
    test(room.master == Test.apple.uid, 'The master must be apple');
    test(room.moderators.isEmpty, 'Must have no moderators');
    test(room.users.length == 2, 'Must have two users');
    test(room.users.first == Test.apple.uid, 'Must have only one user');
    test(room.maximumNoOfUsers == 2, 'Must have maximumNoOfUsers 2');
    test(room.blockedUsers.isEmpty, 'Must have no blockedUsers');
    // test(room.noOfNewMessages.isEmpty, 'Must have no noOfNewMessages');
  }

  Future testMaximumNoOfUsers() async {
    await fa.FirebaseAuth.instance.signOut();

    // Wait until logout is complete or you may see firestore permission denied error.
    await Test.wait();

    // Sign in with apple with its password
    await Test.login(Test.apple);

    // Get the room
    Room room = await Room.create(name: 'Testing Room');

    // update the setting
    await ChatService.instance.updateRoomSetting(room: room, setting: 'maximumNoOfUsers', value: 3);

    // add the users
    await room.invite(Test.banana.uid);
    await room.invite(Test.cherry.uid);

    // This should not work because the max is 3
    await Test.assertExceptionCode(room.invite(Test.durian.uid), Code.roomIsFull);

    // Get the room
    final roomAfter = await Room.get(room.roomId);

    test(roomAfter.users.length == 3,
        "maximumNoOfUsers must be limited to 3. Actual value: ${roomAfter.users.length}. Expected: ${roomAfter.maximumNoOfUsers}");
  }

  Future testInviteUserIntoSingleChat() async {
    await Test.login(Test.apple);
    final room = await Room.create(name: 'Single Room 2', otherUserUid: Test.banana.uid);
    await Test.assertExceptionCode(room.invite(Test.cherry.uid), Code.singleChatRoomCannotInvite);
  }

  Future testInviteUserIntoGroupChat() async {
    await Test.login(Test.apple);
    final room = await Room.create(name: 'Single Room 2', maximumNoOfUsers: 3);
    await Test.assertFuture(room.invite(Test.banana.uid));
    await Test.assertFuture(room.invite(Test.cherry.uid));
    await Test.assertExceptionCode(room.invite(Test.cherry.uid), Code.userAlreadyInRoom);
    await Test.assertExceptionCode(room.invite(Test.durian.uid), Code.roomIsFull);
  }

  /// Test the no of new messages.
  ///
  ///
  // testNoOfNewMessageBadge() async {
  //   // Sign in with apple with its password
  //   await Test.login(Test.apple);

  //   // Get the room
  //   final room = await ChatService.instance.getOrCreateSingleChatRoom(Test.banana.uid);

  //   await ChatService.instance.roomRef(room.id).update({'noOfNewMessages': {}});

  //   // Send a message with the room information.
  //   await ChatService.instance.sendMessage(
  //     room: room,
  //     text: 'yo',
  //   );

  //   // Get the no of new messages.
  //   final roomAfter = await ChatService.instance.getOrCreateSingleChatRoom(Test.banana.uid);

  //   test(roomAfter.noOfNewMessages[Test.banana.uid] == 1,
  //       "noOfNewMessages of Banana must be 1. Actual value: ${roomAfter.noOfNewMessages[Test.banana.uid]}");

  //   // Send a message with the room information.
  //   await ChatService.instance.sendMessage(
  //     room: room,
  //     text: 'yo2',
  //   );

  //   // Get the no of new messages.
  //   final roomAfter2 = await ChatService.instance.getOrCreateSingleChatRoom(Test.banana.uid);

  //   test(roomAfter2.noOfNewMessages[Test.banana.uid] == 2,
  //       "noOfNewMessages of Banana must be 2. Actual value: ${roomAfter.noOfNewMessages[Test.banana.uid]}");
  // }

  Future testChangeDefaultChatRoomName() async {
    await fa.FirebaseAuth.instance.signOut();

    // Wait until logout is complete or you may see firestore permission denied error.
    await Test.wait();

    // Sign in with apple with its password
    await Test.login(Test.apple);

    // Get the room
    Room room = await Room.create(name: 'Testing Room');

    // add the users
    await room.invite(Test.banana.uid);
    await room.invite(Test.cherry.uid);

    const newName = 'Updated Name';

    // rename the room
    await ChatService.instance.updateRoomSetting(room: room, setting: 'name', value: newName);

    // Get the room
    final roomAfter = await Room.get(room.roomId);

    // test: check the new name
    test(roomAfter.name == newName, "The room must have the new name \"$newName\". Actual value: ${roomAfter.name}");
  }

  Future testRenameChatRoomOwnSide() async {
    await fa.FirebaseAuth.instance.signOut();

    // Wait until logout is complete or you may see firestore permission denied error.
    await Test.wait();

    // Sign in with apple with its password
    await Test.login(Test.apple);

    // Get the room
    Room room = await Room.create(name: 'Testing Room');

    // add the users
    await room.invite(Test.banana.uid);
    await room.invite(Test.cherry.uid);

    const renameApple = "Apple's place";

    // rename the room
    await ChatService.instance.updateMyRoomSetting(room: room, setting: 'rename', value: renameApple);

    // Get the room
    Room roomAfter = await Room.get(room.roomId);

    // Test if ChatService.instance.updateMyRoomSetting() function works. It must rename.
    test(roomAfter.rename[myUid!] == renameApple,
        "The room must have a rename for user. Actual Value: ${roomAfter.rename[myUid!]}. Expected: $renameApple");

    // rename the room
    await ChatService.instance.updateMyRoomSetting(room: room, setting: 'rename', value: '');

    // Get the update to the room
    roomAfter = await Room.get(room.roomId);

    // Test if it clears the value. It must delete the value.
    test(roomAfter.rename[myUid!] == null,
        "The room must not have a rename. Actual Value: ${roomAfter.rename[myUid!]}. Expected: Null");
  }

  // Future testToast(BuildContext context) {
  //   final completer = Completer();
  //   FireFlutterService.instance.init(context: () => null);
  //   try {
  //     toast(title: 'FireFlutter Toast', message: 'This is a toast message');
  //     completer.completeError('FireFlutterService.instance.unInit() must throw an exception');
  //     return completer.future;
  //   } catch (e) {
  //     if (e.toString().contains('Null check operator used on a null value') == false) {
  //       completer.completeError('error: $e');
  //       return completer.future;
  //     }
  //   }

  //   FireFlutterService.instance.init(context: () => context);
  //   try {
  //     toast(
  //         title: 'FireFlutter Toast', message: 'This is a toast message', duration: const Duration(milliseconds: 100));
  //     completer.complete('toast() succeed');
  //   } catch (e) {
  //     completer.completeError('toast() must throw an exception; $e');
  //   }

  //   return completer.future;
  // }

  /// Test user document
  ///
  /// This test will create a user document and listen to the document changes.
  StreamSubscription? _testUserDocumentSubscription;
  Future testUserDocument() async {
    // logout before testing
    await fa.FirebaseAuth.instance.signOut();

    //
    final completer = Completer();

    // Random user
    final email = "${randomString()}@gmail.com";
    final randomUser = await Test.loginOrRegister(
      TestUser(
        displayName: email,
        email: email,
        photoUrl: 'https://picsum.photos/id/1/200/200',
      ),
    );

    // A Random user just has registered. By this time, the user document must not exist.
    try {
      final user = await User.get(randomUser.uid);
      if (user == null) {
      } else {
        completer.completeError('User document must NOT found');
        return completer.future;
      }
    } catch (e) {
      completer.completeError('Unknown error happened. Maybe a permission denied error: $e');
      return completer.future;
    }

    // Initialize the user service and create user document by the service.
    UserService.instance.init(adminUid: 'adminUid');

    // Check if the user document is created.
    bool deleted = false;
    _testUserDocumentSubscription?.cancel();
    _testUserDocumentSubscription = UserService.instance.documentChanges.listen((user) async {
      if (user != null) {
        // User document is created. Fine.
        // Well then, delete the user document and see what happens.
        if (deleted == false) {
          // print('uid; ${user.uid}, createdAt: ${user.createdAt}');
          deleted = true;
          await user.delete();
          return;
        }

        // After deleting the user document, the user document must be created
        // again by the [UserService] since the user is logged in and listennig
        // to the user document changes.
        // If the user is logged out and the document is deleted by admin, then
        // the user document must not exist.
        if (deleted == true && completer.isCompleted == false) {
          // print('uid; ${user.uid}, createdAt: ${user.createdAt}');
          completer.complete('testUserDocument() succeed');
        }
      }
    });

    return completer.future;
  }

  /// Returns firebase auth User after login.
  Future<fa.User> testRandomLogin() async {
    // Random user
    final email = "${randomString()}@gmail.com";
    final randomUser = await Test.loginOrRegister(
      TestUser(
        displayName: email,
        email: email,
        photoUrl: 'https://picsum.photos/id/1/200/200',
      ),
    );
    return randomUser;
  }
}
