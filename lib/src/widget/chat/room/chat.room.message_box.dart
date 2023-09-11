import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomMessageBox extends StatefulWidget {
  const ChatRoomMessageBox({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  State<StatefulWidget> createState() => _ChatRoomMessageBoxState();
}

class _ChatRoomMessageBoxState extends State<ChatRoomMessageBox> {
  final TextEditingController message = TextEditingController();
  double? progress;

  Room? room;
  StreamSubscription? roomSubscription;

  @override
  void initState() {
    super.initState();

    //
    roomSubscription = Room.col
        .where('roomId', isEqualTo: widget.roomId)
        .snapshots()
        .listen((event) {
      if (event.size > 0) {
        room = Room.fromDocumentSnapshot(event.docs.first);
        roomSubscription!.cancel();
      }
    });
  }

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
                    // ChatService.instance.onPressedFileUploadIcon(context: context, room: widget.room);
                    final url = await StorageService.instance.upload(
                      context: context,
                      camera: ChatService.instance.uploadFromCamera,
                      gallery: ChatService.instance.uploadFromGallery,
                      file: ChatService.instance.uploadFromFile,
                      progress: (p) => setState(() => progress = p),
                      complete: () => setState(() => progress = null),
                    );
                    await ChatService.instance
                        .sendMessage(room: room!, url: url);
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
                      room: room!,
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
