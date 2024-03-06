import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
            T.photoUpload.tr,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 16),
          if (gallery)
            ListTile(
              leading: const Icon(Icons.photo),
              title: Text(T.selectPhotoFromGallery.tr),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
          if (camera)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(T.takePhotoWithCamera.tr),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
          const SizedBox(height: 16),
          TextButton(
            child: Text(T.cancel.tr,
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
