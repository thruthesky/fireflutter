import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

/// UserProfilePhoto
///
/// Display user profile avatar
///
/// if [uid] is set, then it uses [UserDoc] to display other user's profile
/// photo and it will not render again even if the user's photo changes.
///
/// Use it with [uid] as null on displaying sign-in user's photo.
///
/// [radius] can make how round the photo should be.
@Deprecated('Use ProfilePhoto(). Wrap UserDoc or MyDoc if needed.')
class UserProfilePhoto extends StatelessWidget {
  const UserProfilePhoto({
    required this.uid,
    this.emptyIcon = const Icon(
      Icons.person,
      color: Color.fromARGB(255, 111, 111, 111),
      size: 20,
    ),
    this.emptyIconBuilder,
    this.size = 40,
    this.onTap,
    this.boxShadow = const BoxShadow(
        color: Colors.white, blurRadius: 1.0, spreadRadius: 1.0),
    this.padding,
    this.margin,
    this.radius,
    Key? key,
  }) : super(key: key);

  final String uid;
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
      uid: uid,
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

/// Display user profile photo
///
/// 사진이 없는 경우 기본적으로 emptyIcon 을 보여주고, 원한다면 emptyIconBuilder 로 빌드 할 수 있다.
/// 필요한 경우, UserDoc() 이나 MyDoc() 으로 감쌀 수 있으며, GestureDetector() 로 감싸서 탭 이벤트를 적용하면 된다.
class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({
    required this.user,
    this.emptyIcon = const Icon(
      Icons.person,
      color: Color.fromARGB(255, 111, 111, 111),
      size: 20,
    ),
    this.emptyIconBuilder,
    this.size = 40,
    this.boxShadow = const BoxShadow(
        color: Colors.white, blurRadius: 1.0, spreadRadius: 1.0),
    this.padding,
    this.margin,
    this.radius,
    Key? key,
  }) : super(key: key);

  final UserModel user;
  final double size;
  final BoxShadow boxShadow;

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget emptyIcon;
  final double? radius;
  final Function(UserModel)? emptyIconBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
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
  }
}
