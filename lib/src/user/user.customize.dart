import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserCustomize {
  Widget? loginFirstScreen;
  Widget? profileUpdateForm;
  Widget Function(String? uid, UserModel? user)? publicProfileScreen;

  UserCustomize({
    this.loginFirstScreen,
    this.profileUpdateForm,
    this.publicProfileScreen,
  });
}
