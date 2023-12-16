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
          const SizedBox(height: 16),
          Text(tr.uploadTitle),
          const SizedBox(height: 8),
          if (photoGallery)
            ListTile(
              leading: const Icon(Icons.photo),
              title: Text(tr.uploadFromGallery),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, SourceType.photoGallery);
              },
            ),
          if (photoCamera)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(tr.uploadFromCamera),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, SourceType.photoCamera);
              },
            ),
          if (file)
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: Text(tr.uploadFromFiles),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                debugPrint('Choosing a file');
                Navigator.pop(context, SourceType.file);
              },
            ),
          TextButton(
            child: Text(tr.close),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
