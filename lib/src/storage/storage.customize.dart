import 'package:flutter/material.dart';

class StorageCustomize {
  /// [showUploads] is being invoked when the upload(images or files)
  /// are clicked. It can show any widget like a bottom sheet, a dialog or a
  /// screen.
  ///
  /// The purpose of this function is to show the upload widget in carousel.
  /// The uploaded url may contain image or file from chat, post, profile, etc.
  Future Function(BuildContext context, List<String>? urls, {int index})?
      showUploads;

  /// [uploadSelectionBottomsheetBuilder] is being invoked when the upload button
  /// is clicked. It can show any widget like a bottom sheet. The widget can
  /// call `Navigator.pop(context, ...);` to return the selection option for
  /// uploading  from camera or gallery with `ImageSource.camera` or
  /// `ImageSource.gallery`.
  Widget Function({
    required BuildContext context,
    required bool camera,
    required bool gallery,
  })? uploadSelectionBottomsheetBuilder;

  StorageCustomize({
    this.showUploads,
    this.uploadSelectionBottomsheetBuilder,
  });
}
