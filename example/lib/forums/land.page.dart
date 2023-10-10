import 'package:flutter/material.dart';
import 'package:new_app/router/router.dart';

class PostHome extends StatefulWidget {
  static const String routeName = '/PostHome';
  const PostHome({super.key});

  @override
  State<PostHome> createState() => PostHomeState();
}

class PostHomeState extends State<PostHome> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
