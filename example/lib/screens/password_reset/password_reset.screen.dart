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
          ElevatedButton(onPressed: () {}, child: const Text("Password Reset")),
        ],
      ),
    );
  }
}
