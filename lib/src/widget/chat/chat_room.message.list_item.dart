import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/common/display_media/display_media.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_linkify/flutter_linkify.dart';

class ChatRoomMessageListItem extends StatelessWidget {
  const ChatRoomMessageListItem({
    super.key,
    required this.message,
  });

  final Message message;

  bool get isMyMessage => message.uid == FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    if (message.url != null && message.url != '') {
      return DisplayMedia(url: message.url!);
    }
    return LinkifyText(text: message.text ?? '');
  }
}
