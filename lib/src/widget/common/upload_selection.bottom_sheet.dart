import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

class UploadSelectionBottomSheet extends StatelessWidget {
  const UploadSelectionBottomSheet({
    super.key,
    this.photoGallery = true,
    this.photoCamera = true,
    this.file = true,
  });

  final bool photoCamera;
  final bool photoGallery;
  final bool file;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 18),
          const Text('Choose a file/image from'),
          if (photoGallery)
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose Photo from Gallery'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, SourceType.photoGallery);
              },
            ),
          if (photoCamera)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo from Camera'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, SourceType.photoCamera);
              },
            ),
          if (file)
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Choose File'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                debugPrint('Choosing a file');
                Navigator.pop(context, SourceType.file);
              },
            ),
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
