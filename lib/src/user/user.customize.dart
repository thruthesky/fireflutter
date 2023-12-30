import 'package:flutter/material.dart';

class UserCustomize {
  Widget? loginFirstScreen;
  Future Function(BuildContext context)? showProfile;
  Future Function(BuildContext context, String uid)? showPublicProfile;

  UserCustomize({
    this.loginFirstScreen,
    this.showProfile,
    this.showPublicProfile,
  });
}
