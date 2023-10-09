import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
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

  initTest() async {
    /// This is one time initialization for creating the test account.
    /// Once you have created accounts, you can simply hard code the uid into the Test.users.
    for (final user in Test.users) {
      if (user.uid == null) {
        final login = await Test.loginOrRegister(user);
        user.uid = login.uid;
      }
    }

    // for (var e in Test.users) {
    //   print('${e.displayName}:${e.uid}');
    // }

    /// hard code the uid for speed.
    // for philgo
    // Test.users[0].uid = 'CccjuqddNGbcwLlWAKgolSKVon13';
    // Test.users[1].uid = 'oizgOBmEfrYJY1YqiCd8MNKTVuQ2';
    // Test.users[2].uid = 'v8GcdFB0kHaI5eyqZlfS081D3w03';
    // Test.users[3].uid = 'lbSHvOofD4btiGLVkVhE5hQAFcm2';

    Test.users[0].uid = 'xY0P00Z5MKeYUVeXH3ZZQdOyzqt2';
    Test.users[1].uid = 'Gjv1vA0XW5MU6eRnkTt6Si1vgXt2';
    Test.users[2].uid = 'i2l14MKy12bNLJk7E4J9JuLvIrj2';
    // admin
    Test.users[3].uid = 'DiBndQah89TQu7EHUzu2hDH5gC62';

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
        const Text('''How To TEST
1. Wait until the users are loaded in the [initState].
2. Press run all tests to test all the features.
3. Or press test button to test one by one.
'''),
        const Divider(),
        StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (_, snapshot) {
              final user = snapshot.data;
              if (user == null) {
                return const Text('Logged out');
              }
              return Text('User: ${user.email ?? 'null'}');
            }),
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
          ],
        ),
        const Divider(),
        ElevatedButton(
            onPressed: () {
              PostService.instance.showPostListScreen(context, 'qna');
            },
            child: const Text('QnA Forum')),
        const Divider(),
        ElevatedButton(
          onPressed: testAll,
          child: Text('Run all tests', style: TextStyle(color: Colors.red.shade800)),
        ),
        ElevatedButton(
          onPressed: testUser,
          child: const Text('TEST - User'),
        ),
        ElevatedButton(
          onPressed: testCategory,
          child: const Text('TEST - Category'),
        ),
        ElevatedButton(
          onPressed: testMaximumNoOfUsers,
          child: const Text('TEST maximum no of users'),
        ),
        ElevatedButton(
          onPressed: testCreateGroupChatRoom,
          child: const Text('TEST - create group chat room'),
        ),
        ElevatedButton(
          onPressed: testCreateSingleChatRoom,
          child: const Text('TEST - create single chat room'),
        ),
        ElevatedButton(
          onPressed: testInviteUserIntoSingleChat,
          child: const Text('TEST - invite user into single chat'),
        ),
        ElevatedButton(
          onPressed: testInviteUserIntoGroupChat,
          child: const Text('TEST - invite user into group chat'),
        ),
        ElevatedButton(
          onPressed: testChangeDefaultChatRoomName,
          child: const Text('TEST - Change Default Chat Room Name'),
        ),
        ElevatedButton(
          onPressed: testRenameChatRoomOwnSide,
          child: const Text('TEST - Rename Chat Room Name'),
        ),
        ElevatedButton(
          onPressed: () => testSingle(testFeed),
          child: const Text('TEST - Feed'),
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
    final user = User(uid: 'uid', createdAt: DateTime.now());
    test(user.uid == 'uid', 'uid must be uid');

    // create object from json
    final fromJsonUser = User.fromJson({'uid': 'uid', 'id': 'id'});
    // test(fromJsonUser.createdAt.millisecondsSinceEpoch > 0,
    //     'createdAt is: ${fromJsonUser.createdAt}');

    // Create a user
    String uid = FirebaseAuth.instance.currentUser!.uid;
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

  Future testFeed() async {
    await Test.login(Test.apple);
    User me = await User.get() as User;
    await me.update(followers: FieldValue.delete(), followings: FieldValue.delete());
    if (me.followings.contains(Test.banana.uid)) {
      // await User.fromUid(Test.banana.uid).update(followers: FieldValue.arrayRemove([Test.apple.uid]));
      await FeedService.instance.removeFromFollowers(Test.banana.uid);
    }
    me = await User.get() as User;
    test(await me.follow(Test.banana.uid) == true, "a follows b");
    final User afterFollow = (await User.get())!;
    test(afterFollow.followings.contains(Test.banana.uid), "a follows b");
    test(afterFollow.followings.length == 1, "there must be only 1 followings");
    test(afterFollow.followings.contains(Test.cherry.uid) == false, "apple is not following cherry");

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
    await FirebaseAuth.instance.signOut();

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
    await FirebaseAuth.instance.signOut();

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
    await FirebaseAuth.instance.signOut();

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
}
