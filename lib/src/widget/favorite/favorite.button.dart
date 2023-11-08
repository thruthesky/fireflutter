import 'dart:developer';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Favorite Icon
///
/// Use this to display if the user is favorited or not
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    this.otherUid,
    this.postId,
    this.commentId,
    required this.builder,
    this.onChanged,
    this.padding,
    this.visualDensity,
    this.onWaiting,
    this.style,
    this.iconSize,
  }) : assert(otherUid != null || postId != null || commentId != null,
            "One of 'otherUid, postId, commentId' must have value");

  final String? otherUid;
  final String? postId;
  final String? commentId;
  final Widget Function(bool) builder;
  final Widget Function()? onWaiting;
  final void Function(bool)? onChanged;
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visualDensity;
  final ButtonStyle? style;
  final double? iconSize;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool? favoritedData;

  @override
  Widget build(BuildContext context) {
    if (notLoggedIn) {
      return IconButton(
        onPressed: () async {
          toast(title: tr.loginFirstTitle, message: tr.loginFirstMessage);
        },
        icon: widget.builder(false),
      );
    }
    return StreamBuilder(
      stream: Favorite.query(postId: widget.postId, otherUid: widget.otherUid, commentId: widget.commentId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (favoritedData == null) {
            return favoritedData != null
                ? favoriteIconButton(favoritedData!)
                : (widget.onWaiting?.call() ?? favoriteIconButton(false));
          }
          return favoriteIconButton(favoritedData!);
        }
        if (snapshot.hasError) {
          log(snapshot.error.toString());
          return favoriteIconButton(favoritedData ?? false);
        }
        favoritedData = snapshot.data?.size == 1;
        return favoriteIconButton(
          favoritedData!,
          onPressed: () async {
            final re =
                await Favorite.toggle(postId: widget.postId, otherUid: widget.otherUid, commentId: widget.commentId);
            widget.onChanged?.call(re);
          },
        );
      },
    );
  }

  Widget favoriteIconButton(bool favorited, {Function()? onPressed}) {
    return IconButton(
      padding: widget.padding,
      visualDensity: widget.visualDensity,
      icon: widget.builder(favorited),
      onPressed: onPressed,
      style: widget.style,
      iconSize: widget.iconSize,
    );
  }
}
