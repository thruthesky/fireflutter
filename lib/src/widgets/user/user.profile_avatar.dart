import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widgets/user/user.avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// UserProfileAvatar
///
/// Displays the user's avatar.
///
/// [badgeNumber] is the number of notifications.
///
/// [upload] if [upload] is set to true, then it displays the camera upload
/// button and does the upload.
///
/// [delete] is the callback function that is being called when the user taps the delete button.
///
/// [defaultIcon] is a widget to be displayed when the user's avatar is not available.
/// and the [name] property of AdvancedAvatar is igonored by [defaultIcon].
///
/// Note, that this avatar widget uses the [AdvancedAvatar] widget from
/// the [flutter_advanced_avatar](https://pub.dev/packages/flutter_advanced_avatar) package.
/// See the examples from the github: https://github.com/alex-melnyk/flutter_advanced_avatar/blob/master/example/lib/main.dart
class UserProfileAvatar extends StatefulWidget {
  const UserProfileAvatar({
    super.key,
    required this.user,
    this.size = 100,
    this.radius = 20,
    this.badgeNumber,
    this.upload = false,
    this.delete = false,
    this.uploadStrokeWidth = 6,
    this.shadowBlurRadius = 16.0,
    this.defaultIcon,
    this.backgroundColor,
    this.onTap,
  });

  final User user;
  final double radius;
  final double size;
  final int? badgeNumber;
  final bool upload;
  final bool delete;
  final double uploadStrokeWidth;
  final double shadowBlurRadius;
  final Widget? defaultIcon;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  State<UserProfileAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserProfileAvatar> {
  double? progress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.onTap != null) {
          widget.onTap!();
          return;
        }
        if (widget.upload == false) return;

        final source = await chooseUploadSource(context);
        if (source == null) return;
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: source);

        if (image == null) return;

        final file = File(image.path);
        final url = await StorageService.instance.upload(
          file: file,
          progress: (p) => setState(() => progress = p),
          complete: () => setState(() => progress = null),
          compressQuality: 70,
        );

        final oldUrl = UserService.instance.photoUrl;
        await UserService.instance.update(
          photoUrl: url,
          hasPhotoUrl: true,
        );
        await StorageService.instance.delete(oldUrl);
      },
      child: Stack(
        children: [
          UserAvatar(user: widget.user),
          uploadProgressIndicator(),
          if (widget.upload)
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                Icons.camera_alt,
                color: Colors.grey.shade800,
                size: 32,
              ),
            ),
          if (widget.delete && widget.user.photoUrl.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                  onPressed: () async {
                    await StorageService.instance.delete(UserService.instance.user.photoUrl);
                    await UserService.instance.update(
                      field: 'photoUrl',
                      value: FieldValue.delete(),
                      hasPhotoUrl: false,
                    );
                  },
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.remove_circle,
                    color: Colors.grey.shade600,
                    size: 30,
                  )),
            ),
        ],
      ),
    );
  }

  uploadProgressIndicator() {
    if (progress == null || progress == 0) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: widget.uploadStrokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          value: progress,
        ),
      ),
    );
  }
}
