import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// DefaultAvatarUpdate
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
/// [onUploadSuccess] is the callback function that is being called when the user's avatar is uploaded.
///
/// [onDeleteSuccess] is the callback function that is being called when the user's avatar is deleted.
/// This callback is not called when the user uploads and deletes existing photos.
///
/// [cameraOnly] if [cameraOnly] is set to true, then it displays the camera when upload buton is being pressed.
/// [galleryOnly] if [galleryOnly] is set to true, then it displays the gallery when upload buton is being pressed.
///
///
/// Note, that this avatar widget uses the [AdvancedAvatar] widget from
/// the [flutter_advanced_avatar](https://pub.dev/packages/flutter_advanced_avatar) package.
/// See the examples from the github: https://github.com/alex-melnyk/flutter_advanced_avatar/blob/master/example/lib/main.dart
class DefaultAvatarUpdate extends StatefulWidget {
  const DefaultAvatarUpdate({
    super.key,
    required this.uid,
    this.radius = 100,
    this.badgeNumber,
    this.delete = false,
    this.onUploadSuccess,
    this.uploadStrokeWidth = 6,
    this.shadowBlurRadius = 16.0,
    this.defaultIcon,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.progressBuilder,
  });

  final String uid;
  final double radius;
  final int? badgeNumber;
  final bool delete;
  final double uploadStrokeWidth;
  final double shadowBlurRadius;
  final Widget? defaultIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final void Function()? onUploadSuccess;
  final Widget Function(double? progress)? progressBuilder;

  @override
  State<DefaultAvatarUpdate> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<DefaultAvatarUpdate> {
  double? progress;

  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = UserModel.fromUid(widget.uid);
  }

  bool get isNotUploading {
    return progress == null || progress == 0 || progress!.isNaN;
  }

  bool get isUploading => !isNotUploading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final url = await StorageService.instance.upload(
          context: context,
          progress: (p) => setState(() => progress = p),
          complete: () => setState(() => progress = null),
        );
        if (url == null) return;

        final oldUrl = UserService.instance.user?.photoUrl;

        await user.update(
          photoUrl: url,
        );

        /// Delete exisitng photo
        await StorageService.instance.delete(oldUrl);
      },
      child: Stack(
        children: [
          UserAvatar(
            uid: user.uid,
            radius: widget.radius,
          ),
          uploadProgressIndicator(color: Colors.white),
          if (isUploading)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  ((progress ?? 0) * 100).toInt().toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (isNotUploading)
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.background.tone(55),
                size: 32,
              ),
            ),
          if (widget.delete && isNotUploading)
            StreamBuilder(
              stream: user.ref.child(Def.photoUrl).onValue,
              builder: (_, event) => event.hasData && event.data!.snapshot.exists
                  ? Positioned(
                      top: 0,
                      left: 0,
                      child: IconButton(
                        onPressed: () async {
                          /// 이전 사진 삭제
                          ///
                          /// 삭제 실패해도, 계속 진행되도록 한다.
                          StorageService.instance.delete(event.data!.snapshot.value as String?);
                          await UserService.instance.user!.deletePhotoUrl();
                        },
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.remove_circle,
                          color: Colors.grey.shade600,
                          size: 30,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  uploadProgressIndicator({Color? color}) {
    if (isNotUploading) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: widget.progressBuilder?.call(progress) ??
            SizedBox(
              width: widget.radius,
              height: widget.radius,
              child: CircularProgressIndicator(
                strokeWidth: widget.uploadStrokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? Theme.of(context).primaryColor,
                ),
                value: progress,
              ),
            ),
      ),
    );
  }
}
