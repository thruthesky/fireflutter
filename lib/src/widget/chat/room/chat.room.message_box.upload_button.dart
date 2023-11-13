import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class ChatRoomMessageBoxUploadButton extends StatelessWidget {
  const ChatRoomMessageBoxUploadButton({super.key, this.room, this.onProgress});

  final Room? room;
  final Function(double?)? onProgress;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.camera_alt,
        size: 28,
      ),
      padding: EdgeInsets.zero,
      onPressed: () async {
        if (room == null) {
          toast(title: 'Wait...', message: 'The room is not ready yet.');
          return;
        }
        final url = await StorageService.instance.upload(
          context: context,
          camera: ChatService.instance.uploadFromCamera,
          gallery: ChatService.instance.uploadFromGallery,
          file: ChatService.instance.uploadFromFile,
          progress: (p) => onProgress?.call(p),
          complete: () => onProgress?.call(null),
        );
        await ChatService.instance.sendMessage(room: room!, url: url);
      },
    );
  }
}
