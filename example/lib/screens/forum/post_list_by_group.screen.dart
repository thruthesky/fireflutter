import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostListByGroupScreen extends StatefulWidget {
  static const String routeName = '/PostListByGroup';
  const PostListByGroupScreen({super.key});

  @override
  State<PostListByGroupScreen> createState() => _PostListByGroupScreenState();
}

class _PostListByGroupScreenState extends State<PostListByGroupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('PostListByGroup'),
        ),
        body: const PostListView(
          group: 'community',
        ));
  }
}
