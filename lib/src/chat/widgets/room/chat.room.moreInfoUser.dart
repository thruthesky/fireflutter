import 'package:fireflutter/src/chat/chat.service.dart';
import 'package:flutter/material.dart';

class MoreInfoUserChat extends StatelessWidget {
  const MoreInfoUserChat({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24.0,
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (ChatService.otherUser != null) ...[
              if (ChatService.otherUser?.photoUrl != null) ...[
                CircleAvatar(
                  backgroundImage: NetworkImage(ChatService.otherUser!.photoUrl),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  minRadius: 10,
                  maxRadius: 40,
                ),
              ] else ...[
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  minRadius: 10,
                  maxRadius: 40,
                ),
              ],
              Text(
                ChatService.otherUser!.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ), // TODO update to Theme
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                onPressed: () => {},
                child: const Text('Video Call'),
              ),
              ElevatedButton(
                onPressed: () => {},
                child: const Text('View Profile'),
              ),
              ElevatedButton(
                onPressed: () => {},
                child: const Text('Block this person'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
