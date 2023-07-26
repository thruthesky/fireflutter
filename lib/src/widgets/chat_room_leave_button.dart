import 'package:easychat/easychat.dart';
import 'package:flutter/material.dart';

class LeaveButton extends StatelessWidget {
  const LeaveButton({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

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
                    // TODO leave the room to prevent the error
                    EasyChat.instance.leaveRoom(
                        room: room,
                        callback: () {
                          // TODO or leave here
                        });
                    debugPrint("Leaving");
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
