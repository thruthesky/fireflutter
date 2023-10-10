import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

// TODO: catch exception on login and register
class _LoginFormState extends State<LoginForm> {
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: 282,
      width: size.width,
      child: Center(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(sizeSm),
            child: Column(
              children: [
                textFieldBuilder(false),
                const SizedBox(height: 8),
                textFieldBuilder(true),
                const SizedBox(height: 20),
                buttonBuilder('Login', true),
                buttonBuilder('Register', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // logInRegister() {}

  Widget buttonBuilder(String label, bool isHighlight) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return ElevatedButton(
          onPressed: () async {
            if (!isHighlight) {
              await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(email: email.text, password: password.text)
                  .then(
                    (value) => UserService.instance.sendWelcomeMessage(message: 'Welcome!'),
                  );
            } else {
              await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isHighlight ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withAlpha(25),
            elevation: 0,
            foregroundColor: isHighlight ? Theme.of(context).canvasColor : Theme.of(context).shadowColor,
            minimumSize: Size(constraints.maxWidth, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isHighlight ? Theme.of(context).primaryColor : Theme.of(context).shadowColor.withAlpha(100),
              ),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              // letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }

  TextField textFieldBuilder(bool isPassword) {
    return TextField(
      controller: isPassword ? password : email,
      decoration: InputDecoration(
        label: isPassword ? const Text('Password') : const Text('Email'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: isPassword,
    );
  }
}
