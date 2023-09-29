import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Chat Room Message Box
///
/// Use this widget to display chat input box on chat room screen.
///
/// Note that, the [room] property is required, but it cannbe nullable.
/// The [room] property is not used until user input a message and send it or
/// upload a file. So, the [room] must be ready when user send a message or
/// upload a file.
/// This is because to display the message input box as fast as possible even
/// if the room does not exist, it will display the input box first and then
/// on the parent widget, the app must create a chat room and deliver the
/// [room] value to this widget if the room does not exist.
///
///
class ChatRoomMessageBox extends StatefulWidget {
  const ChatRoomMessageBox({
    super.key,
    required this.room,
  });

  final Room? room;

  @override
  State<StatefulWidget> createState() => _ChatRoomMessageBoxState();
}

class _ChatRoomMessageBoxState extends State<ChatRoomMessageBox> {
  final TextEditingController message = TextEditingController();
  double? progress;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          if (progress != null)
            LinearProgressIndicator(
              value: progress,
            ),
          const Divider(),
          Padding(
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
                    if (widget.room == null) {
                      toast(
                          title: 'Wait...',
                          message: 'The room is not ready yet.');
                      return;
                    }
                    final url = await StorageService.instance.upload(
                      context: context,
                      camera: ChatService.instance.uploadFromCamera,
                      gallery: ChatService.instance.uploadFromGallery,
                      file: ChatService.instance.uploadFromFile,
                      progress: (p) => setState(() => progress = p),
                      complete: () => setState(() => progress = null),
                    );
                    await ChatService.instance
                        .sendMessage(room: widget.room!, url: url);
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
                    if (widget.room == null) {
                      toast(
                          title: 'Wait...',
                          message: 'The room is not ready yet.');
                      return;
                    }
                    if (message.text.isEmpty) return;
                    final text = message.text;
                    message.text = '';
                    await ChatService.instance.sendMessage(
                      room: widget.room!,
                      text: text,
                    );
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
