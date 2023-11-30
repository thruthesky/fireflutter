import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class RChatMessageInputBox extends StatefulWidget {
  const RChatMessageInputBox({
    super.key,
    this.cameraIcon,
    this.sendIcon,
    this.onProgress,
    this.onSend,
  });

  final Widget? cameraIcon;
  final Widget? sendIcon;

  final Function(double?)? onProgress;

  /// [double] is null when upload is completed.
  final Function? onSend;

  @override
  State<RChatMessageInputBox> createState() => _ChatMessageInputBoxState();
}

class _ChatMessageInputBoxState extends State<RChatMessageInputBox> {
  final inputController = TextEditingController();
  double? progress;
  @override
  Widget build(BuildContext context) {
    return Column(
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
                    camera: ChatService.instance.uploadFromCamera,
                    gallery: ChatService.instance.uploadFromGallery,
                    file: ChatService.instance.uploadFromFile,
                    progress: (p) =>
                        widget.onProgress?.call(p) ??
                        setState(() {
                          progress = p;
                        }),
                    complete: () => widget.onProgress?.call(null) ?? setState(() => progress = null),
                  );
                  await RChat.sendChatMessage(url: url);
                },
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: widget.sendIcon ?? const Icon(Icons.send),
                    onPressed: () async {
                      await RChat.sendChatMessage(text: inputController.text);
                      inputController.clear();
                      widget.onSend?.call();
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
