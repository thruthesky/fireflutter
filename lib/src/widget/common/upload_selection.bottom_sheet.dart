import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadSelectionBottomSheet extends StatefulWidget {
  const UploadSelectionBottomSheet({super.key});

  @override
  State<UploadSelectionBottomSheet> createState() => _UploadSelectionBottomSheetState();
}

class _UploadSelectionBottomSheetState extends State<UploadSelectionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 32),
          const Text('Choose a file/image from'),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Photo gallery'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context, ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context, ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Choose File'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              debugPrint('Choosing a file');
              Navigator.pop(context, 'file');
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
