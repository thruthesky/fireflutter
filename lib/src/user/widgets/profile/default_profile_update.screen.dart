import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DefaultProfileUpdateScreen extends StatefulWidget {
  const DefaultProfileUpdateScreen({super.key});

  @override
  State<DefaultProfileUpdateScreen> createState() =>
      _DefaultProfileScreenState();
}

class _DefaultProfileScreenState extends State<DefaultProfileUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(T.profileUpdate.tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: UserService.instance.customize.profileUpdateForm ??
              const DefaultProfileUpdateForm(
                gender: (display: true, require: true),
              ),
        ),
      ),
    );
  }
}
