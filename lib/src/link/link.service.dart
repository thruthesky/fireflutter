import 'package:fireflutter/fireflutter.dart';

class LinkService {
  static LinkService? _instance;
  static LinkService get instance => _instance ??= LinkService();

  late String urlPrefix;

  init({
    required String urlPrefix,
  }) {
    this.urlPrefix = urlPrefix;
  }

  Uri generatePostLink(Post post) {
    return Uri.parse('$urlPrefix/link?pid=${post.id}');
  }

  Uri generateProfileLink(String uid) {
    return Uri.parse('$urlPrefix/link?uid=$uid');
  }

  Uri generateChatRoomLink(String uid) {
    return Uri.parse('$urlPrefix/link?cid=$uid');
  }
}
