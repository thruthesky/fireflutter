import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:new_app/home/landing.page.dart';
import 'package:new_app/login/login.form.dart';

class LoginPageBody extends StatelessWidget {
  const LoginPageBody({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthChange(
        builder: (user) => user == null
            ? const Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                ),
                child: Center(
                  child: LoginForm(),
                ),
              )
            : const LandingPage(),
      ),
    );
  }
}
