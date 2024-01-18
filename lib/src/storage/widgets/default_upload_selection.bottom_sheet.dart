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
          Text(
            '사진 업로드',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          TextButton(
            child: Text('취소',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
