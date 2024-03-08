import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserCustomize {
  Widget? loginFirstScreen;

  Widget? profileUpdateForm;
  Widget Function()? profileUpdateScreen;
  Widget Function(String? uid, User? user)? publicProfileScreen;

  UserCustomize({
    this.loginFirstScreen,
    this.profileUpdateForm,
    this.profileUpdateScreen,
    this.publicProfileScreen,
  });
}
