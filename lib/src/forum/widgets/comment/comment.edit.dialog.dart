import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class CommentEditDialog extends StatefulWidget {
  CommentEditDialog({
    Key? key,
    required this.onCancel,
    required this.onSubmit,
    this.comment,
  }) : super(key: key);

  final Function() onCancel;
  final Function(Json, Function(bool)) onSubmit;
  final CommentModel? comment;

  @override
  State<CommentEditDialog> createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<CommentEditDialog> {
  final content = TextEditingController();
  List<String> files = [];

  double uploadProgress = 0;

  bool inSubmit = false;

  @override
  void initState() {
    super.initState();

    if (widget.comment != null) {
      content.text = widget.comment!.content;
      files = widget.comment!.files;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Comment ' + (widget.comment == null ? 'Create' : 'Update'),
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: content,
              minLines: 1,
              maxLines: 10,
            ),
            SizedBox(height: 8),
            Row(children: [
              FileUploadButton(
                child: Icon(
                  Icons.camera_alt,
                  size: 28,
                ),
                type: 'comment',
                onUploaded: (url) {
                  files = [...files, url];
                  uploadProgress = 0;
                  if (mounted) setState(() {});
                },
                onProgress: (progress) {
                  if (mounted) setState(() => uploadProgress = progress);
                },
                // onError: widget.onError,
              ),
              Spacer(),
              TextButton(
                child: const Text('CANCEL'),
                onPressed: widget.onCancel,
              ),
              TextButton(
                child: inSubmit
                    ? Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(right: 16),
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('SUBMIT'),
                onPressed: inSubmit
                    ? null
                    : () {
                        widget.onSubmit({
                          'content': content.text,
                          'files': files,
                        }, progress);
                      },
              ),
            ]),
            if (uploadProgress > 0)
              LinearProgressIndicator(value: uploadProgress),
            ImageListEdit(
              files: files,
              onDeleted: (deletedFileUrl) {
                if (widget.comment == null) return;

                /// TODO delete image from the comment.

                /// On post (or comment) edit screen, a user may press back button after deleting an image (without saving the post or comment),
                /// Then, the image is deleted but the post(or comment) still has the image and the app is trying to show.
                /// In result, there will be a broken image.
                /// To prevent this senario, when an image is deleted, the app will update the image list immediately.
                // FunctionsApi.instance.request(
                //   FunctionName.commentUpdate,
                //   data: {'id': widget.comment!.id, 'files': files},
                //   addAuth: true,
                // );
              },
            ),
          ],
        ),
      ),
    );
  }

  progress(bool f) {
    setState(() {
      inSubmit = f;
    });
  }
}
