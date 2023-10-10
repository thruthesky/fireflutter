import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:new_app/forums/feed.body.dart';
import 'package:new_app/page.essentials/app.bar.dart';
import 'package:new_app/page.essentials/bottom.navbar.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key});

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

// TODO: follow has an error (Failed assertion: line 116 pos 14: 'path.isNotEmpty')
class _NewsFeedState extends State<NewsFeed> {
  @override
  void initState() {
    super.initState();
    PostService.instance.enableNotificationOnLike = true;
    PostService.instance.init(
        enableNotificationOnLike: true,
        onLike: (Post post, bool isLiked) async {
          if (!isLiked) return;
          MessagingService.instance.queue(
            title: post.title,
            body: '${my.name} liked your post',
            id: myUid,
            uids: [post.uid],
            type: NotificationType.post.name,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Forum'),
      body: const FeedBody(),
      bottomNavigationBar: const BottomNavBar(index: 0),
    );
  }
}
