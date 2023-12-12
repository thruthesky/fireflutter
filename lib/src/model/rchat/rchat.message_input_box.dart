import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class RChatMessageInputBox extends StatefulWidget {
  const RChatMessageInputBox({
    super.key,
    this.cameraIcon,
    this.sendIcon,
    this.onProgress,
    this.onSend,
    this.beforeUpload,
  });

  final Widget? cameraIcon;
  final Widget? sendIcon;

  final Function(double?)? onProgress;

  /// [double] is null when upload is completed.
  final void Function({String? text, String? url})? onSend;

  final Future<String> Function(String path, SourceType source)? beforeUpload;

  @override
  State<RChatMessageInputBox> createState() => _ChatMessageInputBoxState();
}

class _ChatMessageInputBoxState extends State<RChatMessageInputBox> {
  final inputController = TextEditingController();
  double? progress;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (progress != null && !progress!.isNaN) LinearProgressIndicator(value: progress),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: inputController,
            decoration: InputDecoration(
              // isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: '메시지를 입력하세요.',
              prefixIcon: IconButton(
                icon: widget.cameraIcon ?? const Icon(Icons.camera_alt),
                onPressed: () async {
                  final url = await StorageService.instance.upload(
                    context: context,
                    // Review
                    // camera: ChatService.instance.uploadFromCamera,
                    // gallery: ChatService.instance.uploadFromGallery,
                    // file: ChatService.instance.uploadFromFile,
                    gallery: true,
                    photoCamera: true,
                    videoCamera: true,
                    file: true,
                    photoGallery: false,
                    videoGallery: false,
                    progress: (p) => widget.onProgress?.call(p) ?? mounted ? setState(() => progress = p) : null,
                    complete: () => widget.onProgress?.call(null) ?? mounted ? setState(() => progress = null) : null,
                    beforeUpload: widget.beforeUpload,
                  );
                  await RChat.sendMessage(url: url);
                  widget.onSend?.call(text: null, url: url);
                },
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: widget.sendIcon ?? const Icon(Icons.send),
                    onPressed: () async {
                      String text = inputController.text.trim();
                      if (text.isEmpty) return;
                      await RChat.sendMessage(text: text);
                      inputController.clear();
                      widget.onSend?.call(text: text, url: null);
                    },
                  ),
                ],
              ),
            ),
            minLines: 1,
            maxLines: 5,
          ),
        ),
      ],
    );
  }
}
