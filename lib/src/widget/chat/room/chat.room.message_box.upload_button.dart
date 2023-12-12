import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class ChatRoomMessageBoxUploadButton extends StatelessWidget {
  const ChatRoomMessageBoxUploadButton({
    super.key,
    this.room,
    this.onProgress,
    this.visualDensity,
    this.icon,
  });

  final Room? room;
  final Function(double?)? onProgress;
  final VisualDensity? visualDensity;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: visualDensity ?? VisualDensity.standard,
      icon: icon ??
          Icon(
            Icons.camera_alt,
            // size: 28,
            size: 24,
            color: Theme.of(context).colorScheme.onBackground,
          ),
      padding: EdgeInsets.zero,
      onPressed: () async {
        if (room == null) {
          toast(title: 'Wait...', message: 'The room is not ready yet.');
          return;
        }
        final url = await StorageService.instance.upload(
          context: context,
          // Updated from this.
          camera: ChatService.instance.uploadFromCamera,
          gallery: ChatService.instance.uploadFromGallery,
          file: ChatService.instance.uploadFromFile,
          // photoCamera: true,
          // photoGallery: true,
          // file: true,
          // gallery: false,
          // videoCamera: false,
          // videoGallery: false,
          progress: (p) => onProgress?.call(p),
          complete: () => onProgress?.call(null),
        );
        await ChatService.instance.sendMessage(room: room!, url: url);
      },
    );
  }
}
