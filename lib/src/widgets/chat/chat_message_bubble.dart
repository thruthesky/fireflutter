import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({
    super.key,
    required this.chatMessage,
  });

  final ChatMessageModel chatMessage;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  bool _showDateTime = false;
  @override
  Widget build(BuildContext context) {
    final isMyMessage =
        widget.chatMessage.senderUid == FirebaseAuth.instance.currentUser!.uid;
    late final MainAxisAlignment bubbleMainAxisAlignment;
    late final CrossAxisAlignment bubbleCrossAxisAlignment;
    late final Color colorOfBubble;
    late final BorderRadius borderRadiusOfBubble;
    const radiusOfCorners = Radius.circular(16);
    const borderRadiusOfBubbleOfOtherUser = BorderRadius.only(
      topRight: radiusOfCorners,
      bottomLeft: radiusOfCorners,
      bottomRight: radiusOfCorners,
    );
    const borderRadiusOfBubbleOfCurrentUser = BorderRadius.only(
      topLeft: radiusOfCorners,
      bottomLeft: radiusOfCorners,
      bottomRight: radiusOfCorners,
    );
    // To set the bubble details
    if (isMyMessage) {
      colorOfBubble = Theme.of(context).colorScheme.primaryContainer;
      bubbleMainAxisAlignment = MainAxisAlignment.end;
      bubbleCrossAxisAlignment = CrossAxisAlignment.end;
      borderRadiusOfBubble = borderRadiusOfBubbleOfCurrentUser;
    } else {
      colorOfBubble = Theme.of(context).colorScheme.tertiaryContainer;
      bubbleMainAxisAlignment = MainAxisAlignment.start;
      bubbleCrossAxisAlignment = CrossAxisAlignment.start;
      borderRadiusOfBubble = borderRadiusOfBubbleOfOtherUser;
    }

    final user = UserService.instance.get(widget.chatMessage.senderUid);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: bubbleMainAxisAlignment,
      children: [
        if (!isMyMessage) ...[
          FutureBuilder(
            future: user,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black26,
                  ),
                );
              }
              if (snapshot.hasData == false) {
                return const Text('Error - no user');
              }
              final user = snapshot.data as UserModel;
              return Row(
                children: [
                  user.hasPhotoUrl == false
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(user.photoUrl),
                          ),
                        ),
                ],
              );
            },
          ),
        ],
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: bubbleCrossAxisAlignment,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isMyMessage) ...[
                      FutureBuilder(
                        future: user,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) return const Text('');
                          if (snapshot.hasData == false) return const Text('');
                          final user = snapshot.data as UserModel;
                          return user.hasPhotoUrl == false
                              ? const SizedBox()
                              : Text(
                                  user.displayName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                );
                        },
                      ),
                    ],
                  ],
                ),
                if (widget.chatMessage.text != null)
                  GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        _showDateTime = !_showDateTime;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorOfBubble,
                        borderRadius: borderRadiusOfBubble,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.chatMessage.text!),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.chatMessage.fileUrl != null)
                  GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        _showDateTime = !_showDateTime;
                      });
                    },
                    onTap: () {
                      debugPrint('launching ${widget.chatMessage.fileUrl}');
                      launchUrl(Uri.parse(widget.chatMessage.fileUrl!));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorOfBubble,
                        borderRadius: borderRadiusOfBubble,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.file_download),
                            ),
                            Flexible(
                              child: Text(
                                widget.chatMessage.fileName ??
                                    widget.chatMessage.fileUrl ??
                                    'File Attachment',
                                style: const TextStyle(
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.chatMessage.imageUrl != null)
                  Image.network(widget.chatMessage.imageUrl!),
                Visibility(
                  visible: _showDateTime,
                  child: Text(widget.chatMessage.createdAt != null
                      ? toAgoDate(widget.chatMessage.createdAt!.toDate())
                      : ''),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  toAgoDate(DateTime date) {
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays >= 2) {
      return date.toIso8601String();
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} ${diff.inSeconds == 1 ? "second" : "seconds"} ago';
    } else {
      return 'Just Now';
    }
  }
}
