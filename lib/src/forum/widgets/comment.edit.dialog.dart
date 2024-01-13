import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class CommentEditDialog extends StatefulWidget {
  const CommentEditDialog({super.key, required this.post, this.parent, this.comment});

  final PostModel post;
  final CommentModel? parent;
  final CommentModel? comment;

  @override
  State<CommentEditDialog> createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<CommentEditDialog> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Comment',
          ),
        ),
        const SizedBox(height: 16)

        /// 여기터 부터 코멘트 작성, 코멘트 사진 작성, 코멘트 좋아요, 신고, 차단
        ,
        SafeArea(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text(
              'Submit',
            ),
          ),
        )
      ],
    );
  }
}
