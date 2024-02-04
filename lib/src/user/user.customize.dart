import 'package:flutter/material.dart';

class UserCustomize {
  Widget? loginFirstScreen;
  Widget? profileUpdateForm;
  Widget Function(String uid)? publicProfile;

  UserCustomize({
    this.loginFirstScreen,
    this.profileUpdateForm,
    this.publicProfile,
  });
}
