import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserCustomize {
  Future Function(BuildContext context, {String? uid, User? user})?
      showPublicProfileScreen;

  List<Widget> Function(BuildContext context, User user)? publicScreenActions;

  Widget Function(BuildContext context, User user)? publicScreenLikeButton;
  Widget Function(BuildContext context, User user)? publicScreenFavoriteButton;
  Widget Function(BuildContext context, User user)? publicScreenChatButton;
  Widget Function(BuildContext context, User user)? publicScreenFollowButton;
  Widget Function(BuildContext context, User user)? publicScreenBlockButton;
  Widget Function(BuildContext context, User user)? publicScreenReportButton;
  List<Widget> Function(BuildContext context, User user)?
      publicScreenTrailingButtons;

  UserCustomize({
    this.showPublicProfileScreen,
    this.publicScreenActions,
    this.publicScreenLikeButton,
    this.publicScreenFavoriteButton,
    this.publicScreenChatButton,
    this.publicScreenFollowButton,
    this.publicScreenBlockButton,
    this.publicScreenReportButton,
    this.publicScreenTrailingButtons,
  });
}
