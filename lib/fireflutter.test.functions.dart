import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fireflutter/fireflutter.dart';

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
Future<fb.User> loginOrRegister({
  required String email,
  required String password,
  required String photoUrl,
}) async {
  fb.UserCredential? cred;
  try {
    cred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    cred = await fb.FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  final user = cred.user!;

  final userModel = await User.get(user.uid);
  if (userModel == null) {
    final model = User.fromUid(user.uid);
    model.update(
      displayName: email.split('@').first,
      photoUrl: photoUrl,
    );
  }

  return user;
}
