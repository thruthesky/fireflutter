import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChoosePhotoModal extends StatelessWidget {
  const ChoosePhotoModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 32),
            const Text('Choose a photo'),
            SizedBox(height: 24),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                size: 32,
              ),
              title: const Text('From Photo Gallery'),
              onTap: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 32),
              title: const Text('From Camera'),
              onTap: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
