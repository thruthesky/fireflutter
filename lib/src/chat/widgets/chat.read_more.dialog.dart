import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReadMoreDialog extends StatelessWidget {
  const ReadMoreDialog({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: AlertDialog(
        title: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatar(
                key: ValueKey(message.key),
                uid: message.uid!,
                cacheId: message.uid,
                size: 30,
                radius: 12,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateTimeShort(stamp: message.createdAt ?? 0),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: UserDisplayName(
                      uid: message.uid,
                      cacheId: 'chatRoom',
                      style: Theme.of(context).textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        content: Text(message.text!),
      ),
    );
  }
}
