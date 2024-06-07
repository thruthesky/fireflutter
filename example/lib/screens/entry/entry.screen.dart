import 'package:example/screens/home/home.screen.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_sign_in/phone_sign_in.dart';

class EntryScreen extends StatefulWidget {
  static const String routeName = '/Entry';
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
                "Enter complete phone number with country code. Or use email and password in 'email:password' format."),
            PhoneSignIn(
              onSignInSuccess: () => context.go(HomeScreen.routeName),
              onSignInFailed: (e) {
                debugPrint(e.toString());
                error(
                  context: context,
                  message: '$e - FirebaseAuthException in EntryScreen',
                );
              },
              specialAccounts: const SpecialAccounts(
                emailLogin: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
