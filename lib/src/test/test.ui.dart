import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

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

    await testAll();
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
          onPressed: testChatRoomPasswordUpdate,
          child: const Text('TEST - Update Chat Room Password'),
        ),
      ],
    );
  }

  testAll() async {
    Test.start();
    await testCreateGroupChatRoom();
    // await testNoOfNewMessageBadge();
    await testMaximumNoOfUsers();
    await testCreateSingleChatRoom();
    await testInviteUserIntoSingleChat();
    await testInviteUserIntoGroupChat();
    await testChangeDefaultChatRoomName();
    await testRenameChatRoomOwnSide();
    await testChatRoomPasswordUpdate();
    Test.report();
  }

  testCreateGroupChatRoom() async {
    await Test.login(Test.apple);
    final groupRoom = await ChatService.instance.createChatRoom(roomName: 'Group Room 1');
    test(groupRoom.name == 'Group Room 1', 'Must be Group Room 1');
    test(groupRoom.group == true, 'Must be a group chat room');
    test(groupRoom.open == false, 'Must be a private group chat room');
    test(groupRoom.master == Test.apple.uid, 'Must be apple');
    test(groupRoom.moderators.isEmpty, 'Must have no moderators');
    test(groupRoom.users.length == 1, 'Must have only one user');
    test(groupRoom.users.first == Test.apple.uid, 'Must have only one user');
    test(groupRoom.maximumNoOfUsers == 100, 'Must have maximumNoOfUsers 100');
    test(groupRoom.blockedUsers.isEmpty, 'Must have no blockedUsers');
    // test(groupRoom.noOfNewMessages.isEmpty, 'Must have no noOfNewMessages');
  }

  testCreateSingleChatRoom() async {
    await Test.login(Test.apple);
    final room = await ChatService.instance.createChatRoom(roomName: 'Single Room 2', otherUserUid: Test.banana.uid);
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

  testInviteUserIntoSingleChat() async {
    await Test.login(Test.apple);
    final room = await ChatService.instance.createChatRoom(roomName: 'Single Room 2', otherUserUid: Test.banana.uid);
    await Test.assertExceptionCode(room.invite(Test.cherry.uid), Code.singleChatRoomCannotInvite);
  }

  testInviteUserIntoGroupChat() async {
    await Test.login(Test.apple);
    final room = await ChatService.instance.createChatRoom(roomName: 'Single Room 2', maximumNoOfUsers: 3);
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

  testMaximumNoOfUsers() async {
    await FirebaseAuth.instance.signOut();

    // Wait until logout is complete or you may see firestore permission denied error.
    await Test.wait();

    // Sign in with apple with its password
    await Test.login(Test.apple);

    // Get the room
    Room room = await ChatService.instance.createChatRoom(roomName: 'Testing Room');

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

  testChangeDefaultChatRoomName() async {
    await FirebaseAuth.instance.signOut();

    // Wait until logout is complete or you may see firestore permission denied error.
    await Test.wait();

    // Sign in with apple with its password
    await Test.login(Test.apple);

    // Get the room
    Room room = await ChatService.instance.createChatRoom(roomName: 'Testing Room');

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

  testRenameChatRoomOwnSide() async {
    await FirebaseAuth.instance.signOut();

    // Wait until logout is complete or you may see firestore permission denied error.
    await Test.wait();

    // Sign in with apple with its password
    await Test.login(Test.apple);

    // Get the room
    Room room = await ChatService.instance.createChatRoom(roomName: 'Testing Room');

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

  testChatRoomPasswordUpdate() async {
    await FirebaseAuth.instance.signOut();

    // Wait until logout is complete or you may see firestore permission denied error.
    await Test.wait();

    // Sign in with apple with its password
    await Test.login(Test.apple);

    // Get the room
    Room room = await ChatService.instance.createChatRoom(roomName: 'Testing Room');

    // There must be no password upon creating the room
    test(room.password == null,
        "The room must not have a password upon creation. Actual Value: ${room.password}. Expected: null");

    // add the users
    await room.invite(Test.banana.uid);
    await room.invite(Test.cherry.uid);

    // Master Apple updates the chat room password.
    const String password = 'sample';
    await ChatService.instance.updateRoomSetting(room: room, setting: 'password', value: password);

    // Get the room update
    room = await ChatService.instance.getRoom(room.id);

    // TEST: The chat room password must be updated.
    test(room.password == password,
        "The chat room password can be updated by Master. Actual Value: ${room.password}. Expected: $password");

    // Master Apple set Banana as Moderator
    await ChatService.instance.setUserAsModerator(room: room, uid: Test.banana.uid);

    // Sign out Master Apple, Sign in with Moderator Banana with its password
    await FirebaseAuth.instance.signOut();
    await Test.wait(); // Wait until logout is complete or you may see firestore permission denied error.
    await Test.login(Test.banana);

    // Moderator Banana updates the password
    const String bananaPassword = 'bananapass';
    await ChatService.instance.updateRoomSetting(room: room, setting: 'password', value: bananaPassword);

    // Get the room update
    room = await ChatService.instance.getRoom(room.id);

    // TEST: The chat room password must be updated.
    test(room.password == bananaPassword,
        "The chat room password can be updated by Moderator. Actual Value: ${room.password}. Expected: $bananaPassword");

    // Sign out Moderator Banana, Sign in with Cherry with its password
    await FirebaseAuth.instance.signOut();
    await Test.wait(); // Wait until logout is complete or you may see firestore permission denied error.
    await Test.login(Test.cherry);

    const String cherryPassword = 'cherry';

    // TODO for confirmation: how do we handle other exceptions
    const permissionDeniedError =
        '[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.';

    // This should not work because the member is non admin
    await Test.assertExceptionCode(
        ChatService.instance.updateRoomSetting(room: room, setting: 'password', value: cherryPassword),
        permissionDeniedError);

    // Get the room update
    room = await ChatService.instance.getRoom(room.id);

    // TEST: The chat room password should not be updated.
    test(room.password != cherryPassword,
        "The chat room password should not be updated by non-admin member. Actual Value: ${room.password}. Expected: $bananaPassword");

    // Sign out Cherry, Sign in with Master Apple with its password
    await FirebaseAuth.instance.signOut();
    await Test.wait(); // Wait until logout is complete or you may see firestore permission denied error.
    await Test.login(Test.apple);

    // Master Apple clears the password
    await ChatService.instance.updateRoomSetting(room: room, setting: 'password', value: '');

    // Get the room update
    room = await ChatService.instance.getRoom(room.id);

    // TEST: The updated password must be null.
    test(room.password == null, "The password can be cleared. Actual Value: ${room.password}. Expected: null");
  }
}
