import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// 채팅 메시지 입력 박스
///
/// TODO - 업로드 progress bar 를 이 위젯에 직접 표시 할 것.
class ChatMessageInputBox extends StatefulWidget {
  const ChatMessageInputBox({
    super.key,
    required this.chat,
    this.cameraIcon,
    this.sendIcon,
    this.onProgress,
    this.onSend,
  });

  final ChatModel chat;

  final Widget? cameraIcon;
  final Widget? sendIcon;

  final Function(double?)? onProgress;

  /// [double] is null when upload is completed.
  final void Function({String? text, String? url})? onSend;

  @override
  State<ChatMessageInputBox> createState() => _ChatMessageInputBoxState();
}

class _ChatMessageInputBoxState extends State<ChatMessageInputBox> {
  final inputController = TextEditingController();
  double? progress;
  @override
  Widget build(BuildContext context) {
    if (widget.chat.room.isSingleChat &&
        iHave.blocked(widget.chat.room.otherUserUid!)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (progress != null && !progress!.isNaN)
          LinearProgressIndicator(value: progress),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: inputController,
            decoration: InputDecoration(
              isDense: false,
              contentPadding: const EdgeInsets.only(
                top: 7,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: '메시지를 입력하세요.',
              prefixIcon: IconButton(
                icon: widget.cameraIcon ?? const Icon(Icons.camera_alt),
                onPressed: () async {
                  /// 인증된 사용자만 파일 전송 옵션
                  if (widget.chat.room.uploadVerifiedUserOnly &&
                      iam.notVerified) {
                    return error(
                        context: context, message: T.notVerifiedMessage.tr);
                  }
                  final url = await StorageService.instance.upload(
                    context: context,
                    // Review
                    camera: true,
                    gallery: true,
                    progress: (p) => widget.onProgress?.call(p) ?? mounted
                        ? setState(() => progress = p)
                        : null,
                    complete: () => widget.onProgress?.call(null) ?? mounted
                        ? setState(() => progress = null)
                        : null,
                  );

                  await send(url: url);
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

                      /// 인증된 사용자만 URL 전송 옵션
                      if (text.hasUrl == true &&
                          widget.chat.room.urlVerifiedUserOnly &&
                          iam.notVerified) {
                        return error(
                            context: context, message: T.notVerifiedMessage.tr);
                      }

                      inputController.clear();
                      await send(text: text);
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

  send({String? text, String? url}) async {
    try {
      if (text != null) {
        await widget.chat.sendMessage(text: text);
      }
      if (url != null) {
        await widget.chat.sendMessage(url: url);
      }
    } on Issue catch (e) {
      if (mounted) {
        error(context: context, message: '${e.code.tr}\n${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
