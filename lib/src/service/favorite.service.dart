import 'package:fireflutter/fireflutter.dart';

class FavoriteService with FirebaseHelper {
  static FavoriteService? _instance;
  static FavoriteService get instance => _instance ??= FavoriteService._();

  FavoriteService._();
}
