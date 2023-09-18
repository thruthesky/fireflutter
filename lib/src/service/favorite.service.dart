import 'package:flutter/material.dart';

class FavoriteService {
  static FavoriteService? _instance;
  static FavoriteService get instance => _instance ??= FavoriteService._();

  FavoriteService._();

  showFavoriteScreen({required BuildContext context}) {
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
