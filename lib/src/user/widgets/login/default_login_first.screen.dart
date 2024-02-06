import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultLoginFirstScreen extends StatelessWidget {
  const DefaultLoginFirstScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return UserService.instance.customize.loginFirstScreen ??
        Scaffold(
          appBar: AppBar(
            title: const Text('로그인'),
          ),
          body: const Center(
            child: Text('로그인을 먼저 해 주세요.'),
          ),
        );
  }
}
