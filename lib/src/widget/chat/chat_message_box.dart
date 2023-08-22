import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomMessageBox extends StatefulWidget {
  const ChatRoomMessageBox({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  State<StatefulWidget> createState() => _ChatRoomMessageBoxState();
}

class _ChatRoomMessageBoxState extends State<ChatRoomMessageBox> {
  final TextEditingController message = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(
              Icons.camera_alt,
              size: 28,
            ),
            padding: EdgeInsets.zero,
            onPressed: () async {
              // ChatService.instance.onPressedFileUploadIcon(context: context, room: widget.room);
              final url = await StorageService.instance.ask(context: context);
              print('url; $url');
              await ChatService.instance.sendMessage(room: widget.room, url: url);
            },
          ),
          Expanded(
            child: TextField(
              controller: message,
              decoration: const InputDecoration(
                hintText: 'Message',
                border: InputBorder.none,
              ),
              maxLines: 5,
              minLines: 1,
            ),
          ),
          IconButton(
            onPressed: () async {
              if (message.text.isEmpty) return;
              final text = message.text;
              message.text = '';
              await ChatService.instance.sendMessage(
                room: widget.room,
                text: text,
              );
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
