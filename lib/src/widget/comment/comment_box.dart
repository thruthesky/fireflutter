import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/comment.dart';
import 'package:fireflutter/src/service/comment.service.dart';
import 'package:flutter/material.dart';

class CommentBoxController extends ChangeNotifier {
  CommentBoxState? state;

  String? get labelText => state?.labelText;
  String? get hintText => state?.hintText;
  Comment? get replyTo => state?.replyTo;

  set labelText(String? labelText) {
    state?.labelText = labelText;
    notifyListeners();
  }

  set hintText(String? hintText) {
    state?.hintText = hintText;
    notifyListeners();
  }

  set replyTo(Comment? replyTo) {
    state?.replyTo = replyTo;
    notifyListeners();
  }

  // TODO blink animate? or show dance (to show the user that reply is added)?
}

class CommentBox extends StatefulWidget {
  const CommentBox(
      {super.key, required this.postId, this.replyTo, this.labelText, this.hintText, this.onSubmit, this.controller});

  final String postId;
  final Comment? replyTo;
  final String? labelText;
  final String? hintText;
  final Function()? onSubmit;

  final CommentBoxController? controller;

  @override
  State<CommentBox> createState() => CommentBoxState();
}

class CommentBoxState extends State<CommentBox> {
  TextEditingController content = TextEditingController();

  String? labelText;
  String? hintText;
  Comment? replyTo;

  @override
  void initState() {
    super.initState();
    widget.controller?.state = this;
    widget.controller?.addListener(() {
      // listener for updates in the controller
    });
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            UserAvatar(
              uid: UserService.instance.uid,
              key: ValueKey(UserService.instance.uid),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextFormField(
                  autofocus: true,
                  controller: content,
                  minLines: 1,
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: labelText ?? 'Comment',
                    hintText: hintText ?? 'Write a comment...',
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.photo),
              onPressed: () {
                // TODO send photo comment service
              },
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (content.text.isNotEmpty) {
                  // TODO send comment service
                  // CommentService.instance.createComment(
                  //     postId: widget.postId, content: content.text, replyTo: replyTo, lastRootComment: lastRootComment);
                  // TODO show the comment blink, scroll to the comment
                  content.text = '';
                  widget.onSubmit?.call();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
