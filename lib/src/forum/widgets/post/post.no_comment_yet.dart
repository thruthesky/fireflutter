import 'package:flutter/material.dart';

class PostNoCommentYet extends StatelessWidget {
  const PostNoCommentYet({
    Key? key,
    required this.onTap,
    this.margin = const EdgeInsets.all(16),
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  final Function onTap;
  final EdgeInsets margin;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(),
      child: Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: Color.fromARGB(168, 232, 246, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Colors.grey[800]),
            children: [
              TextSpan(
                text:
                    'Oops, there is no comment under this post, yet.\nPleaes be the first to leave a comment.\n',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
              WidgetSpan(
                  child: Icon(
                Icons.create,
                size: 16,
                color: Colors.blue.shade700,
              )),
              TextSpan(
                text: ' Create a comment',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
