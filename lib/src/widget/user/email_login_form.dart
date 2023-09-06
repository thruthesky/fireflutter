import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({
    super.key,
  });

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
                children: [
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(label: Text('Email')),
                  ),
                  TextField(
                    controller: password,
                    decoration: const InputDecoration(label: Text('Password')),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(email: email.text, password: password.text);
                        },
                        child: const Text(
                          'Register',
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
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
                children: [
                  const Text('You have logged in'),
                  Text('uid: ${user.uid}'),
                  ElevatedButton(onPressed: () => UserService.instance.signOut(), child: const Text('Logout'))
                ],
              ));
  }
}
