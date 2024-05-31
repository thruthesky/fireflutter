import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Edit comment dialog
///
/// This dialog is used to create or update a comment.
///
/// This dialog pops with `true` when the comment is created or updated.
class CommentEditDialog extends StatefulWidget {
  const CommentEditDialog({
    super.key,
    this.post,
    this.parent,
    this.comment,
    this.showUploadDialog,
    this.focusOnTextField,
  });

  final Post? post;
  final Comment? parent;
  final Comment? comment;
  final bool? showUploadDialog;
  final bool? focusOnTextField;

  @override
  State<CommentEditDialog> createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<CommentEditDialog> {
  bool get isCreate => widget.comment == null;

  double? progress;

  Comment? _comment;
  Comment get comment => _comment!;

  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.comment != null) {
      // 수정
      _comment = widget.comment;
      contentController.text = comment.content;
    } else {
      // 새로 작성. 이 때, comment ID 가 ref.push() 로 만들어 진다.
      _comment = Comment.fromPost(widget.post!);
    }

    if (widget.showUploadDialog == true) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        upload();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              autofocus: widget.focusOnTextField == true,
              controller: contentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comment',
              ),
              maxLines: 5,
              minLines: 3,
            ),
          ),

          /// 여기터 부터 코멘트 작성, 코멘트 사진 작성, 코멘트 좋아요, 신고, 차단

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                    onPressed: upload,
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 32,
                    )),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (isCreate) {
                      await comment.create(
                        content: contentController.text,
                        category: widget.post!.category,
                        urls: comment.urls,
                        parent: widget.parent,
                      );
                    } else {
                      await comment.update(
                        content: contentController.text,
                        urls: comment.urls,
                      );
                    }

                    if (context.mounted) Navigator.of(context).pop(true);
                  },
                  child: Text(
                    isCreate ? T.writeComment.tr : T.save.tr,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
              height: 16,
              child: Column(
                children: [
                  progress != null && progress!.isNaN == false
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: LinearProgressIndicator(
                            value: progress,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              )),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: EditUploads(
              urls: comment.urls,
              onDelete: (url) => setState(
                () {
                  comment.urls.remove(url);
                  // need to update the commend on the backend
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> upload() async {
    final String? url = await StorageService.instance.upload(
      context: context,
      progress: (p) => setState(() => progress = p),
      complete: () => setState(() => progress = null),
    );
    if (url != null) {
      setState(() {
        progress = null;
        comment.urls.add(url);
      });
    }
  }
}
