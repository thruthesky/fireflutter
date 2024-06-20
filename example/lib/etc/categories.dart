import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/foundation.dart';

bool isDebugMode() {
  return kDebugMode;
}

class Categories {
  static String qna = isDebugMode() ? 'test-qna' : 'qna';
  static String discussion = isDebugMode() ? 'test-discussion' : 'discussion';
  static String buyandsell = isDebugMode() ? 'test-buyandsell' : 'buyandsell';
  static String info = isDebugMode() ? 'test-info' : 'info';
  static String jobsHire = isDebugMode() ? 'test-jobs-hire' : 'jobs-hire';
  static String news = isDebugMode() ? 'test-news' : 'news';

  Categories._();

  static get community => isDebugMode() ? 'test-community' : 'community';
  static get meetup => isDebugMode() ? 'test-meetup' : 'meetup';

  static List<({String name, String id, String? group})> menus = [
    (name: T.discussion.tr, id: discussion, group: null),
    (name: T.qna.tr, id: qna, group: community),
    (name: T.job.tr, id: jobsHire, group: community),
    (name: T.news.tr, id: news, group: community),
    (name: T.buyandsell.tr, id: buyandsell, group: null),
    (name: T.info.tr, id: info, group: null),
  ];

  static String name(String id) {
    for (final menu in menus) {
      if (menu.id == id) {
        return menu.name;
      }
    }
    return '';
  }
}
