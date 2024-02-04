import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultProfileScreen extends StatefulWidget {
  const DefaultProfileScreen({super.key});

  @override
  State<DefaultProfileScreen> createState() => _DefaultProfileScreenState();
}

class _DefaultProfileScreenState extends State<DefaultProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Code.profileUpdate.tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: UserService.instance.customize.profileUpdateForm ??
              const DefaultProfileUpdateForm(),
        ),
      ),
    );
  }
}
