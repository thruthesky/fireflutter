import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({
    super.key,
    this.register = true,
    this.onLogin,
  });

  final bool register;
  final VoidCallback? onLogin;

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return UserReady(
      builder: (user) => user == null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: email,
                  decoration: const InputDecoration(label: Text('Email')),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: password,
                  decoration: const InputDecoration(label: Text('Password')),
                ),
                Row(
                  children: [
                    if (widget.register)
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: email.text, password: password.text);
                          widget.onLogin?.call();
                        },
                        child: const Text(
                          'Register',
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email.text, password: password.text);
                        widget.onLogin?.call();
                      },
                      child: const Text(
                        'Login',
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('You have logged in'),
                Text('uid: ${user.uid}'),
                ElevatedButton(
                    onPressed: () => UserService.instance.signOut(),
                    child: const Text('Logout'))
              ],
            ),
    );
  }
}
