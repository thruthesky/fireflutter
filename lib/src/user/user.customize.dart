import 'package:flutter/material.dart';

class UserCustomize {
  Future Function(BuildContext context, String uid)? showPublicProfileDialog;

  UserCustomize({
    this.showPublicProfileDialog,
  });
}
