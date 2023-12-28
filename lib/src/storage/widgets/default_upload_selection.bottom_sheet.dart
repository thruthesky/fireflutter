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
          const Text('Upload from'),
          const SizedBox(height: 8),
          if (gallery)
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Photo Gallery'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
          if (camera)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
