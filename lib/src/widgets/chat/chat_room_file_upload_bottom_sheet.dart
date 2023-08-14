import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/types/media_source.dart';
import 'package:flutter/material.dart';

class ChatRoomFileUploadBottomSheet extends StatefulWidget {
  const ChatRoomFileUploadBottomSheet({super.key, required this.room});

  final ChatRoomModel room;

  @override
  State<ChatRoomFileUploadBottomSheet> createState() =>
      _ChatRoomFileUploadBottomSheetState();
}

class _ChatRoomFileUploadBottomSheetState
    extends State<ChatRoomFileUploadBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Theme.of(context).canvasColor,
      child: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Choose a file/image from'),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Photo gallery'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context, MediaSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context, MediaSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('Choose File'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  debugPrint('Choosing a file');
                  Navigator.pop(context, MediaSource.file);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
