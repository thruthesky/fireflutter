import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FavoriteService with FirebaseHelper {
  static FavoriteService? _instance;
  static FavoriteService get instance => _instance ??= FavoriteService._();

  FavoriteService._();

  showFavoriteScreen({required BuildContext context}) {
    // TODO
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Favorites'),
          ),
        );
      },
    );
  }
}
