import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class TestUi extends StatefulWidget {
  const TestUi({super.key});

  @override
  State<TestUi> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestUi> with FirebaseHelper {
  @override
  void initState() {
    super.initState();

    initTest();
  }

  initTest() async {
    /// This is one time initialization for creating the test account.
    /// Once you have created accounts, you can simply hard code the uid into the Test.users.
    // for (final user in Test.users) {
    //   if (user.uid == null) {
    //     final login = await Test.loginOrRegister(user);
    //     user.uid = login.uid;
    //   }
    // }

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
    Test.users[3].uid = 'DiBndQah89TQu7EHUzu2hDH5gC62';

    // await User.fromUid(Test.banana.uid).update(field: 'uid', value: Test.banana.uid);

    // await testAll();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('''How To TEST
1. Wait until the users are loaded. On the [initState], it will load apple, banana, cherry, and durian user uids.
2. Press run all tests to test all the features.
3. Or press test button one by one to see the result of each test.
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
        ElevatedButton(
          onPressed: testAll,
          child: Text('Run all tests', style: TextStyle(color: Colors.red.shade800)),
        ),
        // ElevatedButton(
        //   onPressed: testNoOfNewMessageBadge,
        //   child: const Text('TEST noOfNewMessage - Apple & Banana'),
        // ),
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

  testFeed() async {
    await Test.login(Test.apple);
    User me = await User.get() as User;
    await me.update(followers: FieldValue.delete(), followings: FieldValue.delete());
    if (me.followings.contains(Test.banana.uid)) {
      await User.fromUid(Test.banana.uid).update(followers: FieldValue.arrayRemove([Test.apple.uid]));
    }
    me = await User.get() as User;
    test(await me.follow(Test.banana.uid) == true, "a follows b");
    final User afterFollow = (await User.get())!;
    test(afterFollow.followings.contains(Test.banana.uid), "a follows b");
    test(afterFollow.followings.length == 1, "there must be only 1 followings");
    test(afterFollow.followings.contains(Test.cherry.uid) == false, "apple is not following cherry");
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
    final roomAfter = await ChatService.instance.getRoom(room.id);

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
    final roomAfter = await ChatService.instance.getRoom(room.id);

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
    Room roomAfter = await ChatService.instance.getRoom(room.id);

    // Test if ChatService.instance.updateMyRoomSetting() function works. It must rename.
    test(roomAfter.rename[UserService.instance.uid] == renameApple,
        "The room must have a rename for user. Actual Value: ${roomAfter.rename[UserService.instance.uid]}. Expected: $renameApple");

    // rename the room
    await ChatService.instance.updateMyRoomSetting(room: room, setting: 'rename', value: '');

    // Get the update to the room
    roomAfter = await ChatService.instance.getRoom(room.id);

    // Test if it clears the value. It must delete the value.
    test(roomAfter.rename[UserService.instance.uid] == null,
        "The room must not have a rename. Actual Value: ${roomAfter.rename[UserService.instance.uid]}. Expected: Null");
  }
}
