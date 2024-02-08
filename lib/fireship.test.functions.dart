import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireship/fireship.dart';

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
// Future<User> loginOrRegister({
//   required String email,
//   required String password,
//   required String photoUrl,
// }) async {
//   UserCredential? cred;
//   try {
//     cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   } catch (e) {
//     cred = await FirebaseAuth.instance
//         .createUserWithEmailAndPassword(email: email, password: password);
//   }

//   final user = cred.user!;

//   final userModel = await UserModel.get(user.uid);
//   if (userModel == null) {
//     final model = UserModel.fromUid(user.uid);
//     model.update(
//       displayName: email.split('@').first,
//       photoUrl: photoUrl,
//     );
//   }

//   return user;
// }
