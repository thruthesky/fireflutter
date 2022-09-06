import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class EditUploadedImage extends StatelessWidget {
  const EditUploadedImage({
    Key? key,
    required this.url,
    required this.onDeleted,
    this.width,
    this.height,
  }) : super(key: key);

  final String url;
  final Function() onDeleted;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            width: double.infinity,
            child: UploadedImage(
              url: url,
              width: width ?? 150,
              height: height ?? 150,
            )),
        Positioned(
          top: 8,
          left: 8,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(3),
              child: Icon(
                Icons.delete_forever_rounded,
                color: Colors.red.shade800,
                size: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2.5,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            onTap: () async {
              bool? re = await showDialog<bool?>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete file?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Yes'),
                    ),
                  ],
                ),
              );
              if (re == null) return;

              await Storage.delete(url);
              onDeleted();
            },
          ),
        ),
      ],
    );
  }
}
