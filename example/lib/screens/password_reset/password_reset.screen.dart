import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordResetScreen extends StatefulWidget {
  static const String routeName = '/PasswordReset';
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PasswordReset'),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                final actionCodeSettings = ActionCodeSettings(
                  /// This property has dynamic usage depending where you use it
                  ///
                  /// if the logic is handled in web, this will be
                  /// the parameter for deep link
                  ///
                  /// if it is being handled in app, this will be
                  /// the parameter in the deep link of the Dynamic Link
                  url: 'https://withcenter-test-3.firebaseapp.com/path',

                  /// if true, the url will be sent as a universal link
                  /// and can be open by app
                  // handleCodeInApp: false,

                  /// if set, this will be used as the domain (or subdomain) of the link
                  /// since many dynamic links can be configure per project this will ONLY
                  /// use the specified domain. NOTE: if empty, this will use the OLDEST domain
                  // dynamicLinkDomain: 'app.domain',

                  /// if true, it will install the app if the
                  /// device supports the app requirements
                  // androidInstallApp: false,

                  /// bundleId of the app
                  // iOSBundleId: 'com.withcenter.test3',

                  /// if the androidInstallApp is true, the package name
                  /// is required and if not provided it will throw an error
                  // androidPackageName: 'com.withcenter.test3',

                  /// if this is provided, and if the app from the user's device
                  /// are an olderVersion it will redirect to
                  /// PlayStore/AppStore to update the app before proceeding
                  // androidMinimumVersion: '24',
                );

                try {
                  /// TODO - user not found error is not thrown even if the email is not registered
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    /// email of the user that will receive the reset password link
                    email: 'thruthesky@gmail.com',

                    /// This is optional but this is helpful to
                    /// customize the logic flow inside the app
                    actionCodeSettings: actionCodeSettings,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset email sent. Please check your email.',
                        ),
                      ),
                    );
                  }
                } on FirebaseAuthException catch (fe) {
                  debugPrint(fe.code);
                  debugPrint(fe.toString());
                  debugPrint(fe.message);

                  rethrow;
                } catch (error) {
                  debugPrint(error.toString());
                  rethrow;
                }
              },
              child: const Text("Password Reset")),
        ],
      ),
    );
  }
}
