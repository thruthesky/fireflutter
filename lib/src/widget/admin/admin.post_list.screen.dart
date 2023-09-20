import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminPostListScreen extends StatefulWidget {
  static const String routeName = '/AdminPostList';
  const AdminPostListScreen({super.key, this.onTap});

  final Function(Post)? onTap;
  @override
  State<AdminPostListScreen> createState() => _AdminPostListScreenState();
}

class _AdminPostListScreenState extends State<AdminPostListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        title: Text('Admin Post List', style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface)),
      ),
      body: PostListView(
        onTap: widget.onTap,
      ),
    );
  }
}
