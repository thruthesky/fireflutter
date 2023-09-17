import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class StorageCustomize {
  /// [showUploads] is being invoked when the upload(images or files)
  /// are clicked. It can show any widget like a bottom sheet, a dialog or a
  /// screen.
  ///
  /// The purpose of this function is to show the upload widget in carousel.
  /// The uploaded url may contain image or file from chat, post, profile, etc.
  Future Function(BuildContext context, List<String>? urls)? showUploads;

  StorageCustomize({
    this.showUploads,
  });
}
