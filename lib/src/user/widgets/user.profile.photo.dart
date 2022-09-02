import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

/// UserProfilePhoto
///
/// Display user profile avatar
/// If [uid] is null, then it uses [MyDoc] to display signed-in user's profile
/// photo and it will render again on profile photo change.
/// if [uid] is set, then it uses [UserDoc] to display other user's profile
/// photo and it will not render again even if the user's photo changes.
///
/// Use it with [uid] as null on displaying sign-in user's photo.
///
/// [radius] can make how round the photo should be.
class UserProfilePhoto extends StatelessWidget {
  const UserProfilePhoto({
    this.uid,
    this.emptyIcon = const Icon(
      Icons.person,
      color: Color.fromARGB(255, 111, 111, 111),
      size: 20,
    ),
    this.emptyIconBuilder,
    this.size = 40,
    this.onTap,
    this.boxShadow = const BoxShadow(color: Colors.white, blurRadius: 1.0, spreadRadius: 1.0),
    this.padding,
    this.margin,
    this.radius,
    Key? key,
  }) : super(key: key);

  final String? uid;
  final double size;
  final Function()? onTap;
  final BoxShadow boxShadow;

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget emptyIcon;
  final double? radius;
  final Function(UserModel)? emptyIconBuilder;

  @override
  Widget build(BuildContext context) {
    final builder = (UserModel user) => Container(
          padding: padding,
          margin: margin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius ?? size),
            child: user.photoUrl != ''
                ? UploadedImage(
                    url: user.photoUrl,
                    width: size,
                    height: size,
                    loader: SizedBox.shrink(),
                  )
                : emptyIconBuilder == null
                    ? emptyIcon
                    : emptyIconBuilder!(user),
          ),
          constraints: BoxConstraints(
            minWidth: size,
            minHeight: size,
            maxWidth: size,
            maxHeight: size,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: user.photoUrl == '' ? Colors.grey.shade300 : Colors.white,
            boxShadow: [boxShadow],
          ),
        );

    final child = UserDoc(
      uid: uid ?? User.instance.uid,
      builder: builder,
      loader: SizedBox.shrink(),
    );
    if (onTap == null) return child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}
