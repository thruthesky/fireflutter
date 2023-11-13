import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({
    super.key,
    this.register = true,
    this.onLogin,
    this.passwordPadding = const EdgeInsets.all(0),
    this.emailPadding = const EdgeInsets.all(0),
  });

  final bool register;
  final VoidCallback? onLogin;
  final EdgeInsetsGeometry passwordPadding;
  final EdgeInsetsGeometry emailPadding;

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthChange(
      builder: (user) => user == null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: widget.emailPadding,
                  child: TextField(
                    key: const Key('EmailTextField'),
                    controller: email,
                    decoration: const InputDecoration(label: Text('Email')),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Padding(
                  padding: widget.passwordPadding,
                  child: TextField(
                    key: const Key('PasswordTextField'),
                    controller: password,
                    decoration: const InputDecoration(label: Text('Password')),
                  ),
                ),
                Row(
                  children: [
                    if (widget.register)
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(email: email.text, password: password.text);
                          widget.onLogin?.call();
                        },
                        child: const Text(
                          'Register',
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      key: const Key('LoginButton'),
                      onPressed: () async {
                        await FirebaseAuth.instance
                            .signInWithEmailAndPassword(email: email.text, password: password.text);
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
                ElevatedButton(onPressed: () => UserService.instance.signOut(), child: const Text('Logout'))
              ],
            ),
    );
  }
}
