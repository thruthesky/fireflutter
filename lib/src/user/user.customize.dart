import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserCustomize {
  Widget? loginFirstScreen;

  Widget? profileUpdateForm;
  Widget Function()? profileUpdateScreen;
  Widget Function(String? uid, User? user)? publicProfileScreen;
  Future<void> Function(User otherUser)? pushNotificationOnPublicProfileView;

  UserCustomize({
    this.loginFirstScreen,
    this.profileUpdateForm,
    this.profileUpdateScreen,
    this.publicProfileScreen,
    this.pushNotificationOnPublicProfileView,
  });
}
