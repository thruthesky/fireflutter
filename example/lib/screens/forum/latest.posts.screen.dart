import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class LatestPostsScreen extends StatefulWidget {
  static const String routeName = '/LatestPosts';
  const LatestPostsScreen({super.key});

  @override
  State<LatestPostsScreen> createState() => _LatestPostsScreenState();
}

class _LatestPostsScreenState extends State<LatestPostsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LatestPosts'),
      ),
      body: const Column(
        children: [
          Text("Community Latest Posts"),
          PostLatestListView(
            group: 'community',
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ),
          Text("Meetup Latest Posts"),
        ],
      ),
    );
  }
}
