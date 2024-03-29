import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DefaultUploadSelectionBottomSheet extends StatelessWidget {
  const DefaultUploadSelectionBottomSheet({
    super.key,
    this.camera = true,
    this.gallery = true,
    this.padding,
    this.spacing,
  });

  final bool camera;
  final bool gallery;
  final EdgeInsetsGeometry? padding;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
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
            if (spacing != null) SizedBox(height: spacing),
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
              child: Text(T.close.tr,
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
