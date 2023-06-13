import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key, required this.room});

  final ChatRoomModel room;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final text = TextEditingController();
  @override
  void initState() {
    super.initState();
    ChatService.currentRoom = widget.room;
    ChatService.loadOtherUserDocument().then((value) => setState(() {}));
  }

  int orderNo = 0;
  XFile? image;
  String? imagePathResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO How can we manage the overflow error upon changing the orientation
      // Found an error when the user suddenly changed the orientation
      // when the on-screen keyboard is still there.
      // The error tells that the black 'n yellow stripes caused
      // the overflow although there is none displayed on the screen
      resizeToAvoidBottomInset: (MediaQuery.of(context).orientation == Orientation.portrait),
      appBar: AppBar(
        title: Row(
          children: [
            if (ChatService.otherUser?.photoUrl != null) ...[
              Flexible(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(ChatService.otherUser!.photoUrl),
                  backgroundColor: const Color.fromRGBO(200, 200, 200, 1),
                  minRadius: 5,
                  maxRadius: 15,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                ChatService.otherUser?.displayName ?? 'User has no name',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => const MoreInfoUserChat(),
            ),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.menu),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          if (ChatService.otherUser != null) ...[
            Expanded(
              child: FirebaseDatabaseListView(
                query: ChatService.roomRef.orderByChild('orderNo'),
                reverse: true,
                itemBuilder: (context, snapshot) {
                  final message = ChatMessageModel.fromSnapshot(snapshot);
                  orderNo = orderNo < message.orderNo ? orderNo : message.orderNo - 1;
                  final bool isMyMessage = (message.senderUid == UserService.uid);
                  return ChatBubbleWidget(
                    message: message,
                    isMyMessage: isMyMessage,
                    nameInBubble:
                        isMyMessage ? UserService.currentUser.displayName : ChatService.otherUser!.displayName,
                    photoUrl: isMyMessage ? "" : ChatService.otherUser!.photoUrl,
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Column(
                children: [
                  if (image != null && imagePathResponse == null) ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text('Uploading and Sending Photo... '),
                          Spacer(),
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: onFileUpload,
                        icon: const Icon(Icons.camera_alt),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: TextField(
                            controller: text,
                            autofocus: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Message',
                            ),
                            onSubmitted: (v) => onSubmitted(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onSubmitted,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  onSubmitted() {
    if (text.text.isEmpty) {
      return;
    }
    debugPrint(UserService.currentUser.displayName);
    ChatService.sendMessage(message: text.text, orderNo: orderNo);
    text.clear();
  }

  resetPhotoInputMessage() {
    if (mounted) {
      imagePathResponse = null;
      if (image != null) {
        setState(() {
          image = null;
        });
      }
    }
  }

  onFileUpload() async {
    if (image != null && imagePathResponse == null) {
      FireFlutter.instance.error(context, 'A photo is still being Uploaded!');
      return;
    }
    try {
      final re = await chooseMedia();
      if (re == null) return;
      final ImagePicker picker = ImagePicker();
      image = await picker.pickImage(source: re);
      if (image == null) return;
      setState(() {});

      FireFlutter.instance.error(context, '@TODO - Do it on parent project');
      // imagePathResponse = await Api.upload(filePath: image!.path);

      ChatService.sendMessage(orderNo: orderNo, photoUrl: imagePathResponse, message: '');
    } on PlatformException catch (error) {
      if (error.code == 'invalid_image') {
        FireFlutter.instance.error(context, 'Invalid Image: Something is wrong in the image you are trying to send.');
      } else {
        rethrow;
      }
    } catch (error) {
      rethrow;
    } finally {
      resetPhotoInputMessage();
    }
  }

  Future<ImageSource?> chooseMedia() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return const ChoosePhotoModal();
      },
    );
  }
}
