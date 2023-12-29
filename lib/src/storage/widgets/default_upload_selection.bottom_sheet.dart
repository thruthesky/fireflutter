import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';

class DefaultUploadSelectionBottomSheet extends StatelessWidget {
  const DefaultUploadSelectionBottomSheet({
    super.key,
    this.camera = true,
    this.gallery = true,
  });

  final bool camera;
  final bool gallery;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 16),
          const Text('사진 업로드'),
          const SizedBox(height: 8),
          if (gallery)
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('갤러리에서 사진 가져오기'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
          if (camera)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 사진 찍기'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
          TextButton(
            child: Text('취소',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
