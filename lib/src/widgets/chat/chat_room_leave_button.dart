import 'package:fireflutter/src/models/room.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:flutter/material.dart';

@Deprecated('Don\'t use this. Use ChatRoomAppBarTitle instead. This will be deleted')
class LeaveButton extends StatelessWidget {
  const LeaveButton({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Leave'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Leaving Room"),
              content: const Text("Are you sure you want to leave the group chat?"),
              actions: [
                TextButton(
                  child: const Text("Leave"),
                  onPressed: () {
                    // ! For confirmation
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ChatService.instance.leaveRoom(
                      room: room,
                    );
                  },
                ),
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          },
        );
      },
    );
  }
}
