import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fireflutter/fireflutter.dart';

/// [onUploaded] is called on complete.
class FileUploadButton extends StatelessWidget {
  const FileUploadButton({
    this.child,
    required this.type,
    required this.onUploaded,
    required this.onProgress,
    Key? key,
  }) : super(key: key);

  final Widget? child;
  final UploadType type;
  final Function(String) onUploaded;
  final Function(double) onProgress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: child != null ? child : Icon(Icons.image),
      onTap: () => uploadFile(context),
    );
  }

  uploadFile(BuildContext ctx) async {
    // if (kIsWeb) {
    //   FilePickerResult? result = await FilePicker.platform.pickFiles();
    //   if (result == null) return;
    //   final resultFile = result.files.single;

    //   final uploadedFileUrl = await Storage.upload(
    //     basename: resultFile.name.toLowerCase(),
    //     file: resultFile.bytes!,
    //     type: type,
    //     onProgress: onProgress,
    //   );

    //   onUploaded(uploadedFileUrl);
    // } else {
    final String? re = await showModalBottomSheet<String?>(
      context: ctx,
      builder: (context) => Container(
        color: Colors.white,
        child: SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take Photo from Camera'),
                  onTap: () => Navigator.pop(context, 'camera')),
              if (!kIsWeb)
                ListTile(
                    leading: Icon(Icons.photo),
                    title: Text('Choose from Gallery'),
                    onTap: () => Navigator.pop(context, 'gallery')),
              ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('Attach File'),
                  onTap: () => Navigator.pop(context, 'file')),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );

    if (re == null) return;
    String uploadedFileUrl;
    if (re == 'camera' || re == 'gallery') {
      uploadedFileUrl = await Storage.pickUpload(
        onProgress: onProgress,
        source: re == 'camera' ? ImageSource.camera : ImageSource.gallery,
        type: type,
      );
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      // File file = File(result.files.single.path!);
      // debugPrint('file; $file');
      uploadedFileUrl = await Storage.upload(
        basename: result.files.single.name,
        file: result.files.single.bytes!,
        type: type,
        onProgress: onProgress,
      );
    }

    onUploaded(uploadedFileUrl);
    // }
  }
}
