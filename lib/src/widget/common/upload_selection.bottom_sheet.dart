import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

class UploadSelectionBottomSheet extends StatelessWidget {
  const UploadSelectionBottomSheet({
    super.key,
    // this.gallery = true,
    // this.camera = true,
    // this.file = true,
    this.gallery = false,
    this.photoGallery = true,
    this.photoCamera = true,
    this.videoCamera = false,
    this.videoGallery = false,
    this.file = false,
  });

  // final bool gallery;
  // final bool camera;
  // final bool file;

  final bool gallery;
  final bool photoCamera;
  final bool photoGallery;
  final bool videoCamera;
  final bool videoGallery;
  final bool file;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 32),
          const Text('Choose a file/image from'),
          // if (gallery)
          //   ListTile(
          //     leading: const Icon(Icons.photo),
          //     title: const Text('Photo gallery'),
          //     trailing: const Icon(Icons.chevron_right),
          //     onTap: () {
          //       Navigator.pop(context, ImageSource.gallery);
          //     },
          //   ),
          // if (camera)
          //   ListTile(
          //     leading: const Icon(Icons.camera_alt),
          //     title: const Text('Camera'),
          //     trailing: const Icon(Icons.chevron_right),
          //     onTap: () {
          //       Navigator.pop(context, ImageSource.camera);
          //     },
          //   ),
          // if (file)
          //   ListTile(
          //     leading: const Icon(Icons.file_upload),
          //     title: const Text('Choose File'),
          //     trailing: const Icon(Icons.chevron_right),
          //     onTap: () {
          //       debugPrint('Choosing a file');
          //       Navigator.pop(context, 'file');
          //     },
          //   ),
          if (photoGallery)
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Photo gallery'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigator.pop(context, ImageSource.gallery);
                Navigator.pop(context, SourceType.photoGallery);
                // Navigator.pop(context, 'gallery');
              },
            ),
          if (videoGallery)
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Video gallery'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigator.pop(context, SourceType.videoGallery);
                Navigator.pop(context, SourceType.videoGallery);
              },
            ),
          if (gallery)
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, SourceType.gallery);
              },
            ),

          if (photoCamera)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, SourceType.photoCamera);
              },
            ),
          if (videoCamera)
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video Camera'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, SourceType.videoCamera);
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
