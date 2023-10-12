import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:fireflutter/fireflutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestUser {
  final String displayName;
  final String email;
  final String photoUrl;
  final String password = ",*13245a,";
  static int errorCount = 0;
  static int successCount = 0;
  String? uid;
  TestUser({required this.displayName, required this.email, required this.photoUrl});
}

/// Test
///
///
class Test {
  /// [accountSalt] is the salt string for test accounts.
  ///
  /// You can change the [accountSalt] to generate(use) new test accounts.
  static String accountSalt = '5';
  static List<TestUser> users = [
    TestUser(
      displayName: 'Apple',
      email: 'apple@test$accountSalt.com',
      photoUrl: 'https://picsum.photos/id/1/200/200',
    ),
    TestUser(
      displayName: 'Banana',
      email: 'banana@test$accountSalt.com',
      photoUrl: 'https://picsum.photos/id/2/200/200',
    ),
    TestUser(
      displayName: 'Cherry',
      email: 'cherry@test$accountSalt.com',
      photoUrl: 'https://picsum.photos/id/3/200/200',
    ),
    TestUser(
      displayName: 'Durian',
      email: 'durian@test$accountSalt.com',
      photoUrl: 'https://picsum.photos/id/4/200/200',
    ),
    TestUser(
      displayName: 'Eggplant',
      email: 'eggplant@test$accountSalt.com',
      photoUrl: 'https://picsum.photos/id/5/200/200',
    ),
  ];
  static get apple => users[0];
  static get banana => users[1];
  static get cherry => users[2];
  static get durian => users[3];
  static get eggplant => users[4];

  /// Prepare the test accounts
  ///
  /// The purpose of this method is to generate(or get) the uid of the test accounts.
  ///
  /// It will save the uid of the accounts and it will reuse the uid for the next test.
  ///
  /// This function will create test accounts if the account does not exist.
  static Future generateTestAccounts() async {
    final prefs = await SharedPreferences.getInstance();

    for (final user in Test.users) {
      final uid = prefs.getString(user.email);
      if (uid == null) {
        dog('Generating uid of ${user.email}');
        final login = await Test.loginOrRegister(user);
        user.uid = login.uid;
        await prefs.setString(user.email, user.uid!);

        await User.create(uid: user.uid!, email: user.email, displayName: user.displayName, photoUrl: user.photoUrl);
      } else {
        dog('Reusing uid: $uid of ${user.email}');
        user.uid = uid;
      }
    }
  }

  /// Login or register
  ///
  /// Creating a random user
  ///
  /// ```dart
  /// final email = "${randomString()}@gmail.com";
  /// final randomUser = await Test.loginOrRegister(
  ///   TestUser(
  ///     displayName: email,
  ///     email: email,
  ///     photoUrl: 'https://picsum.photos/id/1/200/200'
  ///   ),
  /// );
  /// ```
  ///
  /// @return User of firebase auth
  static Future<fa.User> loginOrRegister(TestUser user) async {
    try {
      final fa.UserCredential cred =
          await fa.FirebaseAuth.instance.signInWithEmailAndPassword(email: user.email, password: user.password);
      return cred.user!;
    } catch (e) {
      final cred =
          await fa.FirebaseAuth.instance.createUserWithEmailAndPassword(email: user.email, password: user.password);
      return cred.user!;
    }
  }

  /// Test login
  static Future<fa.User> login(TestUser user) async {
    //
    await fa.FirebaseAuth.instance.signOut();

    // Wait until logout is complete or you may see firestore permission denied error.
    await Test.wait();

    final fa.UserCredential cred =
        await fa.FirebaseAuth.instance.signInWithEmailAndPassword(email: user.email, password: user.password);
    await Test.wait();
    return cred.user!;
  }

  /// wait
  static Future<void> wait() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  static test(bool cond, [String? reason]) async {
    if (cond) {
      TestUser.successCount++;
      dog('OK [${TestUser.successCount}]: $reason');
    } else {
      TestUser.errorCount++;
      dog('>>>> ERROR [${TestUser.errorCount}]: $reason');
      log(StackTrace.current.toString());
    }
  }

  static start() {
    TestUser.successCount = 0;
    TestUser.errorCount = 0;
    log('------------------- TEST START --------------------');
  }

  static report() {
    log('------------------- TEST REPORT -------------------');
    log('Success: ${TestUser.successCount}');
    log('Error: ${TestUser.errorCount}');
  }

  /// Error code test
  ///
  /// [future] The future that throws an exception. It must throw an exception.
  /// [code] The exception code that must be thrown. Note that the exception code is the last part of the exception message.
  ///
  /// ```dart
  /// await Test.assertExceptionCode(room.invite(Test.cherry.uid), EasyChatCode.userAlreadyInRoom);
  /// await Test.assertExceptionCode(room.invite(Test.durian.uid), EasyChatCode.roomIsFull);
  /// ```
  static Future<void> assertExceptionCode(Future future, String code) async {
    try {
      await future;
      test(false, 'Exception must be thrown');
    } catch (e) {
      if (e.toString().split(': ').last == code) {
        test(true, 'Exception code must be $code');
      } else {
        test(false, 'Exception code must be $code. Actual code: ${e.toString()}');
      }
    }
  }

  /// Assert future must completed without error.
  ///
  /// [future] The future that must be completed.
  /// This will test if the future is completed or not.
  static Future<void> assertFuture(Future future, [String? reason]) {
    return future.then((value) {
      test(true, reason ?? 'Future has completed');
    }).catchError((e) {
      test(false, '${reason ?? 'Future must be completed.'}, Actual exception: $e');
    });
  }

  static Future<User> createRandomUser() {
    final email = "${randomString()}@gmail.com";
    return User.create(
      uid: randomString(),
      email: email,
      displayName: email,
      photoUrl: 'https://picsum.photos/id/100/200/200',
    );
  }
}

Future assertFuture(Future future, [String? reason]) {
  return Test.assertFuture(future, reason);
}

/// Test
test(bool cond, [String? reason]) {
  Test.test(cond, reason);
}

testFailed(String reason) {
  Test.test(false, reason);
}

testSuccess(String reason) {
  Test.test(true, reason);
}
